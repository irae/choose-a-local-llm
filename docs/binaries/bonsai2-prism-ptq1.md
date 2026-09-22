# Ternary-Bonsai-2-27B PTQ1_0 (prism-ml, prism fork)

File: [`prism-ml/Ternary-Bonsai-2-27B-gguf`](https://huggingface.co/prism-ml/Ternary-Bonsai-2-27B-gguf),
`Ternary-Bonsai-2-27B-PTQ1_0.gguf`, revision `6ed5e12`, 5,946,648,928
bytes (5.54 GiB), the smaller ternary packing of the same model.
Server: the PrismML llama.cpp fork (`prism-llama`), release
`prism-b10685-7dffb15`, commit `7dffb158d`, CUDA 12.8. Every run of
this file on every machine is on this page, retired and superseded rows
included; a run a harness or serving defect voided is not.

- **Why it is here.** It is the cheaper of the two servable packings in
  the repository, and the pair says what the packing costs. The two
  files hold the same ternary weights and differ only in how they store
  a trit: this one packs trits densely at 1.75 bits per weight, the
  larger one gives each trit its own 2-bit slot at 2.13. The publisher
  reports no quality difference between them and picks between them by
  hardware. Stock llama.cpp cannot serve either file: it rejects both
  types and has no Hadamard activation runtime.
- **What it settled.** The smaller packing buys window. It serves
  `-c 245760` at q8_0, 94% of the trained 262144, where the larger
  packing reaches 212992, which is the "memory is tightest" case the
  publisher names for this pack. f16 is not usable at depth here: it
  aborted
  on a live CUDA out-of-memory at 147456, mid-evaluation rather than at
  load, and tops out at 139264. Speed is a little under the larger
  packing at every depth: 41.7 / 34.9 / 26.5 / 12.8 tok/s at 4096 /
  24576 / 65536 / 244736, no cell under the 8 tok/s floor, VRAM flat at
  15837 MiB.
- **Where it stands.** No quality gate and no agent row yet, so nothing
  is known about what the smaller packing costs in answers. That pair
  of rows is the open question this file carries.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" top /> | 135k | <TokCell shallow="42.1" deep="22.4" cap="mem" top-shallow top-deep /> | **15.0 GB** | <ScoreCell value="0.976/0.945" sub="100% completion" /> | <ScoreCell value="82" pill="mendel-blind" top /> | <span title="EvalPlus 2h05 · Mendel 1h28"><b>3h33</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" adapter="refusal-ablation LoRA 1.0" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" top /> | 135k | <TokCell shallow="40.8" deep="22.0" cap="mem" top-shallow top-deep /> | **15.0 GB** | <ScoreCell value="0.976/0.945" sub="100% completion" /> | <ScoreCell value="75" pill="mendel-blind" top /> | <span title="EvalPlus 2h32 · Mendel 1h22"><b>3h54</b></span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" top /> | **240k** | <TokCell shallow="41.7" deep="12.8" cap="mem" top-shallow /> | **15.5 GB** | <ScoreCell value="0.982/0.945" sub="100% completion" top /> | <ScoreCell value="73.5" pill="mendel-blind" /> | <span title="EvalPlus 2h20 · Mendel 2h03">4h23</span> |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/bonsai2-prism-ptq1" /> | **160k** | <TokCell shallow="17.9" deep="9.1" cap="mem" /> | 25.5 GB | <ScoreCell value="0.988/0.939" sub="100% completion" top /> | <ScoreCell value="pending" /> | <span title="EvalPlus 4h49 · Mendel —">4h49†</span> |
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | think | budget | Scores | empties | forced | tok/s | wall |
|---|--:|--:|--:|--:|--:|--:|--:|
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/bonsai2-prism-ptq1" />](../setups/kamaji/benchmarks/bonsai-2-27b.md) | 8192 | 16384 | <ScoreCell value="0.988/0.939" sub="100% completion" top /> | none | 10/164 | <TokCell shallow="17.9" deep="9.1" /> | 4h49 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" />](../setups/arrietty/benchmarks/bonsai-2-27b.md) | 8192 | 16384 | <ScoreCell value="0.982/0.945" sub="100% completion" top /> | none | 16/164 | <TokCell shallow="41.7" deep="12.8" /> | 2h20 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" />](../setups/arrietty/benchmarks/bonsai-2-27b.md) | 8192 | 16384 | <ScoreCell value="0.976/0.945" sub="100% completion" /> | none | 12/164 | <TokCell shallow="42.1" deep="22.4" /> | 2h05 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" adapter="refusal-ablation LoRA 1.0" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" />](../setups/arrietty/benchmarks/bonsai-2-27b.md) | 8192 | 16384 | <ScoreCell value="0.976/0.945" sub="100% completion" /> | none | 18/164 | <TokCell shallow="40.8" deep="22.0" /> | 2h32 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="m1-max-32gb" page="/binaries/bonsai2-prism-ptq1" />](../setups/kamaji/benchmarks/bonsai-2-27b.md) | 16056† | 18104 | <ScoreCell value="0.988/0.939" sub="100% completion" /> | none | 7/164 | <TokCell shallow="17.9" deep="9.1" /> | 5h37 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" />](../setups/arrietty/benchmarks/bonsai-2-27b.md) | 30000† | 32048 | <ScoreCell value="0.982/0.945" sub="100% completion" /> | none | 9/164 | <TokCell shallow="41.7" deep="12.8" /> | 4h05 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" adapter="refusal-ablation LoRA 1.0" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" />](../setups/arrietty/benchmarks/bonsai-2-27b.md) | 30000† | 32048 | <ScoreCell value="0.976/0.945" sub="100% completion" /> | none | 10/164 | <TokCell shallow="40.8" deep="22.0" /> | 4h34 |
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" />](../setups/arrietty/benchmarks/bonsai-2-27b.md) | 30000† | 32048 | <ScoreCell value="0.970/0.939" sub="100% completion" /> | none | 6/164 | <TokCell shallow="42.1" deep="22.4" /> | 3h16 |

