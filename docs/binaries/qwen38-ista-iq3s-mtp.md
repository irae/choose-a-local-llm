# Qwen3.8-27B IQ3_S-mtp (ISTA-DASLab)

File: [`ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF`](https://huggingface.co/ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF),
`Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf`, revision `d562806`, about 12.15 GB,
3.50 bits per weight with an MTP head. Server: llama-server on both
machines, f16 KV on the M1 Max 32 GB and q8_0 KV on the RTX 5060 Ti
16 GB. Every run of this file on every machine is on this page,
retired and superseded rows included; a run a harness or serving
defect voided is not.

- **Why it is here.** One of three 3-bit candidates picked for the 12 GB
  budget on 2026-09-07, the only publisher of the three with task-level
  proof of its quant. Added to the RTX 5060 Ti 16 GB on the owner's
  word as the cross-machine pair, so the two setups read the same
  build at the same revision.
- **What it settled.** The drafter loses on this file at every depth on
  the Mac, so it serves without one there; on the card every drafter
  arm reads faster but crashes the server near the desktop's share of
  VRAM, so the card serves without one too. Effort xhigh beats low on
  the agent task in less time, and loses to low on the single-turn
  test. Qwen3.8-27B is never run at effort medium since 2026-09-09
  (owner rule, `benchmarks/PLANNING.md`); the medium rows keep their
  numbers as a record, with no re-run.
- **Where it stands.** The pick for the RTX 5060 Ti 16 GB: guided 85
  and blind 91, both 8 of 8, on a 61440 window, measured
  2026-09-13 to 2026-09-14, the only build there that finishes the
  task. On the M1 Max 32 GB, blind 80.5 at xhigh on a 147456 window,
  measured 2026-09-09 to 2026-09-10. The single-turn score is level
  across the two machines, 0.945 base on both at effort xhigh.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-ista-iq3s-mtp" top /> | 65k | mem | <TokCell shallow="29.43" deep="21.13" top-shallow top-deep /> | **14.8 GB** | <ScoreCell value="0.945/0.909" sub="96% completion" top /> | <ScoreCell value="91" pill="mendel-blind" top /> | <span title="EvalPlus 3h38 · Mendel 1h15">4h53</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-ista-iq3s-mtp" top /> | **147k** | speed | <TokCell shallow="14.1" deep="8.1" top-shallow top-deep /> | **24.4 GB** | <ScoreCell value="0.945/0.921" sub="97% completion" top /> | <ScoreCell value="80.5" pill="mendel-blind" top /> | <span title="EvalPlus 9h43 · Mendel 1h49">11h33</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-ista-iq3s-mtp" top /> | **128k** | mem | <TokCell shallow="15.1" deep="9.7" stale top-shallow top-deep /> | **24.2 GB** | <ScoreCell value="0.976/0.945" sub="99% completion" top /> | <ScoreCell value="76.5" pill="mendel-blind" /> | <span title="EvalPlus 3h12 · Mendel 2h15">5h27</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" hardware="m1-max-32gb" page="/binaries/qwen38-ista-iq3s-mtp" /> | **147k** | speed | <TokCell shallow="14.1" deep="8.1" top-shallow top-deep /> | **24.4 GB** | <ScoreCell value="0.976/0.933" sub="99% completion" top /> | <ScoreCell value="66" note="88%" pill="mendel-blind" /> | <span title="EvalPlus 2h27 · Mendel 2h43">5h10</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-ista-iq3s-mtp" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | 8192 | <ScoreCell value="0.976/0.945" sub="99% completion" top /> | 1 budget | <TokCell shallow="15.1" deep="9.7" /> | 3h12 |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" hardware="m1-max-32gb" page="/binaries/qwen38-ista-iq3s-mtp" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | 8192 | <ScoreCell value="0.976/0.933" sub="99% completion" top /> | 1 budget | <TokCell shallow="14.1" deep="8.1" /> | 2h27 |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-ista-iq3s-mtp" />](../setups/kamaji/benchmarks/qwen3.8-27b.md) | 30000 | <ScoreCell value="0.945/0.921" sub="97% completion" top /> | 5 budget | <TokCell shallow="14.1" deep="8.1" /> | 9h43 |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-ista-iq3s-mtp" />](../setups/arrietty/benchmarks/qwen3.8-27b.md) | 20500 | <ScoreCell value="0.945/0.909" sub="96% completion" top /> | † unproven | <TokCell shallow="29.43" deep="21.13" /> | 3h38 |
