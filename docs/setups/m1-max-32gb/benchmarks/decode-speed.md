# Decode speed vs context depth — M1 Max 32 GB

Every benchmark here answers one question: **how fast does the model
decode when the context is actually full?** A near-empty prompt says 62
tok/s; the same config in a real coding session ran 1.7 tok/s at 135K
used tokens. That one observation created this test, and it runs first
in the stack because everything else depends on its answer: the
harness compaction threshold, the "gated by" verdict, the published max
context, and which seat (main agent, sub-agent, background) a config
can hold. The community measures the same axis as llama.cpp's
`llama-bench` token-generation rate at depth. And it is only the first
gate: a config that flies here but scores low on
[EvalPlus](./evalplus.md) or [Mendel](./mendel.md) gets dropped anyway.

Two rules to read the tables by:

- **The floor is 8 tok/s** — below it, a config is unusable for
  interactive work, whatever its window says.
- **Used tokens, not allocated.** Allocation is storage. Every
  allocated-context table this project once published is retired on
  [the historical page](../historical.md).

## Latest per model and backend

<!-- gen:decode-summary:start -->
| model | best curve | tok/s (shallow → deep) | at | gated by |
|---|---|--:|--:|---|
| [Ternary-Bonsai-27B](./bonsai-27b.md) | MLX, unquantized KV, bounded cache, thinking on | 24.5 → 17.3 | 58k | mem |
| [Ternary-Bonsai-27B](./bonsai-27b.md) | GGUF⁵, q4_0 KV + bias, thinking on | 14.8 → 7.9 | 33k | speed |
| [Gemma-4-12B](./gemma-4-12b-it.md) | GGUF, f16 KV, no drafter, thinking off | 24.64 → 8.86 | 245k | mem |
| [Gemma-4-26B-A4B](./gemma-4-26b-a4b.md) | GGUF, MTP, f16 KV | 60.3 → 17.3 | 197k | mem |
| [Gemma-4-26B-A4B](./gemma-4-26b-a4b.md) | MLX, unquantized KV | 51 → 12.8 | 70k | mem |
| [Qwen3.6-35B-A3B](./qwen3.6-35b-a3b.md) | GGUF, MTP, q8_0 KV, thinking on | 36.5 → 9.2 | 82k | speed |
| [Qwen3.6-35B-A3B](./qwen3.6-35b-a3b.md) | MLX, unquantized KV, thinking on | 55.1 → 37.4 | 41k | mem |
| [Qwen3.8-27B](./qwen3.8-27b.md) | GGUF Q4_K_M (bartowski), MTP, f16 KV, effort medium | 20.0 → 13.7 | 72k | mem |
| [Qwen3.8-27B](./qwen3.8-27b.md) | MLX 4-bit, unquantized KV, effort low | 17 → 15.3 | 28k | mem |
<!-- gen:decode-summary:end -->

## MLX-side engines: flat curves, hard memory ceilings

MLX runtimes barely slow down with depth — then die of memory, fast and
without warning. The curve ends in a Metal OOM, never at the floor. Every
row below runs at f16 KV, the only cache type these servers offer, so the
columns leave it out.

| used tokens | Qwen3.6 MLX | Gemma-26B MLX | Gemma-12B LM Studio | Bonsai MLX | Qwen3.8 MLX |
|--:|--:|--:|--:|--:|--:|
| 4K | 53.3 | 51.1 | 34.2 | 24.5 | — |
| 8K | — | — | — | 24.2 | 17.1 |
| 16K | 49.6 | 43.5 | 32.1 | 22.9 | 16.4 |
| 24-25K | — | 39.6 | — | 22.0 | 14.8 |
| 28K | — | — | — | — | **15.3 — last stable** |
| 32-33K | 42.2 | 35.6 | 30.6 | 20.5 | *OOM ~30K* |
| 37K | **42.0 — last stable** | — | — | — | |
| 41-42K | *OOM ~41K* | — | — | 18.7 | |
| 49K | | 28.8 | — | 18.4 | |
| 57-58K | | — | — | **17.3 — last stable** | |
| 65K | | — | 27.1 | *OOM ~60K* | |
| 70K | | **12.8 — last stable** | — | | |
| 74K | | *OOM ~72K* | — | | |
| 98K | | | 24.5 | | |
| 131K | | | **23.2 — last stable** | | |

Gemma-12B is the outlier twice over: the flattest curve of the project,
and the only MLX config that does not end in an OOM — its engine leans
on macOS memory compression, so its ceiling is where the wired cap fills
and swap starts, not where the process dies. It is also the only column
here that a quality test rules out for tool work: it loops on the
thought channel in multi-turn sessions, whatever the thinking setting.

## llama-side (GGUF): faster decay, but never an OOM

llama runtimes creep down steadily and cross the floor while memory
stays comfortable. The curve ends at the floor or at the window — never
in a crash.

