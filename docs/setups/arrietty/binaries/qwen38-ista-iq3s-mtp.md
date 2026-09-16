# Qwen3.8-27B IQ3_S-mtp (ISTA-DASLab) on RTX 5060 Ti 16 GB

File: [`ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF`](https://huggingface.co/ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF),
`Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf`, revision `d562806`, about 12.2 GB,
3.50 bits per weight with an MTP head. Server: llama-server, q8_0 KV
on this machine. Every run of this file on this machine is on this
page, retired and superseded rows included; a run a harness or serving
defect voided is not.

- **Why it is here.** Added on the owner's word as the cross-machine
  pair to the same file on the Mac, so the two setups read the same
  build.
- **What it settled.** The only build on this card that finishes the
  agent task, at both prompt versions: guided 85, blind 91, both 8 of
  8, on a 61440 window with no drafter. The drafter arms crash the
  server near the desktop's share of the card, so the served config
  drops the drafter.
- **Where it stands.** The pick for this card. Guided 85 and blind 91
  read close to the unsloth UD-IQ3_S build's numbers, and this build
  is the only one of the two that finishes guided.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" top /> | **65k** | mem | <TokCell shallow="29.43" deep="21.13" top-shallow top-deep /> | **14.8 GB** | <ScoreCell value="0.945/0.909" sub="96% completion" top /> | <ScoreCell value="91" pill="mendel-blind" top /> | <span title="EvalPlus 3h38 · Mendel 1h15">4h53</span> |
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" />](../benchmarks/qwen3.8-27b.md) | 20500 | <ScoreCell value="0.945/0.909" sub="96% completion" top /> | † unproven | <TokCell shallow="29.43" deep="21.13" /> | 3h38 |
<!-- gen:binary-evalplus:end -->

Every empty on this file is `† unproven` because the run branch
predates the finish log. The thinking-budget test on this
config records the cause; its blocks on this file had not started as
of this page (state.md and results.md hold only the download start and
the Gemma-12B NVFP4 calibration block).

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" /> | blind-v1.1 | 64k | **91** | 8/8/done | 75.1 | 6,882k | 65k | 3 | 257 | 17 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" /> | guided-v3.0 | 64k | **85** | 8/8/done | 214.8 | 10,680k | 58k | 23 | 320 | 8 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

The window cell is the harness context window of that run. The guided
row shipped the `fs.glob` trap and dismissed the
`mendel-requirify` rimraf references as out of scope; the blind row
avoided both glob traps and never looked at the rimraf references its
own grep printed.

## Speed and context

<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" hide="drafter,effort" />

| measurement | date | config | result |
|---|---|---|---|
| real text, llama-benchy, no drafter | 2026-09-13 | q8_0 KV, `-c 65536` | 29.4 tok/s at 4K, 25.9 at 24K, 21.1 tok/s at 64K, gated by memory; 14.8 GB of VRAM |
| draft-depth climb, real text | 2026-09-13 | n-max 1, `-c 57344` | 33.4 / 29.7 / 24.6 tok/s at 4K / 24K / 56K |
| draft-depth climb, real text | 2026-09-13 | n-max 2, `-c 57344` | 45.9 / 31.9 / 26.2 tok/s at 4K / 24K / 56K, the fastest drafter arm |
| draft-depth climb, real text | 2026-09-13 | n-max 3, `-c 49152` | 37.3 / 30.8 / 31.6 tok/s at 4K / 24K / 48K |

The full curves are on [the benchmarks page](../benchmarks/qwen3.8-27b.md).
The same file at f16 KV on the Mac reads 14.1 tok/s at 4K and
8.1 tok/s at 147K, on a window more than twice as wide.

## Log

- 2026-09-13 — Named on the owner's word as the cross-machine pair to
  the Mac's build of the same file. Drafter sweep at q8_0 KV: n-max 1
  and 2 serve `-c 57344`, n-max 3 `-c 49152`; n-max 2 reads fastest.
  The n-max 2 arm served the guided agent task first and the server
  died three times with a GPU launch timeout, once with Xid 8, at
  about 440 MiB free VRAM; the desktop shares the card. The served arm
  switched to no drafter, which leaves 1.2 GB free and ran clean.
  Guided scored 85, 8 of 8; blind scored 91, 8 of 8, the only build
  that finished the task on this card. `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-14 to 2026-09-15 — EvalPlus at effort xhigh, q8_0 KV, no
  drafter. Calibration set budget 20500. The run hit a CUDA launch
  timeout at 7 of 164, restarted the server and resumed clean; a
  second CUDA watchdog crash on a temporary drafter arm sent the run
  back to the no-drafter fallback arm, which finished the remaining
  problems, keeping the 66 of 164 already solved. Score 0.945/0.909,
  7 empty answers of 164, 217.6 minutes of active time. A drafter
  never changes an answer at temperature 0, so every problem counts
  once. `hardware/arrietty/benchmarks/bench19/`.
- 2026-09-16 — Thinking-budget test started on this machine.
  As of this page its state.md and results.md hold only the
  background download of this file into the default Hugging Face
  cache and the Gemma-12B NVFP4 calibration block; the ISTA
  calibration and budget blocks (`qwen38-ista-calibrate-think`,
  `qwen38-ista-budget-xhigh`, `qwen38-ista-forced-rerun`,
  `qwen38-ista-budget8192-xhigh`, `qwen38-ista-forced-rerun-8192`) are
  pending. `hardware/arrietty/benchmarks/bench21/`.
