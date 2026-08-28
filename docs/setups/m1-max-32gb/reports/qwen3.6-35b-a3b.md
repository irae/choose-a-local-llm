# Qwen3.6-35B-A3B (MoE) on M1 Max 32 GB

llama-server (build 10621) · unsloth UD-Q4_K_XL + embedded MTP · benchmarked
2026-08-25 · `iogpu.wired_limit_mb=25000`

## Summary

MoE (35B total, ~3B active) + MTP is the new speed king: **68 py / 74 js
tok/s** at draft depth 3 — 1.5× Gemma-12B, 4× dense Qwen3.8 — with the
strongest base-model coding pedigree tested (73.4 SWE-bench Verified). The
wired limit is now **25000** (27000 made the machine too slow for normal use;
24000 capped context at 40K): single-session context reaches **96K**, down
from 208K. Decode collapses to ~17 tok/s once ~30K+ tokens are in use —
accepted, since the initial session is where speed matters most. Initial
EvalPlus score below — deflated by a harness bug, not yet fair.

**68 / 74 tok/s** (py/js) at MTP n-max 3 · **96K** max context, q8_0 KV at
62-68 tok/s · **~17 tok/s** at deep fill (31K+ used) · **22.9 GB** RSS at max
context.

## Quality — EvalPlus HumanEval+ (initial, night 1)

| config scored | pass@1 base | pass@1 plus | empty completions |
|---|--:|--:|--:|
| llama-server + MTP, thinking on | 0.610 | 0.610 | 62/164 (~38%) |

**Caveat: this score is not fair and heavily deflated — do not rank on it.**
The run used `max_tokens=3072`; this model's reasoning exhausted that budget
on **38% of the problems**, and each empty completion scores as a hard
failure. The real capability is likely far higher (its base model reports
73.4 SWE-bench Verified). Worst-affected of the three models scored. The
night-2 correction is parked mid-run (5 of 62 empty completions regenerated,
calibrated budget 26624) and resumes on a future night. Details in
`night1/results.md` and `night2/state.md`.

## Which to pick for a coding task

| need | config | tok/s (py/js) | context |
|---|---|--:|--:|
| **Max context** | llama-server + MTP n=3, q8_0 KV, 1 slot | 62.0 / 67.7 | 96K |
| **Max speed** | same config (near-empty context) | 68 / 74 | same |
| **Multi-agent** | untested at limit 25000 (at 24000: OOM even at 2×20K) | – | – |

Single agent — one 96K slot, q8_0 KV (pi id `qwen3.6-35b-a3b`):

```bash
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 98304 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

The old 208K single / 2×96K two-agent configs needed
`iogpu.wired_limit_mb=27000`, which made the machine too slow for normal use.
They are retired; raise the limit again only for a dedicated session.

## Context ramp (n-max 3, q8_0 KV, limit 25000 — current)

| -c | result | tok/s | RSS |
|---|---|--:|--:|
| **98,304** | **OK — maximum (256-tok verified)** | **62.0 / 67.7** | **22.9 GB** |
| 106,496 | Metal OOM | – | – |
| 114,688 | Metal OOM | – | – |
| 131,072 | Metal OOM | – | – |

MTP acceptance is unchanged at the max (py 80%, js 90%). At the retired 24000
limit the max was 40K. **Deep fill:** decode collapses to ~17 tok/s once ~30K+
tokens are in use (measured: 16.7 tok/s at 31,365 used tokens; prompt
processing stays healthy at 556 tok/s). Accepted — the initial session is
where speed matters most. A deep-fill check at 96K is pending.

## MTP draft depth sweep (32K, f16 KV)

| --spec-draft-n-max | py tok/s | py accept | js tok/s | js accept |
|---|--:|--:|--:|--:|
| 2 | 67.75 | 88% | 70.67 | 94% |
| **3** | **68.21** | **82%** | **73.53** | **90%** |
| 4 | 63.53 | 73% | 69.42 | 81% |

No-MTP baseline measurement in progress. Prompt processing is healthy on this
architecture (62–93 tok/s even on tiny prompts, vs ~22 for dense Qwen3.8).

## Context ramp (n-max 3, f16 KV, limit 27000 — historical)

| -c | result | tok/s | RSS |
|---|---|--:|--:|
| 49,152 | OK | 66.3 | 22.8 GB |
| 98,304 | OK | 67.2 | 23.7 GB |
| 131,072 | OK | 67.8 | 24.3 GB |
| **139,264** | **OK — maximum** | **65.5** | **24.5 GB** |
| 147,456 | Metal OOM | – | – |
| 196,608 | Metal OOM | – | – |

Measured under the retired 27000 limit. With q8_0 KV that limit reached 208K
single / 2×96K. KV is only ~19 KB/token, so decode speed does not degrade
with allocated context.

## Decode speed vs used context (depth sweeps, limit 25000)

| depth | llama+MTP q8 (96K alloc) | MLX (Qwen3.6-35B-A3B-4bit) |
|---|--:|--:|
| 4K | 44.5 | 53.3 |
| 16K | 30.1 | 49.6 |
| 33K | 18.8 | 42.2 |
| 37K | | 42.0 |
| ~41K | | Metal OOM — ceiling 37-41K |
| 49K | 13.5 | |
| 65K / 82K / 90K | 10.7 / 8.8 / 8.1 | |

llama never crosses the 8 tok/s floor inside its 96K window — the
deep-context king (RSS 22.8 GB). MLX is 2.2× faster at 33K but memory-capped
at 37-41K (RSS 18.7 GB). Sweep prompts are synthetic continuations; MTP
numbers read below the py/js bench.

---

Method: warmup before every measurement; identical prompts across models;
temp 0. Raw numbers in
[the benchmarks](../benchmarks/qwen3.6-35b-a3b.md). Cross-model picks on
[the comparison page](../comparison.md).
