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

Server: llama-server, `bartowski/Qwen3.8-27B-GGUF:Q4_K_M`, alias
`qwen3.8-27b`, MTP n=3, `-c 49152`, f16 KV
(`server-qwen38-gguf-f16-smoke.log`). pi entry `qwen3.8-27b`:
`contextWindow` 49152, `maxTokens` 8192, confirmed unchanged.

```
benchmarks/mendel-smoke.sh qwen3.8-27b medium
```

`SMOKE-MENDEL model=qwen3.8-27b level=medium calls=8 distinct=8
longest_run=1 loop=ok:1.00 commits=1 clean=yes end=stop wall_s=62
verdict=pass`

Gate: **pass**. Qwen3.8 GGUF continues to Block E (Mendel blind).

## Block C — Gemma-26B GGUF f16, EvalPlus thinking on

Server: published `gemma-4-26b-a4b` command, f16 KV, `-c 212992`
(`server-gemma26-gguf-f16-evalplus.log`).

Calibration, thinking on
(`benchmarks/calibration-gemma26-gguf-think.json`):

```
benchmarks/calibrate.py gemma26-gguf-think gemma-4-26b-a4b \
  '{"chat_template_kwargs":{"enable_thinking":true}}'
```

Same non-convergence as the old calibration: 2 of 10 problems
(`HumanEval/38`, `HumanEval/145`) hit `finish_reason: length` at the
30000-token cap with an empty completion. The 8 converging problems
top out at 13884 completion tokens (`HumanEval/32`). Per AGENT.md,
using `EVALPLUS_MAX_NEW_TOKENS=30000` regardless, matching the old run
so the two scores compare.

Scored run launched:

```
RESULTS_BASE=hardware/m1-max-32gb/benchmarks/bench10/results \
EVALPLUS_MAX_NEW_TOKENS=30000 \
benchmarks/run-humaneval.sh gemma26-gguf-think gemma-4-26b-a4b \
  '{"chat_template_kwargs":{"enable_thinking":true}}'
```

Run watcher and both sunset scripts started per checklist step 6.
Compare against old: 0.713/0.701 base/plus, 46/164 empty.

**Result** (`gemma26-gguf-think`, wall 3:47:00, 164/164):

pass@1 base **0.884**, plus **0.860**, empty **18/164**. A large
improvement over the old q8_0-KV score (0.713/0.701 base/plus,
46/164 empty) — this is the f16 KV row from run 9 re-scored with
thinking on.