† not fast mode: a thinking budget other than 8192, or none. Kept for the record; only fast-mode rows compare across models.
<!-- gen:binary-evalplus:end -->

No EvalPlus run yet. Both arms of this file are scheduled in the run
that measured it.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" /> | blind-v1.1 | 128k | **82** | 8/8/done | 88.4 | 15,676k | 127k | 1 | 258 | 17 |  |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" adapter="refusal-ablation LoRA 1.0" kv="f16" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" /> | blind-v1.1 | 128k | **75** | 8/8/done | 82.0 | 17,259k | 127k | 1 | 269 | 15 |  |
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" /> | blind-v1.1 | 256k | **73.5** | 8/8/done | 123.1 | 25,992k | 225k | 0 | 254 | 17 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

Both rows ran without a smoke and before any EvalPlus score of this
file, so the 0.800 gate did not apply to them (owner, 2026-09-18). The
f16 row is the best agent row of this model on this card. Its worst
defect is trap A, a naive `.then()` on `fs.promises.glob()` that
throws; the q8_0 row carried the trap-C exit hook that deletes the
debug manifest, the same defect its sibling file hit at the same cache
type. All 17 commits of the f16 row are `chore`-typed, where every
other row of this model used `fix(...)`.

## Speed and context

Measured on the RTX 5060 Ti 16 GB, the only machine that served this
file.

<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" hide="drafter,kv,effort" />

| measurement | date | config | result |
|---|---|---|---|
| KV pick | 2026-09-18 | q8_0 against f16, ladder from the trained 262144 | q8_0 serves `-c 245760`; f16 aborts on a live CUDA out-of-memory at 147456 and tops out at 139264 |
| Sweep | 2026-09-18 | q8_0, `-c 245760`, no drafter, depths 4096 / 24576 / 65536 / 244736 | 41.7 / 34.9 / 26.5 / 12.8 tok/s, no depth under the floor, VRAM flat 15837 MiB |
| KV ladder | 2026-09-18 | f16, from the trained 262144 | `-c 139264` serves; 147456 aborts on a live CUDA out-of-memory |
| Sweep | 2026-09-18 | f16, `-c 139264`, no drafter, depths 4096 / 24576 / 65536 / 138240 | 42.1 / 37.3 / 30.1 / 22.4 tok/s, no depth under the floor, VRAM flat ~15355 MiB |

The full curves stay in the run kit,
`hardware/arrietty/benchmarks/bench24/results/`.

## Log

- **2026-09-18** — laddered and swept at q8_0 beside the larger
  packing, on the same fork build, in the run that adopted this model.
  Then laddered and swept at f16, and given a blind agent row at each
  cache type. Run kit: `hardware/arrietty/benchmarks/bench24/`.
- **Pending** — an EvalPlus row at each cache type, both scheduled in
  the same run; a mainline llama.cpp row when mainline learns these
  types.
