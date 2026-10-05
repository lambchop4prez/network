# Plan: bare-metal NixOS inference host (`infer`) + WoL power lifecycle

Supersedes Phases 0–1 of `v100-inference-stack.md`. The V100 leaves the
Proxmox VM (GPC / Ryzen 5 PRO 4650G) and moves to a dedicated bare-metal
open-chassis box: Biostar B450MH + Ryzen 5 5600G + Tesla V100 PCIe 32GB.
Phases 3–5 (LiteLLM router, Hermes gateway, Mac side) stand as written —
only the upstream target changes from "VM on GPC" to "NixOS host `infer`".

Why bare metal helps the stack: no vfio/ACS passthrough risk (the old
Phase 0 open question), no 32GB host-RAM competition with the guest, and
WoL/idle-shutdown operate on the real machine rather than a Proxmox VM.

## Target topology (delta)

```
servonet Talos cluster
  ├─ LiteLLM  (v100-* deployments now point at the gatekeeper, not raw VM IP)
  ├─ v100-gatekeeper  (NEW: wake-on-request forwarder, bjw-s app-template)
  └─ Hermes gateway   (unchanged)
        │ HTTP over servonet
        ▼
infer — bare-metal NixOS (B450MH, 5600G, V100-PCIe 32GB, open frame)
  ├─ podman + quadlet: vLLM fork @ :8000 (27B lane), :8001 (MoE fast lane)
  ├─ idle-shutdown timer (vLLM metrics → poweroff after N min quiet)
  └─ WoL armed on r8169 NIC (BIOS Power-On By PCI-E)
```

## Hardware baseline (pricing handled by lab-assistant, see kanban card)

