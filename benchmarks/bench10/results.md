# Run 10 — results

One section per block, in run order. Every number with the exact
command that produced it and the file under `results/` that holds the
evidence.

## Block A — curves

### A1 — gemma-4-12b-4x, GGUF, f16 KV

Command:

```
llama-server -hf unsloth/gemma-4-12b-it-GGUF:Q4_K_XL \
  --alias gemma-4-12b-4x --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 4 --parallel 4 \
  -ngl 999 -fa on -c <search> \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline
```

`-c` search (published `1048576` does not load): `524288` loads,
`786432` OOMs at load, `655360` loads, `720896` OOMs, `688128` loads
clean on a trivial warmup but OOMs on compute buffers at the first real
depth step (4114 tokens) — dropped as a false positive. Re-verified
`655360` with a realistic 4096-token completion, which passed. Final:
**`-c 655360`** (163840/slot).

Full creep, one slot, `DEPTH_LIST=4096..163840`
(`benchmarks/bench10/results/creep-gemma12-gguf-4x-f16.tsv`):

| depth | decode tok/s | wired MB | free MB | swap Δ MB | compress pages | decompress pages |
| --- | --- | --- | --- | --- | --- | --- |
| 4114 | 42.86 | 25144 | 94 | 0 | 7356 | 209 |
| 8222 | 23.75 | 25144 | 89 | 0 | 122025 | 12391 |
| 16386 | 37.13 | 25160 | 64 | 0 | 44186 | 6739 |
| 24602 | 34.20 | 25157 | 60 | 0 | 24370 | 2221 |
| 32818 | 31.53 | 25159 | 63 | 0 | 28411 | 11576 |
| 49198 | 27.65 | 25137 | 62 | 0 | 107607 | 32332 |
| 65578 | 24.51 | 25078 | 54 | 162 | 102605 | 52485 |

Verdict: **mem**. Swap grew 162 MB at depth 65578 (exit 42). The
stable ceiling is the last clean row: **depth 49198 at 27.65 tok/s**.
Draft acceptance ranged 0.17–1.00 across steps (recorded in the server
log beside each row, not in the TSV). Deviation: swap was already in
use at session start (818.75 MB), a recorded deviation per
`state.md`; this verdict is a swap-growth stop measured against that
baseline, not against zero.

### A2 — gemma-4-26b-a4b-2x, GGUF, f16 KV

Command:

```
llama-server -hf unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL \
  --alias gemma-4-26b-a4b-2x --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 2 --parallel 2 \
  -ngl 999 -fa on -c <search> \
  --cache-type-k f16 --cache-type-v f16 \
  --jinja --port 8081 --offline
```

`-c` search (published `376832` does not load): `425984` (212992/slot
x2) OOMs at load. `212992` loads clean but OOMs on compute buffers on
a real 4096-token completion (checked from the start after the A1
lesson). `131072`, `172032`, `192512`, `202752` all pass the
4096-token check; `208896` fails it. Final: **-c 202752**
(101376/slot).

Full creep, one slot
(`benchmarks/bench10/results/creep-gemma26-gguf-2x-f16.tsv`):

| depth | decode tok/s | wired MB | free MB | swap Δ MB | compress pages | decompress pages |
| --- | --- | --- | --- | --- | --- | --- |
| 4114 | 66.63 | 25477 | 2580 | 0 | 0 | 31 |
| 8222 | 57.44 | 25476 | 2308 | 0 | 0 | 3160 |
| 16386 | 60.76 | 25474 | 2264 | 0 | 0 | 374 |
| 24602 | 52.56 | 25490 | 2039 | 0 | 0 | 559 |
| 32818 | 50.62 | 25474 | 1774 | 0 | 0 | 2382 |
| 49198 | 36.11 | 25451 | 1128 | -48 | 0 | 8487 |
| 65578 | 34.37 | 25347 | 61 | -64 | 0 | 5286 |
| 81958 | 33.56 | 25288 | 60 | -72 | 75 | 934 |

Verdict: **window**. At depth 98338 the request (102634 tokens)
exceeded the allocated `101376`-token slot — the search-bound `-c`
arrived before speed or memory did. No mem or speed stop happened up
to that point; the reported ceiling is **depth 81958 at 33.56 tok/s**,
the deepest row inside the allocated window. This is a hardware
ceiling (the model's trained window is far larger, but `-c 202752`
could not load higher on this machine), not a "stopped early" mistake.

### A3 — LM Studio, gemma-4-12b-it-mlx (row reads `pending` for memory)

Deviation: the local LM Studio model key is `google/gemma-4-12b`, not
`gemma-4-12b-it-mlx` — same local file, different registry key on this
machine. Used the local key; no download happened.

```
lms load google/gemma-4-12b --parallel 4 --gpu max -y
lms server start --port 8081
DEPTH_LIST="4096,131072" MODEL=google/gemma-4-12b \
  python3 tools/sweeps/creep_lmstudio.py
```

Prefill-jump creep, control point 4114 (35.49 tok/s, clean), jump to
131072. The jump step took 1013 s wall time (a very slow prefill, not
a dead server — two stall probes were queued behind the live step
before it answered) and landed at depth 131098: 24.36 tok/s,
**wired_mb 17249**, but swap grew 443 MB by this step.

The requested number: **`wired_mb` at the 131072 row is 17249 MB**.
Verdict on this row is mem (swap growth), so this number is the
allocation right at the edge of swap onset, not a clean steady-state
reading — noted per the row's own "pending" caveat in the runbook.
LM Studio app quit after.

## Block B — Mendel smoke, Qwen3.8 GGUF f16

## Block C — Gemma-26B GGUF f16, EvalPlus thinking on

## Block D — Bonsai MLX thinking off, Mendel

## Block E — Qwen3.8 GGUF f16, Mendel blind

## Block F — EvalPlus, the survivors
