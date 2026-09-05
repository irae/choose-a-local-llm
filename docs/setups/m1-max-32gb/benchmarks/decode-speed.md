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
| [Ternary-Bonsai-27B](./bonsai-27b.md) | MLX, bounded cache, thinking off | 24.5 → 17.3 | 58k | mem |
| [Ternary-Bonsai-27B](./bonsai-27b.md) | GGUF⁴, q4, 2 slots, thinking on | 14.9 → 7.8 | 2x48k | speed |
| [Gemma-4-12B](./gemma-4-12b-it.md) | MLX³, thinking off | 34.19 → 23.23 | 131k | mem |
| [Gemma-4-12B](./gemma-4-12b-it.md) | GGUF, f16 KV, no drafter, thinking off | 24.64 → 8.86 | 245k | window |
| [Gemma-4-26B-A4B](./gemma-4-26b-a4b.md) | MLX | 51 → 12.8 | 70k | mem |
| [Gemma-4-26B-A4B](./gemma-4-26b-a4b.md) | GGUF, MTP f16 | 60.3 → 17.3 | 197k | OOM |
| [Qwen3.6-35B-A3B](./qwen3.6-35b-a3b.md) | MLX, thinking on | 53.3 → 42.0 | 37k | mem |
| [Qwen3.6-35B-A3B](./qwen3.6-35b-a3b.md) | GGUF, MTP q8, thinking on | 36.4 → 43.8 | 8k | mem |
| [Qwen3.8-27B](./qwen3.8-27b.md) | MLX, compaction ~26k, effort medium | 17 → 15.3 | 28k | mem |
| [Qwen3.8-27B](./qwen3.8-27b.md) | GGUF, MTP f16, effort medium | 20.0 → 15.0 | 49k | OOM |
<!-- gen:decode-summary:end -->

## MLX-side engines: flat curves, hard memory ceilings

MLX runtimes barely slow down with depth — then die of memory, fast and
without warning. The curve ends in a Metal OOM, never at the floor.

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

| used tokens | Qwen3.6 +MTP† | Gemma-26B +MTP† | Qwen3.8 +MTP† | Gemma-12B +MTP q8 | Gemma-12B f16, no drafter | Bonsai fork q4† | Bonsai fork, 1 of 2 slots |
|--:|--:|--:|--:|--:|--:|--:|--:|
| 4K | 44.5 | 23.5 | 14.1 | 13.8 | 24.6 | 14.6 | 14.9 |
| 8K | — | — | 12.8 | 8.7 | 24.1 | — | 13.2 |
| 16K | 30.1 | 11.2 | 8.6 | *6.5 — floor at 16K* | 22.7 | 10.6 | 10.8 |
| 24-25K | — | *8.0 — floor ~24K* | *7.3 — floor ~19K* | | 21.6 | 9.0 | 9.2 |
| 32-33K | 18.8 | | | | 20.6 | *7.8 — floor ~30K* | *7.9 — floor ~32K* |
| 49K | 13.5 | | | | 18.8 | | |
| 65K | 10.7 | | | | 17.4 | | |
| 90K | **8.1 — window end** | | | | | | |
| 98K | | | | | 14.9 | | |
| 131K | | | | | 13.0 | | |
| 180K | | | | | 10.7 | | |
| 213K | | | | | 9.7 | | |
| 245K | | | | | **8.9 — window end** | | |

† measured at the retired 25000 wired limit; re-run pending.

Two configs measured here never cross the floor inside their whole
window: Qwen3.6 on llama, with 96K of usable depth, and Gemma-12B on
llama with f16 KV and no drafter, which holds 8.9 tok/s at the model's
own 245K. The same Gemma-12B server with q8_0 KV floors at 16K — a 3.2x
gap at 16K between two KV types of one config.

## What this test caught

- **Speculative decoding costs depth.** On the Bonsai fork, the DSpark
  drafter lifts shallow decode but drops the floor from ~30K to ~20-23K
  and adds 4-5 GB. Free speed shallow, real cost deep — measure both.
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
