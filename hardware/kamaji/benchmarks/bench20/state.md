# Run 20 — state

The run's log: values every later block reads, deviations as they
happen, and the handing-over section at the end.

## Values

| name | value | source |
|---|---|---|
| llama-server version | 0.4.0 (build 10809, commit 5266f24da) | `machine-setup`, `llama-server --version` |
| mlx-lm version | 0.31.3_2 (homebrew) | `machine-setup`, `/opt/homebrew/Cellar/mlx-lm` |
| prism-llama llama-server version | 0.2.0-dev (build 10660, commit e311ed38f) | `machine-setup`, `~/prism-llama/llama-server --version` |
| preflight starting memory | wired 1897 MB, free 19580 MB, swap used 381 MB | `machine-setup`, `tools/preflight.sh` |

### `machine-setup`

`git log` for `benchmarks/run_codegen_wrapper.py` and `benchmarks/run-humaneval.sh` shows `b72fb56`, which carries the finish-log change (`EVALPLUS_FINISH_LOG` exported in `run-humaneval.sh`, line 18). `evalplus.codegen --help` runs. Preflight: all lines `ok`, wired limit 25000, no llama-server or mlx_lm running.
Deviation: none.

### `qwen38-ista-medium-rerun`

Served `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`, `--no-mmproj`, `--spec-type draft-mtp --spec-draft-n-max 3 --parallel 1`, f16 KV, `-c 32768` (bench20 fixed value), alias `qwen3.8-27b`. Probe: a full chat completion, finish_reason `stop`, verified before the watcher started. Watcher and codegen both closed clean; `finish.jsonl` (one level above `humaneval/`, not inside it — the log writes beside the `humaneval/` folder) shows HumanEval/39 at `finish_reason: length`, `completion_tokens: 8192`, `empty: true`. Cause is `cap`.
Full re-scored result: base 0.976, plus 0.945, 1/164 empty, unchanged from the source row. Server and watcher stopped (pids 89982, 90738).
Files: `results/qwen38-ista-medium-rerun/`, `results/server-qwen38-ista-medium-rerun.log`, `results/run-watch-qwen38-ista-medium-rerun.log`.
Deviation: none.

### `qwen38-ista-low-rerun`

Served `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`, `--no-mmproj`, no drafter (bench13's `ista_evalplus_serving` cell), f16 KV, `-c 32768`, alias `qwen3.8-27b`. Probe: full chat completion, finish_reason `stop`, verified before the watcher started. `finish.jsonl` shows HumanEval/39 at `finish_reason: length`, `completion_tokens: 8192`, `empty: true`. Cause is `cap`.
Full re-scored result: base 0.976, plus 0.933, 1/164 empty, unchanged from the source row. Server and watcher stopped (pids 99098, 99824).
Files: `results/qwen38-ista-low-rerun/`, `results/server-qwen38-ista-low-rerun.log`, `results/run-watch-qwen38-ista-low-rerun.log`.
Deviation: none.

### `bonsai-fork-rerun`

Model file `~/prism-llama/Bonsai-demo/models/ternary-gguf/27B/Ternary-Bonsai-27B-Q2_g64.gguf` and the bias file `~/.local/share/choose-a-local-llm/Ternary-Bonsai-27B-kv-bias.gguf` were both present (the bias file moved off `/tmp` since bench4, not missing). Served with `LLAMA_ATTN_ROT_DISABLE=1`, no drafter, `-c 32768`, q4_0/q4_0 KV, the bias file, alias `bonsai-prism`. First probe timed out at 60s on the no-drafter build (~16.9 t/s); a longer probe confirmed `finish_reason: stop` and a real answer, so the server was never at fault. `finish.jsonl` shows all four re-run problems (`HumanEval/47`, `84`, `97`, `129`) at `finish_reason: length`, `completion_tokens: 10240`, `empty: true`. Cause is `cap` for all four. The watcher's 600s silence probes twice confirmed the server alive and generating (HumanEval/97 ran to n_gen 5798+ before the wakeup check), not stalled — a slow no-drafter build, not a death.
Full re-scored result: base 0.927, plus 0.890, 4/164 empty, exact match to the source row (`bench4`, 0.927/0.890). Server and watcher stopped (pids 5328, 6806).
Files: `results/bonsai-fork-rerun/`, `results/server-bonsai-fork-rerun.log`, `results/run-watch-bonsai-fork-rerun.log`.
Deviation: none.

### `bonsai-mlx-rerun`

Served `mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit --port 8081`, thinking on (default), no extra body, budget 10240. Source `bench2/results/bonsai-think`, 5 empty task ids (39, 99, 107, 122, 129).

Deviation: the first server died silently on HumanEval/39 (no crash trace, no OOM in the mem log, free memory stayed flat around 12.8 GB, no swap). The watcher's two 600s-silence probes both failed and it exited 42 (`server-bonsai-mlx-rerun.log`, `run-watch-bonsai-mlx-rerun.log`). No stray process was left; a fresh `mlx_lm.server` came up clean, a real completion probe returned `finish_reason: length`, and the block resumed from the same `jsonl` (159 lines, unchanged) under a new watcher (`server-bonsai-mlx-rerun-retry1.log`, `run-watch-bonsai-mlx-rerun-retry1.log`). No data lost.

Second deviation: after the first restart's old codegen process (pid 19991) turned out to still be alive (a stray the runner's `pgrep` check missed right after the death), it ran concurrently with the resumed one (pid 26484) for a few minutes and wrote two duplicate lines to the `jsonl` (`HumanEval/39`, `HumanEval/99`, identical content both times, no corruption). Killed the stray once found; harmless, left for the evaluator to dedupe by `task_id`.

