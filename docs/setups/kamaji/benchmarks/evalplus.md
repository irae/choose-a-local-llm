# EvalPlus (HumanEval+) — M1 Max 32 GB

The quality gate: pass@1 at temperature 0, output budget calibrated per
model — see [the method](../../../methodology/evalplus). Scores are shared
across serving configs when thinking mode, effort, and quant match.

These runs are shallow, a few thousand tokens each, so the KV cache type
does not move a score and the rows name it only where it is part of the
quant, as the fork's calibrated q4_0 KV is. Each model page names the KV
type its config serves.

<!-- gen:evalplus-table:start -->
| config | budget | pass@1 base | pass@1 plus | empty | completion |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" />](./qwen3.8-27b.md) | 8192 | **0.982** | 0.939 | 0/164 | 100% |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" />](./qwen3.8-27b.md) | 8192 | **0.976** | 0.945 | 1/164 | 99% |
| [<ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" />](./qwen3.8-27b.md) | 8886 | **0.988** | 0.927 | 0/164 | 100% |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" />](./qwen3.8-27b.md) | 8192 | **0.976** | 0.933 | 1/164 | 99% |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" />](./qwen3.8-27b.md) | 30000 | **0.945** | 0.921 | 5/164 | 97% |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" />](./qwen3.6-35b-a3b.md) | 26624 | 0.939 | 0.921 | 5/164 | 97% |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" />](./qwen3.6-35b-a3b.md) | 8192 | **0.951** | 0.915 | 0/164 | 100% |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" />](./bonsai-27b.md) | 10240 | 0.927 | 0.890 | 4/164 | 98% |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" />](./bonsai-27b.md) | 10240 | 0.915 | 0.884 | 5/164 | 97% |
| [<ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" />](./gemma-4-12b-it.md) | 8192 | **0.976** | 0.939 | 0/164 | 100% |
| [<ModelSpec base="Gemma-4-12B" quant="4-bit" server="lms" publisher="lmstudio-community" repo="lmstudio-community/gemma-4-12B-it-MLX-4bit" kv="f16" effort="off" />](./gemma-4-12b-it.md) | 30000 | 0.909 | 0.872 | 0/164 | 100% |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" />](./gemma-4-26b-a4b.md) | 8192 | **0.976** | 0.945 | 0/164 | 100% |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" />](./gemma-4-26b-a4b.md) | 30000 | 0.884 | 0.860 | 18/164 | 89% |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/gemma-4-26b-a4b-it-4bit" kv="f16" effort="on" />](./gemma-4-26b-a4b.md) | 30000 | 0.713 | 0.701 | 46/164 | 72% |
| [<ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="xhigh" />](./qwen3.8-27b.md) | 30000 | **0.957** | 0.939 | 6/164 | 96% |
<!-- gen:evalplus-table:end -->

An empty completion is reasoning that exhausted the output budget; a
high empty rate is a real model limit, not a harness bug. Completion
is the share of the 164 problems that got an answer at all. Read the
two columns together: a low score with a low completion rate measures
delivery, not code quality — the withdrawn Gemma-4-12B thinking-on row
passed 99% of the answers it gave and never answered 37% of the
problems ([historical](../historical.md)). Raw runs and per-problem
results live in the repo's `benchmarks/` run kits; each model's data
page (first column) carries its scoring notes.
