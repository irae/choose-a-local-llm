# Gemma-4-26B-A4B (MoE) on M1 Max 32 GB

llama-server (build 10621) · unsloth UD-Q4_K_XL + MTP draft · benchmarked
2026-08-25 · `iogpu.wired_limit_mb=24000`

## Highlights

- **The full 256K trained window fits on one slot**, in 19.3 GB.
- **The fastest depth curve measured on this machine**, on MLX: 51 tok/s at
  4K, still 12.8 at 70K (ceiling), in 20.0 GB.
- **Fastest Python decode of the llama configs**: 62 tok/s.
- **Two agents at 184K each** on one weight copy.
- **Thinking is nearly free**: it costs only ~3 tok/s.
- Weak point: on llama it crosses the 8 tok/s floor at ~24K. The depth
  belongs to its MLX build, not its llama build.
- Weak point: EvalPlus 0.713/0.701, 46/164 (~28%) empty. Its thinking mode
  often never converges — the worst convergence rate of any scored model
  here.

## Best option

**MLX for depth and speed** — the fast-and-deep contender for the main-agent
seat, quality now scored (0.713/0.701, see below). **llama-server for
window size** — the only way to get the full 256K, and the only way to get
two slots.

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

## Which to pick for a coding task

| need | config | tok/s | context |
|---|---|--:|--:|
| **Max context** | llama-server + MTP n=2, q8_0 KV, 1 slot | 62.4 / 53.3 | 256K |
| **Max js speed** | f16 KV at small context (32K) | 74.8 / 71.6 | 32K |
| **Two agents** | `--parallel 2 -c 376832`, q8_0 KV | 58.4 / 56.5 single-stream | 2×184K |

## Quality — EvalPlus HumanEval+

| config scored | pass@1 base | pass@1 plus | empty completions |
|---|--:|--:|--:|
| mlx_lm.server 4-bit, thinking on, budget 30000 | 0.713 | 0.701 | 46/164 (~28%) |

Score is shared with the llama+MTP config at the same quant (both serve the
same weights).

## Decode speed vs used context (llama at limit 25000, 2026-08-28; mlx re-tested at limit 24000, slow creep, 2026-08-29)

| depth | llama+MTP q8 | MLX (gemma-4-26b-a4b-it-4bit) |
|---|--:|--:|
| 4K | 23.5 | 51.1 |
| 16K | 11.2 | 43.5 |
| 24.5K | 7.97 — under the 8 tok/s floor | 39.6 |
| 33K | | 35.6 |
| 49K | | 28.8 |
| 60K | | 24.96 |
| 62K | | 13.44 |
| 64K | | 23.91 |
| 66K | | 13.07 |
| 68K | | 23.08 |
| **70K** | | **12.83 — last stable, limit 24000** |
| ~72K | | Metal OOM — ceiling ~70-72K at limit 24000 |

llama RSS at floor depth (24.5K, q8_0 KV, 32K alloc): 15.4 GB.

## Context (n-max 2, q8_0 KV, limit 24000 — current)

| -c | slots | result | RSS |
|---|---|---|--:|
| 262,144 | 1 (f16 KV) | Metal OOM — f16 no longer fits | – |
| **262,144** | **1** | **OK, 62.4/53.3 tok/s — full window (256-tok verified)** | **19.3 GB** |
| 327,680 | 2×160K | OK, 67.6/52.7 tok/s | 20.1 GB |
| **376,832** | **2×184K** | **OK, 58.4/56.5 tok/s — two-slot max (256-tok verified)** | **20.4 GB** |
| 385,024 | 2×188K | Metal OOM | – |
| 393,216 | 2×192K | Metal OOM | – |

## MTP draft depth sweep (32K, f16 KV)

Thinking ON (chat endpoint, `enable_thinking: true`, 1024 tokens):

| --spec-draft-n-max | py tok/s | py accept | js tok/s | js accept |
|---|--:|--:|--:|--:|
| **2** | **71.88** | **84%** | **69.25** | **78%** |
| 3 | 67.94 | 74% | 64.90 | 69% |
| 4 | 63.97 | 69% | 61.00 | 65% |

Thinking OFF (sub-agent / fast mode): peak 74.8 py / 71.6 js, also at n-max 2.
Full thinking-off tables in
[the benchmarks](../benchmarks/gemma-4-26b-a4b.md).

## History and reasoning

**q8_0 KV is now mandatory, and it costs JavaScript speed.** Under the
current 24000 wired limit, f16 KV no longer fits the full window at all. q8
lowers js draft acceptance from 81% to 68%, so js decodes at ~53 tok/s while
py keeps 62-68. The retired 27000 limit allowed more on both counts; those
figures are on
[the historical page](../historical.md).

**llama is capped by speed; MLX is capped by memory.** The llama build floors
at ~24K, which makes its 256K window mostly storage. The MLX build stays fast
the whole way to ~68K, then swings between ~13 and ~24 tok/s at 62-70K before
OOMing at ~72K (limit 24000, slow-creep sweep, 2026-08-29; 20.0 GB gfx-resident
at the last stable depth). For actual deep work, MLX is the config that
matters; the llama window is what you use when you need to *hold* a lot of
context rather than decode quickly through it.

**Thinking is binary here.** Gemma 4 has trained-in reasoning
(`<|think|>`) toggled by `enable_thinking` in the chat template. It is
on/off, default off, with no graded effort levels. The speed numbers on this
page were measured with thinking off. Thinking costs only ~3 tok/s, so there
is little reason to avoid it on quality grounds.

**Quality is scored, and the convergence problem is real.** Calibration
alone showed that at a 30K output cap, 2 of 10 sample problems never
finished reasoning at all. The full 164-problem run confirmed it at scale:
46/164 (~28%) empty completions, well above the calibration sample's rate,
for a final EvalPlus of 0.713/0.701. This is model behavior, not a harness
limit — every empty completion still had budget left in the 30000-token
cap. Its smaller sibling, the 12B, does it more often — counterintuitively.

A deep-fill decode check on the llama config is still pending.

---

Method: warmup before every measurement; identical prompts across models;
temp 0. Raw numbers in
[the benchmarks](../benchmarks/gemma-4-26b-a4b.md). Cross-model picks on
[the comparison page](../comparison.md).
