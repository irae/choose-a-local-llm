# Qwen3.8-27B IQ3_S-mtp (ISTA-DASLab) on M1 Max 32 GB

File: [`ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF`](https://huggingface.co/ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF),
`Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf`, revision `d562806`, about 12.2 GB,
3.50 bits per weight with an MTP head. Server: llama-server, f16 KV on
this machine. Every run of this file on this machine is on this page,
retired and superseded rows included; a run a harness or serving
defect voided is not.

- **Why it is here.** One of three 3-bit candidates picked for the 12 GB
  budget on 2026-09-07, the only publisher of the three with task-level
  proof of its quant, and the build the reference setup on the RTX 5060
  Ti serves too.
- **What it settled.** The drafter loses on this file at every depth,
  so it serves without one. Effort xhigh beats low on the agent task in
  less time, and loses to low on the single-turn test. Medium rows are
  records; medium is not run again.
- **Where it stands.** Blind 80.5 at xhigh on a 147K window on this
  machine, against 91 on the card at q8_0 KV on 61K.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" page="/setups/kamaji/binaries/qwen38-ista-iq3s-mtp" top /> | **147k** | speed | <TokCell shallow="14.1" deep="8.1" top-shallow top-deep /> | **24.4 GB** | <ScoreCell value="0.945/0.921" sub="97% completion" top /> | <ScoreCell value="80.5" pill="mendel-blind" top /> | <span title="EvalPlus 9h43 · Mendel 1h49">11h33</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" page="/setups/kamaji/binaries/qwen38-ista-iq3s-mtp" top /> | **128k** | mem | <TokCell shallow="15.1" deep="9.7" stale top-shallow top-deep /> | **24.2 GB** | <ScoreCell value="0.976/0.945" sub="99% completion" top /> | <ScoreCell value="76.5" pill="mendel-blind" top /> | <span title="EvalPlus 3h12 · Mendel 2h15">5h27</span> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" page="/setups/kamaji/binaries/qwen38-ista-iq3s-mtp" /> | **147k** | speed | <TokCell shallow="14.1" deep="8.1" top-shallow top-deep /> | **24.4 GB** | <ScoreCell value="0.976/0.933" sub="99% completion" top /> | <ScoreCell value="66" note="88%" pill="mendel-blind" /> | <span title="EvalPlus 2h27 · Mendel 2h43">5h10</span> |

† from an earlier serving config or method; re-run pending.
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" page="/setups/kamaji/binaries/qwen38-ista-iq3s-mtp" />](../benchmarks/qwen3.8-27b.md) | 8192 | <ScoreCell value="0.976/0.945" sub="99% completion" top /> | 1 budget | <TokCell shallow="15.1" deep="9.7" /> | 3h12 |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" page="/setups/kamaji/binaries/qwen38-ista-iq3s-mtp" />](../benchmarks/qwen3.8-27b.md) | 8192 | <ScoreCell value="0.976/0.933" sub="99% completion" top /> | 1 budget | <TokCell shallow="14.1" deep="8.1" /> | 2h27 |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" page="/setups/kamaji/binaries/qwen38-ista-iq3s-mtp" />](../benchmarks/qwen3.8-27b.md) | 30000 | <ScoreCell value="0.945/0.921" sub="97% completion" top /> | 5 budget | <TokCell shallow="14.1" deep="8.1" /> | 9h43 |
<!-- gen:binary-evalplus:end -->

Every empty on this file is proven as the output budget by a re-run
of the empty problems (2026-09-16).

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" page="/setups/kamaji/binaries/qwen38-ista-iq3s-mtp" /> | blind-v1.1 | 144k | **80.5** | 8/8/done | 109.4 | 10,819k | 118k | 0 | 193 | 17 |  |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" page="/setups/kamaji/binaries/qwen38-ista-iq3s-mtp" /> | blind-v1.1 | 112k | **76.5** | 8/8/done | 135.2 | 7,890k | 89k | 0 | 195 | 17 |  |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" page="/setups/kamaji/binaries/qwen38-ista-iq3s-mtp" /> | blind-v1.1 | 144k | **66** | 7/8/partial | 163.3 | 11,426k | 130k | 0 | 214 | 15 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