Watcher trial note: `run-watch.sh` (the run's own watcher) required
two failed probes before a death verdict and never called one — every
silence resolved as "server alive, the run is thinking." The sunset
`liveness-watch.sh` (one probe, single failure) called **SERVER DEAD**
once mid-run on a probe that simply queued behind a live turn; the run
was not dead and finished cleanly. The two watchers did not match on
this block — `sunset/` stays for the rest of the run per the trial
rule, verdict written here for the closing comparison.

Gate: **pass** (base pass@1 0.884 ≥ 0.800). Continuing to Mendel smoke,
then Mendel blind, in this block.

Mendel smoke, thinking on (pi level `high`, from the entry's
`thinkingLevelMap`):

`SMOKE-MENDEL model=gemma-4-26b-a4b level=high calls=11 distinct=9
longest_run=1 loop=ok:1.00 commits=1 clean=yes end=stop wall_s=31
verdict=pass`

Mendel blind result: **47.5 / 100** (blind v1.1, 8/8 libraries,
complete, valid, no cap, 0 reruns). One critical bug (a `.then()` left
on `require('fs').promises` glob, trap A hit). Completion lost points
on two rimraf calls plus a `package.json` left behind, and a root
`tmp` directory. Never ran `pnpm install` (0/… on the node_modules
criterion, lockfile unchanged). Lint clean on re-run. 21 commits, 6
failed commit attempts, node trap hit 3 times, 2 model nudges.
Telemetry: 80.8 min wall, peak context 208972 (98% of the 212992
window), 1 compaction, 246 tool calls, loop verdict ok (ratio 0.25 on
tool call). Config note: f16 KV, `-c 212992`. Scored on
`claude-fable-5` per Mendel's `PLAN.md`, mendel-benchmark commit
`80c4c13` (branch `benchmark`), run branch
`gemma-4-26b-a4b-high-issue-13` pushed.

Watcher trial note: this run showed no stall or death verdict on
either `run-watch.sh` or the sunset scripts, and the memory readings
were broadly consistent between them — a match, unlike the EvalPlus
run in this same block.

Block C closed.

Gate: **pass**. Starting Mendel blind on the same server, pi level
`high`.

## Block D — Bonsai MLX thinking off, Mendel

Server: published command,
`mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit --prompt-cache-size 2 --port 8081`.
pi entry `prism-ml/Ternary-Bonsai-27B-mlx-2bit` confirmed
`thinkingLevelMap` has `"off": "off"`.

```
benchmarks/mendel-smoke.sh prism-ml/Ternary-Bonsai-27B-mlx-2bit off
```

`SMOKE-MENDEL model=prism-ml/Ternary-Bonsai-27B-mlx-2bit level=off
calls=14 distinct=11 longest_run=1 loop=ok:1.00 commits=1 clean=yes
end=stop wall_s=115 verdict=pass`

Gate: **pass**. Continuing to the guided run.

Mendel guided result: **invalid, raw 27/100** (zero commits, branch
tip still the base commit, 0/8 libraries). Harness fault, not the
model's: the first three turns hit `stream error: Connection error`
(the session's own restart-server deviation, above), then the model
tried `gh issue view 13`, got HTTP 401 (this machine's `gh` token is
invalid), and looped on an interactive `gh auth login` the prompt
forbids — 8 identical retries across 8 nudges,
`tooling_budget_exhausted`, 83.5 min wall for 394 output tokens.
Config note: `mlx_lm.server, --prompt-cache-size 2, thinking off`.
Scored on `claude-fable-5`, mendel-benchmark commit `238ae57` (branch
`benchmark`), `invalid: true` on the row.

`gh auth status` on this machine confirms the token is invalid and
`gh auth login` needs an interactive device-code flow — not fixable
from this session. **This is a stop-and-ask item for the owner**: fix
`gh` auth on the host, then re-run the guided config. Per house rules
a harness-caused retry keeps the best row with no penalty, so the
retry is free once auth is fixed. Not attempted again this session.

Watcher trial note: `run-watch.sh` saw 4 stall probes, all resolved
"server alive, thinking," no death called; the sunset
`liveness-watch.sh` saw zero stall events at all. Both agree — no
false death from either side, a match.

Block D closed (guided invalid pending owner fix; blind run is not in
this run per AGENT.md — the owner decides it from the guided score,
which did not land this session).

## Block E — Qwen3.8 GGUF f16, Mendel blind

Server: same as Block B (`qwen3.8-27b`, MTP n=3, `-c 49152`, f16 KV).

```
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh qwen3.8-27b pi blind medium
```

The blind prompt named issue 13, and this model hit the same `gh`
401 as Block D's Bonsai run — but recovered on its own, falling back
to an unauthenticated `curl` against the public GitHub API and
continuing normally. No abort needed, not a harness fault.

Result: **87/100**, 8/8 libraries, valid, complete. No bug defects
(all three traps handled correctly, trap B caught by the model's own
grep). Lost points on `node_modules` (2/8: `pnpm install
--lockfile-only` only, never a real install check) and commit craft
(9/12: one `--no-verify` commit, TASKS.md never committed). 10
commits, 2 failed commit attempts (same hook reject), 1 tooling
nudge, 0 model nudges, 4 real compactions, peak context 45705/49152
(93%). Config note: f16 KV, `-c 49152`, `maxTokens` 8192. Scored on
`claude-fable-5`, mendel-benchmark commit `1a868b5` (branch
`benchmark`), run branch `qwen3.8-27b-medium-issue-13` pushed.

This is the row that answers Block B's question: whether the GGUF
quant keeps the cell currently held by the MLX score for this model.
The editorial call is the coordinator's/owner's.

Watcher trial note: this run showed no stall or death verdict on
either `run-watch.sh` or the sunset scripts — another match.

Block E closed.

## Block F — EvalPlus, the survivors

### F1 — Gemma-26B GGUF f16, thinking off

Server: Block C's server config (f16 KV, `-c 212992`, `--parallel 1`).

Calibration: all 10 problems converged, max 945 completion tokens.
Budget = max(945×1.5, 8192 floor) = **8192**.

```
RESULTS_BASE=hardware/m1-max-32gb/benchmarks/bench10/results \
EVALPLUS_MAX_NEW_TOKENS=8192 \
benchmarks/run-humaneval.sh gemma26-gguf-off gemma-4-26b-a4b \
  '{"chat_template_kwargs":{"enable_thinking":false}}'
```
