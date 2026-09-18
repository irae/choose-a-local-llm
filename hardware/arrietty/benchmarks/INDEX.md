# Findings by benchmark run — RTX 5060 Ti 16 GB (Linux)

One entry per run: the most interesting findings and conclusions, with
links to the full record. Newest first. Each `benchN/` folder holds that
run's runbook (`AGENT.md`), log (`state.md`), and results (`results.md`,
`results/`). Run numbers are shared with the Mac
(`hardware/kamaji/benchmarks/INDEX.md`).

## bench24, 2026-09-17 to 2026-09-18 ([report](bench24/report.md), [state](bench24/state.md), [results](bench24/results.md))

- Runbook: [bench24/AGENT.md](bench24/AGENT.md). A ternary-weight 27B
  model released 2026-09-17, measured the same day: two GGUF packings,
  both KV types laddered, both swept, one EvalPlus under a thinking
  budget with its forced re-run, a smoke and a blind agent row. Every
  row is served by the publisher's llama.cpp fork, release
  `prism-b10685-7dffb15`; the stock binary makes garbage from these
  files.
- **A 27B model at a 208K window on this card.** Ternary weights cost
  6.71 GiB, so the KV cache becomes the large allocation: `-c 212992`
  at q8_0 on the larger packing, `-c 245760` on the smaller one, 81%
  and 94% of the trained window. Every other 27B build here serves
  65536. Both sweeps end on a window verdict with no depth under the 8
  tok/s floor.
- **The window is used, not offered.** The blind row peaked at 192679
  tokens of 208896, 92.2%, with zero compactions. It is the first row
  in the project where the agent task itself went past 64K.
- **The fastest and the highest-scoring 27B build on this card**: 46.0
  tok/s at 4K against 29.43 for the 3-bit build, and 0.982 / 0.939 on
  HumanEval+ with no empty answer.
- **The agent score does not follow the quality gate**: 60/100 blind
  against 91 for the 3-bit build. The row completed with 16 commits, no
  loop and no nudge, so the loss is judgment, not a harness failure: a
  CRITICAL trap-C regression, a missed trap B, no dependency pruning,
  Prettier left failing.
- **Four problems loop with or without a budget.** Three of seven
  forced answers passed; the four that failed hit the 30000-token cap
  unconverged in the natural re-run, so no forced answer was late and
  the derived budget of 25209 stands.

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
