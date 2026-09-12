# Run 15 — state

Created 2026-09-11 by the coordinator. Not started.

Start here: read `AGENT.md`. The list at the top of that file is the
order. Log every session below, and close each one with a
handing-over section.

## Session 1, 2026-09-11

Worktree `../choose-a-local-llm-run15`, branch `run15`. Preflight: all
`ok`. Starting numbers: wired 1674 MB, free 18329 MB, swap used 493 MB.
Balloon needed (free under the 25600 MB threshold) — the first server
load drives context up slowly, no synthetic balloon.

Started block `bartowski-evalplus-xhigh`. Server up, model loaded,
rev `f0eec4a` confirmed in the log.

Deviation: `benchmarks/calibrate.py` has a `#!/usr/bin/env python3`
shebang, so a direct call uses the system Python, which lacks
`openai`. Ran it with the evalplus pipx venv's Python instead (the
same fix `run-humaneval.sh` already applies to
`run_codegen_wrapper.py`): `PYBIN="$(head -1 "$(command -v
evalplus.codegen)" | sed 's/^#!//; s/ -E$//')"`, then `"$PYBIN"
benchmarks/calibrate.py ...`. Not a stop-and-ask; the run did not
wait.

**Order change from the coordinator.** Before the calibration finished,
the coordinator moved `bartowski-evalplus-xhigh` to last (commit
`6658e34`). Stopped the calibration task and the server (pid 32036,
started by this session). Merged `origin/master` into `run15`
(`c287c6e` → `6658e34`), pushed `run15`. Ran `npm run pi:models`: the
`qwen3.6-35b-a3b-f16` alias already matches the site data, its
`thinkingLevelMap` already copied from the sibling `qwen3.6-35b-a3b`
entry (`off`/`off`, `high`/`high`, rest `null`) — nothing to hand-copy.
Pulled the sweep tool: `local-llm-eval-tools` at `e38c467`.

New order: `qwen36-f16-ladder-creep`, `qwen36-f16-mendel-on`,
`vision-ladder`, `bartowski-evalplus-xhigh`, `retry-sweep`.

Note: `hardware/m1-max-32gb/calibrations/calibration-qwen38-gguf-xhigh.json`
holds only 1 of 10 problems (the calibration task was stopped for the
order change). Not a valid calibration. Re-run it in full when the
`bartowski-evalplus-xhigh` block starts.

Starting block `qwen36-f16-ladder-creep`.

Block `qwen36-f16-ladder-creep` closed. Served `-c` 65536 (top of
DEPTH_LIST, no ceiling found, `gatedBy: untested`). Deepest clean depth
65578. See `results.md` for the full table. Server (pid 40217) kept
running at `-c 65536` for the next block, same config.

Starting block `qwen36-f16-mendel-on`. `gh auth status` ok. Window =
largest multiple of 8192 at or under `qwen36_f16_clean` (65578) =
65536. Server (pid 40217) kept from the block above, same config.
`MENDEL_CONTEXT_WINDOW=65536 ./run-worker.sh qwen3.6-35b-a3b-f16 pi
blind on`, pid 43368. Branch `qwen3.6-35b-a3b-f16-on-issue-13` (none
existed). Watcher started (pid 44515),
`results/run-watch-mendel-qwen36-on.log`.

Block `qwen36-f16-mendel-on` closed. `end_reason: complete`, 33 min
wall, well inside the 300-min cap. Scored by subagent: **50/100**,
worst defect critical (trap A, `.then()` over `fs.promises.glob`).
`qwen36_f16_on` = 50/100, peak_context 61485/65536 (93.8%, corrected
from an earlier 45332 closing-read). Published to
`~/code/mendel-benchmark` branch `benchmark`, commit `57722e8`. Full
detail in `results.md`. Server and watcher stopped, wired recovered
before the next block.

