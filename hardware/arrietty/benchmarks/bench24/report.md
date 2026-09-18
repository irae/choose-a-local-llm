# Run 24 — report

The large form of the run's status line
(`docs/methodology/status-lines.md`, "The site comparison, in full").
A ternary-weight 27B model released on 2026-09-17, measured on the RTX
5060 Ti 16 GB the same day: two GGUF packings, both KV types laddered,
both swept, one EvalPlus under a thinking budget with its forced
re-run, one smoke and one blind agent row. Eleven blocks,
2026-09-17 to 2026-09-18, `retry-sweep` empty. The coordinator
re-derived the empty count from the samples file and the forced count
from `finish.jsonl`; both match the runner's `results.md`.

**Every row of this run is served by the publisher's llama.cpp fork**,
release `prism-b10685-7dffb15`, commit `7dffb158d`. The stock binary
rejects both packings and makes garbage from a `Q2_0` file, because it
has no Hadamard activation runtime. The fork build id is part of each
row's identity, not a footnote: a different fork release is a different
serving stack.

## What the card holds

| File | Size | KV | `-c` | 4K | 24K | 65K | deep | deep depth |
|---|--:|---|--:|--:|--:|--:|--:|--:|
| PQ2_0 | 6.71 GiB | q8_0 | **212992** | 46.0 | 38.2 | 28.2 | 14.5 | 211968 |
| PQ2_0 | 6.71 GiB | f16 | 122880 | — | — | — | — | — |
| PTQ1_0 | 5.54 GiB | q8_0 | **245760** | 41.7 | 34.9 | 26.5 | 12.8 | 244736 |
| PTQ1_0 | 5.54 GiB | f16 | 139264 | — | — | — | — | — |

Both sweeps end on a **window** verdict, not a speed or memory one: no
depth fell under the 8 tok/s floor, and the sweep ran out of context to
test before the card ran out of room. VRAM stayed flat across every
depth, 15735 MiB on PQ2_0 and 15837 MiB on PTQ1_0.

## Quality and the agent task

| Config | Level | Think budget | Base | Plus | Empty | Forced | Wall |
|---|---|--:|--:|--:|--:|--:|--:|
| PQ2_0, q8_0 KV, `-c 32768` | xhigh | 25209 | **0.982** | **0.939** | 0/164 | 7/164 | 176.1 |

The natural re-run (no flag, `max_tokens` 30000) of the forced answers
that failed a test:

| Config | Think budget | Forced | Pass | Late | Loop | Wrong | Re-run wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| PQ2_0, xhigh | 25209 | 7 | 3 | 0 | 4 | 0 | 48.5 |

| Agent row | Window | Score | Worst defect | Calls | Peak ctx | End | Wall |
|---|--:|--:|---|--:|--:|---|--:|
| PQ2_0, blind, xhigh | 208896 | **60/100** | CRITICAL | 245 | 192679 (92.2%) | complete | 1:32:27 |

## Findings

- **A 27B model at a 208K window on a 16 GB card, and it is not a
  trick.** Every other 27B build on this machine serves 65536, because
  12 GiB of weights leave about 2 GiB for the KV cache. Ternary weights
  cost 6.71 GiB, so the KV cache becomes the large allocation and the
  card reaches 81% of the trained window on the larger packing and 94%
  on the smaller one. The arithmetic agrees with the architecture at
  both KV types and at both files, so this is a measured ceiling, not a
  lucky load.
- **The window is used, not offered.** The blind agent row peaked at
  192679 tokens of 208896, 92.2% of the window, with zero compactions.
  This is the first row in the project where the task itself reached
  past 64K. A deep window earns its row from a task that reaches the
  depth, and this one did.
- **It is also the fastest 27B build on this card.** 46.0 tok/s at 4K
  against 29.43 for the ISTA 3-bit build, and 28.2 against 21.13 at
  65K. The ternary packing buys the window and the speed at the same
  time.
- **The quality gate is the best score this card has recorded.** 0.982
  base and 0.939 plus, 100% completion, no empty answer. At the short
  prompt this build is level with the best Mac rows and above every
  other row measured here.
- **The agent score does not follow the quality gate.** 60/100 blind,
  against 91 for the ISTA 3-bit build on the same machine. The row
  completed, committed 16 times, never looped, and used no nudges, so
  the loss is not a harness failure and not non-convergence. It is
  judgment: a CRITICAL trap-C regression (an exit hook that deletes the
  debug manifest before the user can read it), a missed trap B, no
  dependency pruning at all, and Prettier left failing. A short-prompt
  quality gate measures none of that, which is why the project runs
  both.
- **Four problems loop, and they loop with or without a budget.** Of
  seven forced answers, three passed; the four that failed hit the
  30000-token cap unconverged in the natural re-run. No forced answer
  was late, so the derived budget of 25209 needed no correction. The
  same three task ids keep appearing on this model family
  (`HumanEval/32`, `99`, `145`), now at a third build and a second
  level.
- **The calibration cost more than the score did.** Three of ten
  calibration rows never converged inside the 720 s wall, and the
  derived budget landed near the 30000 cap, so this was the most
  expensive calibration on the card. A cheaper fixed budget is worth a
  test on this build, as run 21 tested 8192 against the cap.
- **The model card's sampling defaults are not what the server
  applies.** The card publishes `min_p 0.0` in `general.sampling.*`;
  the server applies `min_p 0.05`. EvalPlus runs greedy, so no score
  moved, but the agent row samples and its config note carries the
  measured value. A reader who copies the card will not reproduce the
  row.

## Pending

- The PTQ1_0 packing has a window and a speed curve and no quality or
  agent row. It is the cheaper file and the larger window; a score
  would say whether the smaller packing costs anything.
- A mainline llama.cpp row, when mainline learns these types. A
  mainline binary is preferable to a fork (owner, 2026-09-17).
- A guided agent row on PQ2_0, to pair with the blind 60.
