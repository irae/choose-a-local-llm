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
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-ptq1" top /> | **240k** | <TokCell shallow="41.7" deep="12.8" cap="mem" top-shallow top-deep /> | **15.5 GB** | <ScoreCell value="pending" /> | <ScoreCell value="pending" /> | — |
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
No EvalPlus run yet.
<!-- gen:binary-evalplus:end -->

No EvalPlus run yet.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
No Mendel run yet.
<!-- gen:binary-mendel:end -->

No agent row yet.

## Speed and context

Measured on the RTX 5060 Ti 16 GB, the only machine that served this
file.

<ModelSpec base="Ternary-Bonsai-2-27B" quant="PTQ1_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" hide="drafter,kv,effort" />

| measurement | date | config | result |
|---|---|---|---|
| KV pick | 2026-09-18 | q8_0 against f16, ladder from the trained 262144 | q8_0 serves `-c 245760`; f16 aborts on a live CUDA out-of-memory at 147456 and tops out at 139264 |
| Sweep | 2026-09-18 | q8_0, `-c 245760`, no drafter, depths 4096 / 24576 / 65536 / 244736 | 41.7 / 34.9 / 26.5 / 12.8 tok/s, no depth under the floor, VRAM flat 15837 MiB |

The full curves stay in the run kit,
`hardware/arrietty/benchmarks/bench24/results/`.

## Log

- **2026-09-18** — laddered and swept beside the larger packing, on the
  same fork build, in the run that adopted this model. Run kit:
  `hardware/arrietty/benchmarks/bench24/`.
- **Pending** — an EvalPlus row and an agent row, so the pair with the
  larger packing can be read; a mainline llama.cpp row when mainline
  learns these types.
