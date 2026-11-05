# Plan: RK1 NPU embedding lab (`lab` namespace)

Exploratory benchmark to pick the embedding model that will back **Honcho's**
embeddings, self-hosted on the RK3588 NPU. Scope of THIS pass is the lab and
the benchmark only — no litellm/Honcho wiring. Owner: opencode.

## Decisions

1. **The NPU is already available on Talos.** All three servonet nodes boot the
   `turing-rk1` schematic, which includes the official `siderolabs/rockchip-rknn`
   extension (`provision/servonet/schematic/turing-rk1.yaml.j2`), so the mainline
   `rocket` driver and `/dev/accel/accel0` exist. This supersedes the
   "RK1 NPU requires Armbian lab-node mode" note in `v100-inference-stack.md`.
2. **Embeddings are the NPU's best case.** The NPU accelerates *prefill* only
   (`MUL_MAT` M>=32, `FLASH_ATTN_EXT`, `MUL_MAT_ID`); decode stays on CPU. An
   embedding pass is a single batched forward pass with no decode, so it is
   pure prefill — the exact shape `ggml-rocket` offloads.
3. **Runtime = `ghcr.io/eburgueno/chat-rk1/rocket-runtime`** (stock llama.cpp
   built `GGML_BACKEND_DL` + `libggml-rocket.so`). `GGML_BACKEND_PATH` set =>
   NPU; unset => CPU baseline on the same image. This is the A/B.
4. **First sweep** (all ungated Q8_0 GGUFs): Qwen3-Embedding-0.6B,
   embeddinggemma-300M, mxbai-embed-large-v1, bge-m3.
5. **Pinned to one node** (`npu.rocket-stack/enabled=true`, on `tom-7110`, 32 GB)
   to keep the benchmark consistent; a privileged pod + `/dev/accel` hostPath
   needs the `lab` namespace to opt into the `privileged` PodSecurity level.

## Target state

```
tom-7110 (RK1 32 GB, npu.rocket-stack/enabled=true)
  lab
  ├─ deploy/embed-lab      llama-server --embeddings :8080, /dev/accel, models PVC
  └─ job/embed-lab-bench   llama-bench pp512/pp2048, NPU vs CPU, 4 models
```

## Repo layout (new files)

```
cluster/apps/lab/
  namespace.yaml               # Namespace lab, PSA enforce=privileged
  kustomization.yaml
  embed/
    ks.yaml                    # embed-lab (app), wait: true
    bench-ks.yaml              # embed-lab-bench (job), no wait
    app/{configmap,pvc,deployment,service,kustomization}.yaml
    bench/{bench-job,kustomization}.yaml
```

## How to run

- Flux reconciles `lab` after merge. Then:
  - `kubectl -n lab get deploy,svc,pvc`
  - `kubectl -n lab logs -f job/embed-lab-bench` — prints a NPU and a CPU
    llama-bench block per model; the `pp512`/`pp2048` columns are the prefill
    (= embedding) throughput to compare.
- End-to-end check on the live server:
  `kubectl -n lab port-forward svc/embed-lab 8080:8080` then
  `curl -s localhost:8080/v1/embeddings -H 'content-type: application/json'
   -d '{"model":"x","input":"hello world"}' | jq '.data[0].embedding | length'`
  (the length is the model's dimension, which drives Honcho's
  `EMBEDDING_VECTOR_DIMENSIONS`).
- Swap model: edit `embed-lab-config` (`MODEL_URL`/`MODEL_FILE`/
  `LLAMA_ARG_POOLING`), then `kubectl -n lab rollout restart deploy/embed-lab`.
- A/B the NPU: `kubectl -n lab set env deploy/embed-lab GGML_BACKEND_PATH=""`
  (restore with `GGML_BACKEND_PATH-`).

## Two repo gotchas this handles

- **Flux blanks unknown `${VAR}`** — verified live: searxng's `${SEARXNG_SECRET}`
  rendered to `""`. The fetch init script therefore carries
  `kustomize.toolkit.fluxcd.io/substitute: disabled` (as does the bench Job).
- **PodSecurity baseline** forbids privileged/hostPath, so the `lab` namespace
  labels `pod-security.kubernetes.io/enforce: privileged` (like rook-ceph/tv).

## Acceptance

1. `just cluster::kubeconform` clean; Flux reconciles `embed-lab` and
   `embed-lab-bench`.
2. `embed-lab` Ready; `/v1/embeddings` returns a vector whose length equals the
   chosen model's dimension.
3. The bench Job logs `... : NPU` and `... : CPU` blocks for all four models.

## Open items (next pass)

- **Embedding model on the NPU is unverified for `llama.cpp --embedding`
  specifically** — no public report found. The bench Job / A/B settles it.
- Wire the winner into litellm as an embedding-mode model, then set Honcho's
  `EMBEDDING_MODEL_CONFIG__MODEL` and `EMBEDDING_VECTOR_DIMENSIONS` — the
  dimension is fixed at Honcho's first DB migration, so choose before then.
- Optional: the NPU boots at 200 MHz; the patched `rocket.ko` (600/900 MHz)
  needs a kernel-module build and is out of scope here.
