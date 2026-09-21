# Run 27 — report

The large form of the run's status line
(`docs/methodology/status-lines.md`, "The site comparison, in full").
The same ternary 27B file as run 24, dense packing at f16 KV, served
with a rank-1 LoRA adapter that ablates the refusal direction **at
inference**. Six blocks, 2026-09-18 to 2026-09-19, `retry-sweep` empty.

The question is narrow: what does a runtime ablation cost? The model
file is byte-identical to run 24's best arm, the fork release is the
same, and the serving flags are the same. Only the adapter is added, at
scale 1.0. So every difference below belongs to the adapter.

The adapter is `bonsai-abliterate-lora.gguf` from
`Continuum-AI-Corp/OrcaBonsai-27B-Uncensored`: 9,682,464 bytes, sha256
`f1669534…67f42`, 258 tensors, 129 `lora_a`/`lora_b` pairs, alpha 1.0.
The server applies it; it is never merged into the weights.

## What the adapter costs

| measure | run 24, no adapter | run 27, adapter | difference |
|---|--:|--:|---|
| `-c` that loads and serves | 139264 | 139264 | none |
| VRAM under a deep request | 15385 MiB | 15385 MiB | none |
| 4096 tok/s | 42.1 | 40.76 | −3.2% |
| 24576 tok/s | 37.3 | 36.18 | −3.0% |
| 65536 tok/s | 30.1 | 29.15 | −3.2% |
| 138240 tok/s | 22.4 | 22.03 | −1.7% |
| EvalPlus base / plus | 0.970 / 0.939 | **0.976 / 0.945** | +0.006 / +0.006 |
| EvalPlus wall, minutes | 195.5 | 274 | +40% |
| blind agent score | **82** | 75 | −7 |
| worst defect | CRITICAL | medium | better |

## Quality and the agent task

EvalPlus at effort xhigh, `-c 32768`, think budget 30000 (the derive
cap; three of ten calibration rows never converged), answer budget
2048, `max_tokens` 32048: **0.976 / 0.945, no empty answer of 164**, 10
forced, 3 of those failed. The natural re-run of those three at 30000
with no flag: all three loop, none is late, so the budget lost no
answer and needs no correction.

The blind agent row, window 135168, peak context 126798 (93.8%), one
compaction, 269 tool calls, 1 h 22 min, end reason complete, loop flag
ok, 0 nudges. Scored by Claude Fable 5.1 in a subagent, per-criterion
sum checked.

## Findings

- **A runtime ablation is nearly free in speed and window.** The
  adapter is 9 MB against a 5.54 GiB file. It adds no VRAM that the
  ladder can read, it takes no window, and it costs about 3 percent of
  decode, falling to 1.7 percent at 135K where memory bandwidth already
  dominates. Anyone who wants this behaviour does not need a merged
  build.
- **It did not cost the quality gate. It raised it.** 0.976 / 0.945
  against 0.970 / 0.939. Both runs are single runs at temperature 0,
  and the gap is one problem on each metric, so read this as "no
  measurable loss", not as a gain.
- **The agent score moved down, and the defect class moved up.** 75
  against 82, but the unablated row carried a CRITICAL defect (trap A,
  a naive `.then()` on `fs.promises.glob()` that throws) and this row
  carried none. This row's worst defect is a task gap: it found the
  legacy package's `rimraf` references, declared `legacy-packages` out
  of scope in its own TASKS.md, and left them. It also never ran
  `pnpm install`, so the lockfile went stale, and it typed 13 of 15
  commits `fix` where its sibling used `chore`.
- **One run per cell.** The two rows differ by 7 points on a 100-point
  rubric, from one run each. That is inside the noise this project has
  measured on repeated rows, so the honest reading is that the adapter
  did not change agent ability in a way one pair of runs can show.
- **The thinking cost is the real price.** The EvalPlus wall grew 40
  percent at the same budget and level, and the forced count grew from
  6 to 10 of 164. The ablated model thinks longer on the problems it
  finds hard.
- **The comparison is only this clean because nothing else moved.**
  Same file, same revision, same fork release, same flags, same
  machine, same day, same prompt version, same scoring tier. A change
  in any one of those would have made the 7-point difference
  unreadable.

## Pending

- A second scale. Only 1.0 was measured; the adapter's effect on the
  agent task at 0.5 is unknown.
- A refusal evaluation. This project measures coding work, so the run
  never tested whether the ablation does what it claims. The score says
  what it costs, not what it buys.
- The `score.mjs` defect that reports `runtime_checks.trap_a.ok: true`
  while its own captured output says `THREW: TypeError`. Run 27's whole
  value is a comparison against run 24's trap-A row, and that flag
  feeds the criteria inputs of both.
