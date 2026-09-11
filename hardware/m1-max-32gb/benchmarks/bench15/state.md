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

## Values this run sets

The runner writes each value here as it measures it, with the block
that produced it.

| name | value | block |
| --- | --- | --- |
| `bartowski_evalplus_xhigh` | | `bartowski-evalplus-xhigh` |
| `qwen36_f16_c` | 65536 | `qwen36-f16-ladder-creep` |
| `qwen36_f16_clean` | 65578 | `qwen36-f16-ladder-creep` |
| `qwen36_f16_on` | | `qwen36-f16-mendel-on` |
| `vision_qwen36_c` | | `vision-ladder` |
| `vision_gemma26_c` | | `vision-ladder` |