Starting block `vision-ladder`. Page image built (deviation:
`textutil -convert pdf` unsupported on this machine, no PDF filter in
`cupsfilter` either — fell back to `qlmanage -t` directly on the RTF,
skipping the PDF step entirely; image verified to show the whole
table). Server A (Qwen3.6 f16, `-c 65536`) served both requests clean.
Server B (Gemma-26B, `-c 204800`) crashed on the image chunk at the
default ubatch (512) — `n_ubatch >= n_tokens` assertion — fixed by
`--ubatch-size 2048`; both requests then served (the filled one hit
`max_tokens` still reasoning, `finish_reason: length`, no crash — not
judged, per the block's own rule).

Block `vision-ladder` closed. `vision_qwen36_c` = 65536,
`vision_gemma26_c` = 204800. Full table in `results.md`.

Coordinator answer: hold `bartowski-evalplus-xhigh` (budget decided
after the vision work). Stopped the EvalPlus server. Owner added
`vision-ladder-up`, `vision-drafter-shallow`, `vision-benchy` before
it. Merged `origin/master` (`6658e34` → `ae1f314`), pushed `run15`.

Starting block `vision-ladder-up`. Qwen3.6 failed its first rung
(`-c 73728`, Insufficient Memory/Compute error on the real request) —
`vision_qwen36_c` stays 65536. Gemma-26B failed its probe (`-c
212992`, same failure mode) — `vision_gemma26_c` stays 204800. Full
evidence in `results.md`. Block closed, neither value moved.

Coordinator's arm pick: Qwen3.6 runs both no-drafter and `n-max 1` at
`-c 65536`; Gemma-26B runs no-drafter only at `-c 204800`/ubatch 2048
(lowering `-c` to fit a drafter is a different configuration, not
this block). Three benchy servers total.

Starting block `vision-benchy`. Corpus server up on :8089. Deviation:
AGENT.md's own example command passes `--depth` as a comma-joined
string (`--depth <depths>`); `llama-benchy --help` shows `--depth
DEPTH [DEPTH ...]` — space-separated, not comma-separated. A
comma-separated call errors immediately (`invalid int value`).
Every call in this block uses space-separated depths instead. Not a
stop-and-ask; the run did not wait.

Starting block `vision-drafter-shallow`.

Qwen3.6 table closed: no-drafter 50.36 tok/s mean; the model card's
claim that projector+MTP drafter don't work together did not hold —
`n-max 1` loaded and served (54.77 tok/s mean, faster than
no-drafter, acceptance 0.889/0.693), `n-max 2` and `3` both OOM'd on
the real request (same signature as `vision-ladder-up`'s failed
climbs); `n-max 4` not tested, inferred to fail the same way (memory
cost grows monotonically with `n-max`).

Gemma-26B table closed: no-drafter 54.29 tok/s mean; `n-max 1` OOM'd
immediately (no headroom left at `-c 204800`); `n-max 2-4` not
tested, inferred fail.

Full tables in `results.md`. Sent both to the coordinator session
"local-llm manager/coordinator/orchestrator" per the block's own
gate; holding for the coordinator's drafter-arm pick per model
before `vision-benchy` starts.

Coordinator answer: Qwen3.6 runs both no-drafter and `n-max 1`
(`-c 65536`); Gemma-26B runs no-drafter only (`-c 204800`/ubatch
2048). Three benchy servers.

`vision-benchy` closed, all three arms done:
- Qwen3.6 no-drafter: 48.84 (4k) → 39.74 (32.8k) → 33.12 (64.5k) tok/s.
- Qwen3.6 n-max 1: 53.88 → 43.68 → 33.85 tok/s, acceptance 0.78-0.94,
  faster than no-drafter at every depth.
- Gemma-26B no-drafter: 53.11 (4k) → 28.28 (98.3k) → 19.24 (203.8k)
  tok/s. The corpus-too-short worry (an earlier report of ~152204
  tokens available) did not hold; the deepest depth ran clean.

No swap growth on any arm. Full tables in `results.md`. Corpus
http.server (:8089) and the last vision server stopped. Vision work
(`vision-ladder`, `vision-ladder-up`, `vision-drafter-shallow`,
`vision-benchy`) is complete. Server loaded, rev
`f0eec4a` confirmed, warmed up.

Deviation: the harness's own background-task monitor killed the
xhigh calibration client process for host memory pressure (system-level
"running low on memory" event) partway through problem 7 of 10. The
server (pid 93405) was not affected — it kept running, cleanly
cancelled the in-flight task, and stayed responsive at its normal
speed (~14 tok/s). Swap was in heavy use at the time (`vm.swapusage`:
1421.75M used of 2048M). `calibrate.py` resumes from its own output
file by `task_id`, so the 6 already-done rows were kept (one,
`HumanEval/32`, hit the 30000-token cap) and the run resumed from
problem 7. Not a stop-and-ask; the run did not wait.

Second interruption of the same kind, at problem 8 of 10. Investigated:
this is not a machine fault. `ps aux` shows `llama-server` itself at
59.1% of the machine's RAM (about 19 GB RSS, expected for a 27B q4
model with `-c 32768`), nothing else abnormal running. The killed
process each time is this session's own detached background-task
monitor (the harness's own low-memory protection for its child
processes), not the llama-server or the calibration's own data — the
server stayed up and healthy both times (cleanly cancelled the
in-flight task, unaffected tok/s afterward), and `calibrate.py`'s
resume-by-`task_id` picked up cleanly both times with no data lost.
Resumed again from problem 8. Flagged to the coordinator as a
machine-health note, not a run blocker. (Two more of the same benign
kill happened on problems 8 and 10, each resumed the same way with no
further investigation, no data lost.)

