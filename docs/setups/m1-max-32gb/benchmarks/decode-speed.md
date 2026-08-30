# Decode speed vs context depth — M1 Max 32 GB

Every benchmark here answers one question: **how fast does the model
decode when the context is actually full?** A near-empty prompt says 62
tok/s; the same config in a real coding session ran 1.7 tok/s at 135K
used tokens. That one observation created this test, and it runs first
in the stack because everything else depends on its answer: the
harness compaction threshold, the "gated by" verdict, the published max
context, and which seat (main agent, sub-agent, background) a config
can hold. The community measures the same axis as llama.cpp's
`llama-bench` token-generation rate at depth.

Two rules to read the tables by:

- **The floor is 8 tok/s** — below it, a config is unusable for
  interactive work, whatever its window says.
- **Used tokens, not allocated.** Allocation is storage. Every
  allocated-context table this project once published is retired on
  [the historical page](../historical.md).

## Latest per model

<!-- gen:decode-summary:start -->
| model | best curve | tok/s (shallow → deep) | at | gated by |
|---|---|--:|--:|---|
| [Ternary-Bonsai-27B](./bonsai-27b.md) | GGUF⁴, q4, 2 slots, thinking on | 14.9† → 7.9 | 2x48k† | speed |
| [Gemma-4-12B](./gemma-4-12b-it.md) | MLX³, thinking off | 37† → 29.29 | 158k* | mem |
| [Gemma-4-26B-A4B](./gemma-4-26b-a4b.md) | MLX | 51 → 12.8 | 70k | mem |
| [Qwen3.6-35B-A3B](./qwen3.6-35b-a3b.md) | GGUF, MTP q8, thinking on | 44† → 8.1† | 90k† | speed |
| [Qwen3.8-27B](./qwen3.8-27b.md) | MLX, compaction ~26k, effort medium | 17 → 15.3 | 28k | mem |

† from an earlier serving config or method; re-run pending.
<!-- gen:decode-summary:end -->

## MLX-side engines: flat curves, hard memory ceilings

MLX runtimes barely slow down with depth — then die of memory, fast and
without warning. The curve ends in a Metal OOM, never at the floor.

| used tokens | Qwen3.6 MLX | Gemma-26B MLX | Gemma-12B LM Studio | Bonsai MLX | Qwen3.8 MLX |
|--:|--:|--:|--:|--:|--:|
| 4K | 53.3 | 51.1 | 36.7† | 24.5 | — |
| 8K | — | — | — | 24.2 | 17.1 |
| 16K | 49.6 | 43.5 | 36.9† | 22.9 | 16.4 |
| 24-25K | — | 39.6 | — | 22.0 | 14.8 |
| 28K | — | — | — | — | **15.3 — last stable** |
| 32-33K | 42.2 | 35.6 | 34.8† | 20.5 | *OOM ~30K* |
| 37K | **42.0 — last stable** | — | — | — | |
| 41-42K | *OOM ~41K* | — | 31.1 | 18.7 | |
| 49K | | 28.8 | 30.3 | 18.4 | |
| 57-58K | | — | 29.3 | **17.3 — last stable** | |
| 65K | | — | **29.3 — last clean** | *OOM ~60K* | |
| 70K | | **12.8 — last stable** | — | | |
| 74K | | *OOM ~72K* | *27.9 — compression onset* | | |

† shallow rows from an earlier era; re-run pending.

Gemma-12B is the outlier twice over: the flattest curve of the project
(still 22.8 tok/s at 158K in an exploratory full-window pass), and the
only MLX config that does not end in an OOM — its engine leans on macOS
memory compression instead, so its ceiling is where compression starts
(between 65K and 74K), not where the process dies.

## llama-side (GGUF): faster decay, but never an OOM

llama runtimes creep down steadily and cross the floor while memory
stays comfortable. The curve ends at the floor or at the window — never
in a crash.

| used tokens | Qwen3.6 +MTP† | Gemma-26B +MTP† | Qwen3.8 +MTP† | Gemma-12B +MTP† | Bonsai fork q4† | Bonsai fork, 1 of 2 slots |
|--:|--:|--:|--:|--:|--:|--:|
| 4K | 44.5 | 23.5 | 14.1 | 14.0 | 14.6 | 14.9 |
| 8K | — | — | 12.8 | 9.0 | — | 13.2 |
| 16K | 30.1 | 11.2 | 8.6 | *6.8 — floor ~11K* | 10.6 | 10.8 |
| 24-25K | — | *8.0 — floor ~24K* | *7.3 — floor ~19K* | | 9.0 | 9.2 |
| 32-33K | 18.8 | | | | *7.8 — floor ~30K* | *7.9 — floor ~32K* |
| 49K | 13.5 | | | | | |
| 65K | 10.7 | | | | | |
| 90K | **8.1 — window end** | | | | | |

† measured at the retired 25000 wired limit; re-run pending.

Qwen3.6 on llama is the only config measured that never crosses the
floor inside its whole window — 96K of usable depth. At the other end,
Gemma-12B on llama floors at ~11K, the shallowest point measured: all
of that model's depth lives in its LM Studio engine.

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
  re-runs — transient system episodes. The memory watcher is mandatory
  for exactly this reason.

## Method, in one breath

Grow one prompt append-only, ~25 s pause per step, memory watcher
running, read the server's own timings, stop only at the floor, an OOM,
or the trained window. Full procedure:
[context creep](../../../methodology/context-creep).

---

Complete curves for every config and era, including retired ones:
[Qwen3.6-35B-A3B](./qwen3.6-35b-a3b.md) ·
[Qwen3.8-27B](./qwen3.8-27b.md) ·
[Gemma-4-26B-A4B](./gemma-4-26b-a4b.md) ·
[Gemma-4-12B](./gemma-4-12b-it.md) ·
[Ternary-Bonsai-27B](./bonsai-27b.md)
