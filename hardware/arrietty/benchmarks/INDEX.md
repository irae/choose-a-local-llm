# Findings by benchmark run — RTX 5060 Ti 16 GB (Linux)

One entry per run: the most interesting findings and conclusions, with
links to the full record. Newest first. Each `benchN/` folder holds that
run's runbook (`AGENT.md`), log (`state.md`), and results (`results.md`,
`results/`). Run numbers are shared with the Mac
(`hardware/kamaji/benchmarks/INDEX.md`).

## bench28, planned 2026-09-19 ([state](bench28/state.md), [results](bench28/results.md))

- Runbook: [bench28/AGENT.md](bench28/AGENT.md). Every scored thinking
  row of this machine in EvalPlus fast mode (`docs/methodology/evalplus.md`,
  "Fast mode": thinking budget 8192, output 16384, no calibration):
  six rows spliced from their earlier budgeted runs, four scored in
  full. Starts when the card is free.

## bench27, 2026-09-18 to 2026-09-19 ([report](bench27/report.md), [state](bench27/state.md), [results](bench27/results.md))

- Runbook: [bench27/AGENT.md](bench27/AGENT.md). The best arm of run 24
  (ternary 27B, dense packing, f16 KV) served again with a rank-1 LoRA
  adapter that ablates the refusal direction at inference, scale 1.0.
  Same file, same fork release, same flags, same machine: only the
  adapter differs, so every difference belongs to it.
- **A runtime ablation is nearly free.** The adapter is 9 MB against a
  5.54 GiB file. It takes no window (`-c 139264` as without it), no
  readable VRAM, and about 3 percent of decode, falling to 1.7 percent
  at 135K.
- **It did not cost the quality gate**: 0.976 / 0.945 against 0.970 /
  0.939 without it, no empty answer either way. One problem on each
  metric, so read it as no measurable loss.
- **The agent score fell 7 points, and the defect class improved**: 75
  against 82, but the unablated row carried a CRITICAL trap-A crash and
  this row carried none. Its worst defect is a task gap, the legacy
  package declared out of scope. One run per cell.
- **The thinking cost is the real price**: the EvalPlus wall grew 40
  percent at the same budget and level, and the forced count grew from
  6 to 10 of 164.
- The run tested no refusal behaviour. This project measures coding
  work, so the numbers say what the ablation costs, not what it buys.

## bench24, 2026-09-17 to 2026-09-19 ([report](bench24/report.md), [state](bench24/state.md), [results](bench24/results.md))

- Runbook: [bench24/AGENT.md](bench24/AGENT.md). A ternary-weight 27B
  model released 2026-09-17: two GGUF packings by two KV types, all
  four arms laddered, swept, scored on EvalPlus under a thinking budget
  with its forced re-run, and given a blind agent row. Twenty-two
  blocks over three days, with an owner stop in the middle. Every row
  is served by the publisher's llama.cpp fork, release
  `prism-b10685-7dffb15`; the stock binary makes garbage from these
  files.
- **A 27B model at a 240K window on this card.** Ternary weights cost
  6.71 and 5.54 GiB, so the KV cache becomes the large allocation:
  `-c 212992` and `-c 245760` at q8_0, 81% and 94% of the trained
  window. Every other 27B build here serves 65536. Every sweep ends on
  a window verdict with no depth under the 8 tok/s floor.
- **The window is used, not offered.** Every blind row peaked above 92%
  of its window, and the deepest reached 225161 tokens, the deepest
  this project has measured. The two q8_0 rows needed no compaction.
- **The fastest 27B build on this card**: 46.3 tok/s at 4K against
  29.43 for the 3-bit build, 32.2 against 21.13 at 65K.
- **The two packings hold the same weights, and the card agrees.**
  Three of the four arms score 0.982 base. The slot packing decodes
  faster here; the dense packing buys window and costs 1.17 GiB less.
