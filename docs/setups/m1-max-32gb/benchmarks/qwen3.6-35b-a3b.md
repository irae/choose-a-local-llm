# Qwen3.6-35B-A3B (MoE) on M1 Max 32 GB — llama-server benchmarks

MoE: 35B total parameters, ~3B active per token. Trained context 262144 (GGUF metadata `qwen35moe.context_length`). MTP embedded in unsloth's MTP-GGUF build. Base-model reference: 73.4 SWE-bench Verified.
Model: `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` (~20 GB).
Build: llama-server 0.3.0 (build 10621). Temperature 0, `n_predict` 256, warmup before every measurement. Same prompts as the other models (py = ISO dates, js = deep clone).

## Recommended configuration (at `iogpu.wired_limit_mb=25000`)

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

## Context — q8_0 KV at `iogpu.wired_limit_mb=25000` (current, 2026-08-25)

Limit history on this 32 GB machine: 27000 made the machine too slow for normal
use; 24000 capped this model at 40K; 25000 is the compromise.

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

## Quality — EvalPlus HumanEval+ (run 3, fair budget)

| config scored | budget | pass@1 base | pass@1 plus | empty | regenerated |
|---|--:|--:|--:|--:|--:|
| llama-server+MTP Q4_K_XL, thinking on | 26624 | **0.939** | **0.921** | 5/164 | 56 (54 missing + 2 previously empty) |

Run 3 finished the correction that run 2 had parked. It regenerated the 56
missing or empty completions at the calibrated budget of 26624 tokens, which
is safe because temperature 0 is deterministic. The run was clean: the server
and the memory probe stayed healthy through every heartbeat check.

5 completions stay genuinely empty at the full budget. That is a real model
limit, the same pattern bonsai-think showed in run 2, not a harness artifact.

Run 1's flawed 3072-token cap had scored this config 0.610/0.610 with 62/164
empty (`night1/results.md`) — the worst-affected block of that run. The
corrected score is 0.329 higher on base.

## Pending

- Thinking-off pass, for sub-agent use.

## Depth sweeps (limit 25000, 2026-08-28)

Decode vs used context, synthetic continuation prompts, 8 tok/s early stop:

| depth | llama+MTP q8 (96K alloc) | mlx (no MTP) |
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
