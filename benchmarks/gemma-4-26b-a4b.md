# Gemma-4-26B-A4B (MoE) on M1 Max 32 GB — llama-server benchmarks

MoE: 26B total parameters, ~4B active per token. Trained context 262144. MTP via separate draft (`mtp-gemma-4-26B-A4B-it.gguf`, ~460 MB), auto-loaded by llama-server.
Model: `unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL` (~14.2 GB).
Build: llama-server 0.3.0 (build 10621). Temperature 0, `n_predict` 256, warmup before every measurement. Same prompts as the other models. Thinking: binary `enable_thinking` in the chat template (trained-in `<|think|>` token, default OFF, no effort levels). All speed numbers below were measured with thinking off (raw `/completion` prompts).

## Recommended configuration (at `iogpu.wired_limit_mb=25000`)

```bash
llama-server -hf unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL \
  --alias gemma-4-26b-a4b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 2 --parallel 1 \
  -ngl 999 -fa on -c 262144 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

Two agents: same command with `--parallel 2 -c 376832` and alias
`gemma-4-26b-a4b-2x` (2×184K).

## Context at `iogpu.wired_limit_mb=25000` (current, 2026-08-25)

At the old 27000 limit the full 256K window fit with f16 KV. At 25000 it needs
q8_0 KV — so q8 now buys context on this model too.

| `-c` | slots | kv | result | rss |
|---|---|---|---|---|
| 262144 | 1 | f16 | Metal OOM | – |
| **262144** | 1 | q8_0 | **OK, 62.4/53.3 tok/s (256-tok verify) — full window** | 19.3 GB |
| 327680 | 2×160K | q8_0 | OK, 67.6/52.7 tok/s | 20.1 GB |
| 360448 | 2×176K | q8_0 | OK, 65.9/52.4 tok/s | 20.3 GB |
| **376832** | 2×184K | q8_0 | **OK, 58.4/56.5 tok/s (256-tok verify) — two-slot max** | 20.4 GB |
| 385024 | 2×188K | q8_0 | Metal OOM | – |
| 393216 | 2×192K | q8_0 | Metal OOM | – |

**q8 KV costs js speed on this model**: js draft acceptance falls from 81% (f16)
to 68% (q8), so js decode drops from ~72 to ~53 tok/s. py is unaffected
(90% acceptance, 62-68 tok/s). A deep-fill decode check is pending.

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

## Context ramp — n-max 2, f16 KV, short probe (`n_predict` 64), warmup first (historical: `iogpu.wired_limit_mb=27000`)

| `-c` | slots | result | rss |
|---|---|---|---|
| 131072 | 1 | OK, 68.0 tok/s | 19.3 GB |
| **262144** | 1 | **OK, 67.8 tok/s — trained maximum** | 21.6 GB |
| 262144 | 2×128K | OK, 68.2 tok/s — max for 2 slots | 21.9 GB |
| 327680 | 2×160K | Metal OOM | – |
| 393216 | 2×192K | Metal OOM | – |
| 524288 | 2×256K | Metal OOM | – |

Model-limited at one slot (full 256K window fits with ~10 GB to spare). Decode speed is flat across context sizes. Speed at 256K (67.8) vs 32K (74.8): the small drop comes from the bigger working set, not KV depth.

## Two-slot with q8_0 KV (historical: `iogpu.wired_limit_mb=27000`)

| `-c` | slots | result | rss |
|---|---|---|---|
| **393216** | 2×192K | **OK, 63.3 tok/s — two-slot config** | 20.6 GB |
| 524288 | 2×256K | loads but Metal errors during decode — invalid | – |

f16 two-slot max was 2×128K. Single-slot stays f16 (model-limited at 256K; q8 buys nothing).

## Pending

- EvalPlus quality gate (night runs).

## Depth sweeps (limit 25000, 2026-08-28)

| depth | llama+MTP q8 (128K alloc) | mlx (`gemma-4-26b-a4b-it-4bit`) |
|---|---|---|
| 4K | 23.5 | 51.1 |
| 16K | 11.2 | 43.5 |
| 24.5K | 7.97 — below the 8 tok/s floor | 39.6 |
| 33K | – | 35.6 |
| 49K | – | 28.8 |
| 74K | – | 22.2 |
| 82K | – | 20.6 |
| ~98K | – | Metal OOM — **ceiling 82-98K** |

llama floor ~24K (speed). **MLX is the deepest fast curve measured in the
whole project**: 22+ tok/s at 74K, RSS 13.5 GB, ceiling not yet found.
Quality on MLX is unscored (the EvalPlus history is llama-side; thinking-mode
convergence issues noted in night2/calibration.md apply to the model, not the
runtime).
