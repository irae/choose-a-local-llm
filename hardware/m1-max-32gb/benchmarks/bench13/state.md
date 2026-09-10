# Run 13 — state

Created 2026-09-09 by the coordinator. Started 2026-09-09.

Start here: read `AGENT.md`. The list at the top of that file is the
order. Log every session below, and close each one with a
handing-over section.

## Session 1, 2026-09-09

- Worktree: `../choose-a-local-llm-run13`, branch `run13`.
- Machine file already had `wired_limit_mb` 25000; the "stale 24000"
  note in `AGENT.md` no longer matched the file, so no fix was needed.
- `tools/preflight.sh`: every line `ok`. Balloon needed. Start
  numbers: wired 1526 MB, free 24688 MB, swap used 384 MB.
- Sweep tool: `local-llm-eval-tools` was on a stale branch
  (`creep-ab-verdict`) whose remote ref had been deleted after merge.
  Switched to `master`, pulled. `creep_tool_hash`: `e38c467`.
- `ista-nmax-shallow` done: table in `results.md`. Coordinator
  corrected the block's own output (no pick, table only) and set
  `ista-nmax-deep` back to all five cells.
- `ista-nodrafter-creep` done: `-c 163840` served the probe clean, no
  bisection needed. Ceiling 147478 tokens at 8.30 tok/s, verdict
  speed. Full table in `results.md`.
- `ista-serving-pick` blocked: this block asks the runner to choose
  between configs, which now belongs to the coordinator (a block
  reports a measurement, not a choice). Flagged to the coordinator
  with the data on hand. Every later block depends on `ista_serving`
  and `ista_window`, so the run is gated here until the coordinator
  answers.
