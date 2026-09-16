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

### `bonsai-mlx-rerun` — running

Served `mlx_lm.server --model prism-ml/Ternary-Bonsai-27B-mlx-2bit --port 8081`, thinking on (default), no extra body, budget 10240. Source `bench2/results/bonsai-think`, 5 empty task ids (39, 99, 107, 122, 129).

Deviation: the first server died silently on HumanEval/39 (no crash trace, no OOM in the mem log, free memory stayed flat around 12.8 GB, no swap). The watcher's two 600s-silence probes both failed and it exited 42 (`server-bonsai-mlx-rerun.log`, `run-watch-bonsai-mlx-rerun.log`). No stray process was left; a fresh `mlx_lm.server` came up clean, a real completion probe returned `finish_reason: length`, and the block resumed from the same `jsonl` (159 lines, unchanged) under a new watcher (`server-bonsai-mlx-rerun-retry1.log`, `run-watch-bonsai-mlx-rerun-retry1.log`). No data lost.

Second deviation: after the first restart's old codegen process (pid 19991) turned out to still be alive (a stray the runner's `pgrep` check missed right after the death), it ran concurrently with the resumed one (pid 26484) for a few minutes and wrote two duplicate lines to the `jsonl` (`HumanEval/39`, `HumanEval/99`, identical content both times, no corruption). Killed the stray once found; harmless, left for the evaluator to dedupe by `task_id`.

Third deviation: the server died silently a second time, again right after prompt processing finished and before the first output token, this time on `HumanEval/107` (`server-bonsai-mlx-rerun-retry1.log`). No OOM, no memory pressure (free ~20 GB flat). Restarted (`server-bonsai-mlx-rerun-retry2.log`), resumed, cleared `HumanEval/107` this time, then died a third time on `HumanEval/122` under the same signature (`server-bonsai-mlx-rerun-retry2.log`). This is a pattern, not a one-off: `mlx_lm.server` 0.31.3_2 silently dies on this model after several requests accumulate in its prompt cache (the log always shows 10 cached sequences right before the death), never a crash trace. Flagged for the owner as a tool bug, not blocking the run. Restarted a third time (`server-bonsai-mlx-rerun-retry3.log`, `run-watch-bonsai-mlx-rerun-retry3.log`); only 2 problems (`HumanEval/122`, `129`) remained.

A subagent (Haiku) researched the pattern: `mlx_lm.server` takes a `--prompt-cache-bytes` flag (confirmed present in this build's `--help`) to cap the KV cache size, a plausible fix for unbounded prompt-cache growth after several requests. Its cited issue numbers are unverified (a Haiku model can misattribute). Note for a future block or run: pass `--prompt-cache-bytes` on this model if the death repeats, and consider periodic restarts for long `mlx_lm.server` EvalPlus runs on Bonsai MLX.

## Handing over

`machine-setup`, `qwen38-ista-medium-rerun`, `qwen38-ista-low-rerun`, `bonsai-fork-rerun` done. `bonsai-mlx-rerun` in progress (resumed after one server death, see above). Begin next session with `bonsai-mlx-rerun`'s close, then `qwen36-gguf-think-rerun`.
