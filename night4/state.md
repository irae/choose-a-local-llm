# Night 4 state

## Start checks

- Before block 1: make sure no model is loaded in LM Studio
  (`~/.cache/lm-studio/bin/lms ps`) and stop its server
  (`lms server stop`) — llama-server needs port 8081.
- Read `night4/lmstudio-forensics.md` and `night3/state.md` in full
  first. The forensics file changes how blocks 2-4 must run.
- No background sweep, watcher, or Monitor processes should be running
  at night 4's start.
- Branch before block 1; never push.

## Next

Block 1: bonsai-prism resume. See `night4/NIGHT-AGENT.md`.

## Run log

Branch `run4` created before block 1.

### Block 1: bonsai-prism EvalPlus resume (in progress)

- Server: `LLAMA_ATTN_ROT_DISABLE=1 ~/prism-llama/llama-server -m
  .../Ternary-Bonsai-27B-Q2_g64.gguf --alias bonsai-prism -ngl 999 -fa on
  -c 65536 --parallel 1 --cache-type-k q4_0 --cache-type-v q4_0
  --kv-mean-center /tmp/Ternary-Bonsai-27B-kv-bias.gguf --jinja --port
  8081`. Bias file already existed at `/tmp` (not wiped), no regeneration
  needed.
- `night2/mem-watch.sh` running, `MEMWATCH_INTERVAL=20`, log at
  `night2/mem-watch.log`.
- `EVALPLUS_MAX_NEW_TOKENS=10240 night3/run-humaneval.sh bonsai-prism
  bonsai-prism` resumed cleanly from the 72-line jsonl.
- Heartbeat: 76/164 lines at ~9m30s into this session's run (pace ~190s
  per problem). Desired next state: let codegen keep running unattended;
  next agent turn checks progress again and evaluates once codegen
  reaches 164.
- Heartbeat (~55 min in): 88/164 lines. No crash signatures, no compress
  bursts beyond normal in `night2/mem-watch.log`. Pace varies (one
  problem near-maxed the 10240 budget). Desired next state: keep polling
  until 164/164, then run `evalplus.evaluate`, record scores, compare
  against Bonsai MLX (0.915/0.884), update `night4/results.md`, the
  Bonsai report/benchmark pages, and the comparison table row currently
  marked "pending", commit.
- Heartbeat (~1h35m in): 96/164 lines, ~190s/problem average, no crash
  signatures, no unusual compression in the watcher log. Still healthy,
  still running unattended.
- Heartbeat (~2h35m in): 105/164 lines. Pace varies 1-4 problems per
  ~9.5 min chunk (some completions run close to the 10240 budget). No
  crash signatures, no unusual watcher activity.
- Heartbeat (~3h20m in): 112/164 lines. Still healthy, no crash
  signatures, still running unattended.
- Heartbeat (~4h20m in): 121/164 lines, 43 remaining. Still healthy.
- Heartbeat (~5h20m in): 128/164 lines, 36 remaining. Still healthy, no
  crash signatures.
- Heartbeat (~7h in): 134/164 lines, 30 remaining. Still healthy.
- Heartbeat (~8h20m in): 145/164 lines, 19 remaining. Still healthy, no
  crash signatures throughout the run.
- **Block 1 finished.** Codegen reached 164/164 (about 9h10m of codegen
  for the resumed 92 problems, no crash signatures, no unusual watcher
  activity for the whole run). Evaluate result: pass@1 base 0.927 / plus
  0.890, 4/164 empty. Compared to Bonsai MLX 2-bit (0.915/0.884): the
  prism fork's q4 KV + calibration bias scores slightly higher — the
  calibration does not cost quality. Stopped `night2/mem-watch.sh` and
  the `bonsai-prism` llama-server; GPU idle. Updated
  `night4/results.md`, `docs/setups/m1-max-32gb/reports/bonsai-27b.md`,
  `docs/setups/m1-max-32gb/benchmarks/bonsai-27b.md`, and
  `docs/setups/m1-max-32gb/comparison.md` (both pending rows for the
  prism fork q4 config). Desired next state: block 2, gemma-12b LM
  Studio ceiling confirmation sweep.

### Block 2: gemma-12b LM Studio ceiling confirmation (finished)

- Stopped LM Studio's server, restarted it on port 8081, `lms load
  google/gemma-4-12b --parallel 4 --gpu max -y` (confirmed via `lms ps`:
  CONTEXT=158464, PARALLEL=4).
- `tools/sweeps/mem-watch-fast.sh`, `MEMWATCH_INTERVAL=20`, scoped to
  this sweep only (started right before, stopped right after).
- `DEPTH_LIST="41000,49000,57000,65000,74000"
  tools/sweeps/lmstudio_sweep.py` (comma-separated, not space-separated
  — the script errors on spaces).
- Result: 41,095→31.05, 49,112→30.25, 57,077→29.25, 65,094→29.29 (all
  clean, no compression), 74,099→27.95 (watcher shows compression burst
  onset inside this step, up to 114,012 pages, plus a swapout burst).
  **Ceiling = onset between 65K and 74K used tokens. Last clean tok/s =
  29.29 at 65,094 tokens.** Context-window figure stays 158,464, flagged
  as the loader's auto-fit estimate (trained max 262,144 in a
  footnote) — matches the forensics prediction ("onset inside the
  74,108-token step").
- Updated `docs/setups/m1-max-32gb/reports/gemma-4-12b-it.md` (new
  ceiling table with watcher state per step),
  `docs/setups/m1-max-32gb/models.json` (maxCtx 158k*, gatedBy mem,
  tokDeep 29.29, regenerated `comparison.md` and `docs/index.md` via
  `node tools/gen-tables.mjs`), the floor table in `comparison.md`
  (hand-maintained, not generated), the highlights bullet, and
  `docs/setups/m1-max-32gb/historical.md` (old 170K/29.7 reading
  labeled superseded, with the reason).
- Also filled the Bonsai prism-fork EvalPlus cell in `models.json`
  (0.927/0.890, from block 1) so the regenerated tables carry it
  consistently.
- Left `google/gemma-4-12b` loaded (parallel 4) for block 3, which
  reuses this server. Desired next state: block 3, Gemma-12B
  thinking-on EvalPlus (calibrate budget first).
