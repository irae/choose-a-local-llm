# Qwen3.8-27B: find a configuration that finishes agent work

Status: draft 2026-09-05. Needs hardware: yes, one Mendel smoke per
candidate.

The best single-turn score on this hardware never completed a Mendel
run (five attempts, four partial, one invalid; the report page opens
with it, `docs/setups/m1-max-32gb/reports/qwen3.8-27b.md`). Run 9 gave
its llama row f16 KV and 49K, and run 10 block B passed the Mendel
smoke on that row (8 tool calls, one clean commit, 62 s), so the row
gets a Mendel blind run in run 10. Before the model retires from the
daily-driver question, this item tries, in order, and stops at the
first that yields a completed run:

1. **Vision off.** A video on this model
   (https://www.youtube.com/watch?v=0xUxO_9zqTU, diagrams only, read
   the transcript) says dropping the vision tower frees memory. Our
   llama command already passes `--no-mmproj`; check whether the MLX
   container and LM Studio still load the tower, and what the GGUF
   saves with and without it at the same `-c`.
2. **Alternative quants, GGUF first.** GGUF takes every flag we use
   (KV type, drafter, slots, no vision); MLX takes none of them. List
   community GGUF builds of this model at 3-bit and at other 4-bit
   recipes, with their proof, and compute the context each buys from
   run 9's KV cost per token. A 3-bit build that reaches 96K at 12
   tok/s beats a 4-bit build at 49K for agent work.
3. **The OOM-at-load threshold.** Moved to `no-oom-at-mendel.md`,
   which holds the llama fit findings (`--fit` is off whenever `-ngl`
   is set by hand; `-ub` sizes the compute buffer; `llama-fit-params`
   projects without a server).

## What is already known

- `kv-quant-on-m1.md`: the model is dense, 48 DeltaNet layers without
  KV and 16 full-attention layers at 64 KiB of KV per token; no lookup
  tables (those belong to the Flash-Next variant). A quantized KV
  cache is slow here because of llama.cpp's decode-time attention
  kernel, not the chip; a q4_0 KV trial is a Qwen-only experiment
  (int4 KV breaks Gemma 4 past about 950 tokens).
- The MLX row's window problem is `backlog/qwen38-mlx-window.md` and
  `no-oom-at-mendel.md`; the MLX server has no memory bound and no
  quantized KV.

Each candidate goes through the Mendel smoke on the llama row; a pass
becomes a bench item. Research publishes no number.
