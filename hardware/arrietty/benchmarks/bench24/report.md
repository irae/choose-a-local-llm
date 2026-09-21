# Run 24 — report

The large form of the run's status line
(`docs/methodology/status-lines.md`, "The site comparison, in full").
A ternary-weight 27B model released on 2026-09-17, measured on the RTX
5060 Ti 16 GB: two GGUF packings by two KV types, all four laddered,
swept and given a blind agent row, and all four given an EvalPlus score
under a thinking budget with its forced re-run. Twenty-two blocks,
2026-09-17 to 2026-09-19, `retry-sweep` empty. An owner stop paused the
run on 2026-09-18 and it resumed on 2026-09-19 after run 27.

**Every row of this run is served by the publisher's llama.cpp fork**,
release `prism-b10685-7dffb15`, commit `7dffb158d`. The stock binary
rejects both packings and makes garbage from a `Q2_0` file, because it
has no Hadamard activation runtime. The fork build id is part of each
row's identity, not a footnote: a different fork release is a different
serving stack.

## What the card holds

| File | Size | KV | `-c` | 4K | 24K | 65K | deep | deep depth | VRAM |
|---|--:|---|--:|--:|--:|--:|--:|--:|--:|
| PQ2_0 | 6.71 GiB | q8_0 | **212992** | 46.0 | 38.2 | 28.2 | 14.5 | 211968 | 15735 MiB |
| PQ2_0 | 6.71 GiB | f16 | 122880 | 46.3 | 40.5 | 32.2 | 25.1 | 121856 | 15.1 GB |
| PTQ1_0 | 5.54 GiB | q8_0 | **245760** | 41.7 | 34.9 | 26.5 | 12.8 | 244736 | 15837 MiB |
| PTQ1_0 | 5.54 GiB | f16 | 139264 | 42.1 | 37.3 | 30.1 | 22.4 | 138240 | 15.0 GB |

Every sweep ends on a **window** verdict, not a speed or memory one: no
depth fell under the 8 tok/s floor, and each sweep ran out of context
to test before the card ran out of room. VRAM stayed flat across every
depth of every arm.

## Quality

Each score is a full 164-problem EvalPlus at effort xhigh under a
server thinking budget, with its own calibration.

| Arm | Think budget | Base | Plus | Empty | Forced | Wall |
|---|--:|--:|--:|--:|--:|--:|
| PQ2_0, q8_0 | 25209 | 0.982 | 0.939 | 0/164 | 7 | 176.1 |
| PQ2_0, f16 | 30000 | **0.982** | **0.945** | 0/164 | 6 | 182.7 |
| PTQ1_0, q8_0 | 30000 | **0.982** | **0.945** | 0/164 | 9 | 244.9 |
| PTQ1_0, f16 | 30000 | 0.970 | 0.939 | 0/164 | 6 | 195.5 |

The natural re-run of every forced answer that failed a test, at 30000
with no flag: **every one of them loops**. None was late, so no derived
budget needed a correction, on any arm.

## The agent task

Blind, prompt v1.1, effort xhigh, one run per arm. Re-scored on
2026-09-18 by Claude Fable 5.1, the project's best tier.

| Arm | Window | Score | Worst defect | Calls | Peak ctx | Compactions | Wall |
|---|--:|--:|---|--:|--:|--:|--:|
| PTQ1_0, f16 | 135168 | **82** | CRITICAL | 258 | 127141 (93.9%) | 1 | 1:28 |
| PQ2_0, f16 | 119808 | 77 | medium | 230 | 110354 (92.9%) | 1 | 1:15 |
| PTQ1_0, q8_0 | 241664 | 73.5 | medium | 254 | **225161** (93.2%) | 0 | 2:03 |
| PQ2_0, q8_0 | 208896 | 60.5 | medium | 245 | 192679 (92.2%) | 0 | 1:32 |

## Findings

- **A 27B model at a 240K window on a 16 GB card, and it is not a
  trick.** Every other 27B build on this machine serves 65536, because
  12 GiB of weights leave about 2 GiB for the KV cache. Ternary weights
  cost 6.71 and 5.54 GiB, so the KV cache becomes the large allocation
  and the card reaches 81% of the trained window on the larger packing
  and 94% on the smaller one. The arithmetic agrees at both files and
  both KV types, so this is a measured ceiling, not a lucky load.
- **The window is used, not offered.** Every blind row peaked above 92%
  of its window, and the deepest reached 225161 tokens, the deepest
  context this project has measured. The two q8_0 rows needed no
  compaction at all. Before this model, no row on this machine passed
  64K.
- **It is also the fastest 27B build on this card**: 46.3 tok/s at 4K
  against 29.43 for the ISTA 3-bit build, and 32.2 against 21.13 at
  65K. The ternary packing buys the window and the speed together.
- **The two packings hold the same weights, and the card agrees.** The
  publisher reports no quality difference and says to pick by hardware.
  Three of the four arms score 0.982 base, across both files. The slot
  packing decodes faster here; the dense packing buys window and costs
  1.17 GiB less.
- **f16 leads q8_0 on the agent task on both packings**, 82 against
  73.5 and 77 against 60.5, while the quality gate does not separate
  them. One run per cell, so this is indicated, not established, and it
  is the most interesting open question this run leaves.
- **The quality gate does not predict the agent score.** The best
  quality arm and the worst agent arm are both PQ2_0 at q8_0. A
  short-prompt score measures none of what the agent rubric measures,
  which is why the project runs both.
- **The scoring tier changed the reading, not only the numbers.** All
  four rows were first scored by a subagent that ran on the session
  default model. The re-score on the best tier moved three of four
  scores, one by sixteen points, and it removed a whole conclusion: no
  scorer on the best tier grades the trap-C exit hook critical, so the
  earlier claim that both q8_0 arms carried a critical defect was an
  artifact of the weaker scorer. Two of the earlier scorings also
  reported a headline that did not match their own breakdown.
- **Loops, not small budgets.** Across all four arms every forced
  answer that failed its tests fails again without the budget, at the
  30000-token cap. The same task ids keep appearing on this model
  family (`HumanEval/32`, `99`, `145`).
- **The calibrations cost more than the scores did.** Three arms
  derived the 30000 cap, because calibration rows never converged. A
  cheaper fixed budget is worth a test on this model, as run 21 tested
  8192 against the cap.
- **The model card's sampling defaults are not what the server
  applies.** The card publishes `min_p 0.0`; the server applies
  `min_p 0.05`. EvalPlus runs greedy, so no score moved, but the agent
  rows sample and their config notes carry the measured value. A reader
  who copies the card will not reproduce the row.

## Pending

- A second run of any f16 against q8_0 pair, to test whether the agent
  gap survives repetition.
- A mainline llama.cpp row, when mainline learns these types. A
  mainline binary is preferable to a fork (owner, 2026-09-17).
- A guided agent row on any arm, to pair with the four blind rows.
- The fixed-budget test on this model, against the derived cap.
