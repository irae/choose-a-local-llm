# Ternary-Bonsai-2-27B PQ2_0 (prism-ml, prism fork)

File: [`prism-ml/Ternary-Bonsai-2-27B-gguf`](https://huggingface.co/prism-ml/Ternary-Bonsai-2-27B-gguf),
`Ternary-Bonsai-2-27B-PQ2_0.gguf`, revision `6ed5e12`, 7,206,168,928
bytes (6.71 GiB), a ternary GGUF in the packed 2-bit layout.
Server: the PrismML llama.cpp fork (`prism-llama`), release
`prism-b10685-7dffb15`, commit `7dffb158d`, CUDA 12.8. Every run of
this file on every machine is on this page, retired and superseded rows
included; a run a harness or serving defect voided is not.

- **Why it is here.** Stock llama.cpp rejects `PQ2_0` and `PTQ1_0` as
  unknown types and makes garbage from a `Q2_0` file, because it has no
  Hadamard activation runtime. The publisher's fork is the only path to
  this file. The binary is one release behind `latest`: the newer tag
  shipped Windows DLLs only while its Linux CUDA asset was still
  building. A different fork release is a different serving stack, so
  the build id belongs in every row of this page.
- **What it settled.** Ternary weights change what a 16 GB card holds.
  At 6.71 GiB of weights the KV cache becomes the large allocation, and
  the card serves `-c 212992` at q8_0, against 65536 for every 12 GiB
  27B build on the same machine. f16 stops at 122880. The sweep found
  no speed ceiling at all: 46.0 tok/s at 4K down to 14.5 at 211968,
  every cell above the 8 tok/s floor, VRAM flat at 15735 MiB.
- **Where it stands.** EvalPlus 0.982/0.939 with no empty answer, the
  best quality gate on this card. The blind agent row scored 60 with a
  CRITICAL worst defect, and it is the first row in this project where
  the task itself went past 64K: peak context 192679 of a 208896
  window, 92.2%, zero compactions. A guided row and a cheaper fixed
  thinking budget are pending.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" top /> | **208k** | mem | <TokCell shallow="46.0" deep="14.5" top-shallow top-deep /> | **15.4 GB** | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | <ScoreCell value="60" pill="mendel-blind" top /> | <span title="EvalPlus 2h56 · Mendel 1h32">4h29</span> |
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" />](../setups/arrietty/benchmarks/bonsai-2-27b.md) | 27257 | <ScoreCell value="0.982/0.939" sub="100% completion" top /> | none | <TokCell shallow="46.0" deep="14.5" /> | 2h56 |
<!-- gen:binary-evalplus:end -->

The scored run carries a server thinking budget of 25209 tokens
(answer budget 2048, `max_tokens` 27257), derived from a calibration
whose longest converged reasoning ran 16806 tokens. No answer is empty
and none ends on `length`. Seven problems hit the budget and were
forced to answer; three passed. The four that failed hit the
30000-token cap unconverged in the natural re-run, so no forced answer
was late and the budget needed no correction.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" kv="q8_0" effort="xhigh" hardware="rtx-5060ti-16gb" page="/binaries/bonsai2-prism-pq2" /> | blind-v1.1 | 208k | **60** | 8/8/done | 92.4 | 19,572k | 193k | 0 | 245 | 16 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

The blind row ended `complete`, with 16 commits, no repetition loop and
no nudge, so its 60 is judgment and not a harness failure. The worst
defect is CRITICAL: an exit hook added in
`packages/mendel-development/validate-manifest.js` removes the
temporary directory, so the debug manifest the code has just printed is
deleted before a reader can open it. Trap B was missed, no dependency
pruning happened at all, and Prettier was left failing on `TASKS.md`.

## Speed and context

Measured on the RTX 5060 Ti 16 GB, the only machine that served this
file.

<ModelSpec base="Ternary-Bonsai-2-27B" quant="PQ2_0" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-2-27B-gguf" hide="drafter,kv,effort" />

| measurement | date | config | result |
|---|---|---|---|
| KV pick | 2026-09-17 | q8_0 against f16, ladder from the trained 262144 | q8_0 serves `-c 212992`, f16 `-c 122880`; 262144 fails to allocate |
| Sweep | 2026-09-17 | q8_0, `-c 212992`, no drafter, depths 4096 / 24576 / 65536 / 211968 | 46.0 / 38.2 / 28.2 / 14.5 tok/s, no depth under the floor, VRAM flat 15735 MiB |
| Smoke | 2026-09-18 | window 208896, effort xhigh | pass: 12 calls, 1 commit, clean tree, no loop, 0 compactions, 37 s |

The full curves stay in the run kit,
`hardware/arrietty/benchmarks/bench24/results/`.

## Log

- **2026-09-17** — the model was published the same day and the owner
  put it in front of the queue. The fork binary was taken as a release
  asset and proven with one real request before any measurement; no
  source build was needed or attempted. Both KV types were laddered and
  the file was swept to its deepest servable depth. Run kit:
  `hardware/arrietty/benchmarks/bench24/`.
- **2026-09-18** — calibration at effort xhigh, then EvalPlus under the
  derived thinking budget, the natural re-run of its forced failures,
  the smoke and the blind agent row. Run kit:
  `hardware/arrietty/benchmarks/bench24/`.
- **Pending** — a guided agent row to pair with the blind 60; a fixed
  thinking budget against the derived 25209, as the 3-bit build tested
  8192 against the cap; a mainline llama.cpp row when mainline learns
  these types, because a mainline binary is preferable to a fork.
