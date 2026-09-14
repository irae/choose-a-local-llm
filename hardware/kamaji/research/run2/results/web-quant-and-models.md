# Web research — containers, quantization, new models (2026-09-03)

Sources gathered by a web-research sub-agent. Leads, not verified
truth. The new-model figures came partly from secondary sources —
verify every model card before shortlisting.

## Container correctness on M1 Max

- K-quants (Q4_K_M, Q5_K_M) are the quality-per-bit default on Apple
  GPUs. IQ-quants use codebook lookups that Apple GPUs run ~3.5x
  slower. https://github.com/ggml-org/llama.cpp/discussions/5617
- Q4_0 online repacking targets the CPU ARM NEON path, not Metal;
  value for GPU-only runs unconfirmed — measure.
  https://github.com/ggml-org/llama.cpp/pull/9921
- M1 has no native bf16 (M2+ does): prefer fp16 paths on M1 Max
  (speculative — verify).
- Instruction sets: M1 Max supports NEON `dotprod`, NOT `i8mm`
  (arrived with M2). Check `sysctl -a | grep hw.optional`.
- Templates: dump a GGUF's embedded template with `gguf_dump.py`
  (`tokenizer.chat_template`); MLX repos carry it in
  `tokenizer_config.json`. Wrong template = broken tool-call parsing
  and leaked thinking text. Gemma has no official tool role — stock
  template breaks tool calls
  (https://huggingface.co/unsloth/gemma-3-27b-it-qat-GGUF/discussions/2);
  Qwen 3.x needs `--jinja` for think tags, community-fixed templates
  exist (https://huggingface.co/froggeric/Qwen-Fixed-Chat-Templates).
- Overrides: llama-server `--jinja`, `--chat-template-file <path>`;
  LM Studio: My Models → gear → Prompt Template.
- KV cache: Q4 KV causes large silent output drift (8.3% output match
  vs 81.6% at Q8 in one 7B measurement). Q8 or full precision only.
- Pin exact HF revisions: quant makers replace files silently
  (Unsloth swapped builds 2026-08-19 and invalidated benchmarks).

## MLX quantization quality

- CONFIRMED bad conversions exist: all HF mlx-community Gemma-4
  quants reported broken because Per-Layer Embedding layers got
  quantized; fix repo `FakeRocket543/mlx-gemma4`.
  https://huggingface.co/mlx-community/gemma-4-e2b-4bit/discussions/1
- Check the `config.json` quantization block (bits, group_size,
  per-layer overrides) against a known-good reference before trusting
  any MLX download.
- Bit width dominates quality (8-bit near-lossless, 4-bit +0.5 PPL,
  3-bit large loss); group size 32 vs 64 is secondary; mixed
  precision on embeddings/lm_head matters most.
  https://n8programs.substack.com/p/an-examination-of-mlx-quantization
- Better local quant recipe:
  `mlx_lm.convert --hf-path <org/model> -q --q-bits 4
  --q-group-size 32 --quant-predicate mixed_4_6`.
- Advanced: `mlx_lm.dwq` (distillation against an fp teacher, biggest
  reported gain) and `mlx_lm.dynamic_quant`.
  https://github.com/ml-explore/mlx-lm/blob/main/mlx_lm/LEARNED_QUANTS.md

## New model candidates (32 GB unified memory, coding/agentic)

1. GLM-4.7-Flash — 30B-A3B MoE, MIT. Same active-param class as
   Qwen3.6-35B-A3B, reported strong agentic gains.
   https://huggingface.co/unsloth/GLM-4.7-Flash-GGUF
2. Meta Muse Glimmer 30B — 29.6B dense, Apache 2.0, OFFICIAL GGUF and
   MLX releases. https://huggingface.co/meta-models/Muse-Glimmer-30B
3. Poolside Laguna XS 2.1 — 33.4B total / 3B active MoE, OpenMDW-1.1.
   Built for long-horizon agent coding; check llama.cpp support
   first. https://huggingface.co/poolside/Laguna-XS-2.1
4. Mistral Devstral Small 2 — 24B dense, Apache 2.0; smaller, leaves
   RAM headroom for context.
   https://huggingface.co/mistralai/Devstral-Small-2-24B-Instruct-2512

Researcher's own confidence note: some 2026-specific figures came
from secondary sources and one arXiv citation looked mismatched —
verify cards directly.
