# Qwen3.8-27B Q4_K_M (OBLITERATUS)

File: [`OBLITERATUS/Qwen3.8-27B-OBLITERATED`](https://huggingface.co/OBLITERATUS/Qwen3.8-27B-OBLITERATED),
`Qwen3.8-27B-OBLITERATED-Q4_K_M.gguf`, revision `a58c3b5`,
16,810,705,952 bytes (15.66 GiB), the larger quantization of an
abliterated repack of the dense 27B model. Server: llama-server, CUDA,
the prebuilt build named in the setup overview. Every run of this file
on every machine is on this page, retired and superseded rows included;
a run a harness or serving defect voided is not.

- **Why it is here.** The file is larger than the card it was measured
  on, so it cannot serve from VRAM alone. The owner asked what a 16 GB
  card does with it when the window is fixed at 64K and the layers that
  do not fit live in host RAM.
- **What it settled.** Host-RAM offload costs about 4.4 times the speed
  on this card. With 45 of 64 layers on the GPU the file reads 5.13
  tok/s at 4K and 2.31 at about 64K, where the same model's Q3_K_M,
  entirely in VRAM, reads 22.67 and 16.74. No depth reaches the 8 tok/s
  usability floor. Memory was never the limit: VRAM held flat at 13422
  MiB against the run's 13811 MiB cap, so the cost is the transfer of
  19 layers per token, not capacity.
- **Where it stands.** No quality row and no agent row, and none is
  planned on this card: the run ended at its speed gate, because
  scoring a config that already fails the floor would spend most of a
  day. The reference setup holds this file in unified memory with no
  offload at all, which is a different question on a different machine.

## Configurations

<!-- gen:binary-rows:start -->
No configuration row.

Retired entry (RTX 5060 Ti 16 GB): Qwen3.8-27B, GGUF, Q4_K_M (OBLITERATUS, abliterated), q8_0 KV, 19 layers in host RAM, effort medium — the row never reached the 8 tok/s floor; the owner retired the model and deleted both files ([details](../setups/arrietty/qwen38-obliterated-retired.md)).
<!-- gen:binary-rows:end -->

<!-- gen:binary-best-preset:start -->
No server preset: this file is not served by a llama.cpp build.
<!-- gen:binary-best-preset:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
No EvalPlus run yet.
<!-- gen:binary-evalplus:end -->

No EvalPlus run. The run that measured this file ended at its speed
gate before any scoring block.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
No Mendel run yet.
<!-- gen:binary-mendel:end -->

No agent row. The 8 tok/s floor is not reached at any depth, so the
agent task cannot run usefully on this serving config.

## Speed and context

Measured on the RTX 5060 Ti 16 GB, the only machine that served this
file.

<ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="OBLITERATUS" repo="OBLITERATUS/Qwen3.8-27B-OBLITERATED" hide="drafter,kv,effort" />

| measurement | date | config | result |
|---|---|---|---|
| Offload ladder | 2026-09-18 | `-c 65536` fixed, q8_0 KV, a VRAM cap of 13811 MiB | `-ngl 45` of 64 loads at 13397 MiB and holds 13426 MiB under a real 64K request; 47 and 51 go over the cap at load |
| Sweep | 2026-09-18 | q8_0, `-c 65536`, `-ngl 45`, no drafter, depths 4096 / 24576 / 49152 / 64512 | 5.13 / 3.49 / 2.67 / 2.31 tok/s, every depth under the 8 tok/s floor, VRAM flat 13422 MiB |

The full curves stay in the run kit,
`hardware/arrietty/benchmarks/bench25/results/`.

## Server presets

<!-- gen:binary-presets:start -->
No server preset: this file is not served by a llama.cpp build.
<!-- gen:binary-presets:end -->

## Log

- **2026-09-18** — measured with part of its weights in host RAM, under
  a VRAM cap that left 2.5 GB for the system. The run ended at the
  sweep on its speed gate. Run kit:
  `hardware/arrietty/benchmarks/bench25/`.
- **Pending** — nothing on this card. The same file on the reference
  setup, where 32 GB of unified memory holds it without offload, is a
  separate question.
