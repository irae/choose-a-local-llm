# Qwen3.6-35B-A3B NVFP4-MTP (michaelw9999) on RTX 5060 Ti 16 GB

File: [`michaelw9999/Qwen3.6-35B-A3B-NVFP4-MTP-GGUF`](https://huggingface.co/michaelw9999/Qwen3.6-35B-A3B-NVFP4-MTP-GGUF),
`Qwen3.6-35B-A3B-NVFP4-MTP-HQ.gguf`, revision `df112dd`, about 20.5 GB,
an NVFP4 repack with an embedded MTP head. The file never loaded, so
no configuration row and no run exists for it on this machine.

- **Why it is here.** The card runs NVFP4 natively (Blackwell, compute
  capability 12.0), so the first run's list carried an NVFP4 build of
  this model, and this was the only community NVFP4-plus-MTP repack
  named for it.
- **What it settled.** The file does not load. `llama-server` fails
  at `done_getting_tensors` with "wrong number of tensors; expected
  1101, got 1079", independent of `--n-cpu-moe` and of `-c`. The
  loader prints `unused tensor blk.N.nextn.*` warnings for every
  layer, so it sees the MTP tensors but still comes up 22 short of
  what the architecture expects. This is a file and llama.cpp build
  compatibility defect, not a VRAM or ladder condition.
- **Where it stands.** Dropped. The owner's word, 2026-09-14: "a
  popular stable release over a niche build." The unsloth
  `Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf` file serves this model on the card
  instead; see `qwen36-unsloth-ud-q4kxl.md`.

## Configurations

<!-- gen:binary-rows:start -->
No configuration row.
<!-- gen:binary-rows:end -->

No configuration row. The file never reached a served state.

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
No EvalPlus run yet.
<!-- gen:binary-evalplus:end -->

No EvalPlus run yet.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
No Mendel run yet.
<!-- gen:binary-mendel:end -->

No agent run yet.

## Speed and context

No speed measurement exists; the file never loaded.

## Log

- 2026-09-13 — Named in the card's first runbook as the NVFP4-plus-MTP
  build of the 35B-A3B model, the block `sweep-qwen36-nvfp4`.
  `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-14 — Download verified against its recorded revision and
  sha256, file size matches the planned 20.5 GB. The load fails at
  `done_getting_tensors: wrong number of tensors; expected 1101, got
  1079`, tried with and without `--n-cpu-moe` and at `-c` 98304 and
  4096. Not a memory or ladder condition, so the run stops and asks
  instead of retrying. The owner rules out a re-download, since the
  same revision and sha256 would refetch the identical bytes, and
  picks the unsloth `Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf` file instead:
  "a popular stable release over a niche build." The block and its
  downstream smoke, guided and blind rows are skipped for this file.
  `hardware/arrietty/benchmarks/bench17/`.