Calibration complete, 10/10, every row confirmed
`resolved_reasoning_effort: xhigh`.

| task_id | completion_tokens | finish_reason |
|---|--:|---|
| HumanEval/0 | 1073 | stop |
| HumanEval/10 | 11697 | stop |
| HumanEval/26 | 377 | stop |
| HumanEval/32 | 30000 | length (capped) |
| HumanEval/38 | 1192 | stop |
| HumanEval/53 | 290 | stop |
| HumanEval/76 | 6198 | stop |
| HumanEval/99 | 30000 | length (capped) |
| HumanEval/124 | 3643 | stop |
| HumanEval/145 | 28564 | stop |

Two problems (`HumanEval/32`, `HumanEval/99`) hit the 30000-token cap
— AGENT.md's stop-and-ask condition. Gate sent to the coordinator
session "local-llm manager/coordinator/orchestrator" with the full
table and a candidate answer: budget 30000 (matches the runbook's own
single-cap/ISTA-precedent value; `HumanEval/145`'s 28564 stop shows
the model does converge near that ceiling on its own). Holding the
full EvalPlus run until the coordinator answers. Server (pid 93405)
kept loaded. Nothing queued behind this block to fill the wait —
`retry-sweep` has nothing to retry yet, every earlier block closed
clean — so the GPU sits loaded-but-idle, which is the explicit
stop-and-ask exception to the no-idle rule.

## Values this run sets

The runner writes each value here as it measures it, with the block
that produced it.

| name | value | block |
| --- | --- | --- |
| `bartowski_evalplus_xhigh` | 0.957/0.939 | `bartowski-evalplus-xhigh` |
| `qwen36_f16_c` | 65536 | `qwen36-f16-ladder-creep` |
| `qwen36_f16_clean` | 65578 | `qwen36-f16-ladder-creep` |
| `qwen36_f16_on` | 50/100 | `qwen36-f16-mendel-on` |
| `vision_qwen36_c` | 65536 | `vision-ladder` |
| `vision_gemma26_c` | 204800 | `vision-ladder` |

## Session 1 continued — bartowski-evalplus-xhigh starts

Coordinator's gate answer: budget 30000, start the full set now with
the calibration already in hand. Started block
`bartowski-evalplus-xhigh`: server up (pid 36308), rev `f0eec4a`
confirmed, warmed up.
`RESULTS_BASE=hardware/m1-max-32gb/benchmarks/bench15/results
EVALPLUS_MAX_NEW_TOKENS=30000 benchmarks/run-humaneval.sh
bartowski-evalplus-xhigh qwen3.8-27b
'{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}'`, pid 37258.
Watcher started (pid 37757), `results/run-watch-evalplus.log`,
watching
`results/bartowski-evalplus-xhigh/humaneval/qwen3.8-27b_openai_temp_0.0.jsonl`.
Expect about ten hours; the owner may pause it between problems and
resume via the codegen's own task_id skip (not an interruption for
`retry-sweep`).

Owner correction: stop sending a coordinator message on every 20-minute
status tick. The coordinator only hears from the runner at a real push
(block close, gate, restart) — the tick's short status line stays in
chat only, per `status-lines.md`. Applying this from here on.

Coordinator correction (not a deviation): an xhigh completion on this
model runs past the watcher's 600s default silence window, which gave
run 13 a false dead-server verdict. Stopped the first watcher (pid
37757, silence 600s default) and restarted with `RUNWATCH_SILENCE=2700`
(pid 43035), same server log, same output file, same base URL and
model. Server (pid 36308) and the codegen run (pid 37258) were not
touched.

Block `bartowski-evalplus-xhigh` closed. 164/164, base 0.957, plus
0.939, 6/164 empty, active wall 8:30:20. `bartowski_evalplus_xhigh` =
0.957/0.939 (see `results.md` for the full breakdown and both
deviations: the four benign memory-guard kills of the calibration
client, and the one watcher restart at `RUNWATCH_SILENCE=2700`).
Server and watcher stopped.

## Handing over, session 1 close, 2026-09-12

Every block in the run's order is closed:
`qwen36-f16-ladder-creep`, `qwen36-f16-mendel-on` (scored 50/100,
published to mendel-benchmark), `vision-ladder`, `vision-ladder-up`,
`vision-drafter-shallow`, `vision-benchy`, `bartowski-evalplus-xhigh`
(scored 0.957/0.939). `retry-sweep` has nothing to do — every block
closed clean, no killed or interrupted rows from this run. The run's
real work is done.

Machine state: no server running, no watcher running, GPU idle, wired
at baseline. Evidence archived: `tools/archive-evidence.sh
hardware/m1-max-32gb/benchmarks/bench15/results run15` — 36 files to
`~/.local/share/choose-a-local-llm/evidence/run15`.