The current prompt versions are blind v1.1 and guided v3.0. Older
versions stay here as records and never compare with newer ones.

## Speed and context

<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" hide="drafter,effort" />

| measurement | date | config | result |
|---|---|---|---|
| ladder and creep | 2026-09-08 | MTP n-max 3, `-c 114688` then `-c 131072` | 114718 tokens clean at 9.67 tok/s; swap grew at 131098 |
| creep | 2026-09-09 | no drafter, `-c 163840` | 14.1 tok/s at 4K, 8.30 at 147478, under the floor at 163858; zero swap |
| drafter sweep, two depths | 2026-09-09 | n-max 0 to 4 at depth 256 and 98338 | no drafter wins every cell: 14.44 against 12.41 (n-max 3) shallow, 9.50 against 7.89 deep; acceptance 90 to 64 percent |
| real text, llama-benchy | 2026-09-11 | no drafter | 14.1 tok/s at 4K, 8.3 at 147K, within four percent of the creep |

The full curves are on [the benchmarks page](../benchmarks/qwen3.8-27b.md).

## Log

- 2026-09-07 — Picked as one of three 3-bit candidates in a research
  run on this machine, with the AtomicChat and unsloth 3-bit files;
  the owner approved the three downloads the same evening.
  `hardware/kamaji/research/qwen38-configs.md`.
- 2026-09-07 to 2026-09-08 — Research run: ladder and creep with the
  drafter at n-max 3, the only measured ceiling of the three
  candidates, 114718 at 9.67 tok/s. Both smokes level with the 4-bit
  control. `hardware/kamaji/research/run3/`.
- 2026-09-08 — Full gate at effort medium, inherited from the control
  row: EvalPlus 0.976 / 0.945, one empty at budget 8192; blind 76.5,
  8 of 8, on a 114688 window, trap A failed in the same shape as the
  4-bit control. A run-time loop guard with an empty-output bug voided
  one attempt in seconds; it was fixed and the row re-run under a
  fresh alias. `hardware/kamaji/benchmarks/bench12/`.
- 2026-09-09 — Medium banned on this model. Every medium row keeps its
  numbers as a record.
- 2026-09-09 to 2026-09-10 — One-build run at f16 KV and wired 25000:
  the drafter sweep at two depths, the no-drafter creep to 147K, blind
  at xhigh (80.5, 8 of 8, 109 minutes) and at low (66, 7 of 8, ended
  on the 25-minute turn cap), EvalPlus at low (0.976 / 0.933, one
  empty, 2h23) and at xhigh (0.945 / 0.921, five empties at the 30000
  cap, 9h43). A calibration first ran at the wrong level by omission;
  the tool now records the requested and resolved level. Sampling
  recorded for the first time: temperature 1.0, top_p 0.95 from the
  file. `hardware/kamaji/benchmarks/bench13/`.
- 2026-09-11 — Real-text speed with llama-benchy, no drafter, within
  four percent of the creep. `hardware/kamaji/benchmarks/bench16/`.
- 2026-09-14 — The same file's revision chosen for the RTX 5060 Ti,
  so the pair reads across providers and across machines.
- 2026-09-16 — Re-run of the empty EvalPlus problems at medium and low:
  HumanEval/39 hits the 8192 budget at both levels; cause `budget`.
  `hardware/kamaji/benchmarks/bench20/`.
- Pending — the re-run of the five xhigh empties is not scheduled; the
  thinking-budget test runs on this file on the card first
  ([method](../../../methodology/evalplus.md#unproven-yet-a-thinking-budget-instead-of-a-larger-output-budget)).
