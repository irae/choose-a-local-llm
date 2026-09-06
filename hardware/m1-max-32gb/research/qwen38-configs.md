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
3. **Reasoning effort: low and xhigh, not medium.** The community
   reports (owner, 2026-09-06) that effort medium is the worst of this
   model's settings for agent work: it thinks too much and does not
   reach a conclusion. Low and xhigh are the two to try. Every scored
   row here ran medium (the llama blind 87 included) or low on the MLX
   build, and the MTP acceptance sweep on the report page shows medium
   only as the fastest decode. The owner also pointed at
   https://www.youtube.com/watch?v=dHK90xc9Q64; its transcript,
   fetched and condensed, is `qwen38-configs/video-dHK90xc9Q64.md`.
   That video says nothing about effort levels; it covers quant and
   context on 32 GB Macs (4-bit MLX holds 32K at 15.8 tok/s, 19.2 GB;
   llama.cpp issue 27756, a silent end-of-sequence past about 130K
   context on this model), which feeds candidate 2. The trial:
   the Mendel smoke on the llama f16 row at low and at xhigh, then the
   blind run at whichever passes with the fewer nudges, against the
   medium row's 87. Run 11 holds no Qwen3.8 block; the deferred EvalPlus
   at medium and the guided run wait for this item's answer, because
   the effort level decides which config is worth scoring.
4. **The OOM-at-load threshold.** Moved to `no-oom-at-mendel.md`,
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
