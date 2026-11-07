# Plan: Honcho model routing across the fleet

How Honcho's roles should be spread over the available hardware, so the
MacBook stops doing background work and its two big oMLX models stop fighting
for memory. Extends `honcho-mlops.md`. Owner: opencode.

## Hardware

| tier | host | can run | notes |
|---|---|---|---|
| 0 | Turing RK1 ×3 (Talos) | embeddings (**NPU**), light LLM | always on, 8 cores, 16–32 GB |
| 1 | Mac mini M1 (oMLX) | gemma-4-e4b | addressable on the LAN; **not yet wired into litellm** |
| 2 | MacBook M5 Max (oMLX `:8899`) | gpt-oss-20b, qwen3.8-flash-next | interactive only — the two models sit near oMLX's memory guard, so they conflict |
| 3 | V100 host (NixOS) | 27B / MoE lanes | **not online yet** |
| — | OrcaRouter (cloud, free) | — | last-resort fallback |

## The constraint that shapes everything

The RK3588 NPU accelerates **prefill only**; decode never leaves the CPU. So
for *generation* roles the RK1's ceiling is the CPU decode rate — roughly
**10 t/s for a 3B-class Q4_K_M** (F16 would be ~3 t/s: unusable). That is fine
for background work and poor for interactive chat. Measured on `tom-7110`, the
NPU's prefill edge for *embeddings* is real but modest (1.68× at pp512 for
Qwen3-Embedding-0.6B F16) and shrinks with sequence length.

## Proposed routing

| Honcho role | knob | primary | fallback |
|---|---|---|---|
| Embeddings | `EMBEDDING_MODEL_CONFIG__MODEL` | **RK1** (F16, NPU) | — |
| Deriver (memory extraction) | `DERIVER_MODEL_CONFIG__MODEL` | **RK1** 3B Q4 | mini → cloud |
| Summary | `SUMMARY_MODEL_CONFIG__MODEL` | **mini** gemma-4-e4b | RK1 → cloud |
| Dream (deduction / induction) | `DREAM_*_MODEL_CONFIG__MODEL` | **RK1** / mini (background) | cloud |
| Dialectic minimal / low | `DIALECTIC_LEVELS__{minimal,low}__MODEL_CONFIG__MODEL` | RK1 / mini | cloud |
| Dialectic medium / high / max | `DIALECTIC_LEVELS__{medium,high,max}__MODEL_CONFIG__MODEL` | **MacBook** | mini → cloud |

The payoff is on the MacBook: it keeps only the interactive dialectic, so only
one of its two large models needs to be resident at a time — which is exactly
the memory-guard conflict.

Caveats the RK1 tier must respect: the nodes also run ceph / monitoring / the
Honcho server itself, and decode saturates all 8 cores, so a resident LLM needs
CPU limits and ~2.5 GB RAM with KV.

## Phases

1. **Measure** *(this pass)* — `llm-lab-bench`: Phi-4-mini-instruct,
   Llama-3.2-3B-Instruct and Qwen3-4B (all Q4_K_M), prefill + decode, NPU vs
   CPU, via `llama-bench` with `LLAMA_ARG_REPACK=0` for the NPU arm.
2. **Serve** — a persistent RK1 `llama-server` (`-nr`) for the light tier,
   registered in litellm as a `LiteLLMModel`.
3. **Wire** — point Honcho's role knobs at tiered aliases; add the mini lane.
4. **Later** — V100 lanes take over the mid tier; the RK1 keeps embeddings and
   maybe deriver.

## Open items

- **Mini details needed to wire tier 1**: `.lan` hostname, oMLX port, the served
  model name for gemma-4-e4b, and whether oMLX requires an API key.
- **MacBook**: decide which single model stays resident for interactive
  dialectic (gpt-oss-20b vs qwen3.8-flash-next) rather than both.
- **Batching**: Honcho's deriver batches by tokens
  (`DERIVER_REPRESENTATION_BATCH_*`); on a ~10 t/s tier the batch thresholds
  matter more than the model choice.
