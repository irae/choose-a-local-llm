# Qwen3.6-35B-A3B (MoE) on M1 Max 32 GB — llama-server benchmarks

MoE: 35B total parameters, ~3B active per token. Trained context 262144 (GGUF metadata `qwen35moe.context_length`). MTP embedded in unsloth's MTP-GGUF build. Base-model reference: 73.4 SWE-bench Verified.
Model: `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` (~20 GB).
Build: llama-server 0.3.0 (build 10621). Temperature 0, `n_predict` 256, warmup before every measurement. Same prompts as the other models (py = ISO dates, js = deep clone).

## Recommended configuration

```bash
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 212992 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

Two agents: same command with `--parallel 2 -c 196608` and alias `qwen3.6-35b-a3b-2x` (2×96K).

## MTP sweep — 32K context, f16 KV

| n-max | py tok/s | py accept | js tok/s | js accept |
|---|---|---|---|---|
| off (baseline) | 52.34 | – | 52.41 | – |
| 2 | 67.75 | 162/184 (88%) | 70.67 | 75/80 (94%) |
| **3** | **68.21** | 181/220 (82%) | **73.53** | 84/93 (90%) |
| 4 | 63.53 | 189/260 (73%) | 69.42 | 88/108 (81%) |

Peak at n-max 3. Short-prompt pp 62–93 tok/s (vs ~22 for dense Qwen3.8 — the MoE + newer kernels are far healthier).

## Context ramp — n-max 3, f16 KV, short probe (`n_predict` 64), warmup first

| `-c` | result | rss |
|---|---|---|
| 49152 | OK, 66.3 tok/s | 22.8 GB |
| 65536 | OK, 67.6 tok/s | 23.2 GB |
| 81920 | OK, 68.0 tok/s | 23.5 GB |
| 98304 | OK, 67.2 tok/s | 23.7 GB |
| 131072 | OK, 67.8 tok/s | 24.3 GB |
| **139264** | **OK, 65.5 tok/s — max** | 24.5 GB |
| 147456 | Metal OOM | – |
| 163840 | Metal OOM | – |
| 196608 | Metal OOM | – |

f16 max single-session context: 136K at ~65 tok/s, 24.5 GB RSS. KV is very light (~19 KB/token); the ceiling comes from the ~20 GB weights. Decode speed is flat across the whole context range.

## Context — q8_0 KV (the default per KV policy)

| `-c` | slots | result | rss |
|---|---|---|---|
| 196608 | 1 | OK, 67.2 tok/s | – |
| **212992** | 1 | **OK, 63.6 tok/s — max (208K)** | 24.1 GB |
| 229376 | 1 | Metal OOM | – |
| 262144 | 1 | Metal OOM | – |
| **196608** | 2×96K | **OK, 66.5 tok/s — two-slot config** | 24.2 GB |

**Max single-session: 208K (q8_0 KV)**; two slots: **2×96K** (higher untested). f16 alternatives: 136K / 2×64K.

## Multi-slot

| `-c` | slots | result | rss |
|---|---|---|---|
| 131072 | 2×64K | OK, 67.0 tok/s — two-slot max | 23.5 GB |
| 139264 | 2×68K | Metal OOM | – |

## Reasoning control

The chat template has no `reasoning_effort` (unlike Qwen3.8) — only binary `enable_thinking`
(default on). Disable with `--chat-template-kwargs '{"enable_thinking":false}'`.

## Pending

- EvalPlus quality gate (night runs).
