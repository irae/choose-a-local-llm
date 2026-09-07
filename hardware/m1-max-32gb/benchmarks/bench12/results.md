# Run 12 — results

One section per block, in run order. Every number with the exact
command that produced it and the file under `results/` that holds the
evidence.

## Pre-block prep — wired 24000 ceilings for Qwen3.6 GGUF, q8_0 and f16 (2026-09-07)

Not a scored block. This answers `AGENT.md`'s open wired-limit
question (`24000 or 25000`) with fresh numbers at 24000, found while
debugging a `local-llm-eval-tools` compaction issue on the same
machine, same day. Full tool-side evidence, both false-positive and
real findings, is on that repo's `creep-ab-verdict` and
`creep-configurable-thresholds` branches (not part of this repo).

Server command for both arms, wired 24000:
```
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c <value> \
  --cache-type-k <q8_0|f16> --cache-type-v <q8_0|f16> \
  --jinja --port 8081 --offline
```

**q8_0 KV.** Binary search the same way as run11's block 1, but with a
real sweep step as the completion test, not a one-token warmup: a
one-token probe passed at `-c 49920` and failed at `-c 50368`
(`results/server-qwen36-gguf-q8-c49920-w24000-oom.log`), but the first
real creep step at `-c 49920` still hit a Metal OOM
(`kIOGPUCommandBufferCallbackErrorOutOfMemory`) on the actual sweep
prompt size. **`-c 40960` is the value confirmed to serve real sweep
traffic at wired 24000** — a one-token probe is not a safe ceiling
test for this config; use a real request the size of the intended
workload.

Creep, q8_0, `-c 40960`, wired 24000, `STEP_PAUSE_S=60`, default
`COMPACT_PAGES`/`RECOVERY_FRACTION`/`MAX_COMPACTING_STEPS` (the
published thresholds, unmodified):
`results/creep-qwen36-gguf-q8-w24000-c40960.tsv` (old tool),
`results/creep-qwen36-gguf-q8-w24000-c40960-newtool.tsv` (new tool,
`local-llm-eval-tools`). Both tools agree row for row:

| depth_tokens | decode_toks (old) | decode_toks (new) |
| --- | --- | --- |
| 4114 | 36.66 | 36.60 |
| 8222 | 44.17 | 43.85 |
| 16386 | 31.25 | 31.04 |
| 24602 | 24.18 | 24.15 |
| 32818 | 19.65 | 19.60 |

Both stop at depth 32818 with a `mem` verdict (sustained
compress/decompress above 200 pages, 3 steps, speed did not recover).
**This point is flagged, not accepted at face value**: the same
compaction check fires from ordinary speed decay at this depth range
even with no real memory problem (see the `local-llm-eval-tools`
branches above for the same-day evidence and the env-configurable fix
for `RECOVERY_FRACTION`/`MAX_COMPACTING_STEPS`). Zero swap growth in
either run at wired 24000. **Recommend re-running this creep with
loosened thresholds before treating 32818 as a hard ceiling for
gating**; `-c 40960` itself is confirmed safe to serve.

**f16 KV.** Binary search at wired 24000 (same method): `-c 33792`
loads and serves a real completion; `-c 33920` fails the same Metal
OOM way (`results/server-qwen36-gguf-f16-c33792-w24000.log`). Compare
run11's f16 arm at wired 25000, which reached `-c 40960` — 1000 MB
less wired limit costs about 7100 tokens of window on this model.

Creep, f16, `-c 33792`, wired 24000, ladder to 32768, four runs (old,
new, old, new), loosened thresholds
(`COMPACT_PAGES=5000 RECOVERY_FRACTION=0.75 MAX_COMPACTING_STEPS=6`),
`STEP_PAUSE_S=60`:
`results/creep-qwen36-gguf-f16-w24000-c33792.tsv` (old, run 1),
`results/creep-qwen36-gguf-f16-w24000-c33792-newtool-run1.tsv` (new,
run 1), `results/creep-qwen36-gguf-f16-w24000-c33792-run2.tsv` (old,
run 2), `results/creep-qwen36-gguf-f16-w24000-c33792-newtool-run2.tsv`
(new, run 2). All four runs: `no ceiling found up to 32768`, zero or
negative `swap_delta_mb` on every row, both tools agree the refactor
is not the cause of anything seen. Decode speed and page-churn swing
widely run to run even on identical unmodified code (old tool alone:
40-54 tok/s one run, 21-27 tok/s the next) — read this as machine
noise between runs, not a tool or config signal.

**Working conclusion, not yet a gate decision:** wired 24000 served
both arms today with zero swap growth, at smaller windows than wired
25000 (`-c 40960` vs `-c 98304` for q8_0's confirmed-safe ceiling;
`-c 33792` vs `-c 40960` for f16). Wired 25000 produced real swap
growth under sustained back-to-back sweeps with no recovery gap
between them (see the `local-llm-eval-tools` branches); it has not
been tested with proper recovery gaps between sweeps, so "25000 always
swaps" is not established, only "25000 swapped under the stacking
pattern tested so far." The coordinator should read the linked
branches in full before setting `AGENT.md`'s wired-limit line for this
run.