<!-- gen:binary-evalplus:end -->

On the M1 Max 32 GB the medium and low rows each hold one empty,
HumanEval/39, proven as the output budget by a re-run at budget 8192
on 2026-09-16. The five xhigh empties of that machine are recorded as
completions that hit the 30000-token budget by the run's own finish
reasons; they are not re-run. On the RTX 5060 Ti 16 GB the seven
empties at xhigh are unproven, because the run branch predates the
finish log; the thinking-budget test on this config records the
cause.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-ista-iq3s-mtp" /> | blind-v1.1 | 64k | **91** | 8/8/done | 75.1 | 6,882k | 65k | 3 | 257 | 17 |  |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/qwen38-ista-iq3s-mtp" /> | blind-v1.1 | 144k | **80.5** | 8/8/done | 109.4 | 10,819k | 118k | 0 | 193 | 17 |  |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" hardware="m1-max-32gb" page="/binaries/qwen38-ista-iq3s-mtp" /> | blind-v1.1 | 112k | **76.5** | 8/8/done | 135.2 | 7,890k | 89k | 0 | 195 | 17 |  |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" hardware="m1-max-32gb" page="/binaries/qwen38-ista-iq3s-mtp" /> | blind-v1.1 | 144k | **66** | 7/8/partial | 163.3 | 11,426k | 130k | 0 | 214 | 15 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-ista-iq3s-mtp" /> | guided-v3.0 | 64k | **85** | 8/8/done | 214.8 | 10,680k | 58k | 23 | 320 | 8 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

The current prompt versions are blind v1.1 and guided v3.0. On the
RTX 5060 Ti 16 GB the guided row shipped the `fs.glob` trap and dismissed the
`mendel-requirify` rimraf references as out of scope; the blind row
avoided both glob traps and never looked at the rimraf references its
own grep printed.

## Speed and context

<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" hide="drafter,effort,kv" />

| machine | measurement | date | config | result |
|---|---|---|---|---|
| M1 Max 32 GB | ladder and creep | 2026-09-08 | f16 KV, MTP n-max 3, `-c 114688` then `-c 131072` | 114718 tokens clean at 9.67 tok/s; swap grew at 131098 |
| M1 Max 32 GB | creep | 2026-09-09 | f16 KV, no drafter, `-c 163840` | 14.1 tok/s at 4K, 8.30 at 147478, under the floor at 163858; zero swap |
| M1 Max 32 GB | drafter sweep, two depths | 2026-09-09 | f16 KV, n-max 0 to 4, one 256-token completion per cell at depth 256 (`-c 106496`) and at depth 98338 (`-c 122880`) | no drafter wins every cell: 14.44 against 12.41 (n-max 3) at depth 256, 9.50 against 7.89 at depth 98338; acceptance 90 to 64 percent at depth 256 |
| M1 Max 32 GB | real text, llama-benchy | 2026-09-11 | f16 KV, no drafter | 14.1 tok/s at 4K, 8.3 at 147K, within four percent of the creep |
| RTX 5060 Ti 16 GB | real text, llama-benchy | 2026-09-13 | q8_0 KV, no drafter, `-c 65536` | 29.4 tok/s at 4K, 25.9 at 24K, 21.1 at 64K, gated by memory; 14.8 GB of VRAM |
| RTX 5060 Ti 16 GB | draft-depth climb, real text | 2026-09-13 | q8_0 KV, n-max 1, `-c 57344` | 33.4 / 29.7 / 24.6 tok/s at 4K / 24K / 56K |
| RTX 5060 Ti 16 GB | draft-depth climb, real text | 2026-09-13 | q8_0 KV, n-max 2, `-c 57344` | 45.9 / 31.9 / 26.2 tok/s at 4K / 24K / 56K, the fastest drafter arm |
| RTX 5060 Ti 16 GB | draft-depth climb, real text | 2026-09-13 | q8_0 KV, n-max 3, `-c 49152` | 37.3 / 30.8 / 31.6 tok/s at 4K / 24K / 48K |

The card reads about twice the Mac's speed on less than half its
window. The full curves are on the archive pages of
[the M1 Max](../setups/kamaji/benchmarks/qwen3.8-27b.md) and
[the RTX 5060 Ti](../setups/arrietty/benchmarks/qwen3.8-27b.md).