- PSU: 550–650W ATX 80+ Gold; V100 takes dual PCIe 8-pin → EPS adapter.
- RAM: 2×16GB DDR4-3600 CL18 1.35V (board max 32GB, 2 slots; fall back to
  3200 CL16 if XMP is flaky on Biostar's B450 BIOS).
- BIOS: needs Vermeer-capable firmware for the 5600G (Biostar AGESA
  1.2.0.x, `B45CS50x.BSS`); enable Power-On By PCI-E, disable ErP.
- Cooling: dual-40mm shroud on the card + one directed 120mm fan at the
  blower inlet; the whole point of the power cycle is that idle = 0 dB.

## Flake layout (follows existing repo pattern)

Revive the commented host-generator block in `flake.nix`:

```nix
hosts = {
  auth  = { system = "x86_64-linux"; format = "proxmox-lxc"; };
  ca    = { system = "x86_64-linux"; format = "proxmox-lxc"; };
  infer = { system = "x86_64-linux"; format = "raw-efi-img"; };  # bare metal
};
```

New files:

- `hosts/infer/default.nix` — imports `../default` + the GPU/power modules;
  sets `networking.hostName = "infer"`, static servonet IP (the LiteLLM
  upstream must not drift — old open-question #4), agenix/secrets wiring
  matching `hosts/auth`.
- `modules/nvidia-volta/` (new shared module, not host-specific):
    ```nix
    { config, lib, pkgs, ... }:
    {
      hardware.nvidia = {
        modesetting.enable = true;
        # Volta (sm_70): 580 is the LAST driver branch — 590+ drops Volta.
        # Pin explicitly; do NOT let `stable`/`latest` float past 580.
        package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
        # open kernel module = Turing+ only; Volta needs the proprietary one.
        open = false;
        powerLimit = lib.mkDefault 200;   # 250W stock; 200 for the 40mm shroud
      };
      services.nvidiaReservedVideoMemory = ... ; # verify name in installed nixpkgs
      # persistence + power-limit oneshot (unit name check against nixpkgs):
      systemd.services."nvidia-power-limit" = {
        after = [ "multi-user.target" ];
        WantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "oneshot";
        script = "${config.hardware.nvidia.package}/bin/nvidia-smi -pl 200";
      };
    }
    ```
- `modules/baremetal/` — r8169 NIC (B450MH = Realtek 1GbE, in-tree, fine),
  `boot.loader.systemd-boot`, no qemu-guest (do **not** import
  `modules/qemu-vm` for this host).

Install path: `nixos-generators` `raw-efi-img` → dd to NVMe; or
`nixos-infect` if reusing the existing drive.

## Serving stack: containers, not native nixpkgs

Do NOT try to build vLLM/PyTorch from nixpkgs for sm_70:
nixpkgs `cudaPackages` has moved to CUDA 13, and **CUDA 13 has no sm_70**.
The 1Cat-vLLM fork targets CUDA 12.x wheels anyway.

- `virtualisation.podman.enable = true`
- `hardware.nvidia-container-toolkit.enable = true` (recent nixpkgs module;
  verify it covers the container runtime hook on the pinned nixpkgs — if
  not, fall back to `virtualisation.docker.enable` + the manual runtime
  install documented in the NixOS Nvidia wiki page)
- Quadlet units in `hosts/infer/quadlet/`:
  - `vllm-big.container` → fork image, `--gpus all`, port 8000, binds
    `/srv/models` (large NVMe data partition), `--kv-cache-dtype fp8`
  - `vllm-fast.container` → port 8001, MoE lane
  - both `Restart=on-failure`, boot-order After=podman.socket + nvidia
  - first-boot gate inside the guest: `python -c "import torch; print(
    torch.cuda.get_arch_list())"` must contain `sm_70` (carried over from
    old Phase 2 acceptance)

## Power lifecycle — WoL + idle shutdown (the noise fix)

### Arm wake (on `infer`, in the flake)
- BIOS: Power-On By PCI-E enabled, ErP/deep-sleep disabled.
- systemd unit on every boot (settings do not survive every PSU cycle):
    ```nix
    systemd.services.wol-enable = {
      description = "Arm Wake-on-LAN";
      after = [ "network-pre.target" ];
      before = [ "network.target" ];
      serviceConfig.Type = "oneshot";
      script = "${pkgs.ethtool}/bin/ethtool -s enp3s0 wol g";  # confirm iface name
    };
    ```
- Record the NIC MAC in the repo (or in the gatekeeper ConfigMap) as the
  single source of truth.

### Idle → off (on `infer`, in the flake)
- systemd timer, every 1 min, on a 30-min window. Poll the vLLM
  `/metrics` `vllm:prompt_tokens_total` **counter** (not `ss`/connections —
  keepalives give false-busy readings): if unchanged for the window,
  `systemctl poweroff`.
- Caveat carried from the reference implementation: a single streamed
  response longer than the window looks idle. Acceptable for our request
  shapes; guard by also checking `num_requests_running > 0` before off.
- Prefer full poweroff over S3 suspend: B450MH S3 support is spotty on
  Biostar boards, VRAM contents are lost either way, and poweroff is what
  silences the shroud completely. Revisit suspend only if boot latency
  turns out unbearable.

### Wake-on-request (servonet cluster, in the flux repo)
- New app `cluster/apps/selfhosted/v100-gatekeeper/` (bjw-s app-template,
  same shape as litellm's siblings — ocirepository + helmrelease +
  kustomization, route behind the existing auth policy):
  - tiny forwarder (Go/single-binary container) on `:8080`:
    1. GET `:8000/health` on infer → if up, reverse-proxy the request.
    2. If down → UDP magic packet to infer's MAC (broadcast + optional
       directed-subnet), poll health up to 120s, then proxy.
    3. 504 after 120s so LiteLLM falls through to the Mac/mini chain.
  - LiteLLM config change: `v100-big` → `http://v100-gatekeeper:8080/big/v1`,
    `v100-fast` → `http://v100-gatekeeper:8080/fast/v1`; fallback chains
    otherwise unchanged.
- Latency contract: first request after off = WoL + NixOS boot + model
  preload ≈ 60–120s. Hermes/LiteLLM client `request_timeout` must be ≥150s
  on the v100 aliases; subsequent requests in the same session are normal.
- Idle-shutdown window (30 min) is longer than any realistic bursty
  session gap, so a session won't get killed mid-work; tune both knobs
  together.

## Acceptance

1. `nvidia-smi` on bare metal: V100 32GB, driver 580.x (branch ≤580),
   persistence on, power limit applied.
2. Both quadlet lanes serve completions; `sm_70` arch gate passes.
3. Idle > window → host powers itself off; fan noise measured 0 dB (off).
4. `wakeonlan <mac>` from a cluster node (or any servonet host) boots it.
5. `curl` through litellm with infer **powered off** → succeeds after a
   long first-token delay; fallback chain hides total gatekeeper failure.
6. `nix flake check` + image build reproducible from the pinned lock.

## Open questions

1. Keep GPC's 4650G as a second wakeable tier (old Mac-mini-tier pattern),
   or retire it from the inference chain once `infer` is stable?
2. Gatekeeper forwarder: write the ~150-line Go binary in this repo
   (`src/v100-gatekeeper/`) or take an existing off-the-shelf proxy and
   bolt WoL on via an Envoy ext_proc? (Go binary recommended — trivial,
   no extra moving parts.)
3. Secrets for the gatekeeper route: reuse litellm's master key
   convention or its own ExternalSecret?
4. Confirm installed-nixpkgs option names at implementation time:
   `hardware.nvidia-container-toolkit.enable`, nvidia power-limit option,
   persistenced unit naming — all verified against the pinned nixpkgs rev
   in `flake.lock` before writing final config.
