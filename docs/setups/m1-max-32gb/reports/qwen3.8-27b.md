# Qwen3.8-27B on M1 Max 32 GB

llama-server (Metal, build 10621) + mlx-lm 0.31.3 · benchmarked 2026-08-25

## Summary

**Fastest usable decode: mlx_lm.server at 19.7 tok/s** — plain MLX beats
llama-server's best MTP configuration (16.9 tok/s, draft depth 3; 12.4
without MTP). At the current wired limit (25000), MLX holds ~14-17 tok/s
across its whole usable window (memory ceiling between 28.7K and ~33K), while
llama+MTP crosses the 8 tok/s usability floor at ~19K of used context — **MLX
wins this model's equilibrium**. The 27000-era context maxima (160K single,
2×72K) are withdrawn pending re-probe.

**19.7 tok/s** on mlx_lm.server at ≤48K · **16.9 tok/s** on llama-server +
MTP n-max 3 · **~26K** suggested compaction threshold (mlx) · **14.2 tok/s**
at 28K used (mlx, RSS 14.3 GB).

## Quality — EvalPlus HumanEval+ (fair score, night 2)

| config scored | pass@1 base | pass@1 plus | empty completions |
|---|--:|--:|--:|
| mlx_lm.server 4-bit, reasoning_effort=medium | 0.982 | 0.939 | 0/164 |

**Fair score — the token-budget flaw is fixed.** Night 2 calibrated this
config's output budget (8192; its longest observed reasoning was ~2.6K
tokens) and regenerated the three night-1 empty completions. Zero empty
completions remain. The strongest HumanEval+ result of the models scored so
far. Details in `night2/results.md`.

## Which to pick for a coding task

| need | config | tok/s (py/js) | context |
|---|---|--:|--:|
| **Daily driver** | mlx_lm.server, compaction at ~26K | 14-17 across the window | to ~29K ceiling |
| **llama alternative** | llama-server + MTP n=3, q8_0 KV | 14.1 shallow | floor ~19K; maxima pending re-probe |

## Decode speed vs used context (limit 25000, 2026-08-28)

| depth | llama+MTP q8 | mlx |
|---|--:|--:|
| 4-8K | 14.1 / 12.8 | 17.1 |
| 16K | 8.6 | 16.4 |
| 24.5K | 7.3 — below the 8 tok/s floor | 15.4 |
| 28.7K | – | 14.2 (RSS 14.3 GB) |
| ~32K | – | Metal OOM — server thread dies, /health stays 200 |

llama's floor is speed (~19K); mlx's is memory (ceiling 29-33K) and it never
drops below 14 tok/s inside it. pi setup for the mlx config: compaction
threshold ~26K, below the verified-good 28.7K.

## How to start each variant

Fastest single agent — mlx-lm (OpenAI-compatible API, one request at a time):

```bash
mlx_lm.server --model mlx-community/Qwen3.8-27B-4bit --port 8081
```

llama variant — the depth floor (~19K) makes big allocations pointless; sized
just above the floor, q8_0 KV (pi id `qwen3.8-27b`):