Third deviation: the server died silently a second time, again right after prompt processing finished and before the first output token, this time on `HumanEval/107` (`server-bonsai-mlx-rerun-retry1.log`). No OOM, no memory pressure (free ~20 GB flat). Restarted (`server-bonsai-mlx-rerun-retry2.log`), resumed, cleared `HumanEval/107` this time, then died a third time on `HumanEval/122` under the same signature (`server-bonsai-mlx-rerun-retry2.log`). This is a pattern, not a one-off: `mlx_lm.server` 0.31.3_2 silently dies on this model after several requests accumulate in its prompt cache (the log always shows 10 cached sequences right before the death), never a crash trace. Flagged for the owner as a tool bug, not blocking the run. Restarted a third time (`server-bonsai-mlx-rerun-retry3.log`, `run-watch-bonsai-mlx-rerun-retry3.log`); only 2 problems (`HumanEval/122`, `129`) remained.

A subagent (Haiku) researched the pattern: `mlx_lm.server` takes a `--prompt-cache-bytes` flag (confirmed present in this build's `--help`) to cap the KV cache size, a plausible fix for unbounded prompt-cache growth after several requests. Its cited issue numbers are unverified (a Haiku model can misattribute). Note for a future block or run: pass `--prompt-cache-bytes` on this model if the death repeats, and consider periodic restarts for long `mlx_lm.server` EvalPlus runs on Bonsai MLX.

Close: after the third restart, the block finished. The output `jsonl` had 171 raw lines for 164 unique task ids (duplicates from the race and the restart cycle); verified every duplicate pair agreed on pass/fail (the `HumanEval/107` and `122` duplicates differ in wording but all pass, greedy decoding is not always byte-identical across a fresh MLX process, but the tests are behavior tests, not text-diffs). The evaluator's own `pass@1` already used the 164 unique tasks (153/164 = 0.933 base, 148/164 = 0.902 plus, matching the printed score exactly), so no correction was needed there; de-duplicated the `jsonl`/`raw.jsonl` files to 164 lines each for a clean record.
Final: base 0.933, plus 0.902, 2/164 empty (`HumanEval/39`, `129`, both `cap`). Three of the five source empties (`99`, `107`, `122`) recovered and passed on today's build — an improvement over the source row (`bench2`, 0.915/0.884, 5/164 empty), not a like-for-like repeat. Server and watcher stopped (pids 46642, 47116).
Files: `results/bonsai-mlx-rerun/`, `results/server-bonsai-mlx-rerun*.log`, `results/run-watch-bonsai-mlx-rerun*.log`.
Deviation: see the three notes above (server deaths, stray duplicate process, prompt-cache research). Total re-run wall: about 5h20min across three server restarts, most of it in the second restart's long generations for `107`, `122`, `129`.

### `qwen36-gguf-think-rerun`

Source `bench2/results/qwen36-think`. Removed 5 empty task ids (4, 23, 55, 107, 121) — `HumanEval/4` in the source run was a server error, not a model answer, and re-runs like the others per `AGENT.md`. Served `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL`, `--alias qwen3.6-35b-a3b`, MTP n-max 3, `-c 32768`, q8_0/q8_0 KV, thinking on, no extra body, budget 26624.

Deviation: right after the first server load, two stray `run_codegen_wrapper.py` processes (pids 20007, 39289) started hitting the fresh server with `bonsai-mlx-rerun` traffic. These were children of the `bonsai-mlx-rerun` retry1/retry2 codegen that survived a `kill -9` on their bash parent (killing the parent bash of `run-humaneval.sh` does not kill the Python child it execs into). Caught immediately from the unexpected `task 0` activity in the fresh server's log and an `lsof -i :8081` check; killed both stray PIDs, confirmed `bonsai-mlx-rerun`'s already-committed files were untouched (`git status` clean, `git diff --stat` empty) and `qwen36-gguf-think-rerun`'s own files were untouched (still 159 lines, the pre-codegen count). Restarted the qwen36 server clean, verified no established connections before probing, real probe returned `finish_reason: stop`. Lesson for the rest of this run: a `kill` or `kill -9` on a `run-humaneval.sh` bash PID does not reliably kill the `run_codegen_wrapper.py` child; check `pgrep -fl run_codegen_wrapper.py` too after any bash-level kill, not just the run-humaneval.sh pid.

Close: codegen and evaluation ran clean once the stray processes were cleared — no server incidents during the block itself. `finish.jsonl` shows HumanEval/23 and 55 at `finish_reason: length`, 26624 tokens, genuinely empty (`cap`); HumanEval/4, 107, 121 all completed and passed. Full re-scored result: base 0.957, plus 0.939, 2/164 empty, up from the source row's 0.939/0.921/5 empty (one of the source empties was a server error, not a real generation). Server and watcher stopped (pids 62801, 63527).
Files: `results/qwen36-gguf-think-rerun/`, `results/server-qwen36-gguf-think-rerun.log`, `results/run-watch-qwen36-gguf-think-rerun.log`.

### `gemma26-gguf-think-rerun`

Served `unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL`, `--alias gemma-4-26b-a4b`, MTP n-max 2, `-c 212992`, f16/f16 KV, thinking on, budget 30000. Same server as bench9/bench10's published `gemma-4-26b-a4b` command with `f16` KV and `-c 212992`, per `AGENT.md`'s pointer. Clean run, 18 problems, no server incidents, checked `pgrep -fl run_codegen_wrapper.py` before this block's server load per the reminder above — clean.
`finish.jsonl`: 16 of 18 re-run problems hit `finish_reason: length` at the 30000 budget (genuinely empty, cause `cap`); `HumanEval/41` and `94` completed (`stop`) and passed.
Full re-scored result: base 0.896, plus 0.872, 16/164 empty, up slightly from the source row's 0.884/0.860/18 empty. Server and watcher stopped (pids 73301, 74075).
Files: `results/gemma26-gguf-think-rerun/`, `results/server-gemma26-gguf-think-rerun.log`, `results/run-watch-gemma26-gguf-think-rerun.log`.
Deviation: none.

### `gemma26-mlx-think-rerun`

Served `mlx_lm.server --model mlx-community/gemma-4-26b-a4b-it-4bit --prompt-cache-size 2 --port 8081`, thinking on, budget 30000. 46 re-run problems, the run's largest block. Confirmed `pgrep -fl run_codegen_wrapper.py` was clean before the server load. Clean run throughout — no server deaths, unlike `bonsai-mlx-rerun`'s three; this build already passes `--prompt-cache-size 2`, capping the prompt cache the earlier deviation flagged as the likely cause.
Full re-scored result: base 0.793 (130/164), plus 0.768 (126/164), 31/164 empty, all `cap`. Up from the source row's 0.713/0.701/46 empty — 15 of 46 empties recovered on today's build. Server and watcher stopped (pids 6113, 6839).
Files: `results/gemma26-mlx-think-rerun/`, `results/server-gemma26-mlx-think-rerun.log`, `results/run-watch-gemma26-mlx-think-rerun.log`.
Deviation: none.

### `qwen38-unsloth-xhigh-rerun`

Served `unsloth/Qwen3.8-27B-GGUF:UD-IQ3_S`, `--alias qwen3.8-27b-iq3s`, no drafter (nmax0), `-c 32768`, f16/f16 KV, `reasoning_effort: xhigh`, budget 20000. Clean run, no server incidents. All 8 re-run problems hit `finish_reason: length` at 20000, no recoveries — the new score is an exact match to the source row (`bench18`, 0.945/0.927/8 empty).
Server and watcher stopped (pids 79588, 80092).
Files: `results/qwen38-unsloth-xhigh-rerun/`, `results/server-qwen38-unsloth-xhigh-rerun.log`, `results/run-watch-qwen38-unsloth-xhigh-rerun.log`.
Deviation: none.

## Handing over

Every block of the AGENT.md order ran: `machine-setup`, `qwen38-ista-medium-rerun`, `qwen38-ista-low-rerun`, `bonsai-fork-rerun`, `bonsai-mlx-rerun`, `qwen36-gguf-think-rerun`, `gemma26-gguf-think-rerun`, `gemma26-mlx-think-rerun`, `qwen38-unsloth-xhigh-rerun`. `retry-sweep` had nothing queued — no block waited on a human across the whole run; every retry (three on `bonsai-mlx-rerun`, one on `qwen36-gguf-think-rerun`'s stray-process cleanup) resolved inline. The run is done pending the coordinator's review and publish.

**Summary of the eight re-run rows**, cause counts (`cap` = length at budget, `model` = stop with no answer — none of this run's empties were `model`):

| mnemonic | new score (base/plus) | new empty | old score (base/plus) | old empty | recovered |
|---|---|--:|---|--:|--:|
| `qwen38-ista-medium-rerun` | 0.976/0.945 | 1/164 | 0.976/0.945 | 1/164 | 0 |
| `qwen38-ista-low-rerun` | 0.976/0.933 | 1/164 | 0.976/0.933 | 1/164 | 0 |
| `bonsai-fork-rerun` | 0.927/0.890 | 4/164 | 0.927/0.890 | 4/164 | 0 |
| `bonsai-mlx-rerun` | 0.933/0.902 | 2/164 | 0.915/0.884 | 5/164 | 3 |
| `qwen36-gguf-think-rerun` | 0.957/0.939 | 2/164 | 0.939/0.921 | 5/164 | 3 |
| `gemma26-gguf-think-rerun` | 0.896/0.872 | 16/164 | 0.884/0.860 | 18/164 | 2 |
| `gemma26-mlx-think-rerun` | 0.793/0.768 | 31/164 | 0.713/0.701 | 46/164 | 15 |
| `qwen38-unsloth-xhigh-rerun` | 0.945/0.927 | 8/164 | 0.945/0.927 | 8/164 | 0 |

Every remaining empty across all eight rows hit `finish_reason: length` at its budget — none were a model choosing to stop with no answer. So this run's finding: no scored EvalPlus row in this batch had a hidden `model`-cause empty; the empties on the site are all genuine budget caps.

**Machine state left behind:** GPU idle, no `llama-server` or `mlx_lm.server` process running, wired memory recovered to baseline after the last block. No stray `run_codegen_wrapper.py` processes (checked before every server load after the `qwen36-gguf-think-rerun` incident).

**Evidence archived:** not yet run — the coordinator or the next session should run `tools/archive-evidence.sh hardware/kamaji/benchmarks/bench20/results run20` before closing this run out.

**Open flags for the owner/coordinator, not stop conditions:**
1. `bonsai-mlx-rerun`'s `mlx_lm.server` died silently three times on long generations with no OOM signature; a Haiku subagent's research points at unbounded prompt-cache growth as the likely cause (the `--prompt-cache-size 2` flag `gemma26-mlx-think-rerun`'s command already carries avoided the issue there) — worth adding `--prompt-cache-size` or `--prompt-cache-bytes` to future Bonsai MLX serve commands. The subagent's cited GitHub issue numbers are unverified.
2. A `kill`/`kill -9` on a `run-humaneval.sh` bash PID does not reliably kill its `run_codegen_wrapper.py` Python child — this run hit it once (stray processes from a killed `bonsai-mlx-rerun` attempt briefly hit the next block's fresh server before being caught and killed, no data was written). Worth a note in the checklist for future runs.
3. The coordinator's earlier review question about `finish.jsonl`'s cause split is answered above: every empty this run touched was `cap`, none `model`.
