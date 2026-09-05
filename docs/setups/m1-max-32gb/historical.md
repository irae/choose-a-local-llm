# Historical data — M1 Max 32 GB

## What this page is

Superseded measurements, moved off the current pages as they were
replaced. **Newest first**: the top section is the most recent
supersession; the bottom is the oldest era. Each section says what
replaced it and why. The per-run findings and conclusions live in the
repo's
[benchmark findings index](https://github.com/irae/choose-a-local-llm/blob/master/benchmarks/INDEX.md).

::: danger DO NOT USE THESE NUMBERS
Everything on this page is **superseded, wrong, or both**. It is kept only to
show what changed and why.

- **Retired memory limit.** Many rows were measured at
  `iogpu.wired_limit_mb=27000`, which made the machine too slow for normal
  use. The current limit is 24000, so every context maximum here is too high.
- **Wrong axis.** Several tables measure *allocated* context, which is
  storage, not speed. The depth sweeps replaced this with decode speed
  against *used* context — the number that decides whether a config is
  usable.
- **Deflated quality scores.** Early EvalPlus passes used a fixed output
  budget that was too small, so reasoning ran out of tokens and empty
  completions scored as failures. Two models were badly understated.
- **Mixed eras in one table.** Some rows here are current and some are not,
  and they are not always labeled.

For numbers you can act on, go to [the comparison page](./comparison.md).
Full raw archives, with their eras labeled, live in the benchmarks pages.
:::

## Three GGUF rows at the fast sweep and the old KV type (superseded 2026-09-05, run 9)

Run 9 picked the KV cache type per model with a short creep of both
types, then ran the slow creep at the pick with the largest `-c` the
machine loads. These rows were measured before that, with the fast
sweep of 2026-08-28 and, for two of them, at q8_0 KV. All three
published `-c` values OOM at load under the 24000 limit.

| row | old | now |
| --- | --- | --- |
| Qwen3.8-27B GGUF MTP, effort medium | q8_0 KV, `-c 32768`, 19k gated by speed, 14.1 to 8 tok/s, 18.9 GB | f16 KV, `-c 49152`, 49k gated by mem (OOM at load above it), 20.0 to 15.0 tok/s, 23.5 GB |
| Gemma-4-26B-A4B GGUF MTP | q8_0 KV, `-c 262144`, 24k gated by speed, 23.5 to 8 tok/s, 15.4 GB | f16 KV, `-c 212992`, 197k gated by mem (OOM at load above it), 60.3 to 17.3 tok/s, 25.6 GB |
| Qwen3.6-35B-A3B GGUF MTP, thinking on | q8_0 KV, `-c 98304`, 90k gated by speed, 44 to 8.1 tok/s, 22.8 GB | q8_0 KV, `-c 49152`, 8k gated by mem, 36.4 to 43.8 tok/s, 25.0 GB |

The Qwen3.6 change is not a KV change. f16 does not load for it, so
q8_0 stays; the slow creep's memory columns showed compaction from 16K
that the fast sweep could not see, and the published `-c` never loaded.
Evidence: `benchmarks/bench9/results.md`.

## Gemma-4-12B figures measured on the retired LM Studio entry (superseded 2026-09-04)

Every number in this section was measured on the LM Studio entry
`google/gemma-4-12b`. That entry always thinks, ships Google's pre-fix
chat template, produced all three invalid Mendel rows, and is gone from
the model store. Its readings were copied onto the thinking-off row of
the site, which is a different entry. **Do not use them for either
entry.** The current curves for both backends are on
[the Gemma-12B report](./reports/gemma-4-12b-it.md); the evidence behind
the retirement is on
[its data page](./benchmarks/gemma-4-12b-it.md#the-retired-entry).

Headline figures withdrawn: 29.3 tok/s at 65K used tokens, a
compression-onset ceiling of 65-74K, a shallow reading of 35.4 tok/s,
and 8.1 GB at max context.

Ceiling confirmation sweep (`--parallel 4`, watcher at 20 s, wired limit
24000, 2026-08-30):

| depth | decode tok/s | watcher state |
|---|--:|---|
| 41,095 | 31.05 | clean |
| 49,112 | 30.25 | clean |
| 57,077 | 29.25 | clean |
| 65,094 | 29.29 — read as the last clean step | clean |
| 74,099 | 27.95 | compression/swap onset inside this step |

Shallow sweep (`--parallel 4`, `STEP_SLEEP=25`, wired limit 24000,
2026-08-30):

| depth | decode tok/s |
|---|--:|
| 4,175 | 35.41 |
| 8,292 | 34.89 |
| 16,465 | 33.88 |
| 24,638 | 33.08 |
| 33,071 | 32.19 |

RSS 8.1 GB at 33,071 tokens.

EvalPlus, thinking on: 0.622 base / 0.610 plus, with 61 of 164
completions empty. It is a completion-rate failure wearing a quality
number's clothes — 102 of the 103 answers it delivered pass. It is not a
score for any current configuration, and no thinking-on score exists for
the model today.

## Mendel rows from old prompt versions (superseded 2026-09-02)

Replaced by fresh rows on blind prompt v1.1 and guided v3.0, run
from the new moving base tags (`benchmark-blind-base`,
`benchmark-guided-base`), which include the tap crash fix. The site
tables now count only the current prompt version; the full per-version
archive stays in the hosted Mendel reports. Never compare these rows
with the current ones — different prompt versions never share a table.

| model | test | config | score | status |
|---|---|---|--:|---|
| Qwen3.8-27B | blind v1.0 | mlx 4-bit, effort medium, `pi` | 80/100 | partial — ~4h time budget, 3/8 libraries |
| Ternary Bonsai-27B | blind v1.0 | mlx 2-bit, `pi` | 58/100 | partial — `mlx_lm.server` tool-parser crash |
| Qwen3.6-35B-A3B | blind v1.0 | llama-server | 41.5/100 | complete |
| Gemma-4-26B-A4B | blind v1.0 | llama-server | 38/100 | partial |
| Qwen3.6-35B-A3B | guided v2.1 | llama-server | 65.5/100 | complete — all 8 libraries in 75.6 min |
| Ternary Bonsai-27B | guided v2.1 | mlx 2-bit, `pi` | 69/100 | partial — stuck 45+ min on a self-made bug, closed at 3/8 |
| Qwen3.8-27B | guided v2.1 | mlx 4-bit, `pi` | 84/100 | partial |

The run narratives for these rows lived on the comparison page; their
findings stay in the
[benchmark findings index](https://github.com/irae/choose-a-local-llm/blob/master/benchmarks/INDEX.md)
and the hosted reports' defect ledgers.

## Bonsai MLX depth rows 44-48K, transient dip (superseded 2026-08-30)

Three rows from an early depth pass read far under the curve. The
watched slow-creep re-test recovered to ~18 tok/s at greater depths
(50-58K), so the dip was a transient system episode (memory pressure or
background load), not a property of the config. The current
[Bonsai report](./reports/bonsai-27b.md) shows the clean curve.

| depth | decode tok/s |
|---|--:|
| 44K | 12.10 |
| 46K | 11.89 |
| 48K | 11.33 |

## Gemma-4-12B LM Studio ceiling, old criterion (superseded 2026-08-30)

Old rows read "170K, 29.7 tok/s" — the deepest point LM Studio's auto-fit
loader let a request reach before failing clean, not a compression/swap
ceiling. The revised criterion
([context creep](../../methodology/context-creep)) defines the ceiling
as the onset of memory compression/swap in the watcher log, with tok/s
taken from the last clean step before onset. A confirmation sweep under
the new criterion found onset between 65K and 74K used tokens (65,094
tokens clean at 29.29 tok/s; 74,099 tokens shows compression bursts up
to 114,012 pages). That replacement is itself superseded: it was
measured on the retired entry — see the 2026-09-04 section at the top of
this page. Current figures are on
[the comparison page](./comparison.md) and
[the Gemma-12B report](./reports/gemma-4-12b-it.md).

## Fast-sweep memory ceilings, pre slow-creep rule (limit 25000, superseded 2026-08-29)

The first depth sweeps for these three MLX configs used a fast sweep — no
pause between depth steps. The slow-creep rule (25 s pause per step,
[the measurement rules](../../methodology/context-creep)) replaced them
with a re-test at limit 24000 on 2026-08-29. Shallow-depth rows (below the
lowest row here) did not change and stay on the current pages.

| model | fast-sweep ceiling | fast-sweep last stable | slow-creep re-test |
|---|---|---|---|
| Gemma-4-26B-A4B, MLX | 82-98K | 82K, 20.6 tok/s | 70-72K; last stable 70K, 12.83 tok/s |
| Ternary-Bonsai-27B, MLX | 57-61K | 57K, 18.2 tok/s | 58-60K; last stable 58K, 17.27 tok/s |
| Qwen3.8-27B, MLX | ~32K (OOM, server thread died) | 28.7K, 14.2 tok/s, RSS 14.3 GB | 28-30K; last stable 28K, 15.29 tok/s |

## Deflated EvalPlus scores (fixed 3072-token budget, corrected 2026-08-28/29)

The first quality pass capped output at 3072 tokens. Reasoning exhausted the
cap, and the empty completions scored as hard failures. These are lower
bounds, not measurements.

| model / config | deflated base | deflated plus | empty | corrected base/plus |
|---|--:|--:|--:|--:|
| Qwen3.6-35B-A3B, llama+MTP, thinking on | 0.610 | 0.610 | 62/164 (~38%) | 0.939 / 0.921 |
| Ternary Bonsai-27B, mlx 2-bit, thinking on | 0.640 | 0.634 | 49/164 (~30%) | 0.915 / 0.884 |
| Qwen3.8-27B, mlx 4-bit, effort medium | 0.970 | 0.939 | 3/164 (~2%) | 0.982 / 0.939 |

The lesson generalizes: treat any single-pass score with a fixed output
budget as a lower bound until the budget is calibrated from measured
reasoning length ([the EvalPlus method](../../methodology/evalplus)).

## Decode speed (best server-usable config per model, retired 2026-08-28)

Cards moved out of the comparison page when it was slimmed to the current
picture, 2026-08-28.

| model | config | py tok/s | js tok/s |
|---|---|--:|--:|
| Gemma-4-26B-A4B (MoE) | llama-server + MTP n=2 | 71.9 | 69.3 |
| Qwen3.6-35B-A3B (MoE) | llama-server + MTP n=3 | 68.2 | 73.5 |
| Gemma-4-12B | llama-server + MTP n=3 | 35.0 | 35.6 |
| Ternary Bonsai-27B | mlx_lm.server (limit 25000: 24.5) | 24.5 | 24.5 |
| Qwen3.8-27B | mlx_lm.server | 19.7 | 19.6 |
| Qwen3.8-27B | llama-server + MTP n=3 | 16.9 | 15.7 |

All values are thinking-on where the model supports it. Thinking-off
(sub-agent mode): Gemma-26B 74.8/71.6 at n=2, Gemma-12B 45.2/31.3 at n=4.
Qwen's true fastest, MLX + MTP at 20.2/22.5, is CLI-only and cannot back a
harness. Gemma-26B's numbers are f16 KV at 32K; its 256K config needs q8 KV
now, which drops js to ~53 tok/s because draft acceptance falls under q8.

## Max context — single session (retired 2026-08-28)

| model | config | max context | tok/s at it |
|---|---|--:|--:|
| Gemma-4-26B-A4B (MoE) | llama-server, 1 slot, q8_0 KV | 256K (model limit) | 62.4 py / 53.3 js |
| Gemma-4-12B | llama-server, 1 slot | 256K (model limit) | 45.2 |
| Qwen3.6-35B-A3B (MoE) | llama-server, 1 slot, q8_0 KV | 96K (memory, limit 25000) | 62.0 |
| Ternary Bonsai-27B | mlx_lm.server, bounded prompt cache | 49K (memory, limit 25000) | 18.8 |
| Qwen3.8-27B | llama-server, 1 slot, q8_0 KV | re-probe pending at limit 25000 | – |
| Qwen3.8-27B | mlx_lm.server | 28K OK; ceiling &lt;33K (limit 25000) | 14.2 at 28K |

Context limits are mode-independent, because KV is preallocated. The tok/s
column here comes from short thinking-off probes; see each report for
thinking-on speeds.

## Multi-session, concurrent agents (retired 2026-08-28)

| model | config | sessions | context each |
|---|---|--:|--:|
| Gemma-4-12B | llama-server `--parallel 4 -c 1048576`, q8_0 KV | 4 | 256K |
| Gemma-4-26B-A4B (MoE) | llama-server `--parallel 2 -c 376832`, q8_0 KV | 2 | 184K |
| Qwen3.6-35B-A3B (MoE) | untested at limit 25000 (at 24000: OOM at 2×20K) | – | – |
| Qwen3.8-27B | re-probe pending at limit 25000 | – | – |
| Ternary Bonsai-27B | prism fork `--parallel 2 -c 98304`, q4_0 KV | 2 | 48K — 9.8 tok/s each concurrent, 10.0 GB RSS |

**Decision: parallel serving runs on llama-server only.** MLX has no slots.
Its only concurrency is one server process per agent, each with its own full
weight copy and its own port to wire into the harness. That was measured —
two Bonsai instances at 14.0 tok/s each, 14.9 GB — but ruled out as not worth
the operational fiddling. Bonsai regains a multi-session story when a brew
llama.cpp release loads its ternary GGUF, with a projected ~300K total
context to split across slots.

## Qwen3.6-35B-A3B — context ramp at the retired 27000 limit (oldest era)

Moved off the report page. f16 KV, MTP n-max 3. Under the current 25000
limit this config reaches 96K with q8_0 KV, not 139K.

| -c | result | tok/s | RSS |
|---|---|--:|--:|
| 49,152 | OK | 66.3 | 22.8 GB |
| 98,304 | OK | 67.2 | 23.7 GB |
| 131,072 | OK | 67.8 | 24.3 GB |
| 139,264 | OK — maximum at 27000 | 65.5 | 24.5 GB |
| 147,456 | Metal OOM | – | – |
| 196,608 | Metal OOM | – | – |

With q8_0 KV the 27000 limit reached 208K on one slot and 2×96K on two.
Those configs are retired.

## Qwen3.8-27B — context ramp and slot layouts at the retired 27000 limit (oldest era)

Moved off the report page. f16 KV, MTP n-max 3. The current maxima at 25000
have not been re-probed, so no replacement table exists yet — the depth floor
at ~19K makes big allocations pointless for this model anyway.

| -c | result | RSS |
|---|---|--:|
| 49,152 | OK | 21.2 GB |
| 65,536 | OK | 22.0 GB |
| 98,304 | OK — validated with a 4K-token prompt | 24.1 GB |
| 106,496 | Metal OOM | – |
| 114,688 | Metal OOM | – |
| 131,072 | Metal OOM | – |

| agents | flags | context per agent | RSS |
|---|---|--:|--:|
| 1 | `--parallel 1 -c 98304` | 96K | 24.1 GB |
| 2 | `--parallel 2 -c 90112` | 44K | 24.2 GB |

MTP stayed active in both. The next 8K step OOMed in both: `-c 106496` with
one slot, `-c 98304` with two. The 160K single and 2×72K configs from this
era are withdrawn.

---

Raw data, with eras labeled, in the benchmarks pages.
