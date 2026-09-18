# Run 23 — report

The large form of the run's status line
(`docs/methodology/status-lines.md`, "The site comparison, in full").
A community Q3_K_M build of Qwen3.8-27B, abliterated by its publisher,
adopted on the RTX 5060 Ti 16 GB at **effort medium by owner overrule**
(owner, 2026-09-17; `AGENTS.md` bans medium for this model everywhere
else). Nine blocks, 2026-09-17 to 2026-09-18, with an owner pause in
the middle so a model released that day could take the card.
`retry-sweep` empty. The coordinator re-derived the empty count from
the samples file and the forced count from `finish.jsonl`; both match
the runner's `results.md`.

The run carried a gate that could have ended it: a serving window under
32768 tokens would have aborted it before any calibration, because a
window under 32K does not pass EvalPlus on this task (owner,
2026-09-17). The gate did not fire.

## What the card holds

| KV | `-c` | note |
|---|--:|---|
| q8_0 | **65536** | the pick; 73728 fails to allocate |
| f16 | 32768 | 40960 fails to allocate |

Speed at the pick, q8_0, `-c 65536`, no drafter:

| depth | 4096 | 24576 | 64512 |
|---|--:|--:|--:|
| tok/s | 22.67 | 20.65 | 16.74 |

No depth fell under the 8 tok/s floor, so `oblit_q3km_clean` is 64512,
the deepest depth tested.

## Quality

| Config | Level | Think budget | Base | Plus | Empty | Forced | Wall |
|---|---|--:|--:|--:|--:|--:|--:|
| Q3_K_M, q8_0 KV, `-c 32768` | medium | 3986 | 0.854 | 0.787 | 3/164 | 5/164 | 89 |

The natural re-run of the forced answers that failed a test:

| Config | Think budget | Forced | Pass | Late | Loop | Wrong | Re-run wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| Q3_K_M, medium | 3986 | 5 | 1 | 0 | 0 | 4 | 16 |

## The agent task

The smoke failed, so the blind row did not run. The run ends with no
agent row.

## Findings

- **The gate did not fire, and the planning estimate was
  pessimistic.** q8_0 serves 65536, the same window the two 3-bit
  builds of this model get on this card, although this file is about
  0.6 GiB larger. The arithmetic of the architecture predicted the
  ceiling to within one step at both KV types.
- **This build cannot do the agent task at all, and the cause is the
  file, not the harness.** The smoke ended with zero tool calls in 9
  seconds: the model wrote its calls as literal text inside a
  `<tool_call>` block, so nothing executed. The file's own chat
  template carries no `tools` and no `tool_call` handling, so `--jinja`
  has nothing to parse. The abliterated repack shipped a stripped
  template. A thinking block was present in the session log, so the
  level reached the server and this is not the no-thinking-block
  stop-and-ask case. A re-run of the same config cannot fix it.
- **Medium costs this model most of its quality.** 0.854 base and 0.787
  plus, against 0.945 and 0.909 for the ISTA 3-bit build at xhigh on
  the same card, and 0.982 and 0.939 for the ternary build at xhigh.
  Two variables moved at once here, the build and the level, so neither
  alone is proven; what is certain is that this pair is the weakest
  quality row the card has recorded on this model.
- **Medium reasons short, and the budget follows.** The derived
  thinking budget is 3986 tokens, against 25209 for a build at xhigh
  and the 30000 cap for this model's earlier runs. The scored run took
  89 minutes, the cheapest EvalPlus on a 27B model on this machine.
- **The failures are wrong answers, not loops.** Of five forced
  answers, one passed and four failed; all four failed again without
  the budget at the 30000-token cap, as wrong answers rather than
  non-convergence. This is the first config in the thinking-budget
  experiment whose forced failures are `forced-fail-wrong` rather than
  `forced-fail-loop`. The budget lost nothing and needed no correction.
- **A converged answer can still be empty.** The calibration produced
  one row, `HumanEval/32`, that reasoned 13358 characters and then
  finished on `stop` with an empty answer, with no budget flag and no
  `length` cut. `thinking-budget.py derive` already drops such a row
  from the converged set, so the derived budget came from
  `HumanEval/145`. The run's `state.md` says the tool counted it as
  converged; that sentence is wrong and the numbers are right. The
  shape itself is evidence the experiment wants: non-convergence that
  ends itself, which no cause word on the site can express today.

## Pending

- A tool-calling row for this build needs a different serving config: a
  chat template that handles tools, supplied to the server rather than
  taken from the file. That is a new row and a planning decision, not a
  retry.
- An xhigh row, to separate the build from the level. The medium rows
  of this run are a record of the owner's overrule, not a target.
