# Gemma-4-12B-it Q4_K_XL on M1 Max 32 GB — llama-server benchmarks

Build: llama-server 0.3.0 (build 10621, commit c1d0e7a00), Metal.
Wired limit: `iogpu.wired_limit_mb=27000`.
All runs: temperature 0, `n_predict` 256 unless noted. Fresh server start per config.
MTP works: the unsloth repo ships a separate draft model (`mtp-gemma-4-12b-it.gguf`) and llama-server loads it automatically with `--spec-type draft-mtp`.

## Recommended configuration (result of all tests below)

```bash
llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
  --alias gemma-4-12b-it --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 4 --parallel 1 \
  -ngl 999 -fa on -c 262144 \
  --jinja --port 8081
```

- `--spec-draft-n-max 4` is the peak (45.0 py / 31.3 js tok/s vs 22.3 without MTP, +102% / +41%).
- f16 KV (no `--cache-type-*` flags) is lossless and much faster than q8_0 for Python (+5.5 tok/s).
- Context is **model-limited, not memory-limited**: 256K (the trained maximum) fits in ~14 GB RSS.
- Sub-agent variant: `--parallel 2 -c 524288` gives 2×256K slots at 16.9 GB RSS — both slots at the model maximum.
- Reasoning effort: not applicable — the chat template reports `supports_reasoning_effort: false`.

Base startup command (flags that change per run are shown in each section):

```bash
llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
  --alias gemma-4-12b-it --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 32768 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

Prompts:

- **py**: `Write a Python function that parses ISO dates.`
- **js**: `Write a JavaScript function that deep clones an object.`

## Thinking

Gemma 4 has trained-in binary thinking (`<|think|>`, `enable_thinking` in the chat template, default OFF, no effort levels). All sections below except the one marked "thinking ON" were measured with thinking off (raw `/completion` prompts).

## MTP sweep — thinking ON — chat endpoint, `enable_thinking: true`, 1024 tokens, 32K, f16 KV

| n-max | py tok/s | py accept | js tok/s | js accept |
|---|---|---|---|---|
| **3** | **35.00** | 694/985 (70%) | **35.55** | 700/969 (72%) |
| 4 | 33.34 | 735/1152 (64%) | 33.91 | 739/1135 (65%) |
| 6 | 26.80 | 784/1429 (55%) | 25.92 | 776/1477 (53%) |

Thinking-on peak is n-max 3 (thinking-off peak is n-max 4): thinking text drafts worse, so shallower wins. Mixed-agent guidance: use n=3 for a thinking main-agent server, n=4 for thinking-off sub-agent slots.

## Baseline — no MTP (no `--spec-type` flags)

| prompt | pp tok/s | decode tok/s | draft_n | accepted |
|---|---|---|---|---|
| py | 45.3 | 22.27 | – | – |
| js | 48.6 | 22.16 | – | – |

## MTP sweep — q8_0 KV, 32K context

| n-max | py tok/s | py accept | js tok/s | js accept |
|---|---|---|---|---|
| 1 | 24.26 | 126/129 (98%) | 22.42 | 114/140 (81%) |
| 2 | 24.90 | 167/174 (96%) | 21.91 | 155/198 (78%) |
| 3 | 37.90 | 188/199 (94%) | 31.30 | 174/242 (72%) |
| 4 | 39.49 | 201/216 (93%) | 31.06 | 186/274 (68%) |
| 6 | 36.37 | 215/238 (90%) | 26.53 | 200/327 (61%) |
| 7 | 38.42 | 219/246 (89%) | 27.69 | 205/345 (59%) |

Peak: n-max 4 for Python; js ties between 3 and 4. n-max 4 chosen (best py, js within noise).

## KV cache: q8_0 vs f16 at n-max 4

| KV type | py tok/s | js tok/s |
|---|---|---|
| q8_0 | 39.49 | 31.06 |
| f16 | 44.99 | 31.30 |
| f16 (repeat, same server) | 45.22 | 31.31 |

## Context ramp — n-max 4, f16 KV, short probe (`n_predict` 64)

GGUF metadata: `gemma4.context_length = 262144`, sliding window 1024 on 5 of 6 layers (KV stays small).

| `-c` | slots | result | RSS |
|---|---|---|---|
| 131072 | 1 | OK, 37.5 tok/s | 10.4 GB |
| 262144 | 1 | OK, 35.5 tok/s — model maximum | 12.4 GB |
| 524288 | 2×262144 | OK, MTP active, 37.5 tok/s | 16.9 GB |
| 786432 | 3×262144 | OK, MTP active, 37.1 tok/s | 21.2 GB |
| 1048576 | 4×262144 | Metal OOM (f16 KV) | – |
| 1048576 | 4×262144, **q8_0 KV** | **OK, 33.7 tok/s** | 16.9 GB |

With q8_0 KV (default per KV policy), **four full 256K slots fit** — the best concurrency config on the machine.

No Metal OOM at any size. The model's trained context is the ceiling, not memory.

## Final config validation — n-max 4, f16 KV, `-c 262144`

| prompt | pp tok/s | decode tok/s | draft_n | accepted |
|---|---|---|---|---|
| 4087-token text, `n_predict` 128 | 279.7 | 29.19 | 147 | 89 (61%) |
| py | 50.5 | 44.88 | 216 | 201 (93%) |
| js | 53.2 | 31.20 | 310 | 177 (57%) |

No Metal errors. RSS 14.2 GB after the long prompt — ~17.8 GB left for macOS + DB.

## Comparison with Qwen3.8-27B

| metric | Qwen3.8-27B Q4_K_M | Gemma-4-12B Q4_K_XL |
|---|---|---|
| best decode (py) | 16.8 tok/s | 45.2 tok/s |
| best decode (js) | 15.6 tok/s | 31.3 tok/s |
| best n-max | 3 | 4 |
| pp at 4K prompt | 122.8 tok/s | 279.7 tok/s |
| max context, 1 slot | 96K (memory limit) | 256K (model limit) |
| max context, 2 slots | 2×44K (memory limit) | 2×256K (model limit) |
| RSS at max, 1 slot | 24.1 GB | 12.4 GB |