```bash
llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 32768 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

The old 160K and 2×72K configs were measured at the retired 27000 limit and
are withdrawn pending re-probe
([the benchmarks](../benchmarks/qwen3.8-27b.md) keep the archive).

## MTP draft depth sweep

256 tokens, temperature 0, q8_0 KV, 32K context. Prompts: py = "Write a
Python function that parses ISO dates.", js = "Write a JavaScript function
that deep clones an object."

| --spec-draft-n-max | py tok/s | py accept | js tok/s | js accept |
|---|--:|--:|--:|--:|
| off (baseline) | 12.44 | – | 12.44 | – |
| 1 | 12.39 | 91% | 12.02 | 85% |
| 2 | 11.98 | 87% | 10.68 | 72% |
| **3** | **16.79** | **77%** | **15.58** | **69%** |
| 4 | 16.33 | 75% | 13.03 | 55% |
| 6 | 13.12 | 61% | 10.21 | 44% |
| 7 | 12.73 | 53% | 10.16 | 40% |

The n-max 3 result repeated exactly on a second run (16.77). A second JS
prompt (debounce, run twice) matched deep clone within 0.3 tok/s — the JS
penalty comes from the language, not the task, so the settings choice is the
same for both languages.

## KV cache: q8_0 vs f16 (at n-max 3)

| KV type | py tok/s | js tok/s | quality |
|---|--:|--:|---|
| q8_0 | 16.79 | 15.58 | near-lossless |
| **f16** | **16.93** | **15.73** | **lossless** |

q8_0 is the default: halves KV memory, unlocks **160K** context (176K OOMs),
and produced **byte-identical outputs to f16** in the deterministic temp-0
comparison (512 tokens, both prompts). f16 is the secondary option: ~1%
faster, capped at 96K.

## Context ramp (n-max 3, f16 KV)

| -c | result | RSS |
|---|---|--:|
| 49,152 | OK | 21.2 GB |
| 65,536 | OK | 22.0 GB |
| **98,304** | **OK — validated with a 4K-token prompt, no errors** | **24.1 GB** |
| 106,496 | Metal OOM | – |
| 114,688 | Metal OOM | – |
| 131,072 | Metal OOM | – |

KV grows only ~0.8 GB per 16K tokens — the hybrid DeltaNet layers keep no KV,
only the full-attention layers do.

### Serving variants (chosen at startup)

| agents | flags | context per agent | RSS |
|---|---|--:|--:|
| 1 | `--parallel 1 -c 98304` | 96K | 24.1 GB |
| 2 | `--parallel 2 -c 90112` | 44K | 24.2 GB |

MTP stays active in both variants. The next 8K step OOMs in both: `-c 106496`
with one slot, `-c 98304` with two.

## Reasoning effort (chat endpoint, 1024-token replies)

| effort | py tok/s | js tok/s | acceptance |
|---|--:|--:|--:|
| xhigh (default) | 14.44 | 13.96 | 58–61% |
| **medium** | **17.50** | **16.30** | **73–81%** |

Medium is ~21% faster per token: the MTP head predicts medium-effort text
better. Add `--reasoning-effort medium` when top quality is not needed.

## Backend comparison: llama-server (GGUF) vs mlx-lm (MLX)

| variant | py tok/s | js tok/s | memory |
|---|--:|--:|--:|
| llama-server Q4_K_M, no MTP | 12.44 | 12.44 | ~21 GB RSS |
| llama-server Q4_K_M + MTP n=3, f16 KV | 16.93 | 15.73 | ~21 GB RSS |
| **mlx-lm MLX 4-bit, no MTP** | **19.69** | **19.58** | **15.5 GB peak** |

MLX beats GGUF+MTP on decode — its Metal kernels handle this hybrid
architecture better than llama.cpp's. But MLX loses everywhere else: max
context measured **48K** (64K prompts OOM; llama-server reaches 96K), prompt
processing ~105 tok/s (no faster than llama.cpp's 123), one request at a time
(no sub-agent slots), and multi-instance is impossible (two 15.5 GB weight
copies exceed the wired limit). MTP-on-MLX exists only as a CLI (no API) —
disqualified for harness use; raw numbers remain in
[the benchmarks](../benchmarks/qwen3.8-27b.md).

## Max llama-server speed at medium effort

Chat endpoint, 1024-token replies, warmup first. Depth sweep at
`--reasoning-effort medium` — the peak stays at n-max 3.

| --spec-draft-n-max | py tok/s | py accept | js tok/s | js accept |
|---|--:|--:|--:|--:|
| **3** | **17.52** | **81%** | **16.31** | **73%** |
| 4 | 16.57 | 75% | 14.86 | 65% |
| 6 | 13.44 | 61% | 11.60 | 51% |

Best llama-server can do at medium: **17.5 / 16.3 tok/s** (n-max 3, f16 KV) —
~4% over its xhigh chat-endpoint numbers via better MTP acceptance.

## Open issue

Prompt processing on short prompts is ~20 tok/s, but reaches only ~123–127
tok/s on 1.5K–4K prompts — still low for this hardware class. This is
independent of MTP (the no-MTP baseline shows the same numbers), so it looks
like a Metal kernel limitation of the new hybrid DeltaNet architecture in the
current build. Worth re-testing on future llama.cpp releases.

---

Method: fresh server start per configuration; identical curl per run;
temperature 0. Full raw numbers in
[the benchmarks](../benchmarks/qwen3.8-27b.md). Cross-model picks on
[the comparison page](../comparison.md).
