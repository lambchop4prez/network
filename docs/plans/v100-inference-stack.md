# Plan: V100 inference VM + LiteLLM router + Hermes gateway

Goal: make the Proxmox-hosted V100 32GB box the durable "lower tier" inference
endpoint, fronted by LiteLLM on the servonet Talos cluster, with the Hermes
gateway consuming the router. MacBook (M5 Max 128GB) stays the primary fast
tier; it never has to be awake for delegated work.

Owner: opencode. Constraints and acceptance criteria below are binding;
estimates are marked as estimates.

## Target topology

```
MacBook M5 Max (primary; oMLX on Tims-MacBook-Pro.lan:8899 when awake)
  │
  ▼ (delegated / fallback traffic)
servonet Talos cluster (Turing Pi RK1 ×3)
  ├─ litellm-operator + LiteLLMProxy CR ── envoy-internal route (master key auth)
  ├─ Hermes gateway (Deployment + volsync ceph-block PVC at /opt/data)
  └─ (optional) small llama.cpp pod — last-resort fallback tier
  │
  ▼ HTTP on servonet
GPC Proxmox VM "infer" (PCIe-passthrough Tesla V100-PCIe 32GB, sm_70) — DEFERRED until hardware ships
  └─ 1Cat-vLLM serving Qwen3.8-27B (NVFP4/AWQ) + Qwen3-30B-A3B + embed/ASR sidecars
OrcaRouter (cloud tier, free slugs — last-resort fallback)
Mac Mini M1 — deferred (no static lease yet; joins as oMLX mini lane when onboarded)
```

> **Superseded by `litellm-hermes-cluster.md` (executed 2026-10-04):** both Macs run
> **oMLX** (jundot/omlx, OpenAI-compatible `/v1/*`), not llama-server/Ollama — and this
> MacBook's instance binds **8899**, not the oMLX default 8000, nor the 8080/11434 this
> table originally carried. LiteLLM ships via **litellm-operator** (`LiteLLMProxy` +
> `LiteLLMModel` CRs, `applyMode: file`), not a bjw-s app-template chart. v100 lanes are
> deferred to the hardware-arrival PR and will point at the **v100-gatekeeper**, not the raw
> host (per `infer-host-nixos-flake.md`).

## Phase 0 — hardware & Proxmox host prep (GPC, Ryzen 5 PRO 4650G)

- [ ] Confirm the GPU: Tesla V100 **32GB** (PCIe or SXM2-on-carrier), passive cooling.
      250W, no fan → case needs directed airflow; otherwise prefer an active-cooler variant.
- [ ] IOMMU: GRUB `amd_iommu=on iommu=pt`; verify groups:
      `find /sys/kernel/iommu_groups/ -type l | sort -t/ -k6 -n`
      The GPU must be in a group containing only GPU (function 0 + audio). If the
      x16 slot shares a group with USB/host bridges, either live with ACS override
      (last resort, document it) or pick the workaround in Proxmox docs.
- [ ] Blacklist nouveau on host; no NVIDIA driver needed on the host.
- [ ] `nvidia-smi -pl 250` after first guest boot (from inside the guest).

## Phase 1 — VM via existing `provision/gpc` Terraform pattern

Add to `provision/gpc` (bpg/proxmox provider, secrets via existing Vault data sources —
do NOT inline credentials):