## Log

- 2026-09-07 — M1 Max: picked as one of three 3-bit candidates in a
  research run, with the AtomicChat and unsloth 3-bit files; the owner
  approved the three downloads the same evening.
  `hardware/kamaji/research/qwen38-configs.md`.
- 2026-09-07 to 2026-09-08 — M1 Max: research run, ladder and creep
  with the drafter at n-max 3, the only measured ceiling of the three
  candidates, 114718 at 9.67 tok/s. Both smokes level with the 4-bit
  control. `hardware/kamaji/research/run3/`.
- 2026-09-08 — M1 Max: full gate at effort medium, inherited from the
  control row: EvalPlus 0.976 / 0.945, one empty at budget 8192; blind
  76.5, 8 of 8, on a 114688 window, trap A failed in the same shape as
  the 4-bit control. A run-time loop guard with an empty-output bug
  voided one attempt in seconds; it was fixed and the row re-run under
  a fresh alias. `hardware/kamaji/benchmarks/bench12/`.
- 2026-09-09 — Both machines: the owner banned effort medium on
  Qwen3.8-27B. Every medium row keeps its numbers as a record, with no
  re-run.
  `benchmarks/PLANNING.md`.
- 2026-09-09 to 2026-09-10 — M1 Max: one-build run at f16 KV and wired
  25000: the drafter sweep at two depths, the no-drafter creep to
  147K, blind at xhigh (80.5, 8 of 8, 109 minutes) and at low (66, 7
  of 8, ended on the 25-minute turn cap), EvalPlus at low (0.976 /
  0.933, one empty at budget 8192) and at xhigh (0.945 / 0.921, five
  empties at the 30000 budget). A calibration first ran at the wrong level by
  omission; the tool now records the requested and resolved level.
  Sampling recorded for the first time: temperature 1.0, top_p 0.95
  from the file. `hardware/kamaji/benchmarks/bench13/`.
- 2026-09-11 — M1 Max: real-text speed with llama-benchy, no drafter,
  within four percent of the creep. `hardware/kamaji/benchmarks/bench16/`.
- 2026-09-13 to 2026-09-14 — RTX 5060 Ti: named on the owner's word as
  the cross-machine pair to the Mac's build, at the Mac's revision.
  Drafter sweep at q8_0 KV: n-max 1 and 2 serve `-c 57344`, n-max 3
  `-c 49152`; n-max 2 reads fastest. The n-max 2 arm served the guided
  task first and the server died three times with a GPU launch
  timeout at about 440 MiB free VRAM; the desktop shares the card. The
  served arm switched to no drafter, which leaves 1.2 GB free and ran
  clean. Guided 85, 8 of 8; blind 91, 8 of 8, the only build that
  finished the task on the card. `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-15 — RTX 5060 Ti: EvalPlus at xhigh, q8_0 KV, budget 20500.
  Two driver watchdog crashes on the drafter arm inside the run; the
  run resumed on a no-drafter arm and every problem counts once, since
  a drafter never changes an answer at temperature 0. 0.945 / 0.909,
  7 empty of 164, 217.6 minutes of active time; the runner reported no
  empties and the coordinator re-derived the count from the samples.
  `hardware/arrietty/benchmarks/bench19/`.
- 2026-09-16 — M1 Max: re-run of the empty EvalPlus problems at medium
  and low. HumanEval/39 hits the 8192 budget at both levels, cause
  `budget`; neither score moved. `hardware/kamaji/benchmarks/bench20/`.
- 2026-09-16 to 2026-09-17 — RTX 5060 Ti: the thinking-budget test,
  effort xhigh, q8_0 KV, no drafter. The calibration's longest
  converged reasoning ran 22947 tokens, so the thinking budget sits at
  the 30000 cap. The budgeted full run: 0.976 / 0.933, no empty
  answer, 6 forced answers of which 5 pass the base tests and 4 the plus, 273.4 minutes, against
  0.945 / 0.909 with 7 empties in 217.6 minutes without the budget.
  The natural re-run of the two forced failures and a second budgeted
  run at a fixed 8192 thinking budget follow.
  `hardware/arrietty/benchmarks/bench21/`.
- Pending — M1 Max: the re-run of the five xhigh empties is not
  scheduled
  ([method](../methodology/evalplus.md#unproven-yet-a-thinking-budget-instead-of-a-larger-output-budget)).
