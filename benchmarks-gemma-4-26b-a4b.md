# Gemma-4-26B-A4B (MoE) on M1 Max 32 GB — llama-server benchmarks

MoE: 26B total parameters, ~4B active per token. Trained context 262144. MTP via separate draft (`mtp-gemma-4-26B-A4B-it.gguf`, ~460 MB), auto-loaded by llama-server.
Model: `unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL` (~14.2 GB).
Build: llama-server 0.3.0 (build 10621). Temperature 0, `n_predict` 256, warmup before every measurement. Same prompts as the other models. Thinking: binary `enable_thinking` in the chat template (trained-in `<|think|>` token, default OFF, no effort levels). All speed numbers below were measured with thinking off (raw `/completion` prompts).

## Recommended configuration

```bash
llama-server -hf unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL \
  --alias gemma-4-26b-a4b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 2 --parallel 1 \
  -ngl 999 -fa on -c 262144 \
  --jinja --port 8081
```

Two agents: `--parallel 2 -c 262144` (2×128K slots).

## MTP sweep — thinking ON — chat endpoint, `enable_thinking: true`, 1024 tokens, 32K, f16 KV

| n-max | py tok/s | py accept | js tok/s | js accept |
|---|---|---|---|---|
| **2** | **71.88** | 640/766 (84%) | **69.25** | 624/797 (78%) |
| 3 | 67.94 | 706/951 (74%) | 64.90 | 690/999 (69%) |
| 4 | 63.97 | 750/1088 (69%) | 61.00 | 737/1142 (65%) |

Peak stays at n-max 2. Thinking costs only ~3 tok/s vs thinking-off.

## MTP sweep — thinking OFF — raw `/completion`, 256 tokens, 32K, f16 KV

| n-max | py tok/s | py accept | js tok/s | js accept |
|---|---|---|---|---|
| **2** | **74.81** | 162/184 (88%) | **71.59** | 157/195 (81%) |
| 3 | 74.81 | 182/219 (83%) | 70.92 | 177/231 (77%) |
| 4 | 73.78 | 195/239 (82%) | 66.95 | 189/264 (72%) |

Peak at n-max 2 (n=3 ties on py, loses on js). Short-prompt pp 86–117 tok/s. No-MTP baseline not measured (skipped — the sweep already brackets the gain pattern seen on every other model).

## Context ramp — n-max 2, f16 KV, short probe (`n_predict` 64), warmup first

| `-c` | slots | result | rss |
|---|---|---|---|
| 131072 | 1 | OK, 68.0 tok/s | 19.3 GB |
| **262144** | 1 | **OK, 67.8 tok/s — trained maximum** | 21.6 GB |
| 262144 | 2×128K | OK, 68.2 tok/s — max for 2 slots | 21.9 GB |
| 327680 | 2×160K | Metal OOM | – |
| 393216 | 2×192K | Metal OOM | – |
| 524288 | 2×256K | Metal OOM | – |

Model-limited at one slot (full 256K window fits with ~10 GB to spare). Decode speed is flat across context sizes. Speed at 256K (67.8) vs 32K (74.8): the small drop comes from the bigger working set, not KV depth.

## Two-slot with q8_0 KV (the default per KV policy)

| `-c` | slots | result | rss |
|---|---|---|---|
| **393216** | 2×192K | **OK, 63.3 tok/s — two-slot config** | 20.6 GB |
| 524288 | 2×256K | loads but Metal errors during decode — invalid | – |

f16 two-slot max was 2×128K. Single-slot stays f16 (model-limited at 256K; q8 buys nothing).

## Pending

- EvalPlus quality gate (night runs).
