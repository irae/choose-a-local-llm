# Finding the best local coding model for your machine

A repeatable process to answer, for one specific computer: **which local
model, runtime, and configuration should I code with?** Everything runs
against OpenAI-compatible servers that a coding harness can actually use.

## What this project measures

- **Usable speed at real session depth, not benchmark speed.** Decode speed
  falls as the context fills. A model that benchmarks at 60 tok/s can crawl
  at 2 tok/s mid-session.
- **Context that fits the machine while it stays a desktop.** Memory
  footprints are measured so the Mac remains usable while a model serves.
- **Quality per quantization.** Published scores cover full-precision
  models. What you run is a quant. One score per model and thinking
  mode; runtimes at standard quants share it.
- **A pick per use, not a single winner.** Models are used in more
  than one way, and the data is kept so each use can be read from it.

Every config gets a KV cache pick, a decode-vs-used-context sweep and an
honest "capped by" verdict: speed floor, memory OOM, or model window. The
usability floor here is 8 tok/s. EvalPlus gates every config; Mendel
ranks the survivors.

Read [the methodology](./methodology.md) before running anything. The
flow is binding.

## Setups

### M1 Max, 32 GB

Apple Silicon, wired limit 25000 MB. Five models, three runtimes:
llama-server, mlx_lm.server, and the PrismML llama.cpp fork. LM Studio
was tried and retired.
Depth sweeps and EvalPlus scores are complete for every model; two
models have finished the agent task. The rule: MLX runtimes barely slow
down but hit hard memory ceilings; llama runtimes hold their speed
deeper at f16 KV, and their ceiling is the largest `-c` that loads.

<!-- gen:models-evaluated:start -->
| Config | Max ctx | Gated by¹ | tok/s¹ | EvalPlus² | Coding³ |
|---|--:|:--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="xhigh" top /> | 72k | mem | <TokCell shallow="11.8" deep="8.6" /> | <ScoreCell value="0.957/0.939" sub="96% completion" top /> | <ScoreCell value="93" pill="mendel-blind" top /> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" top /> | 82k | speed | <TokCell shallow="43.7" deep="13.0" top-deep /> | <ScoreCell value="0.939/0.921" sub="97% completion" top /> | <ScoreCell value="83" pill="mendel-guided" top /> |
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" top /> | 147k | speed | <TokCell shallow="14.1" deep="8.3" stale /> | <ScoreCell value="0.945/0.921" sub="97% completion" top /> | <ScoreCell value="80.5" pill="mendel-blind" top /> |
| <ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" /> | 104k | mem | <TokCell shallow="15.8" deep="10.3" stale /> | <ScoreCell value="0.988/0.927" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" /> | **197k** | mem | <TokCell shallow="60.3" deep="17.3" stale top-shallow top-deep /> | <ScoreCell value="0.884/0.860" sub="89% completion" /> | <ScoreCell value="47.5" pill="mendel-blind" /> |
| <ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" /> | **245k** | mem | <TokCell shallow="24.64" deep="8.86" stale /> | <ScoreCell value="0.976/0.939" sub="100% completion" top /> | <ScoreCell value="37.5" note="38%" pill="mendel-guided" /> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" /> | 58k | mem | <TokCell shallow="24.5" deep="17.3" stale top-deep /> | <ScoreCell value="0.915/0.884" sub="97% completion" /> | <ScoreCell value="37.5" note="38%" pill="mendel-blind" /> |
| <ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" /> | 33k | speed | <TokCell shallow="14.8" deep="7.9" stale /> | <ScoreCell value="0.927/0.890" sub="98% completion" /> | <ScoreCell value="31.5" note="38%" pill="mendel-guided" /> |
| <ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" /> | 28k | mem | <TokCell shallow="17" deep="15.3" stale top-deep /> | <ScoreCell value="0.976/0.927" sub="100% completion" top /> | <ScoreCell value="12.5" note="13%" pill="mendel-blind" /> |
| <ModelSpec base="Qwen3.6-35B-A3B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.6-35B-A3B-4bit" kv="f16" effort="on" /> | 41k | mem | <TokCell shallow="55.1" deep="37.4" stale top-shallow top-deep /> | <ScoreCell value="0.939/0.921" sub="97% completion" top /> | <ScoreCell value="pending" /> |
| <ModelSpec base="Gemma-4-26B-A4B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/gemma-4-26b-a4b-it-4bit" kv="f16" effort="on" /> | 70k | mem | <TokCell shallow="51" deep="12.8" stale top-shallow /> | <ScoreCell value="0.713/0.701" sub="72% completion" /> | <ScoreCell value="pending" /> |

