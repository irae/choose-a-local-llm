# Qwen3.6-35B-A3B (MoE) on M1 Max 32 GB — llama-server benchmarks

MoE: 35B total parameters, ~3B active per token. Trained context 262144 (GGUF metadata `qwen35moe.context_length`). MTP embedded in unsloth's MTP-GGUF build. Base-model reference: 73.4 SWE-bench Verified.
Model: `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` (~20 GB).
Build: llama-server 0.3.0 (build 10621). Temperature 0, `n_predict` 256, warmup before every measurement. Same prompts as the other models (py = ISO dates, js = deep clone).

## Recommended configuration (at `iogpu.wired_limit_mb=24000`)

```bash
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 98304 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

Multi-slot at 25000 is untested. At 24000, `--parallel 2 -c 40960` OOMed (the
second slot adds compute buffers). The old `qwen3.6-35b-a3b-2x` (2×96K) needed
the 27000 limit and is retired.

## Context — q8_0 KV at `iogpu.wired_limit_mb=24000` (current, 2026-08-25)

Limit history on this 32 GB machine: 27000 made the machine too slow for normal
use; 24000 capped this model at 40K; 25000 was the compromise until
2026-08-29, when 24000 became the standing value.

| `-c` | slots | result | rss |
|---|---|---|---|
| **98304** | 1 | **OK, 62.0/67.7 tok/s (256-tok verify) — max (96K)** | 22.9 GB |
| 106496 | 1 | Metal OOM | – |
| 114688 | 1 | Metal OOM | – |
| 131072 | 1 | Metal OOM | – |

MTP acceptance unchanged at the max (py 154/192 = 80%, js 84/93 = 90%).

**Deep-fill behavior**: decode collapses to ~17 tok/s once the used context is
large — measured 16.7 tok/s at 31,365 used tokens (in a 40K window; prompt
processing stayed healthy at 556 tok/s). The user also saw ~17 tok/s at ~40K
used in the old 208K config at 27000. So the collapse tracks used tokens, not
the allocation or the limit. Accepted for this setup: the initial session is
where speed matters most. A deep-fill check at 96K is pending. Lesson for the
flow: probe with a filled context too — allocation-only probes overstate what
is usable.

## Context — q8_0 KV at `iogpu.wired_limit_mb=24000` (historical)

| `-c` | slots | result | rss |
|---|---|---|---|
| 32768 | 1 | OK, 68.4/72.3 tok/s (py/js) | 22.1 GB |
| 40960 | 1 | OK, 65.6/72.1 tok/s (256-tok verify) — max (40K) | 22.2 GB |
| 49152 | 1 | loads, decode collapses to ~17 tok/s | 22.2 GB |
| 65536 | 1 | Metal OOM (reproduced twice) | – |
| 98304–196608 | 1 | Metal OOM | – |
| 40960 | 2×20K | Metal OOM — no viable multi-slot config | – |

## MTP sweep — 32K context, f16 KV

| n-max | py tok/s | py accept | js tok/s | js accept |
|---|---|---|---|---|
| off (baseline) | 52.34 | – | 52.41 | – |
| 2 | 67.75 | 162/184 (88%) | 70.67 | 75/80 (94%) |
| **3** | **68.21** | 181/220 (82%) | **73.53** | 84/93 (90%) |
| 4 | 63.53 | 189/260 (73%) | 69.42 | 88/108 (81%) |

Peak at n-max 3. Short-prompt pp 62–93 tok/s (vs ~22 for dense Qwen3.8 — the MoE + newer kernels are far healthier).

## Context ramp — n-max 3, f16 KV, short probe (`n_predict` 64), warmup first (historical: `iogpu.wired_limit_mb=27000`)

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

## Context — q8_0 KV (historical: `iogpu.wired_limit_mb=27000`)

| `-c` | slots | result | rss |
|---|---|---|---|
| 196608 | 1 | OK, 67.2 tok/s | – |
| **212992** | 1 | **OK, 63.6 tok/s — max (208K)** | 24.1 GB |
| 229376 | 1 | Metal OOM | – |
| 262144 | 1 | Metal OOM | – |
| **196608** | 2×96K | **OK, 66.5 tok/s — two-slot config** | 24.2 GB |

Max single-session at 27000: 208K (q8_0 KV); two slots: 2×96K. f16 alternatives: 136K / 2×64K. All of these need the 27000 limit, which is retired (too slow for normal use).

## Multi-slot (historical: `iogpu.wired_limit_mb=27000`)

| `-c` | slots | result | rss |
|---|---|---|---|
| 131072 | 2×64K | OK, 67.0 tok/s — two-slot max | 23.5 GB |
| 139264 | 2×68K | Metal OOM | – |

## Reasoning control

The chat template has no `reasoning_effort` (unlike Qwen3.8) — only binary `enable_thinking`
(default on). Disable with `--chat-template-kwargs '{"enable_thinking":false}'`.

## Quality — EvalPlus HumanEval+ (2026-08-28, fair budget)

| config | budget | pass@1 base | pass@1 plus | empty | completion | regenerated |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" /> | 26624 | **0.939** | **0.921** | 5/164 | 97% | 56 (54 missing + 2 previously empty) |

This corrected the 56 missing or empty completions at the calibrated budget
of 26624 tokens, which is safe because temperature 0 is deterministic. The
run was clean: the server and the memory probe stayed healthy through every
heartbeat check.

5 completions stay genuinely empty at the full budget. That is a real model
limit, not a harness artifact.

A 2026-08-26 pass under a flawed 3072-token cap had scored this config
0.610/0.610/62% with 62/164 empty (superseded, see
[the historical page](../historical.md)). The corrected score is 0.329
higher on base.

## Pending

- Thinking-off pass, for sub-agent use.

## Ladder and creep — f16 KV, no drafter (2026-09-11, wired limit 25000)

`unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` rev `5bc3e23`,
`--no-mmproj`, no drafter, one slot. `-c 65536` served a real
6001-token completion at 25027 MB wired; no larger `-c` was probed,
65536 being the depth list's end.

| depth | tok/s | wired MB | swap Δ |
|--:|--:|--:|--:|
| 4114 | 50.49 | 25027 | 0 |
| 8222 | 48.41 | 25025 | 0 |
| 16386 | 46.17 | 25010 | 0 |
| 24602 | 43.71 | 25010 | 0 |
| 32818 | 41.50 | 25009 | 0 |
| 40982 | 39.32 | 25008 | 0 |
| 49198 | 37.20 | 24967 | 0 |
| 57362 | 35.03 | 24921 | 0 |
| 65578 | 33.64 | 24921 | 0 |

No ceiling found: the deepest step is the list's end. With the
drafter the same arm loads only `-c 40960`.

## Vision — the projector loaded (2026-09-11, wired limit 25000)

Same files, projector `mmproj-BF16.gguf` loaded, f16 KV, one slot.
The request carries one synthetic statement page, 1400×1400 PNG,
plus a prompt; "filled" adds 4096 tokens of text.

| `-c` | loaded | served | wired at load | wired after | prompt tokens, filled | prompt tokens, bare | image tokens |
|--:|:--:|:--:|--:|--:|--:|--:|--:|
| 65536 | yes | yes | 25680 MB | 25678 MB | 8983 | 1978 | 7005 |
| 73728 | with an OOM line | no, compute error | | | | | |

The reply read the whole table correctly on both requests. Drafter
cells at depth 256 with the projector on, one warmup and two counted
requests each:

| n-max | tok/s | acceptance | wired at load |
|--:|--:|--:|--:|
| none | 50.33, 50.38 | — | 25476 MB |
| 1 | 58.11, 51.42 | 0.889, 0.693 | 25555 MB |
| 2 | out of memory on the request | | |
| 3 | out of memory on the request | | |

The model card says the projector and the drafter do not work
together; n-max 1 works. `llama-benchy` 0.4.0 on the code corpus,
projector loaded, no image in the prompts, `--cache-ram 0`:

| arm | 4096 | 32768 | 64512 | acceptance |
|---|--:|--:|--:|--:|
| no drafter | 48.84 | 39.74 | 33.12 | — |
| n-max 1 | 53.88 | 43.68 | 33.85 | 0.78 to 0.94 |

## Real-text decode at the server's sampling (llama-benchy 0.4.0, 2026-09-11, wired limit 25000)

`llama-benchy` sends 512 prompt tokens after a code-text conversation
of the stated depth and reads 256 generated tokens, two runs after one
warmup, no sampling parameter passed. Draft acceptance from the server
log, per counted request. `--cache-ram 0` on the server for these
readings only.

| config | depth | tok/s | sd | acceptance | wired |
|---|--:|--:|--:|--:|--:|
| llama, no drafter, f16 KV, `-c 40960` | 4096 | 49.80 | 0.41 | no drafter | 24.0 GB |
| llama, no drafter, f16 KV, `-c 40960` | 39936 | 38.26 | 0.01 | no drafter | 24.0 GB |
| llama+MTP n-max 3, q8_0 KV, `-c 98304` | 4096 | 43.68 | 0.82 | 0.60–0.85 | 25.6 GB |
| llama+MTP n-max 3, q8_0 KV, `-c 98304` | 49152 | 19.23 | 0.87 | 0.54–0.59 | 25.6 GB |
| llama+MTP n-max 3, q8_0 KV, `-c 98304` | 81920 | 13.01 | 0.16 | 0.60–0.62 | 25.6 GB |

The no-drafter deep cell sits at 39936: a benchy request adds its own
768 tokens on top of the depth, so 40960 does not fit `-c 40960`.

## Depth sweeps (llama at limit 25000, 2026-08-28; mlx re-tested at limit 24000, slow creep, 2026-08-29)

Decode vs used context, synthetic continuation prompts, 8 tok/s early stop:

| depth | llama+MTP, q8_0 KV (96K alloc) | mlx, f16 KV (no MTP) |
|---|---|---|
| 4K | 44.5 | 53.3 |
| 16K | 30.1 | 49.6 |
| 32-33K | 18.8 | 42.2 |
| 37K | – | 42.0 |
| ~41K | – | Metal OOM — **ceiling 37-41K** |
| 49K | 13.5 | – |
| 65K | 10.7 | – |
| 82K | 8.8 | – |
| 90K | 8.1 | – |

**The 8 tok/s floor is never crossed inside the 96K llama window** — the
deep-context king confirmed (RSS 22.8 GB). MLX (RSS 18.7) is 2.2× faster at
32K but memory-capped at 33-41K. mlx model:
`mlx-community/Qwen3.6-35B-A3B-4bit`.