| used tokens | Qwen3.6 +MTP, f16 KV | Qwen3.6 +MTP, q8_0 KV | Gemma-26B +MTP, f16 KV | Qwen3.8 4-bit +MTP, f16 KV | Qwen3.8 ISTA 3-bit, f16 KV, no drafter | Gemma-12B f16 KV, no drafter | Gemma-12B f16 KV, no drafter, 1 of 2 slots | Gemma-12B +MTP, q8_0 KV | Bonsai fork, f16 KV, no drafter | Bonsai fork, q4_0 KV + bias |
|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|--:|
| 4K | 69.1 | 36.5 | 60.3 | 20.0 | 14.1 | 24.6 | 25.0 | 13.8 | 15.0 | 14.8 |
| 8K | 71.3 | 44.1 | — | 18.2 | 13.8 | 24.1 | 24.1 | 8.7 | 16.3 | 13.2 |
| 16K | 65.7 | 31.2 | 56.5 | 16.1 | 13.3 | 22.7 | 22.8 | *6.5 — floor at 16K* | 15.6 | 10.8 |
| 24-25K | 61.0 | 24.2 | — | 17.2 | 12.8 | 21.6 | 21.5 | | 15.1 | 9.1 |
| 32-33K | 56.5 | 19.6 | 45.9 | 16.4 | 12.4 | 20.6 | 20.6 | | 14.5 | *7.9 — floor at 33K* |
| 41K | **52.6 — window end** | 16.6 | — | 15.6 | 12.0 | 19.5 | 19.5 | | 13.9 | |
| 49K | | 14.3 | 45.9 | 15.0 | 11.5 | 18.8 | 18.6 | | 13.4 | |
| 65K | | 11.2 | — | **13.7 — last clean, swap past it** | 10.9 | 17.4 | 16.9 | | 12.5 | |
| 82K | | **9.2 — last above the floor** | — | | 10.2 | 15.7 | **15.7 — last clean per slot, swap past it** | | 11.5 | |
| 98K | | *7.9 — floor* | — | | 9.7 | 14.9 | | | 10.8 | |
| 115K | | | 26.4 | | 9.2 | 13.6 | | | 10.2 | |
| 131K | | | — | | 8.7 | 13.0 | | | **9.7 — window end, no floor found** | |
| 147K | | | — | | **8.3 — last above the floor** | — | | | | |
| 164K | | | — | | *7.9 — floor* | — | | | | |
| 180K | | | — | | | 10.7 | | | | |
| 197K | | | **17.3 — last step, `-c` 212992 the largest that loads** | | | — | | | | |
| 213K | | | | | | 9.7 | | | | |
| 245K | | | | | | **8.9 — window end** | | | | |

The Qwen3.6, Qwen3.8 GGUF, Bonsai f16 and Gemma-12B two-slot columns
ran at wired limit 25000 between 2026-09-06 and 2026-09-09; the
Gemma-26B, Gemma-12B one-slot and Bonsai q4_0 columns at 24000 between
2026-08-30 and 2026-09-05.

Four configs measured here never cross the floor inside their whole
window: Qwen3.6 on llama at f16 KV, Gemma-26B on llama, the Bonsai fork
at f16 KV, and Gemma-12B on llama with f16 KV and no drafter, which
holds 8.9 tok/s at the model's own 245K. The same Gemma-12B server with
q8_0 KV floors at 16K, a 3.2x gap at 16K between two KV types of one
config, and the same Bonsai fork at q4_0 KV floors at 33K.

## What this test caught

- **Speculative decoding costs depth, and on one build it costs speed
  too.** On the Bonsai fork, the DSpark drafter lifts shallow decode but
  drops the floor from ~30K to ~20-23K and adds 4-5 GB. On the Qwen3.8
  ISTA 3-bit build the MTP drafter loses at every depth, 12.4 against
  14.4 tok/s at depth 256 and 7.9 against 9.5 at 98K, and dropping it
  moved the served window from 131072 to 163840. Measure the drafter per
  build, at two depths.
- **A fake 44K OOM.** mlx_lm.server pools several multi-GB KV caches
  and acts like a memory leak; `--prompt-cache-size 2` removed the fake
  ceiling. A server can also keep answering `/health` 200 after its
  generation thread died — the sweep scripts watch the server log, not
  the endpoint.
- **Fast sweeps understate ceilings.** Pausing ~25 s between depth
  steps (as a real agent would) lets macOS compress memory and raised
  measured ceilings by ~2K tokens; the pause rule retired three earlier
  ceilings (Gemma-26B 82K → 70K among them).
- **Not every bad reading is real.** A 12 tok/s dip at 44-48K on Bonsai
  and a 7 tok/s crash at 98K on Gemma-12B both vanished on watched
  re-runs — transient system episodes. The sweep samples memory on every
  step for exactly this reason.
- **The KV type can be the ceiling.** On Gemma-12B, q8_0 KV falls under
  the floor by 16K while f16 holds to the model's window — 3.2x apart at
  16K, and f16 still fits inside the wired limit. The KV policy's "~1%
  speed edge" is model-dependent, and this model retired its own
  published ceiling.

## Fast is a ticket, not a win

This test decides whether a config is *usable*, not whether it is
*chosen*. The quality tiers come after: EvalPlus gates, Mendel tests
real agentic work, polyglot ranks the survivors — and a config that
loses there is dropped no matter how good its curve was. The live
example is Gemma-26B: the fastest MLX depth curve on this page
(51 tok/s shallow, 70K deep), parked anyway after scoring 0.713 on the
gate and failing the agentic tier. Read this page as the entry
requirement, and [the comparison](../comparison.md) for who actually
wins seats.

## Method, in one breath

Grow one prompt append-only, ~25 s pause per step, memory counters read
into every step row, read the server's own timings, stop only at the
floor, an OOM, or the trained window. Full procedure:
[context creep](../../../methodology/context-creep).

---

Complete curves for every config and era, including retired ones:
[Qwen3.6-35B-A3B](./qwen3.6-35b-a3b.md) ·
[Qwen3.8-27B](./qwen3.8-27b.md) ·
[Gemma-4-26B-A4B](./gemma-4-26b-a4b.md) ·
[Gemma-4-12B](./gemma-4-12b-it.md) ·
[Ternary-Bonsai-27B](./bonsai-27b.md)
