# Qwen3.8-27B Q4_K_M on M1 Max 32 GB — llama-server benchmarks

## Recommended configuration (result of all tests below)

```bash
llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 98304 \
  --jinja --port 8081
```

- `--spec-draft-n-max 3` is the clear decode-speed peak (16.8 py / 15.6 js tok/s vs 12.4 without MTP).
- KV is a context/speed dial: f16 (lossless, marginally faster) up to 96K; q8_0 (near-lossless) up to 160K at ~1% decode cost — see the long-context variant section.
- `-c 98304` (96K) is the max stable context: 112K and 128K hit Metal OOM. RSS ~24.1 GB, ~7.9 GB left for macOS + DB.
- For 2+ concurrent agents use `--parallel 2 -c 90112` (2×44K slots, the max): MTP survives, RSS ~24.2 GB. `--parallel 2 -c 98304` OOMs.
- `--reasoning-effort medium` decodes ~21% faster than xhigh (higher MTP acceptance on medium-effort output).

Build: llama-server 0.3.0 (build 10621, commit c1d0e7a00), Metal.
Wired limit: `iogpu.wired_limit_mb=27000`.
All runs: temperature 0, `n_predict` 256 unless noted. Fresh server start per config.

Base startup command (flags that change per run are shown in each section):

```bash
llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 32768 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

Prompts:

- **py**: `Write a Python function that parses ISO dates.`
- **js**: `Write a JavaScript function that deep clones an object.`
- **long**: 1521-token English text, `n_predict` 64 (prompt-processing probe)

## Baseline — no MTP (no `--spec-type` flags)

| prompt | pp tok/s | decode tok/s | draft_n | accepted |
|---|---|---|---|---|
| py | 22.4 | 12.47 | – | – |
| long | 127.1 | 11.78 | – | – |
| py (fresh start) | 23.5 | 12.44 | – | – |
| js | 24.4 | 12.44 | – | – |

## MTP `--spec-type draft-mtp --spec-draft-n-max 1`

| prompt | pp tok/s | decode tok/s | draft_n | accepted |
|---|---|---|---|---|
| py | 22.6 | 12.39 | 133 | 121 (91%) |
| js | 22.7 | 12.02 | 137 | 117 (85%) |

## MTP `--spec-draft-n-max 2` (rerun of the handoff config)

| prompt | pp tok/s | decode tok/s | draft_n | accepted |
|---|---|---|---|---|
| py | 22.0 | 11.98 | 186 | 161 (87%) |
| js | 22.7 | 10.68 | 209 | 150 (72%) |

## MTP `--spec-draft-n-max 3`

| prompt | pp tok/s | decode tok/s | draft_n | accepted |
|---|---|---|---|---|
| py | 21.3 | 16.79 | 230 | 178 (77%) |
| py (repeat) | 21.9 | 16.77 | 230 | 178 (77%) |
| js | 22.0 | 15.58 | 248 | 172 (69%) |

## MTP `--spec-draft-n-max 3` + f16 KV (no `--cache-type-*` flags, lossless)

| prompt | pp tok/s | decode tok/s | draft_n | accepted |
|---|---|---|---|---|
| py | 21.0 | 16.93 | 230 | 178 (77%) |
| js | 22.2 | 15.73 | 248 | 172 (69%) |

## Medium-effort depth sweep — chat endpoint, f16 KV, `max_tokens` 1024, warmup first

| n-max | py tok/s | py accept | js tok/s | js accept |
|---|---|---|---|---|
| 3 | 17.52 | 723/897 (81%) | 16.31 | 702/962 (73%) |
| 4 | 16.57 | 767/1023 (75%) | 14.86 | 738/1138 (65%) |
| 6 | 13.44 | 804/1311 (61%) | 11.60 | 769/1518 (51%) |

Peak stays at n-max 3 at medium effort: 17.5/16.3 tok/s.

## Reasoning effort — chat endpoint, N=3 + f16 KV, `max_tokens` 1024

Both efforts hit the 1024-token cap while thinking; decode speed is the comparison.

| effort | prompt | decode tok/s | draft_n | accepted |
|---|---|---|---|---|
| xhigh | py | 14.44 | 1089 | 659 (61%) |
| xhigh | js | 13.96 | 1123 | 648 (58%) |
| medium | py | 17.50 | 897 | 723 (81%) |
| medium | js | 16.30 | 962 | 702 (73%) |

## MTP `--spec-draft-n-max 4`

| prompt | pp tok/s | decode tok/s | draft_n | accepted |
|---|---|---|---|---|
| py | 20.5 | 16.33 | 253 | 191 (75%) |
| js | 21.8 | 13.03 | 319 | 175 (55%) |

## MTP `--spec-draft-n-max 6`

| prompt | pp tok/s | decode tok/s | draft_n | accepted |
|---|---|---|---|---|
| py | 20.5 | 13.12 | 330 | 200 (61%) |
| js | 21.0 | 10.21 | 422 | 184 (44%) |

## MTP `--spec-draft-n-max 7`

| prompt | pp tok/s | decode tok/s | draft_n | accepted |
|---|---|---|---|---|
| py | 20.8 | 12.73 | 377 | 201 (53%) |
| js | 17.5 | 10.16 | 471 | 187 (40%) |

## MLX backend — mlx-lm 0.31.3 (brew), `mlx_lm.generate`, chat template applied

Model: `mlx-community/Qwen3.8-27B-4bit`. 256 tokens, temp 0. Peak memory 15.5 GB.

| prompt | decode tok/s | notes |
|---|---|---|
| py | 19.69 | beats GGUF+MTP (16.8) with no MTP at all |
| js | 19.58 | pp 73 tok/s on 62-token prompt (warm) |

MLX has no slot system: `mlx_lm.server` handles one request at a time, requests queue.
No `-c` preallocation — KV grows per request up to the trained 262K window, memory permitting.

### MLX context probe (`mlx_lm` API, 32-token generations, warmup first)

| prompt depth | pp tok/s | peak memory |
|---|---|---|
| 8K | 106 | 19.2 GB |
| 16K | 107 | 20.5 GB |
| 32K | 102 | 23.0 GB |
| 48K | 96 | 25.6 GB |
| 64K | Metal OOM | – |

**MLX max context ≈ 48K** (vs 96K on llama-server). MLX pp (~105 tok/s) is no faster than
llama.cpp (122.8 at 4K) — MLX wins decode only. Marginal memory ~0.16 GB per 1K tokens
(≈3× llama-server's f16 KV slope): prefill activation buffers dominate.

### MTP on MLX (`mlx_vlm.generate`, draft `Qwen3.8-27B-MTP-4bit`, depth fixed at 2)

| prompt | decode tok/s | acceptance | peak memory |
|---|---|---|---|
| py | 20.24 | 82.8% (2.66 tok/round) | 17.1 GB |
| js | 22.49 | 97.1% (2.94 tok/round) | 17.1 GB |

Best Qwen decode overall for js; py ties plain MLX. Needs the mlx-vlm package (pipx).
Multi-instance MLX is impossible for this model: two weight copies (2×15.5 GB) exceed the wired limit.

## Long-context variant — q8_0 KV (near-lossless, user-approved quality bar)

f16 KV was chosen for speed (+~1%), not because q8_0 failed quality. Halving KV doubles the context budget:

| `-c` | KV | result | rss |
|---|---|---|---|
| 131072 | q8_0 | OK, 14.7 tok/s (short probe) | 19.4 GB |
| **163840** | q8_0 | **OK — q8-KV maximum (160K)** | 23.1 GB |
| 180224 | q8_0 | Metal OOM | – |
| 196608 | q8_0 | Metal OOM | – |

96K (f16, lossless) vs 160K (q8_0, near-lossless) at ~1% decode cost.

Two-slot with q8_0 KV:

| `-c` | slots | result | rss |
|---|---|---|---|
| **147456** | 2×72K | **OK, 14.6 tok/s — recommended** | 22.9 GB |
| 155648 | 2×76K | loads, but decode degrades to 10.1 tok/s (memory pressure) | 23.4 GB |
| 163840 | 2×80K | Metal OOM | – |

(f16 two-slot max was 2×44K.)

## Context ramp — N=3, f16 KV, short probe (`n_predict` 64)

| `-c` | result | RSS |
|---|---|---|
| 49152 | OK, 14.9 tok/s | 21.2 GB |
| 65536 | OK, 14.8 tok/s | 22.0 GB |
| 98304 | OK, 14.8 tok/s | 24.1 GB |
| 106496 | Metal OOM | – |
| 114688 | Metal OOM | – |
| 131072 | Metal OOM | – |

## Final config validation — N=3, f16 KV, `-c 98304`

| prompt | pp tok/s | decode tok/s | draft_n | accepted |
|---|---|---|---|---|
| 4086-token text, `n_predict` 128 | 122.8 | 15.34 | 123 | 86 (70%) |
| py | 18.7 | 16.84 | 230 | 178 (77%) |
| js | 18.3 | 15.59 | 248 | 172 (69%) |

No Metal errors. RSS 24.1 GB after the long prompt.

## JS prompt check — `Write a JavaScript function that debounces another function.`

Run twice on the final config. Same speed as the deep-clone prompt (15.59), so the deep-clone prompt stays as the JS benchmark.

| run | decode tok/s | draft_n | accepted |
|---|---|---|---|
| 1 | 15.33 | 255 | 170 (67%) |
| 2 | 15.35 | 255 | 170 (67%) |

## Concurrency — N=3, f16 KV, `--parallel 2`

| `-c` | slots | result | RSS |
|---|---|---|---|
| 65536 | 2×32K | OK, MTP active, py 17.05 tok/s | 23.1 GB |
| 81920 | 2×40K | OK, MTP active | 23.9 GB |
| 90112 | 2×44K | OK, MTP active — max for 2 slots | 24.2 GB |
| 98304 | 2×48K | Metal OOM | – |

## Quality — EvalPlus HumanEval+ (night 2, fair budget)

**pass@1 0.982 base / 0.939 plus** (mlx 4-bit, reasoning_effort=medium, output
budget 8192, temperature 0). Night 1's flawed 3072 cap had scored it
0.970/0.939. Zero empty completions. The strongest HumanEval+ result of the
models scored so far. Details: `night2/results.md`.

## Depth sweeps at `iogpu.wired_limit_mb=25000` (2026-08-28)

Decode vs used context, append-only prompts, 8 tok/s early stop:

| depth | llama+MTP q8 (32K alloc) | mlx |
|---|---|---|
| 4K | 14.1 | – |
| 8K | 12.8 | 17.1 |
| 16K | 8.6 | 16.4 |
| 24.5K | 7.3 — below floor | 15.4 |
| 28.7K | – | 14.2, RSS 14.3 GB |
| ~32K | – | Metal OOM (server thread dies; /health stays 200) |

**llama floor ~19K (speed); mlx never crosses the floor — its limit is a
memory ceiling between 28.7K and ~33K.** MLX wins this model's equilibrium:
~14-17 tok/s across its whole usable window. Suggested pi setup: mlx config
with compaction threshold ~26K (below the known-good 28.7K). The 27000-era
context maxima (160K single, 2×72K) are withdrawn pending re-probe.
