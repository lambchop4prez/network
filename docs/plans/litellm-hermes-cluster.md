# Plan: LiteLLM router + Hermes gateway on servonet (cluster side of the inference stack)

Executes Phases 3–4 of `v100-inference-stack.md` now, while the V100 machine
(`infer`) waits on hardware. Owner: opencode. Constraints and acceptance
criteria below are binding; estimates are marked as estimates.

## Decisions (supersede the v100 plan where they differ)

1. **oMLX, not llama-server/Ollama.** Both Macs run oMLX (jundot/omlx):
   OpenAI-compatible `/v1/*` (+ Anthropic `/v1/messages`), default port
   **8000**, multi-model with LRU. This corrects the v100 plan's upstream
   table (`macbook-chat` was `llama-server:8080`, `mini` was `Ollama:11434` —
   both wrong).
2. **LiteLLM via litellm-operator** (home-operations), not a plain app-template
   chart. Reviewed: Go operator (distroless, multi-arch **amd64+arm64
   verified** in its release workflow), CRDs `LiteLLMProxy` + `LiteLLMModel`
   (`litellm.home-operations.com/v1alpha1`), deterministic `config.yaml`
   rendering, rolling restart only on config-hash change, `routerSettings`
   free-form (fallbacks/timeout/retries expressible), managed HTTPRoute,
   secret-backed API keys, chart digest-pinned + cosign-signed. `applyMode:
   file` → **no DB, no PVC, no SOPS-encrypted config** for LiteLLM.
   Risk: v1alpha1 / 0.0.x project youth. Mitigation: pin chart version;
   escape hatch is the rendered config is a stock LiteLLM config, convertible
   to a plain app-template chart if the operator misbehaves.
3. **v100 lanes + v100-gatekeeper deferred.** `infer` doesn't exist; its
   lanes land in a follow-up PR when the bare-metal NixOS host ships (per
   `infer-host-nixos-flake.md`, upstreams point at the gatekeeper, not the
   raw host). No `v100-*` LiteLLMModel CRs in this round.
4. **Optional cloud lane.** An OpenRouter or opencode-go subscription (user's
   choice, key in Bitwarden) joins the fallback chain as the last resort, so
   the router is never fully dark even if both Macs sleep.
5. **Auth: LiteLLM master key only** (answers v100 open question 2).
   `tinyauth` is disabled in `auth-system` and ext-auth would break
   non-browser API clients; the route sits on `envoy-internal` (LAN + TLS).
6. **Storage** (answers v100 open question 3): LiteLLM = none (file mode);
   Hermes = `components/volsync` PVC on `ceph-block` (sibling pattern; no
   Longhorn).

## Target state

```
MacBook (oMLX :8000, M5 Max — primary tier, may sleep)
Mac mini (oMLX :8000, M1 — secondary tier)
OpenRouter/opencode-go (optional cloud tier)
  │  OpenAI-compatible over LAN
  ▼
servonet Talos (Turing Pi RK1 ×3, arm64)
  ├─ litellm-operator (operator + webhook, CRDs)
  ├─ litellm proxy (LiteLLMProxy CR) ─ route litellm.servonet.lan → envoy-internal
  │    fallbacks: macbook → mini → cloud
  └─ hermes gateway (Deployment, /opt/data on ceph-block)
       config.yaml → provider: custom → http://litellm.selfhosted.svc:4000/v1
       Discord bot (always-available surface)
```

## Phase 3 — LiteLLM

### Prerequisites (user inputs — collect first)

- [x] Bitwarden item `litellm` with `LITELLM_MASTER_KEY`
      (create: `openssl rand -hex 32`); if cloud lane added, the provider key
      (`OPENROUTER_API_KEY` or the opencode-go key) in the same item.
      → 2026-10-04: Servonet SM project carries `LITELLM_MASTER_KEY`,
      `LITELLM_MACBOOK_OMLX_API_KEY`, `LITELLM_ORCAROUTER_API_KEY` (cloud lane = OrcaRouter).
