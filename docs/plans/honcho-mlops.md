# Plan: Honcho memory server in `mlops`

Adds Honcho (plastic-labs, AGPL-3.0) — agent-memory infrastructure — to the
`mlops` namespace, following the repo's Flux + bjw-s `app-template`
conventions. Owner: opencode.

## Decisions

1. **Postgres = dedicated pgvector cluster, not `components/postgres`.**
   Honcho requires the `vector` (pgvector) extension plus `pg_trgm` and
   `btree_gin` (its `database/init.sql`), and its vector store is pgvector by
   default. The shared `components/postgres` cluster uses the stock
   `ghcr.io/cloudnative-pg/postgresql:17` image, which has no pgvector — so an
   app-local `cnpg-cluster.yaml` (the immich/hindsight precedent) is used
   instead: `ghcr.io/tensorchord/cloudnative-vectorchord:17.5-0.4.3`, with the
   three extensions created in `postInitApplicationSQL`.
2. **Redis = shared `components/dragonfly`, unchanged** (APP=honcho →
   `honcho-dragonfly`). Its stock config is sufficient; no per-app tuning.
3. **LLM = in-cluster litellm proxy**, model `macbook-gpt-oss-20b` (same model
   hindsight uses). A `LiteLLMVirtualKey` (`honcho` → secret
   `honcho-litellm-key`) is added next to the proxy because the operator
   resolves `proxyRef` in the CR's own namespace.
4. **Auth off** (`AUTH_USE_AUTH=false`): Honcho is LAN-only behind
   `envoy-internal`, consistent with the other servonet services.

## Target state

```
servonet Talos (arm64)
  mlops
  ├─ honcho-postgres17   CNPG, pgvector+pg_trgm+btree_gin, ceph-block 10Gi
  ├─ honcho-dragonfly     from components/dragonfly (cache)
  ├─ honcho-api           :8000, migrations on start, route honcho.servonet.lan
  └─ honcho-deriver       background reasoning worker (no port)
        LLM  ──► http://litellm.mlops.svc.servonet.lan:4000/v1  (macbook-gpt-oss-20b)
        DB   ──► postgresql+psycopg://…@honcho-postgres17-rw.mlops…
        cache──► redis://honcho-dragonfly.mlops…
```

## Repo layout (new files)

```
cluster/apps/mlops/honcho/
  ks.yaml                  # KS honcho; dependsOn cloudnative-pg,
                           #   external-secrets-manifests, litellm, dragonfly;
                           #   components: [components/dragonfly]; APP=honcho
  app/
    ocirepository.yaml     # ghcr.io/bjw-s-labs/helm/app-template 5.3.0
    cnpg-cluster.yaml      # honcho-postgres17, vectorchord image, extensions
    externalsecret.yaml    # honcho-pg-secret ← bitwarden, + DB_CONNECTION_URI
    helmrelease.yaml       # api + deriver controllers, service, route
    kustomization.yaml
```

Edits: `cluster/apps/mlops/kustomization.yaml` (register the KS);
`cluster/apps/mlops/litellm/app/llmkeys.yaml` (Honcho virtual key).

## Prerequisites (user inputs)

- Bitwarden: `HONCHO_PG_USER`, `HONCHO_PG_PASSWORD` (URL-safe password). The
  DB secret stays unpopulated until these exist.
- **Embedding model** (open): the litellm proxy exposes chat models only.
  Honcho's embedding module is pointed at litellm, but a
  `text-embedding-3-small`-compatible model must be registered there before
  vector search works. Chat/deriver/reasoning work without it.

## Acceptance

1. `just analyze` clean; Flux reconciles the `honcho` Kustomization.
2. `honcho-postgres17` Cluster healthy and `honcho-dragonfly` Ready (also
   required for the tuppr TalosUpgrade health gate to stay green).
3. `honcho-api` pod Ready; `curl https://honcho.servonet.lan/health` returns OK.
4. `honcho-deriver` pod running the reasoning queue.

## Risks

- **arm64**: verified — Honcho's CI builds `linux/amd64,linux/arm64` on tags.
- **Vectorchord image contrib extensions**: `pg_trgm`/`btree_gin` availability
  in the image assumed (CNPG base carries contrib); verify at first reconcile.
- **RK1 memory budget**: api + deriver at 1Gi limits each sit alongside the
  existing mlops workloads (litellm, hindsight, hermes); watch cluster metrics.
- **Embedding gap** (see prerequisites) — vector search is degraded until an
  embedding model is registered in litellm.
