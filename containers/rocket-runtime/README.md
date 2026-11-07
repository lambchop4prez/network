# rocket-runtime

Aarch64 inference image for the **RK3588 NPU** (Turing RK1): stock `llama.cpp`
(`llama-server`, `llama-bench`, `llama-cli`) built with a shared, DL-capable
`ggml`, plus the [`ggml-rocket`](https://github.com/gregordinary/ggml-rocket)
NPU backend as a runtime-loadable `libggml-rocket.so`.

The **same image** runs both backends — the CPU-vs-NPU switch is one variable:

```sh
# CPU baseline (no NPU backend loaded)
llama-bench -m model.gguf

# NPU: ggml dlopens the rocket backend and offloads prefill to the NPU
GGML_BACKEND_PATH=/opt/rocket/libggml-rocket.so llama-bench -m model.gguf
```

## Why this exists here

It is vendored from [`eburgueno/chat-rk1`](https://github.com/eburgueno/chat-rk1)'s
`docker/runtime/Dockerfile`. That project's README and manifests reference
`ghcr.io/eburgueno/chat-rk1/rocket-runtime:v0.1.0`, but **that package is not
anonymously pullable** — the GHCR token endpoint returns `401`, there is no
matching release tag, and no publish-workflow run. Rather than depend on an
unpublished third-party artifact, this repo builds and owns its own copy from
pinned upstream commits.

## Build & publish

Built and pushed by [`.github/workflows/rocket-runtime.yaml`](../../.github/workflows/rocket-runtime.yaml)
on GitHub's native `ubuntu-24.04-arm` runner (no QEMU):

- `workflow_dispatch` (optionally with a version), or
- pushing a `rocket-runtime-v*.*.*` git tag.

It publishes to `ghcr.io/lambchop4prez/rocket-runtime`. A local build is the
same:

```sh
docker buildx build --platform linux/arm64 -t ghcr.io/lambchop4prez/rocket-runtime:v0.1.0 containers/rocket-runtime
```

> **First publish:** GHCR packages are private by default. Make it public
> (GitHub profile → Packages → rocket-runtime → Package settings → Change
> visibility), otherwise pods get `ImagePullBackOff`. There are no
> `imagePullSecrets` anywhere in this repo, so a public package is the
> convention.

Pin consumers to the published **digest** once it exists.

## Pinned upstream sources

| Component | Repo | Ref |
|---|---|---|
| llama.cpp | `ggml-org/llama.cpp` | `465e49b9cea78a68b9c244ffb48d0ee24a82873d` |
| rocket-userspace | `gregordinary/rocket-userspace` | `1a181cd69fd98fafa998cfeca963d35cb5f43c46` |
| ggml-rocket | `gregordinary/ggml-rocket` | `fb3f14e6b0873911af5d209f15f3b84393afbd54` |
| patches (uAPI header) | `gregordinary/patches` | `314b1b34b561e0b7f92a9893798eda3f3a8abf16` |

The llama.cpp pin is deliberately contemporaneous with the ggml-rocket release
so its vendored ggml is `GGML_BACKEND_API_VERSION` 2 — the ABI ggml-rocket
targets. Bump only alongside a ggml-rocket that re-checks the backend vtable.

## License

The image links `rocket-userspace` (**GPL-3.0**) and `ggml-rocket`
(**GPL-3.0-or-later**), so the built image is GPL-3.0-or-later as a whole (the
image label says so). All sources are public and pinned above, which satisfies
source availability for redistribution.

## Use in this repo

Consumed by the embedding lab: `cluster/apps/lab/embed/` (see
`docs/plans/embedding-lab-rk1-npu.md`).