- [x] Static DHCP reservations / `.lan` names for the MacBook and Mac mini on
      `192.168.42.0/24` (v100 open question 4, now needed for the oMLX
      upstreams — the router's `apiBase` must not drift).
      → MacBook resolves via `Tims-MacBook-Pro.lan`; mini deferred with its lane.
- [x] oMLX on both Macs bound to the LAN interface (`0.0.0.0:8000` or the
      specific NIC) with the macOS firewall allowing the cluster's `10.4.3.0/24`
      source range. oMLX API key: check the dashboard settings — if it has one,
      enable it and store it in the `litellm` Bitwarden item; otherwise the CRs
      use a literal dummy key (`openai/` provider passes it through).
      → MacBook binds `0.0.0.0:8899` (not 8000) with key auth on; keys stored in bws.

### Repo layout (new files)

```
cluster/apps/selfhosted/litellm/
  operator/
    ks.yaml                  # Flux KS name: litellm-operator (wait: true)
    app/
      ocirepository.yaml     # oci://ghcr.io/home-operations/charts/litellm-operator, pinned tag
      helmrelease.yaml       # webhook: on; llmkube.autoRegister: false;
                             # resources 10m/64Mi → 128Mi (arm64 OK)
      kustomization.yaml
  ks.yaml                    # name: litellm; dependsOn: litellm-operator,
                             #   external-secrets-manifests
  app/
    externalsecret.yaml      # ← Bitwarden item `litellm`
    litellmproxy.yaml        # LiteLLMProxy CR
    models/
      kustomization.yaml
      macbook-<m>.yaml       # LiteLLMModel CRs (one per served model)
      mini-<m>.yaml
      cloud-<m>.yaml         # only if the cloud lane is added
```

The two-Kustomization split (operator, then CRs) mirrors home-ops and avoids
applying CRs before the operator's webhook/CRDs exist; the base patch in
`cluster/base/cluster.yaml` already adds `install.crds: CreateReplace`.

### LiteLLMProxy CR (shape)

- image `ghcr.io/berriai/litellm:<pinned-v1>@sha256:<digest>` (arm64 manifest
  verified at implementation; `main-stable` is a moving tag — do not use)
- `route`: `litellm.servonet.lan` → `envoy-internal` (networking) — DNS and
  `servonet-internal-tls` cert come from the existing k8s-gateway/cert-manager
  mechanism, same as redlib & co.
- `env`: `LITELLM_MASTER_KEY` ← secretKeyRef (ExternalSecret),
  `LITELLM_LOG: INFO`
- `routerSettings` (free-form, rendered verbatim):
  - `routing_strategy: simple-shuffle`
  - `request_timeout: 600`, `num_retries: 2`, `cooldown_time: 60`
  - `fallbacks`: `"<macbook-primary>": ["<mini-model>", "<cloud-model>"]`
    (exact aliases follow model discovery; cloud entry omitted if no sub)
- `generalSettings`: `health_check` periodic (verify oMLX exposes a `/health`
  endpoint first — if not, skip; request-timeout + fallback is the backstop)
- resources: requests 100m/256Mi, limits 1Gi; no Redis (the shared
  `components/dragonfly` carries an `amd64` nodeSelector and is unschedulable
  on this all-arm64 cluster — do not reuse it here; revisit if prompt-cache
  Redis is ever wanted)

### LiteLLMModel CRs (shape)

```yaml
apiVersion: litellm.home-operations.com/v1alpha1
kind: LiteLLMModel
metadata: { name: macbook-<slug> }
spec:
  modelName: macbook-<slug>          # what clients call
  params:
    model: openai/<served-name>      # what the oMLX instance reports
    apiBase: http://<macbook-lan>:8000/v1
    apiKey: <key-or-dummy>
  info:
    mode: chat
    supportsFunctionCalling: true    # per-model, from discovery
```

## Phase 4 — Hermes gateway

```
cluster/apps/selfhosted/hermes/
  ks.yaml                    # dependsOn: litellm, rook-cluster,
                             #   external-secrets-manifests;
                             #   components: volsync; substitute
                             #   VOLSYNC_CAPACITY 10Gi, VOLSYNC_PUID/PGID 10000
  app/
    ocirepository.yaml       # bjw-s-labs app-template (sibling shape)
    helmrelease.yaml
    config.yaml (ConfigMap)  # seed source
    seed-job.yaml            # one-shot: copies ConfigMap → /opt/data on first
                             #   boot only (marker-file guard; Talos has no
                             #   shell, so no `hermes config set` on nodes)
    externalsecret.yaml      # ← Bitwarden items `hermes` (DISCORD_BOT_TOKEN)
                             #   + `litellm` (LITELLM_MASTER_KEY)
    kustomization.yaml
```

- image `docker.io/nousresearch/hermes-agent:<v2026.x>@sha256:<digest>` —
  arm64 published (verified v2026.9.21 amd64+arm64); pin the digest at
  implementation. Command `gateway run`.
- `config.yaml` (mounted for seeding, lands in `/opt/data`):
  `model: { provider: custom, model: <macbook-primary-alias>,
  base_url: http://litellm.selfhosted.svc.cluster.local:4000/v1, api_key: … }`
  Key injection: prefer env interpolation if Hermes supports it in config;
  else the seed job writes the key file from the Secret (0600).
  Resolve at implementation.
- env: `HERMES_UID/GID: 10000` (verify against the image's `/etc/passwd`),
  `DISCORD_BOT_TOKEN` ← secret, `API_SERVER_ENABLED=true` on `127.0.0.1:8642`
  (probes only — no route for v1; Hermes Desktop on the Mac keeps its own
  local profile, independent state by design).
- persistence: existingClaim `hermes` (volsync `ceph-block`, 10Gi) at
  `/opt/data`; kopia backup cadence via the component defaults (12h).
- probes: readiness/liveness `GET /health :8642` (verify path at
  implementation), generous startup (model-less boot should still be fast —
  startup 120s).
- resources: requests 250m/1Gi, limits 2Gi (fits 8Gi RK1 nodes alongside
  litellm's 1Gi).

## Implementation sequence

1. **Discover oMLX endpoints** (on the MacBook, then from a cluster-reachable
   vantage): `curl -s http://localhost:8000/v1/models` and the mini's
   `:8000` — record served model names, context sizes, tool-call support,
   whether an API key is required. This fixes all aliases in step 3.
2. **Collect user inputs** from Phase 3 prerequisites (Bitwarden item(s),
   `.lan` names, oMLX bind/firewall on both Macs).
3. **Write the litellm app** files above with the discovered models; resolve
   the latest pinned operator chart tag + litellm image digest.
   `just analyze` → commit → Flux reconcile → verify (below).
4. **Write the hermes app** files above (image digest, PUID/PGID, seed
   behavior, probe path — verify each against the pinned image first with a
   throwaway pod or `docker run` locally).
   `just analyze` → commit → Flux reconcile → verify (below).
5. **Correct `v100-inference-stack.md`**: oMLX upstream table (port 8000,
   not 8080/11434), storage + auth answers, note that v100 lanes are deferred
   to the hardware-arrival PR, and that upstreams will point at the gatekeeper
   per `infer-host-nixos-flake.md`.

## Acceptance

1. `just analyze` clean; Flux reconciles both Kustomizations without error.
2. `curl -H "Authorization: Bearer $LITELLM_MASTER_KEY"
   https://litellm.servonet.lan/v1/chat/completions` per alias succeeds;
   unauthenticated → 401. (Run from the MacBook — it is the real client.)
3. **Fallback hides the Mac:** quit oMLX in the MacBook's menu bar; new
   requests still complete, served by the mini (cloud if configured) —
   confirm via the `model` field / litellm response metadata, no client-side
   error.
4. Hermes answers a Discord DM end-to-end through the router; `kubectl
   delete pod -n selfhosted -l app.kubernetes.io/name=hermes` → pod
   recreated, state intact on the PVC.

## Risks

- **litellm-operator youth (v1alpha1):** pinned; webhook self-manages its cert
  (no cert-manager dependency); escape hatch = plain app-template chart.
- **Docker Hub pull for hermes:** public image, 3 nodes, 1 replica — within
  rate limits; move to a ghcr mirror if a mirror exists at implementation.
- **oMLX availability is user-machine quality:** sleep/lid-close drops the
  tier; that is what the fallback chain is for. oMLX LRU can unload a model
  under memory pressure — expect first-request latency spikes, not failures.
- **RK1 memory budget:** litellm 1Gi + hermes 2Gi limits are conservative
  against the existing workloads; watch `just` cluster metrics after cutover.

## Open questions

1. Cloud lane: OpenRouter or opencode-go (or neither for now) — decides the
   third fallback hop and the Bitwarden item contents.
2. Hermes Discord: new bot (needs `DISCORD_BOT_TOKEN` in Bitwarden) or reuse
   an existing bot token?
3. Should `litellm.servonet.lan` also be reachable from outside the LAN
   (VPN/tailscale) in v1, or is LAN-only correct for now?