- `proxmox_virtual_environment_vm.infer`:
    - `machine_type = "q35"`, `bios = "ovmf"` (required for vfio GOP)
    - `hostpci`: GPU device (`0000:XX:00.0` from lspci), `pcie = true`, `pci-opts = { "rombar" = 1 }`
      (rombar=1 first; if guest won't boot, retry rombar=0 documented as fallback)
    - CPU: `host` type; memory: 32–48 GB; disk: ≥200 GB (model cache) on fastest datastore
    - cloud-init user: `gpu` group; serial console as primary (headless)
- Guest OS: Ubuntu 22.04 LTS (matches 1Cat-vLLM wheel targets; Debian 12 acceptable).

Acceptance: `lspci` in guest sees 3D controller; `nvidia-smi` reports V100 32GB,
driver branch **≤ 580** (Volta dropped in 590), persistence mode ON.

## Phase 2 — 1Cat-vLLM inside the guest

Reference: https://github.com/1CatAI/1Cat-vLLM (SM70-focused vLLM fork).

- Python: 3.10/3.11; **CUDA toolkit 12.x** (12.6 sweet spot) — CUDA 13 nvcc has no sm_70.
- Install the fork's SM70 wheels (see repo `docker/` + prebuilt extensions notes).
- [ ] Gate: `python -c "import torch; print(torch.cuda.get_arch_list())"` must contain `sm_70`.
- Serve commands (systemd units, bind to `0.0.0.0:<port>` on servonet interface):
    - `vllm serve QUASAR-QAT/Qwen3.8-27B-NVFP4 --kv-cache-dtype fp8 --max-model-len 131072 ...`
      (follow repo's recommended flags for sm_70: Flash-V100 attention, CUDA graphs;
      MTP/DFlash2 only behind their documented opt-in flags)
    - second unit for `Qwen3.6-35B-A3B` NVFP4/AWQ (the fast MoE lane)
- Model cache on the VM's large disk; pre-warm both at boot via systemd ordering.

Estimated single-card throughput (bandwidth model ÷4 of fork's TP4 measured rows;
re-benchmark on day one with the fork's gates — treat ±30%):

| Model                     | ctx      | est. tok/s (b=1) | notes                                 |
| ------------------------- | -------- | ---------------- | ------------------------------------- |
| Qwen3.8-27B NVFP4         | ≤8K      | 35–45            | fp8 KV                                |
| Qwen3.8-27B NVFP4         | 128K     | 18–25            | fits via fp8 KV (~15GB KV)            |
| Qwen3.8-27B + DFlash2/MTP | 16K code | 40–70            | acceptance-dependent                  |
| Qwen3.6-35B-A3B NVFP4     | 8K       | 60–100           | 3B active; best delegate model        |
| GPT-OSS-20B MXFP4         | 8K       | 80–120           | trivial fit                           |
| Dense 70B                 | —        | ✗                | doesn't fit 32GB; stays on Mac        |
| Qwen3.8 Flash-Next        | —        | ✗                | ~52GiB in-GPU at Q5_K_M; stays on Mac |

## Phase 3 — LiteLLM on servonet (Flux)

Implemented as of 2026-10-04 via `litellm-hermes-cluster.md` — **litellm-operator**
(chart 0.0.21, CRDs `LiteLLMProxy`/`LiteLLMModel`), not a bjw-s chart. Upstreams as
shipped (v100 lanes land in the hardware-arrival PR):

- `cluster/apps/selfhosted/litellm/app/`
    - `litellmproxy.yaml`: image `ghcr.io/berriai/litellm:litellm_stable_release_branch-v1.66.0-stable@sha256:1ae3674b…`
      (arm64 verified; plain `v1.66.0` tags do not exist upstream), `applyMode: file`
      → **no PVC / no DB** (answers open question 3: rook-ceph+volsync only for Hermes).
    - Upstreams (`LiteLLMModel` CRs):
        - `macbook-qwen38-flash-next|qwen38-27b|qwen38-27b-fp16` → `http://Tims-MacBook-Pro.lan:8899/v1`
          (oMLX; ctx 262144; key `LITELLM_MACBOOK_OMLX_API_KEY`; may sleep)
        - `cloud-orcarouter-free`, `cloud-glm-5-3-flash-free`, `cloud-deepseek-v4-flash-free`
          → `https://api.orcarouter.ai/v1` (`openai/` prefix; key `LITELLM_ORCAROUTER_API_KEY`)
        - `v100-big`/`v100-fast` → **deferred**; will point at `http://v100-gatekeeper:8080/...`
          per `infer-host-nixos-flake.md`, not the raw host.
    - fallback chains: every macbook lane → its cloud lane (mini lane joins when the M1 is onboarded).
    - master key + provider keys via ExternalSecret `litellm-secrets` (Bitwarden SM project Servonet).
    - Route `litellm.servonet.lan` → `envoy-internal`, created by the operator from `spec.route`;
      **auth is the LiteLLM master key only** (answers open question 2 — tinyauth is disabled in
      `auth-system` and ext-auth would break non-browser API clients).

Acceptance: `curl` completions through `https://litellm.servonet.lan` against each model alias,
with the Mac powered off, served by the cloud tier (V100 when it lands) with zero client-side
errors (fallback must hide Mac absence).

## Phase 4 — Hermes gateway on cluster

- Deployment in `cluster/apps/selfhosted/hermes/` (bjw-s app-template, shipped 2026-10-04):
    - image `nousresearch/hermes-agent:v2026.9.24@sha256:fca358f1…` (official multi-arch, arm64 published)
    - args `gateway run`; env: `API_SERVER_ENABLED/HOST` + master key and Discord tokens
      via ExternalSecret `hermes-secrets` (Bitwarden `HERMES_*` items) — env injection
      overrides `.env`, so secrets never land on the volume
    - PVC (rook-ceph **ceph-block**, volsync component like siblings — no Longhorn) mounted
      at `/opt/data` = HERMES_HOME; `config.yaml` seeded **once by an initContainer** from a
      ConfigMap (marker = file absent; a Job cannot attach alongside the RWO pod). Talos nodes
      have no shell, so all config arrives via volume/ConfigMap.
- Access: Telegram/Discord gateway is the "always available" surface; Hermes desktop
  on the Mac keeps its own local profile (independent state — expected).

## Phase 5 — Mac side (manual, not in repo)

- oMLX on the MacBook bound to the LAN (`0.0.0.0:8899`, hostname `Tims-MacBook-Pro.lan`),
  macOS firewall allowing the cluster range; TLS optional
  (router holds the public-facing surface). Mac mini defers until it has a static lease.
- Delegation default in the Mac's Hermes config: point delegated/cron/background
  profiles at `litellm.<internal-domain>` so big-interactive stays local and
  doc/review/test batches land on the V100 tier automatically.

## Deferred / out of scope

- RK1 NPU (RKNN/RKLLM) experiments — requires Armbian lab-node mode; separate plan.
- Whisper on RK1 via sherpa-onnx RKNN — separate plan.
- Mac Mini upgrade (M4+/Studio) — revisit when prices stabilize; until then mini
  is embedder/RAG tier only (7–8B cap).

## Open questions for review

1. V100 form factor actually on order — PCIe vs SXM2-carrier? (affects Phase 0 cooling + PCI address)
2. ~~Should LiteLLM sit behind pocket-id, tinyauth, or just its own master key?~~ **Answered:** master key only — `tinyauth` is disabled in `auth-system` and ext-auth would break non-browser API clients; route sits on `envoy-internal` (LAN + TLS).
3. ~~Rook-ceph vs Longhorn for LiteLLM/Hermes PVCs~~ **Answered:** LiteLLM = none (`applyMode: file`); Hermes = `components/volsync` PVC on `ceph-block`. No Longhorn anywhere in the repo.
4. Static DHCP reservations for `infer` VM + Mac Mini so the LiteLLM upstreams never drift. **Partial:** MacBook resolved via existing `Tims-MacBook-Pro.lan` lease; mini reservation still open (mini lane deferred).