† from an earlier serving config or method; re-run pending.
<!-- gen:models-evaluated:end -->

¹ Whichever limit hits first: the max memory a config fits in, the max
context that stays usable — usable meaning at or above the 8 tok/s floor —
or the model's own trained window, when neither of the other two arrives.
tok/s is that same decode speed, shallow near an empty context, then deep
at max ctx.

² Scored once per model and thinking mode; runtimes serving the same
model at a standard quant share the score. Aggressive quants (for
example the prism fork's calibrated q4 KV) do not share — they pass the
gate separately.

³ Coding: the Mendel score of that config at that thinking level, out
of 100, one real repository task with known traps; the pill names the
test, blind or guided, and the cell shows the config's run with the
most libraries done, then the higher score. A muted percentage before
the score is the share of libraries done when the run did not finish,
`invalid` when every attempt was. Rows sort by the
average of the EvalPlus base score and this one; a row with only one
of the two sorts after every row with both.

⁴ LM Studio's MLX engine — the only runtime that loads this model's
`gemma4_unified` architecture. It is retired on that machine; see
[why](./setups/m1-max-32gb/lmstudio-retired.md).

⁵ PrismML's llama.cpp fork, an approved exception to the no-forks rule.

See [the measurement rules](./methodology/context-creep) for why a slow
creep is more realistic than a fast sweep.

"Memory (at max ctx)" is the wired GPU memory the config holds at max ctx.

| model | report | benchmarks |
|---|---|---|
| Qwen3.6-35B-A3B (MoE) | [report](./setups/m1-max-32gb/reports/qwen3.6-35b-a3b.md) | [data](./setups/m1-max-32gb/benchmarks/qwen3.6-35b-a3b.md) |
| Gemma-4-26B-A4B (MoE) | [report](./setups/m1-max-32gb/reports/gemma-4-26b-a4b.md) | [data](./setups/m1-max-32gb/benchmarks/gemma-4-26b-a4b.md) |
| Gemma-4-12B-it | [report](./setups/m1-max-32gb/reports/gemma-4-12b-it.md) | [data](./setups/m1-max-32gb/benchmarks/gemma-4-12b-it.md) |
| Ternary Bonsai-27B | [report](./setups/m1-max-32gb/reports/bonsai-27b.md) | [data](./setups/m1-max-32gb/benchmarks/bonsai-27b.md) |
| Qwen3.8-27B | [report](./setups/m1-max-32gb/reports/qwen3.8-27b.md) | [data](./setups/m1-max-32gb/benchmarks/qwen3.8-27b.md) |

Also on this setup: the [comparison page](./setups/m1-max-32gb/comparison.md)
with the full depth and quality tables, the
[setup overview](./setups/m1-max-32gb/index.md) with the machine
configuration, and
[historical measurements](./setups/m1-max-32gb/historical.md) taken under
retired memory limits.

### More setups

A PC with an NVIDIA GPU comes next: Bonsai on the CUDA builds of the prism
fork, and lower quants of the other models. It gets the same shape — setup
overview, comparison, reports, benchmarks.

## Why this exists

This site is the worked example for one machine, but the process applies to
any box: substitute your memory budget and your candidates.

The reason the depth axis matters more than any published benchmark: a real
coding session here measured 1.7 tok/s at 135K used tokens, on a config whose
near-empty benchmark said 62 tok/s. Context maxima alone are storage, not
speed. So every config is swept against *used* context until it drops under
the usability floor or runs out of memory, and the floor — not the window —
sets the harness compaction threshold.

Published quality scores have the same problem. They cover full-precision
weights, and what fits on a desktop is a quant, so quality is measured on
the quant actually served. Narrow differences between runtimes' standard
quants do not count: one score per model and thinking mode covers them.
Aggressive or calibrated quants get their own gate.
