# Gemma-4-26B-A4B (MoE) on M1 Max 32 GB

llama-server (build 10621) · unsloth UD-Q4_K_XL + MTP draft · benchmarked
2026-08-25 · `iogpu.wired_limit_mb=25000`

## Summary

The MoE big sibling of Gemma-12B does everything its family does, faster.
Under the current wired limit of **25000** the **full 256K trained window
still fits on one slot** — but only with q8_0 KV (f16 now OOMs). q8 costs js
speed: draft acceptance falls from 81% to 68%, so js decodes at ~53 tok/s vs
py's 62-68. Two slots reach **2×184K**. Thinking (binary, default off) costs
only ~3 tok/s. Quality gate (EvalPlus) pending.

**62 / 53 tok/s** (py/js) with q8_0 KV at MTP n=2 · **256K** full model
window on one slot · **2×184K** on two slots · **19.3 GB** RSS at 256K.

## Which to pick for a coding task

| need | config | tok/s | context |
|---|---|--:|--:|
| **Max context** | llama-server + MTP n=2, q8_0 KV, 1 slot | 62.4 / 53.3 | 256K |
| **Max js speed** | f16 KV at small context (32K) | 74.8 / 71.6 | 32K |
| **Two agents** | `--parallel 2 -c 376832`, q8_0 KV | 58.4 / 56.5 single-stream | 2×184K |

Single agent — one 256K slot, q8_0 KV (pi id `gemma-4-26b-a4b`):

```bash
llama-server -hf unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL \
  --alias gemma-4-26b-a4b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 2 --parallel 1 \
  -ngl 999 -fa on -c 262144 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

Two concurrent agents — 2×184K slots, q8_0 KV (pi id `gemma-4-26b-a4b-2x`):

```bash
llama-server -hf unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL \
  --alias gemma-4-26b-a4b-2x --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 2 --parallel 2 \
  -ngl 999 -fa on -c 376832 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

q8_0 KV is now required for the full window (f16 OOMs at limit 25000) and it
lowers js draft acceptance (81% → 68%), so js decodes at ~53 tok/s. py keeps
62-68. Thinking: binary `enable_thinking` (trained-in `<|think|>`, default
off, no effort levels); speed numbers here were measured with thinking off.

## MTP draft depth sweep (32K, f16 KV)

Thinking ON (chat endpoint, `enable_thinking: true`, 1024 tokens):

| --spec-draft-n-max | py tok/s | py accept | js tok/s | js accept |
|---|--:|--:|--:|--:|
| **2** | **71.88** | **84%** | **69.25** | **78%** |
| 3 | 67.94 | 74% | 64.90 | 69% |
| 4 | 63.97 | 69% | 61.00 | 65% |

Thinking OFF (sub-agent / fast mode): peak 74.8 py / 71.6 js, also at n-max 2
— thinking costs only ~3 tok/s. Full thinking-off tables in
[the benchmarks](../benchmarks/gemma-4-26b-a4b.md).

## Context (n-max 2, q8_0 KV, limit 25000 — current)

| -c | slots | result | RSS |
|---|---|---|--:|
| 262,144 | 1 (f16 KV) | Metal OOM — f16 no longer fits | – |
| **262,144** | **1** | **OK, 62.4/53.3 tok/s — full window (256-tok verified)** | **19.3 GB** |
| 327,680 | 2×160K | OK, 67.6/52.7 tok/s | 20.1 GB |
| **376,832** | **2×184K** | **OK, 58.4/56.5 tok/s — two-slot max (256-tok verified)** | **20.4 GB** |
| 385,024 | 2×188K | Metal OOM | – |
| 393,216 | 2×192K | Metal OOM | – |

At the retired 27000 limit, f16 KV held the full 256K single slot (21.6 GB
RSS) and q8 reached 2×192K. A deep-fill decode check is pending.

## Decode speed vs used context (depth sweeps, limit 25000)

| depth | llama+MTP q8 | MLX (gemma-4-26b-a4b-it-4bit) |
|---|--:|--:|
| 4K | 23.5 | 51.1 |
| 16K | 11.2 | 43.5 |
| 24.5K | 7.97 — under the 8 tok/s floor | 39.6 |
| 33K | | 35.6 |
| 49K | | 28.8 |
| 74K | | 22.2 |
| 82K | | 20.6 |
| ~98K | | Metal OOM — ceiling 82-98K |

llama is capped by speed (~24K floor); MLX is capped by memory (82-98K) and
stays fast the whole way — 13.5 GB RSS at 74K. The MLX config is the
fast-and-deep contender for the main-agent seat, quality pending (night 3).

---

Method: warmup before every measurement; identical prompts across models;
temp 0. Raw numbers in
[the benchmarks](../benchmarks/gemma-4-26b-a4b.md). Cross-model picks on
[the comparison page](../comparison.md).
