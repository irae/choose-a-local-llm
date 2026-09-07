# Research item — a 10 GB agent model for personal assistant harnesses

Status: draft 2026-09-06. Needs hardware: yes, the M1 Max for a slow creep and one tool-call smoke on three to five candidates.

The coding models under test take 15 to 25 GB and keep the coding seat. A personal assistant harness (Hermes Agent, OpenClaw) needs a second model that runs beside them, or alone all day, in about 10 GB: weights plus a large KV cache. Coding quality is secondary. The model must follow instructions, emit correct tool calls on every turn, recall long context, and stay above 8 tok/s at depth. The desk part below leaves only Mac measurements open.

## Candidates

Scope: released between 2025-09-06 and 2026-09-06, 4B to 14B parameters, a 64K or larger trained context. Sizes are the GGUF file on disk as the repository lists them. Benchmarks come from the vendor card unless the source column says otherwise.

| Model | Released | Params | Architecture | KV per token, f16 | Trained ctx | GGUF sizes | MLX | Tool calls in template | Tool-use scores | Long-context scores |
|---|---|---|---|---|---|---|---|---|---|---|
| Qwen3.5-9B | 2026-02 | 9B dense | Hybrid: 24 Gated DeltaNet layers + 8 full-attention layers (GQA 16 q / 4 kv, head 256) | 32 KiB (8 layers) | 262,144 | Q4_K_M 5.68 GB, UD-Q4_K_XL 5.97 GB, Q8_0 9.53 GB (unsloth) | mlx-community 4bit, 8bit; lmstudio-community 4bit | Yes, Hermes-style `<tool_call>` XML; thinking off by default on the small series | BFCL-V4 66.1, TAU2-Bench 79.1 | LongBench v2 55.2, AA-LCR 63.0 |
| Qwen3.5-4B | 2026-02 | 4B dense | Same layout as the 9B, hidden 2560 (GQA 16 q / 4 kv, head 256) | 32 KiB (8 layers) | 262,144 | Q4_K_M 2.74 GB, UD-Q4_K_XL 2.91 GB, Q8_0 4.48 GB (unsloth) | mlx-community | Yes, same template as the 9B | BFCL-V4 50.3, TAU2-Bench 79.9, IFEval 89.8 | LongBench v2 50.0, AA-LCR 57.0 |
| Gemma-4-E4B-it | 2026-07-30 | 4.5B effective, 8B with embeddings, dense | 42 layers: 35 sliding (512 window) + 7 global; the last 18 layers share KV, so 4 global layers own a cache (GQA 8 q / 2 kv, global head 512) | 16 KiB (4 layers, sharing on); 28 KiB if the runtime allocates all 7 | 131,072 | Q4_K_M 4.98 GB, Q8_0 8.19 GB (unsloth) | mlx-community 4bit (mlx-lm issue #1242 open at the time of the search), lmstudio-community 4bit | Yes, native function calling; thinking off by default | Tau2 airline 52.0, retail 67.1, telecom 18.4; IFEval 96.7 (tech report table 5). No BFCL published | MRCR v2 128K 25.4 |
| Gemma-4-12B-it | 2026-07-30 | 12B dense | 48 layers: 40 sliding (1024 window) + 8 global; global layers use 1 kv head of 512 | 16 KiB (8 layers) | 262,144 | Q4_K_M 7.12 GB, UD-Q4_K_XL 7.37 GB (unsloth); QAT UD-Q4_K_XL 6.72 GB | lmstudio-community 4bit; mlx-lm lacks `gemma4_unified` (this project's index page) | Yes, native | Tau2 airline 75.0, retail 77.6, telecom 54.4; IFEval 97.2 (tech report). No BFCL published | MRCR v2 128K published for 31B only (66.4) |
| LFM2.5-8B-A1B | 2026-05-28 (blog) | 8.3B total, 1.5B active, MoE (32 experts, 4 active) | 24 layers: 18 gated conv + 6 GQA attention (32 q / 8 kv, head 64) | 12 KiB (6 layers) | 128,000 | Q4_K_M 5.16 GB, Q5_K_M 6.03 GB, Q8_0 9.01 GB (LiquidAI) | Vendor MLX build | Yes, pythonic list between `<\|tool_call_start\|>` and `<\|tool_call_end\|>` | BFCL v3 64.4, BFCL v4 48.5, Tau2 telecom 88.1, retail 39.8; IFEval 91.8 | 128K window; no recall score published |
| Granite-4.1-8B-instruct | 2026-04-29 | 8B dense | 40 layers, all full attention (GQA 32 q / 8 kv, head 128) | 160 KiB | 131,072 in the config (IBM says 512K for the 8B) | Q4_K_M 5.35 GB, UD-Q4_K_XL 5.49 GB, Q8_0 9.35 GB (unsloth) | Not found | Yes, `--jinja` required; unsloth ships template fixes | BFCL v3 68.3 (IBM) | Not published |
| Ministral-3-8B-Instruct-2512 | 2025-12-02 | 8B dense + 0.4B vision | 34 layers, all full attention (GQA 32 q / 8 kv, head 128), no sliding window | 136 KiB | 262,144 | Q4_K_M 5.2 GB, Q8_0 9.03 GB (unsloth) | mlx-community 4bit (mlx-vlm) | Yes, native function calling, `mistral` parser | Not published per size | Not published |
| Ministral-3-14B-Instruct-2512 | 2025-12-02 | 13.5B dense + 0.4B vision | 40 layers, all full attention (GQA 32 q / 8 kv, head 128) | 160 KiB | 262,144 | Q4_K_M 8.24 GB, Q5_K_M 9.62 GB (mistralai) | mlx-community 4bit | Yes, native | Arena Hard 0.551, WildBench 68.5; no BFCL | Not published |

Out of scope, with the reason:

- NVIDIA-Nemotron-Nano-12B-v2 (2025-08-29): eight days before the window. 8 attention layers of 62, 32 KiB per token, BFCL v3 66.98. A good shape; it stays a reserve if the window moves.
- Nemotron-3-Nano-30B-A3B, GLM-4.7-Flash, Trinity-Mini: 26B to 30B total, above the class.
- Qwen3.6: no 4B to 14B member found on the Hub. Qwen3.8-9B is a community distillation, not a Qwen release.
- Hermes-4-14B (2025-08-26): before the window, and a dense Qwen3-14B base at 160 KiB per token.

## Context that fits in 10 GB

Method. KV per token at f16 = layers that own a cache × kv heads × head dim × 2 (K and V) × 2 bytes. q8_0 in llama.cpp stores 34 bytes per 32 values, so q8_0 per token = f16 per token × 0.53. The budget is 10,240 MB. Fixed overhead is 1,000 MB: compute buffers, the sliding-window and linear-attention state, and scratch. That value comes from this machine: Gemma-4-12B UD-Q4_K_XL measured 10.4 GB at `-c 131072` (`../../../docs/setups/m1-max-32gb/benchmarks/gemma-4-12b-it.md`), and 10,400 − 7,370 (weights) − 2,048 (131,072 × 16 KiB) = 982 MB. Context = (10,240 − weights − 1,000) × 1024 / KiB per token, then the trained context caps it. MB and KiB are binary units here; the repository file sizes are taken as listed.

| Model, quant | Weights MB | KV MB left | f16 KiB/token | Context at f16 | q8_0 KiB/token | Context at q8_0 | Verdict |
|---|--:|--:|--:|--:|--:|--:|---|
| Qwen3.5-9B Q4_K_M | 5,680 | 3,560 | 32 | 3,560 × 1024 / 32 = 113,920 | 17 | 214,437 | Fits: 64K at f16 with room |
| Qwen3.5-4B Q4_K_M | 2,740 | 6,500 | 32 | 6,500 × 1024 / 32 = 208,000 | 17 | 391,529 → 262,144 trained | Fits: trained window at q8_0, 208K at f16 |
| Gemma-4-E4B-it Q4_K_M | 4,980 | 4,260 | 16 | 4,260 × 1024 / 16 = 272,640 → 131,072 trained | 8.5 | 131,072 trained | Fits: trained window at f16. Without KV sharing (28 KiB) still 155,794 |
| Gemma-4-12B-it UD-Q4_K_XL | 7,370 | 1,870 | 16 | 1,870 × 1024 / 16 = 119,680 | 8.5 | 225,280 | Fits: 64K at f16 with room; measured 10.4 GB at 131,072 |
| LFM2.5-8B-A1B Q4_K_M | 5,160 | 4,080 | 12 | 4,080 × 1024 / 12 = 348,160 → 128,000 trained | 6.4 | 128,000 trained | Fits: trained window at f16 |
| Granite-4.1-8B Q4_K_M | 5,350 | 3,890 | 160 | 3,890 × 1024 / 160 = 24,896 | 85 | 46,863 | Fails 64K at both KV types |
| Ministral-3-8B Q4_K_M | 5,200 | 4,040 | 136 | 4,040 × 1024 / 136 = 30,419 | 72 | 57,458 | Fails 64K at both KV types |
| Ministral-3-14B Q4_K_M | 8,240 | 1,000 | 160 | 1,000 × 1024 / 160 = 6,400 | 85 | 12,047 | Fails |

Two rules from this machine apply on top of the arithmetic. First, q8_0 KV costs 2 to 4 microseconds per cached token on llama-server here against 0.2 to 0.3 for f16 (`kv-quant-on-m1.md`), so every candidate that reaches 64K at f16 runs at f16; the q8_0 column is for the record. Second, the five models that fit all reach 64K at f16, so the pick turns on tool-call reliability and decode speed at depth, not on memory.

## Known issues per candidate

- Qwen3.5-9B and 4B, llama.cpp. Issue #20837 (open): with thinking on, the 9B writes the tool call inside the think block and stops; thinking off fixes it. Issues #21158 and #22684 (tool call text in `reasoning_content`, PEG parser failures with text before `<tool_call>`) closed in 2026-03 and 2026-06; the project build 10621 is later than both. Issue #20704: slow multimodal decode on an M2, so serve with `--no-mmproj`. MTP draft on Metal is a net loss at every setting (issue #23752); do not add the drafter. Cache reuse on the hybrid layout needs an exact prefix: a change in an earlier message re-prefills the whole prompt on both llama-server and mlx_lm.server, which a harness with a stable system prompt tolerates. MLX: mlx-community 4bit and 8bit exist; secondary reports give 25 to 35 tok/s on M-series at shallow depth, none on an M1 Max.
- Gemma-4-E4B, llama.cpp. Issue #21468: cache reuse is not supported for the models with shared KV layers, so every request re-prefills the full prompt. For an agent turn with a 10K token system prompt that is the whole cost of the turn. The peg-gemma4 tool-call issues #21375, #22786, #25072 closed between 2026-05 and 2026-08. Unless #21468 is closed before the run, E4B goes last. mlx-lm: issue #1242 on the mlx-community E4B conversion.
- Gemma-4-12B. No shared KV layers, so cache reuse works, and this project already runs it with `--jinja` on build 10621. Thinking on is a pitfall on both backends (report page). The LM Studio engine loops in multi-turn tool work (comparison page). MLX serving is LM Studio only.
- LFM2.5-8B-A1B, llama.cpp. Issue #23838 (open at the search): the server tool parser rejects the documented `<|tool_call_start|>[f(x)]<|tool_call_end|>` output with a 500; the detection function looks for `<|tool_list_start|>`. The pythonic format is not the OpenAI JSON shape, so the harness depends on the parser. Vendor speed claim: 253 tok/s on an M5 Max at MLX. No M1 figure.
- Granite-4.1-8B. `--jinja` required; unsloth template fixes. Older Granite 4 issues #16415 (template detection) and #16465 (crash on `:` or `\u` in tool arguments) are from 2025. Excluded by the memory arithmetic anyway.
- Ministral 3. Mistral tokenizer regex issues in llama.cpp recur per family (issues #15594, #18706); the official GGUF repositories carry the templates. Excluded by the memory arithmetic.

## What the harnesses need

Hermes Agent: any OpenAI-compatible `/v1/chat/completions` endpoint; a minimum of 64,000 tokens of context, refused at startup below that; `--jinja` on llama-server, without it the tools parameter is ignored and the model prints tool calls as text; native tool calls preferred, with a generic text handler as fallback. The system prompt and tool schemas take 4K to 8K tokens and go out on every call, so prompt-cache reuse decides the turn latency. The Mac guide starts from Qwen3.5-9B Q4_K_M at `-c 131072` with q4_0 KV; this project keeps f16 for the speed reason above.

OpenClaw: OpenAI-compatible chat completions; its llama.cpp recipes use a 65,536 context and an 8,192 output budget, config examples go to 120K to 196K. The context page example shows a system prompt of about 9,600 tokens, of which tool schemas are about 8,000 and bootstrap files (AGENTS.md, SOUL.md, TOOLS.md, IDENTITY.md, USER.md, MEMORY.md) about 6,000; bootstrap injection caps at 60,000 characters. A model must pass the setup tool check, or OpenClaw does not select it; verify tool support in `/props`. The provider maps thinking-off to the Qwen template flag. Guides recommend reasoning off for Qwen.

So the pick must hold at least 64K, keep 10K tokens of prefix cached across turns, and answer the OpenAI tools API with a parsed `tool_calls` field. All five fitting candidates meet the first on paper; the second rules out E4B while #21468 stands; the third is what the smoke measures.

## Mac procedure

Serve four candidates, in this order: Qwen3.5-9B, Gemma-4-12B, LFM2.5-8B-A1B, Qwen3.5-4B. Add Gemma-4-E4B only if llama.cpp issue #21468 is closed in the installed build. Wired limit 24000, machine prepared as the checklist says, one server at a time, log to a file.

1. Start the server. `-c` is the computed f16 limit rounded down to a multiple of 4096, or the trained window.

   ```bash
   llama-server -hf unsloth/Qwen3.5-9B-GGUF:Q4_K_M \
     --alias qwen3.5-9b --no-mmproj --parallel 1 \
     -ngl 999 -fa on -c 110592 \
     --cache-type-k f16 --cache-type-v f16 \
     --jinja --port 8081
   ```

   ```bash
   llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
     --alias gemma-4-12b --no-mmproj --parallel 1 \
     -ngl 999 -fa on -c 118784 \
     --cache-type-k f16 --cache-type-v f16 \
     --jinja --port 8081
   ```

   ```bash
   llama-server -hf LiquidAI/LFM2.5-8B-A1B-GGUF:Q4_K_M \
     --alias lfm2.5-8b --parallel 1 \
     -ngl 999 -fa on -c 126976 \
     --cache-type-k f16 --cache-type-v f16 \
     --jinja --port 8081
   ```

   ```bash
   llama-server -hf unsloth/Qwen3.5-4B-GGUF:Q4_K_M \
     --alias qwen3.5-4b --no-mmproj --parallel 1 \
     -ngl 999 -fa on -c 204800 \
     --cache-type-k f16 --cache-type-v f16 \
     --jinja --port 8081
   ```

   ```bash
   llama-server -hf unsloth/gemma-4-E4B-it-GGUF:Q4_K_M \
     --alias gemma-4-e4b --no-mmproj --parallel 1 \
     -ngl 999 -fa on -c 131072 \
     --cache-type-k f16 --cache-type-v f16 \
     --jinja --port 8081
   ```

2. Verify the load with one real completion and read wired memory. Record the wired MB; it must be at or under 10,240 at `-c`. If it is over, the overhead assumption is wrong for that model: halve `-c` once and record the new value beside the row.
3. Run the slow creep, raw completion path (`../../../docs/methodology/context-creep.md`):

   ```bash
   DEPTH_LIST=4096,8192,16384,24576,32768,49152,65536,81920,98304 \
   MODEL=<alias> SWEEP_BASE=http://127.0.0.1:8081 \
   python3 tools/sweeps/creep_llama.py > /tmp/<alias>-creep.tsv 2>&1
   ```

   Extend `DEPTH_LIST` to the `-c` in 16K steps for the models above 98304. Read the verdict from the last line. The published number is the deepest clean row.
4. Run one tool-call smoke against the chat path, thinking off, temperature 0:

   ```bash
   curl -s http://127.0.0.1:8081/v1/chat/completions -H 'Content-Type: application/json' -d '{
     "model": "<alias>", "temperature": 0, "max_tokens": 256,
     "chat_template_kwargs": {"enable_thinking": false},
     "tools": [{"type": "function", "function": {"name": "get_weather",
       "description": "Current weather for one city",
       "parameters": {"type": "object", "properties": {"city": {"type": "string"}},
         "required": ["city"]}}}],
     "messages": [{"role": "system", "content": "You are a personal assistant. Use tools when they apply."},
       {"role": "user", "content": "What is the weather in Lisbon right now?"}]
   }'
   ```

   Pass: `choices[0].message.tool_calls[0].function.name` is `get_weather`, its `arguments` parse as JSON with `city` equal to `Lisbon`, `finish_reason` is `tool_calls`, and `content` holds no raw tool markup. Record the raw response beside the verdict.
5. Pass rules per candidate: 8 tok/s or more at 65,536 used tokens on the creep, and a pass on the smoke. Record the ceiling too. EvalPlus and Mendel do not apply; the harness on the other machine runs the real agent turn afterwards.
6. Write the rows into a bench block under `../benchmarks/` and close this item with the pick.

## Sources

- Qwen3.5-9B card and config: https://huggingface.co/Qwen/Qwen3.5-9B, https://huggingface.co/Qwen/Qwen3.5-9B/raw/main/config.json
- Qwen3.5-4B card and config: https://huggingface.co/Qwen/Qwen3.5-4B, https://huggingface.co/Qwen/Qwen3.5-4B/raw/main/config.json
- Qwen3.5 GGUF sizes and settings: https://huggingface.co/unsloth/Qwen3.5-9B-GGUF, https://huggingface.co/unsloth/Qwen3.5-4B-GGUF, https://unsloth.ai/docs/models/qwen3.5
- Qwen3.5 MLX: https://huggingface.co/mlx-community/Qwen3.5-9B-MLX-4bit, https://huggingface.co/lmstudio-community/Qwen3.5-9B-MLX-4bit
- Gemma 4 model card and tech report: https://ai.google.dev/gemma/docs/core/model_card_4, https://arxiv.org/html/2607.02770v1
- Gemma 4 configs: https://huggingface.co/google/gemma-4-E4B-it/raw/main/config.json, https://huggingface.co/google/gemma-4-12B-it/raw/main/config.json
- Gemma 4 GGUF and MLX: https://huggingface.co/unsloth/gemma-4-E4B-it-GGUF, https://huggingface.co/unsloth/gemma-4-12b-it-GGUF, https://unsloth.ai/docs/models/gemma-4, https://huggingface.co/mlx-community/gemma-4-e4b-it-4bit, https://github.com/ml-explore/mlx-lm/issues/1242
- LFM2.5-8B-A1B: https://huggingface.co/LiquidAI/LFM2.5-8B-A1B, https://huggingface.co/LiquidAI/LFM2.5-8B-A1B-GGUF, https://www.liquid.ai/blog/lfm2-5-8b-a1b
- Granite 4.1: https://research.ibm.com/blog/granite-4-1-ai-foundation-models, https://huggingface.co/ibm-granite/granite-4.1-8b/raw/main/config.json, https://huggingface.co/unsloth/granite-4.1-8b-GGUF, https://unsloth.ai/docs/models/ibm-granite-4.1
- Ministral 3: https://huggingface.co/mistralai/Ministral-3-14B-Instruct-2512, https://huggingface.co/mistralai/Ministral-3-14B-Instruct-2512-GGUF, https://huggingface.co/unsloth/Ministral-3-8B-Instruct-2512-GGUF, https://huggingface.co/mistralai/Ministral-3-8B-Instruct-2512/raw/main/config.json
- Nemotron Nano 12B v2: https://huggingface.co/nvidia/NVIDIA-Nemotron-Nano-12B-v2
- llama.cpp issues: https://github.com/ggml-org/llama.cpp/issues/20837, https://github.com/ggml-org/llama.cpp/issues/21158, https://github.com/ggml-org/llama.cpp/issues/22684, https://github.com/ggml-org/llama.cpp/issues/20704, https://github.com/ggml-org/llama.cpp/issues/23752, https://github.com/ggml-org/llama.cpp/issues/21468, https://github.com/ggml-org/llama.cpp/issues/21375, https://github.com/ggml-org/llama.cpp/issues/22786, https://github.com/ggml-org/llama.cpp/issues/25072, https://github.com/ggml-org/llama.cpp/issues/23838, https://github.com/ggml-org/llama.cpp/issues/16415, https://github.com/ggml-org/llama.cpp/issues/16465
- Hermes Agent: https://hermes-agent.nousresearch.com/docs/guides/local-llm-on-mac, https://hermes-agent.nousresearch.com/docs/integrations/providers, https://github.com/NousResearch/hermes-agent/pull/18265
- OpenClaw: https://docs.openclaw.ai/gateway/local-models, https://docs.openclaw.ai/plugins/llama-cpp, https://docs.openclaw.ai/concepts/context, https://docs.openclaw.ai/reference/token-use
- Apple Silicon speed, secondary: https://willitrunai.com/blog/qwen-3-5-mlx-apple-silicon-guide, https://github.com/marcofariasmx/local-llm-apple-silicon
- This project: `../../../docs/setups/m1-max-32gb/benchmarks/gemma-4-12b-it.md`, `kv-quant-on-m1.md`