- **f16 leads q8_0 on the agent task on both packings**, 82 against
  73.5 and 77 against 60.5, where the quality gate does not separate
  them. One run per cell, so it is indicated, not established.
- **The scoring tier changed the reading.** All four rows were first
  scored by a subagent on the session default model. The re-score on
  the best tier moved three of four scores, one by sixteen points, and
  removed a conclusion: the trap-C exit hook is not critical on the
  best tier, so the earlier "both q8_0 arms carry a critical defect"
  was an artifact of the weaker scorer.
- **Loops, not small budgets.** On all four arms every forced answer
  that failed its tests fails again without the budget, at the
  30000-token cap. The same task ids keep appearing on this model
  family (`HumanEval/32`, `99`, `145`).

## bench25, 2026-09-18 ([report](bench25/report.md), [state](bench25/state.md), [results](bench25/results.md))

- Runbook: [bench25/AGENT.md](bench25/AGENT.md). The Q4_K_M build of the
  same abliterated 27B file that run 23 measured, served with part of
  its weights in host RAM: `-c 65536` fixed, q8_0 KV, and an `-ngl`
  ladder under a VRAM cap of 13811 MiB that leaves 2.5 GB for the
  system. That cap is this run's own rule; the card has no reserve rule.
- **`-ngl 45` of 64 is what fits**, at 13426 MiB under a real 64K
  request. 47 and 51 go over the cap at load.
- **Weights in host RAM cost about 4.4 times the speed**: 5.13 tok/s at
  4K against 22.67 for the same model's Q3_K_M inside the card, and
  2.31 against 16.74 at about 64K. No depth reaches the 8 tok/s floor.
- **Memory was never the limit; the bus was.** VRAM held flat at 13422
  MiB against the 13811 cap through the whole sweep.
- **The run ended at the sweep on its speed gate** (coordinator,
  2026-09-18): scoring a config that already fails the floor would
  spend most of a day. No quality row and no agent row exist for this
  build, and none is planned on this card.

## bench23, 2026-09-17 to 2026-09-18 ([report](bench23/report.md), [state](bench23/state.md), [results](bench23/results.md))

- Runbook: [bench23/AGENT.md](bench23/AGENT.md). A community Q3_K_M
  build of the dense 27B model, abliterated by its publisher, adopted
  at effort medium by owner overrule. The run carried a context gate
  that would have aborted it under a 32768-token window; the gate did
  not fire. An owner pause in the middle gave the card to a model
  released that day.
- **The larger quant keeps the window.** q8_0 serves `-c 65536`, the
  same window the two 3-bit builds of this model get here, although the
  file is about 0.6 GiB larger; f16 stops at 32768. Speed 22.67 / 20.65
  / 16.74 tok/s, about 23 percent under the 3-bit builds at both ends.
- **This build cannot do the agent task, and the file is the cause.**
  The smoke ended with zero tool calls in 9 seconds: the model wrote
  its calls as literal text, because the file's own chat template
  carries no `tools` and no `tool_call` handling, so `--jinja` has
  nothing to parse. The abliterated repack shipped a stripped template.
  A re-run of the same config cannot fix it; a tools-capable template
  supplied to the server is a different row.
- **Medium costs this model most of its quality**: 0.854 / 0.787,
  against 0.945 / 0.909 for the 3-bit build at xhigh. Build and level
  moved together, so neither alone is proven.
- **The first config whose forced failures are wrong answers, not
  loops.** Medium reasons short, so the derived budget is 3986 tokens
  and the run took 89 minutes, the cheapest EvalPlus on a 27B model
  here. Of five forced answers one passed; the four that failed failed
  again without the budget, as wrong answers.
- **A converged answer can still be empty.** One calibration row
  reasoned 13358 characters and finished on `stop` with an empty
  answer, with no budget flag and no `length` cut. The derive tool
  already drops such a row, so the budget came from the next longest.

## bench21, 2026-09-16 to 2026-09-17 ([report](bench21/report.md), [state](bench21/state.md), [results](bench21/results.md))