- Merged `origin/master` twice more while waiting: `6645657` (moved
  `ista-nmax-deep` ahead of the pick, fixed `-c 122880`, one
  measurement per cell at depth 98338) and `e1711c7` (named the
  branch rule in `AGENT.md`'s Essentials).
- `ista-nmax-deep` done, all five cells at `-c 122880`, depth 98338:
  table in `results.md`. Acceptance at depth is close to the shallow
  block's numbers.
- Merged `origin/master` again: `67f3e36`. The coordinator's
  research-run-3 read was wrong: those 1.000-acceptance lines were
  47-token steps, and the real figure on a substantial generation is
  0.778, in line with this run's numbers. Re-ran `none` on a fresh
  server with the filler and instruction in one request, `prompt_n`
  98610: 9.496 tok/s, wired 21227 MB, confirms the original row.
- Coordinator's gate released: no drafter wins on both speed and
  window, no trade to weigh. `ista_serving`, `ista_window` and
  `ista_evalplus_serving` set below. `ista_evalplus_serving`'s `-c
  32768` is the coordinator's own call, flagged as unmeasured on this
  build; the first `ista-evalplus-low` request confirms it works
  before the full set.
- `ista-smoke-xhigh` done: pass, 182s, one commit, clean tree, no
  loop. Full line in `results.md`.
- Long-prompt completion check done (mandatory, `ista_window` above
  120K): real content at depth 144510, not a silent EOS. Safe to run.
- Flagged the pi model id before `ista-mendel-xhigh`: `AGENT.md` named
  the bare `qwen3.8-27b`, which is a different, non-ISTA build in
  `~/.pi/agent/models.json` and would have made the row
  indistinguishable from the 4-bit control's. Coordinator corrected
  the runbook (`758e3cd`) to `qwen3.8-27b-ista`. Merged.
- `ista-mendel-xhigh` done: branch `qwen3.8-27b-ista-xhigh-issue-13`,
  17 commits, loop ok (0.38), 109.4 min, peak context 117,940/147,456,
  no compaction. Scored on `claude-opus-5`: 80.5/100 (coordinator's
  ruling on criterion 1 — count the critical only, since trap B is
  criterion 2's own named finding). Full matrix in `results.md`.
- `ista-smoke-low` done: pass, 139s, one commit, clean tree, no loop.
  Full line in `results.md`. Next: `ista-mendel-low`.
- `ista_temperature` read from the run's own `meta.json`
  (`server_context.props.default_generation_settings.params`):
  temperature 1.0, top_p 0.95. `AGENT.md`'s
  `~/.local/share/mendel-benchmark/` path does not exist on this
  machine; the sampling values are recorded in `<slug>-meta.json`
  instead (`PLAN.md`, "Pinned thinking level and sampling").
- Coordinator confirmed this is the first Mendel row this project
  publishes with sampling recorded, and traced it to llama-server
  reading `general.sampling.*` from the model file. Confirmed
  `~/code/mendel-benchmark` was on the old worker (`134b1d6`); pulled
  to `154b9af` after `ista-mendel-low` closed, before writing rows
  (coordinator's ordering, to avoid a conflict with two upstream
  commits that also touch `results.json`/`results.csv`).
- `ista-mendel-low` done: branch `qwen3.8-27b-ista-low-issue-13`, 15
  commits, loop ok (0.30), 163.3 min, peak context 130,154/147,456, no
  compaction. Scored on `claude-opus-5`: 66/100 (trap A and trap C both
  hit, trap B excluded per the settled convention). Comparison table
  in `results.md`: xhigh wins on score and spends less context doing
  it.
- Correction on `ista-mendel-low`: its `meta.json` reads `end_reason
  turn_timeout`, not the clean stop the worker log's "done" line
  implied. Marked `partial: true` in the published row. Caught by the
  subagent that wrote the row, not by this session's own read.
- Both rows written to `mendel-benchmark` on `154b9af`, `generate-report.mjs`
  run, `results.csv` appended by hand (the generator does not write
  it), pushed `benchmark` at `f14a235`.
- `ista-evalplus-low`: server at `ista_evalplus_serving` (no drafter,
  `-c 32768`) confirmed serving with a real completion. Calibration
  done: 1/10 length stops (`HumanEval/99`), below the two-stop
  non-convergence threshold; three other problems ran 22K-27K
  reasoning tokens before stopping naturally, a long tail flagged in
  `benchmarks/calibration.md`. Budget 30000. Launched the full set.
- Coordinator held the full run: 10 problems at ~13.9 min average
  projects to ~35h for 164, against medium's 3h07 at budget 8192.
  Asked for the raw wall_s and token counts from both calibrations.
- **Bug found while pulling those numbers**: the "low" calibration ran
  `calibrate.py` with no extra-body argument, so no `reasoning_effort`
  was sent. The chat template defaults to `xhigh` when unset (read
  from `meta.json`'s `server_context.props.model_info.chat_template`).
  So the calibration I reported as "low" ran at xhigh. Stopped the
  xhigh calibration I had just started to keep the machine busy (it
  would have duplicated this by accident), renamed the mislabeled file
  to `calibration-qwen38-ista-mtp-low-MISLABELED-actually-xhigh.json`,
  and re-ran the low calibration with the `reasoning_effort` argument
  passed explicitly this time. The full EvalPlus run's own
  `run-humaneval.sh` call did carry the argument correctly (verified:
  `EVALPLUS_EXTRA_BODY` was set from the third CLI argument, which I
  did pass); only the standalone `calibrate.py` invocation was wrong.
  Mendel's smoke/mendel-low runs are unaffected: pi's harness sets the
  thinking level through its own CLI flag and `thinkingLevelMap`, a
  different code path from `calibrate.py`'s `extra_body`.
- Coordinator's ruling: keep the low calibration once it finishes, do
  not re-calibrate xhigh (the mislabeled file is a valid xhigh
  calibration, renamed to `calibration-qwen38-ista-mtp-xhigh.json`),
  start the full low gate and expect to stop/resume it. The 35h
  projection was wrong: the set is bimodal, and medium's fast path
  (86.4s/problem) held for 9 of 10 low problems, so the real range is
  roughly 8-36h depending on the runaway rate across all 164.
- Corrected low calibration done: all 10 `stop`, non-empty, no
  runaways, avg 95.4s/problem. Budget 8192 (floor). Both calibration
  files now carry a sibling `.resolved-effort.txt` recording what
  `server_context.props` actually resolved.
- Starting the full low gate: `RESULTS_BASE=hardware/m1-max-32gb/benchmarks/bench13/results`,
  run name `ista-evalplus-low`. Completions land at
  `hardware/m1-max-32gb/benchmarks/bench13/results/ista-evalplus-low/humaneval/qwen3.8-27b_openai_temp_0.0.jsonl`.
  If this spans into a later run, resume from that path with the same
  `RESULTS_BASE` and run name; `evalplus.codegen` skips existing
  `task_id`s on restart.
- Status, on the manager's request (2026-09-10): no fresh
  `qwen38-ista-mtp-xhigh` calibration ran. One was started (pid 1701)
  and killed within seconds, before it produced any row, once the
  mislabeling bug was found. No new xhigh calibration is needed or
  queued; the renamed file on disk
  (`calibration-qwen38-ista-mtp-xhigh.json`, with its
  `.resolved-effort.txt`) is the valid one, already committed
  (`13542b2`). `ista-evalplus-low`: 39/164 task_ids in the completions
  jsonl, elapsed 27:21, 0 length stops so far (max generation 2380
  tokens against the 8192 budget). Not stopped. Noted for later: master
  has a new `calibrate.py` that records `requested_extra_body` and
  `resolved_reasoning_effort` per row; will use it on the next fresh
  calibration, not mid-run.
- `ista-evalplus-low` done: 164/164 codegen'd, 1 runaway (hit the 8192
  cap, empty content), wall about 2h23min.
  `evalplus.evaluate` failed on every problem the first pass:
  `pass@1: 0.000` both base and plus, a harness bug. Root cause:
  `reliability_guard()`'s `RLIMIT_AS`/`RLIMIT_DATA` calls raise
  `ValueError: current limit exceeds maximum limit` on macOS, the
  same bug bench1 documented and fixed in a different venv
  (`~/.local/pipx/venvs/evalplus/`); this session's venv
  (`~/.venvs/local-llm-bench/`) never got the patch. Extended the
  Darwin exemption to all three `setrlimit` calls in that venv's
  installed `evalplus/eval/utils.py`, deleted the stale
  `_eval_results.json` (or `evaluate` reuses the cached zero), re-ran
  evaluation only. Real result: pass@1 0.976/0.933, 1/164 empty,
  level with medium (0.976/0.945, one empty) on base.
- Coordinator confirmed the xhigh calibration is a skip, not a
  resume: 10 rows, 9 `stop`, 1 `length` (`HumanEval/99`, 30000 cap,
  empty), one length stop under the two-stop threshold. Started the
  full xhigh gate: `RESULTS_BASE=hardware/m1-max-32gb/benchmarks/bench13/results`,
  budget 30000, `reasoning_effort: xhigh` passed explicitly, same
  server as the low gate (no drafter, `-c 32768`, f16 KV). Completions
  land at `hardware/m1-max-32gb/benchmarks/bench13/results/ista-evalplus-xhigh/humaneval/qwen3.8-27b_openai_temp_0.0.jsonl`.
  If this spans into a later run, resume from that path with the same
  `RESULTS_BASE` and run name. Watcher running
  (`RUNWATCH_MEM_LOG` `/tmp/run13-evalplus-xhigh-mem.log`). Applying
  the `reliability_guard` venv fix before evaluating; do not skip it
  again.
- First watcher declared the server dead at the default `SILENCE`
  600s: a false positive. The server was confirmed alive and actively
  generating (task 265799, 24871 tokens, 13.42 tok/s at the time) — a
  single generation on this raw completion path (no streaming) can run
  30+ minutes at xhigh's runaway lengths, past the default silence
  window. Restarted the watcher with `RUNWATCH_SILENCE=2700` (45 min),
  recorded here since a ceiling measured with a changed silence value
  must say so (`context-creep.md`'s rule for `STALL_S`, applied the
  same way to this scoring run's watcher).
- **Owner paused `ista-evalplus-xhigh` for later resume.** Stopped
  codegen at the moment a completion landed (right at the start of the
  following problem, never mid-generation), so no partial work was
  lost. Progress at pause: **76/164 task_ids** in
  `hardware/m1-max-32gb/benchmarks/bench13/results/ista-evalplus-xhigh/humaneval/qwen3.8-27b_openai_temp_0.0.jsonl`,
  2 confirmed runaways (cap hits) so far. Server stopped
  (`ista_evalplus_serving`, no drafter, `-c 32768`, f16 KV). To
  resume: start that server, confirm it serves, then re-run the same
  command — `evalplus.codegen` skips existing `task_id`s and continues
  with 76-163:

  ```bash
  RESULTS_BASE=hardware/m1-max-32gb/benchmarks/bench13/results EVALPLUS_MAX_NEW_TOKENS=30000 \
    benchmarks/run-humaneval.sh ista-evalplus-xhigh qwen3.8-27b '{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}'
  ```

  Start a fresh watcher with `RUNWATCH_SILENCE=2700` (not the
  default), for the same reason recorded above. Delete the stale
  `_eval_results.json` before `evalplus.evaluate` if one exists from a
  prior partial evaluate attempt (there is none yet here). Apply the
  `reliability_guard` venv fix before evaluating if this resumes on a
  fresh venv.
- **Resumed.** Owner asked for a warmup first: killed LM Studio (was
  not running), preflight all `ok`, then a slow creep to 32768 on
  `ista_evalplus_serving` as a machine warmup, not a scored sweep —
  clean all the way, swap flat, `no ceiling found up to 32768`.
  `run-humaneval.sh` correctly skipped all 76 completed `task_id`s
  (confirmed in `codegen.log`, `(resuming from 1)` on each) and picked
  up at `HumanEval/76`. Fresh watcher started, `RUNWATCH_SILENCE=2700`.

## Values this run sets

The runner writes each value here as it measures it, with the block
that produced it.

| name | value | block |
| --- | --- | --- |
| `creep_tool_hash` | `e38c467` | the session's first creep |
| `ista_nodrafter_c` | `163840`, ceiling 147478 @ 8.30 tok/s | `ista-nodrafter-creep` |
| `ista_serving` | no drafter (no `--spec-type`, no `--spec-draft-n-max`), `-c 163840` | coordinator gate |
| `ista_window` | `147456` | coordinator gate |
| `ista_evalplus_serving` | no drafter, `-c 32768`; confirmed serving, calibrated (corrected), budget 8192 | `ista-evalplus-low` |
| `ista_temperature` | temperature 1.0, top_p 0.95 (from `<slug>-meta.json`, not the AGENT.md path, which does not exist) | `ista-mendel-xhigh` |

## Projector restore and checksum audit

Owner request, done disk-only, sequential, alongside the running
`ista-evalplus-xhigh` gate (checked the gate's jsonl line count grew
between each repo; it was mid a long completion for the middle stretch,
confirmed alive via the server log each time, never stalled). Did not
touch the `OBLITERATUS` files under LM Studio's cache; those are the
owner's own. Checksums came from the Hugging Face API's LFS `oid`
per file at the pinned revision, saved to
`results/checksums-<repo-short>.txt`. Downloaded the missing projector
with `hf download <repo> <file> --revision <rev>` (the `hf` CLI lives
in `~/.venvs/local-llm-bench`; no `huggingface-cli` or `hf` on the bare
`PATH`). Computed sha256 on every `.gguf` in each snapshot by following
the symlink to its blob, never trusting the blob filename.

| repo | file | expected oid | computed sha256 | result |
| --- | --- | --- | --- | --- |
| `bartowski/Qwen3.8-27B-GGUF` | `Qwen3.8-27B-Q4_K_M.gguf` | `e103abf9d914d1d7b2f2592f055f2759a71195c350a01c135f71aaae86bca52b` | same | match |
| `bartowski/Qwen3.8-27B-GGUF` | `mmproj-Qwen3.8-27B-bf16.gguf` | `e43a597863a21bfa48b0fbd4553a771ae4117e25bb172e66f1dbc3fc6d037131` | same | match |
| `unsloth/Qwen3.6-35B-A3B-MTP-GGUF` | `Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf` | `55983c5a75a1ab969824077b3bb3de4146e82a9234072b48ad4e8f92ad3fe9f1` | same | match |
| `unsloth/Qwen3.6-35B-A3B-MTP-GGUF` | `mmproj-BF16.gguf` | `da63cb47a76763c712393f8a017070188a304fa39f8aeea6edc629ed7b975cfa` | same | match |
| `unsloth/gemma-4-26b-a4b-it-GGUF` | `gemma-4-26B-A4B-it-UD-Q4_K_XL.gguf` | `ef728c8e0c337fd1067b947af006e38a9ef2419e56feced4fd29b4bf0636e30c` | same | match |
| `unsloth/gemma-4-26b-a4b-it-GGUF` | `mmproj-BF16.gguf` | `41926ed5f1403cf5add23b0684992805ea6f97253096132e769e65646b8cef9d` | same | match |
| `unsloth/gemma-4-26b-a4b-it-GGUF` | `mtp-gemma-4-26B-A4B-it.gguf` | `6326fb9f5e487aa8dcdd313a091e3c67724cb2a666ec3b7d2895b5b26d93ed1b` | same | match |

All three repos pass. No mismatch, so no delete-and-redownload step
ran (step 5 of the request). Note on the `unsloth/gemma-4-26b-a4b-it-GGUF`
API path: the repo's real casing is `gemma-4-26B-A4B-it-GGUF` (the
lowercase form 307-redirects); the local snapshot directory keeps the
lowercase name from the original download, unaffected.

Step 6 (checksum audit of every other GGUF repo in the cache) held:
the xhigh gate has not closed yet.
