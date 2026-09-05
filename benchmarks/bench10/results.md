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

## Block B — Mendel smoke, Qwen3.8 GGUF f16

## Block C — Gemma-26B GGUF f16, EvalPlus thinking on

## Block D — Bonsai MLX thinking off, Mendel

## Block E — Qwen3.8 GGUF f16, Mendel blind

## Block F — EvalPlus, the survivors