- Runbook: [bench21/AGENT.md](bench21/AGENT.md). The thinking budget
  under test (`docs/methodology/evalplus.md`, "Unproven yet",
  `../research/thinking-budget.md`): two run 19 configs scored again
  under a server thinking budget, then the natural re-run of the
  problems where the budget fired and the answer failed. Ten blocks,
  no block waited on a human.
- **A thinking budget removes every empty answer.** Gemma-4-12B NVFP4
  with thinking on: 0.976/0.951 at a 7350 budget against 0.659/0.640
  with 53 empties. The ISTA Qwen3.8 at xhigh: 0.976/0.933 against
  0.945/0.909 with 7 empties.
- **No forced answer was late.** Every forced failure either loops to
  30000 without the flag or converges and is still wrong. No budget
  needed a correction.
- **A fixed 8192 budget scores the same as the 30000 cap on the ISTA
  config**, with the same failed problems, in 175.0 minutes against
  273.4. It forces 11 answers against 6.
- HumanEval/99 and HumanEval/145 loop on both models at every budget.

## bench19, 2026-09-15 to 2026-09-16 ([report](bench19/report.md), [state](bench19/state.md), [results](bench19/results.md))

- Runbook: [bench19/AGENT.md](bench19/AGENT.md). EvalPlus on every row
  of this setup, eight blocks, no block waited on a human.
- **The runner's empty counts were wrong on every thinking-on row.**
  It wrote `0/164` from a log line; the samples hold 3 to 53 empties.
  The coordinator re-derived every row. Rule for the next runbooks: the
  empty count comes from the samples file, with the command written
  out.
- **Thinking off beats thinking on on both Gemma-12B builds**, by a
  wide margin: 0.951 against 0.793 on the k-quant, 0.927 against 0.659
  on NVFP4, and every failure at thinking on is an empty answer. The
  k-quant converges more often than NVFP4 at the same budget.
- **The two 3-bit Qwen3.8 builds sit within one point of the Mac's
  scores** at xhigh: unsloth 0.957/0.921, ISTA 0.945/0.909, with 3 and
  7 empties at budgets near 20000.
- **The desktop's share of the card cost two driver watchdog crashes
  on the ISTA drafter arm**; the run resumed and every problem counts
  once. No crash on any no-drafter arm.
- The run 19 branch predates the finish log, so every empty on this
  card is `† unproven`; run 21 records the cause on two of these
  configs under a thinking budget.

## bench17, 2026-09-13 to 2026-09-15 ([report](bench17/report.md), [state](bench17/state.md), [results](bench17/results.md))

- Runbook: [bench17/AGENT.md](bench17/AGENT.md). The first run on this
  machine: six llama.cpp builds read with `llama-benchy` up to their
  deep context, three drafter climbs, seven guided agent rows and one
  blind row. No EvalPlus (owner, 2026-09-13).
- **The ISTA 3-bit Qwen3.8 is the pick for this card**: guided 85 and
  blind 91, both 8 of 8, at a 61440 window, no drafter, q8_0 KV,
  29.4 → 21.1 tok/s. The only build that finished the task.
- **The MTP drafter pays on this card on every build that has one**,
  unlike the dense Qwen3.8 on the Mac, but it costs VRAM: a smaller
  `-c` on the dense builds, more expert layers in host RAM on the MoE.
- **The desktop shares the card.** At about 440 MiB free the ISTA
  n-max 2 server died three times with a GPU launch timeout; no
  drafter, at 1.2 GB free, ran clean.
- **Gemma-4-12B fails the agent task on both builds and both thinking
  levels**, with zero commits each time. NVFP4 fits the trained window
  and reads 2 to 5 percent faster than the k-quant.
- **The MoE builds serve 97K at about 45 tok/s** with part of the
  experts in host RAM, and score 48.5 (Qwen3.6) and 37.5 (Gemma-26B)
  guided.
