# Qwen3.8-27B on M1 Max 32 GB

llama-server (Metal, build 10621) + mlx-lm 0.31.3 · benchmarked 2026-08-25

## Highlights

- **The best quality score of any config measured here.** EvalPlus 0.982 /
  0.939, with zero empty completions.
- **The model to send hard problems to.** Nothing else scores close.
- **MLX holds 14-17 tok/s across its whole usable window.** It never gets
  slow inside the context it can hold.
- Weak point: it is the slowest model on this hardware. 19.7 tok/s is its
  ceiling.
- Weak point: a small window. MLX OOMs between 29K and 33K.
- Weak point: prompt processing is poor, ~123 tok/s even on long prompts.

## Best option

**mlx_lm.server, 4-bit, with compaction set at ~26K.** Plain MLX beats
llama-server's best MTP configuration, and it keeps its speed to the edge of
its window. Set the harness compaction threshold at ~26K, below the
verified-good 28.7K.

```bash
mlx_lm.server --model mlx-community/Qwen3.8-27B-4bit --port 8081
```

Add `--reasoning-effort medium` when top quality is not needed: it is ~21%
faster per token, and it is the setting the record EvalPlus score was
measured on.

The llama alternative — the ~19K depth floor makes big allocations
pointless, so this is sized just above the floor (pi id `qwen3.8-27b`):

```bash
llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 32768 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

## Which to pick for a coding task

| need | config | tok/s (py/js) | context |
|---|---|--:|--:|
| **Daily driver** | mlx_lm.server, compaction at ~26K | 14-17 across the window | to ~29K ceiling |
| **llama alternative** | llama-server + MTP n=3, q8_0 KV | 14.1 shallow | floor ~19K; maxima pending re-probe |

## Quality — EvalPlus HumanEval+ (run 2)

| config scored | pass@1 base | pass@1 plus | empty completions |
|---|--:|--:|--:|
| mlx_lm.server 4-bit, reasoning_effort=medium | 0.982 | 0.939 | 0/164 |

## Decode speed vs used context (limit 25000, 2026-08-28)

| depth | llama+MTP q8 | mlx |
|---|--:|--:|
| 4-8K | 14.1 / 12.8 | 17.1 |
| 16K | 8.6 | 16.4 |
| 24.5K | 7.3 — below the 8 tok/s floor | 15.4 |
| 28.7K | – | 14.2 (RSS 14.3 GB) |
| ~32K | – | Metal OOM — server thread dies, /health stays 200 |

## Backend comparison: llama-server (GGUF) vs mlx-lm (MLX)

| variant | py tok/s | js tok/s | memory |
|---|--:|--:|--:|
| llama-server Q4_K_M, no MTP | 12.44 | 12.44 | ~21 GB RSS |
| llama-server Q4_K_M + MTP n=3, f16 KV | 16.93 | 15.73 | ~21 GB RSS |
| **mlx-lm MLX 4-bit, no MTP** | **19.69** | **19.58** | **15.5 GB peak** |

## MTP draft depth sweep

256 tokens, temperature 0, q8_0 KV, 32K context.

| --spec-draft-n-max | py tok/s | py accept | js tok/s | js accept |
|---|--:|--:|--:|--:|
| off (baseline) | 12.44 | – | 12.44 | – |
| 1 | 12.39 | 91% | 12.02 | 85% |
| 2 | 11.98 | 87% | 10.68 | 72% |
| **3** | **16.79** | **77%** | **15.58** | **69%** |
| 4 | 16.33 | 75% | 13.03 | 55% |
| 6 | 13.12 | 61% | 10.21 | 44% |
| 7 | 12.73 | 53% | 10.16 | 40% |

## Reasoning effort (chat endpoint, 1024-token replies)

| effort | py tok/s | js tok/s | acceptance |
|---|--:|--:|--:|
| xhigh (default) | 14.44 | 13.96 | 58–61% |
| **medium** | **17.50** | **16.30** | **73–81%** |

At medium effort the llama peak stays at n-max 3:

| --spec-draft-n-max | py tok/s | py accept | js tok/s | js accept |
|---|--:|--:|--:|--:|
| **3** | **17.52** | **81%** | **16.31** | **73%** |
| 4 | 16.57 | 75% | 14.86 | 65% |
| 6 | 13.44 | 61% | 11.60 | 51% |

## KV cache: q8_0 vs f16 (at n-max 3)

| KV type | py tok/s | js tok/s | quality |
|---|--:|--:|---|
| q8_0 | 16.79 | 15.58 | near-lossless |
| **f16** | **16.93** | **15.73** | **lossless** |

## History and reasoning

**MLX wins this model's equilibrium, and that was not obvious.** MLX beats
GGUF+MTP on decode because its Metal kernels handle this hybrid DeltaNet
architecture better than llama.cpp's. But MLX loses on every other axis: max
context measured 48K against llama-server's 96K, prompt processing at ~105
tok/s is no faster than llama.cpp's 123, it serves one request at a time with
no sub-agent slots, and multi-instance is impossible because two 15.5 GB
weight copies exceed the wired limit. It still wins, because llama crosses
the 8 tok/s floor at ~19K while MLX never drops below 14 inside its window.
Speed you can actually use beats a window you cannot decode through.

**The quality score is fair, and it is the project's best.** Run 2 calibrated
this config's output budget to 8192 — its longest observed reasoning was only
~2.6K tokens — and regenerated the three empty completions left from run 1.
Zero empty completions remain. Details in `night2/results.md`.

**Medium reasoning effort is faster for a mechanical reason.** The MTP head
predicts medium-effort text better than xhigh-effort text, so acceptance
climbs from 58–61% to 73–81%. That is where the ~21% per-token gain comes
from.

**q8_0 KV is free here.** It halves KV memory, unlocks 160K context — 176K
OOMs — and produced byte-identical outputs to f16 in a deterministic temp-0
comparison over 512 tokens and both prompts. f16 remains the secondary
option: ~1% faster, capped at 96K. KV grows only ~0.8 GB per 16K tokens,
because the hybrid DeltaNet layers keep no KV; only the full-attention layers
do.

**The n-max 3 result is real.** It repeated exactly on a second run (16.77).
A second JS prompt — debounce, run twice — matched deep clone within 0.3
tok/s, so the JS penalty comes from the language, not the task. The settings
choice is the same for both languages.

**The old context maxima are withdrawn.** Every allocation figure for this
model was measured at the retired 27000 wired limit and awaits a re-probe at
25000. Those tables are on
[the historical page](../historical.md); do not use them.
The depth floor at ~19K makes large allocations pointless here anyway.
[The benchmarks](../benchmarks/qwen3.8-27b.md) keep the labeled archive.
MTP-on-MLX exists only as a CLI with no API, so it is disqualified for
harness use; its raw numbers stay in the benchmarks too.

**Open issue: prompt processing.** It is ~20 tok/s on short prompts and
reaches only ~123–127 tok/s on 1.5K–4K prompts, which is low for this
hardware class. It is independent of MTP — the no-MTP baseline shows the same
numbers — so it looks like a Metal kernel limitation of the new hybrid
DeltaNet architecture in the current build. Worth re-testing on future
llama.cpp releases.

---

Method: fresh server start per configuration; identical curl per run;
temperature 0. Full raw numbers in
[the benchmarks](../benchmarks/qwen3.8-27b.md). Cross-model picks on
[the comparison page](../comparison.md).
