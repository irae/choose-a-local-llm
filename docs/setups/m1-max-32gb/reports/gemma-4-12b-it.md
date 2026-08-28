# Gemma-4-12B-it + MTP on M1 Max 32 GB

llama-server (Metal, build 10621) · unsloth Q4_K_XL · benchmarked 2026-08-25

## Summary

**Decode: 35.0 py / 35.6 js tok/s with thinking on** (45.2 / 31.3 thinking
off, the sub-agent mode) with MTP and lossless f16 KV. Unlike Qwen3.8-27B,
context is **model-limited, not memory-limited**: the full trained window of
**256K tokens** fits in ~14 GB RSS, leaving ~18 GB free. Four agent slots at
the full 256K each fit with q8_0 KV (16.9 GB).

**35.0 / 35.6 tok/s** thinking on (45.2 / 31.3 off) · MTP depth **n-max 3
thinking on, 4 off** · **256K** full model context fits · **4×256K** on four
slots with q8_0 KV.

**Which to pick:** one config rules all three categories — max context (256K,
the trained window), max speed, and it needs no compromise to get there. No
MLX variant tested (llama-server already saturates this model's speed). Four
256K slots hit Metal OOM — 3 is the maximum at full window. pi model ids:
`gemma-4-12b` / `gemma-4-12b-3x`.

Single agent — one 256K slot, q8_0 KV:

```bash
llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
  --alias gemma-4-12b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 4 --parallel 1 \
  -ngl 999 -fa on -c 262144 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

The speed numbers on this page were measured with f16 KV, which was +5.5 py
tok/s on this model; q8_0 is now the default on every config per the KV
policy. A re-probe under the current wired limit is pending.

Four concurrent agents — 4×256K slots, q8_0 KV (16.9 GB RSS, 33.7 tok/s, MTP
active; pi id `gemma-4-12b-4x`; f16 alternative: 3×256K):

```bash
llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
  --alias gemma-4-12b-4x --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 4 --parallel 4 \
  -ngl 999 -fa on -c 1048576 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

## MTP sweep — thinking ON

Chat endpoint, `enable_thinking: true`, 1024 tokens. The optimum shifts to
n-max 3 with thinking (thinking text drafts worse). Mixed-agent guidance: n=3
for a thinking main-agent server, n=4 for thinking-off sub-agent slots.

| --spec-draft-n-max | py tok/s | py accept | js tok/s | js accept |
|---|--:|--:|--:|--:|
| **3** | **35.00** | **70%** | **35.55** | **72%** |
| 4 | 33.34 | 64% | 33.91 | 65% |
| 6 | 26.80 | 55% | 25.92 | 53% |

## Thinking OFF (sub-agent / fast mode)

Peak: **45.2 py / 31.3 js tok/s** at n-max 4 with f16 KV (22.3 without MTP).
KV finding: lossless f16 beat q8_0 (+5.7 tok/s py) — f16 is used everywhere.
MTP uses the separate `mtp-gemma-4-12b-it.gguf` draft from the unsloth repo.
Full thinking-off sweep and KV tables are in
[the benchmarks](../benchmarks/gemma-4-12b-it.md).

## Context (n-max 4, f16 KV)

| -c | slots | result | RSS |
|---|---|---|--:|
| 131,072 | 1 | OK | 10.4 GB |
| **262,144** | **1** | **OK — trained maximum, validated with 4K-token prompt** | **12.4 GB** |
| **524,288** | **2×256K** | **OK — MTP active on both slots** | **16.9 GB** |

No Metal OOM at any size. GGUF metadata: trained context 262,144; sliding
window 1024 on 5 of every 6 layers, so KV grows only ~1 GB per 64K tokens.
The ceiling is the model, not the 32 GB machine. Context limits are
mode-independent (KV is preallocated by `-c`); probe speeds were measured
thinking-off.

## Cross-model comparison

Speed, context, and concurrency across all tested models live on
[the comparison page](../comparison.md). Thinking: Gemma 4 has trained-in
reasoning (`<|think|>`), toggled by `enable_thinking` in the chat template —
binary on/off, **default off**, no graded effort levels. All speed numbers
here were measured with thinking off.

## Decode speed vs used context (depth sweeps, limit 25000)

| depth | llama+MTP q8 | LM Studio MLX engine (lms CLI, port 1234) |
|---|--:|--:|
| 4K | 14.0 | 36.7 |
| 8K | 9.0 | |
| 16K | 6.8 — under the 8 tok/s floor | 36.9 |
| 33K / 49K | | 34.8 / 33.1 |
| 74K / 98K | | 30.8 / 28.6 |
| 131K / 147K | | 26.1 / **25.1 — ceiling still not found** |

llama floors at ~11K; LM Studio's engine (the only working MLX path — mlx-lm
lacks the `gemma4_unified` type) runs the **deepest and flattest usable curve
of the whole project**: 25+ tok/s at 147K, no OOM found, 8.8 GB RSS at 74K.
Model: `lmstudio-community/gemma-4-12B-it-MLX-4bit`; serve with `lms server
start --port 1234` + `lms load ... --gpu max`. Quality unscored (night 3).

---

Method: fresh server start per configuration; identical curl per run;
temperature 0. Full raw numbers in
[the benchmarks](../benchmarks/gemma-4-12b-it.md).
