# Run 22 — state

The run's log: values every later block reads, deviations as they
happen, and the handing-over section at the end.

## Values

| name | value | source |
|---|---|---|
| `budget_message` | `Thinking budget reached. Give the final answer now.` | runbook, Essentials |
| `THINKING_BUDGET_MARGIN` | 1.5 | runbook, planning value |
| `fork_has_reasoning_budget` | yes | `machine-setup` |

## `machine-setup`

Worktree `../choose-a-local-llm-run22`, branch `run22`, off `master` at `ce15675`.

Preflight: all lines `ok`. Wired limit 25000. Start numbers: wired 2093 MB, free 19442 MB, swap used 409 MB. Memory line said balloon needed (free below 25600 MB threshold); no balloon was run, the first real server load is the ramp.

Tool commits: `thinking-budget.py`, `calibrate.py`, `run_codegen_wrapper.py` all at `250b0c9`. `calibrate.py` writes `reasoning_len` (line 163).

`llama-server --version`: 0.4.0 (build 10809, commit `5266f24da`). `--reasoning-budget` and `--reasoning-budget-message` both print. `~/prism-llama/llama-server --help` also prints both flags: `fork_has_reasoning_budget` = `yes`.

`evalplus.codegen --help` runs clean.

Message probe, MoE 26B GGUF (`--reasoning-budget 32`, thinking on): `reasoning_content` ends with the budget message, `content` is not empty, `usage.completion_tokens_details` present but empty (no forced-token subfield). Pass.

Message probe, fork (`bonsai-prism`, Q2_g64, q4_0/q4_0 KV, bias file, `-c 32768`, `--reasoning-budget 32`): `reasoning_content` ends with the budget message, `content` is not empty. Pass.

Both probe servers stopped after their probe. Wired after stop: 133919 pages (~2093 MB), matching the preflight start value.

Done: versions, probe results and the message recorded here, committed.
Deviation: none.

## `gemma26-gguf-calibrate-think`

Served without a thinking budget: `llama-server -hf unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL --alias gemma-4-26b-a4b --no-mmproj --spec-type draft-mtp --spec-draft-n-max 2 --parallel 1 -ngl 999 -fa on -c 32768 --cache-type-k f16 --cache-type-v f16 --jinja --port 8081`, thinking on (`enable_thinking: true`).

Calibration `calibration-gemma26-gguf-think-budget.json`, 10/10 problems, margin 1.5.

`gemma26_think_budget` = 19491
`gemma26_answer_budget` = 2048
`gemma26_max_tokens` = 21539

Derive output: converged 8, cut 2, max_reasoning_tokens 12994, max_answer_tokens 1098.

Server kept up for the budget block.
Files: `hardware/kamaji/calibrations/calibration-gemma26-gguf-think-budget.json`, `hardware/kamaji/benchmarks/bench22/results/gemma26-gguf-calibrate-think/server.log`.
Deviation: none.

### evalplus gemma-4-26b-a4b think-budget — running

Served with the budget: `--reasoning-budget 19491 --reasoning-budget-message "$BUDGET_MSG"`, `-c 32768`. Verified with a real request (`finish_reason: length` at 512 tokens, expected under budget). Wired after load: ~20161 MB.

Watcher started (pid 37475), `RUNWATCH_MEM_LOG=~/.local/share/choose-a-local-llm/run22-gemma26-budget-think-mem.log`. Codegen started (pid 37728), `EVALPLUS_MAX_NEW_TOKENS=21539`.

Deviation: `run_codegen_wrapper.py`'s `_task_id_for` loads both `get_human_eval_plus()` and `get_mbpp_plus()` to build its task-id lookup, even on a HumanEval-only run. The MBPP cache file was missing (`~/Library/Caches/evalplus/MbppPlus-v0.2.0.jsonl`), so `evalplus`'s own `wget.download` tried to fetch it from the GitHub release asset redirect (an Azure blob URL) and hung there — a live TCP connection, not a dead one, so `run-watch.sh`'s death signatures never caught it; only a `pgrep`/`lsof` check on the codegen pid showed the stuck connect. `curl` reached and downloaded the same URL in under 10 s, so the network was fine; the hang is a `wget` package fault, not a firewall block. Fix: downloaded the file with `curl` and `gunzip`, placed it at the cache path `evalplus` expects, so the loader is now offline-safe. No change to the tool script. This can recur on any block whose dataset differs from `humaneval`'s cache; a future run should pre-seed both dataset caches in `machine-setup`. First codegen attempt lost ~26 min to the hang before this was found and fixed; killed and restarted clean, no partial data lost (0 lines written before the fix).

Close: HumanEval base 0.988, plus 0.957, 0/164 empty, 16/164 forced (budget message fired, none came back empty). Codegen wall 2:45:47 (18:48–21:33 UTC). Server and watcher stopped. Wired after stop: ~1956 MB, matching the preflight start value.
Files: `hardware/kamaji/benchmarks/bench22/results/gemma26-gguf-budget-think/`.

### `gemma26-gguf-forced-rerun` — running

`prepare` found 16 forced, 2 forced-failed: `HumanEval/141`, `HumanEval/145`. Served the same config without the two reasoning flags, generous budget `EVALPLUS_MAX_NEW_TOKENS=30000`. Watcher started (pid 85271), codegen started (pid 85772), resuming cleanly from the 162-line jsonl seeded by `prepare`.

Close: 0 forced-failed problems left unfixed by data (2 re-run: `HumanEval/141` forced-fail-wrong, `HumanEval/145` forced-fail-loop). Score unchanged, base 0.988, plus 0.957. Re-run wall 8 min 20 s. `corrected_think_budget`: unchanged (19491), no late answer. Server and watcher stopped.
Files: `hardware/kamaji/benchmarks/bench22/results/gemma26-gguf-forced-rerun/`.
Deviation: none.

## `qwen38-bartowski-calibrate-xhigh` — running

Served: `llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M --alias qwen3.8-27b --no-mmproj --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 -ngl 999 -fa on -c 32768 --cache-type-k f16 --cache-type-v f16 --jinja --port 8081`, effort xhigh.

Deviation: the server took about 10 minutes from launch to the first `loading model` log line, with near-zero RSS the whole time and no error — a cold HF cache resolution/hash step on this 29 GB file, not a download (the file was already on disk, 29 GB under `~/.cache/huggingface/hub/models--bartowski--Qwen3.8-27B-GGUF`). Loaded clean after that. Verified with a real request (`finish_reason: stop`).

Calibration running (pid 92408), `calibration-qwen38-bartowski-xhigh-budget.json`.

Calibration done, 10/10 problems. Derive: converged 9, cut 1, max_reasoning_tokens 25766, max_answer_tokens 979.

`qwen38_think_budget` = 30000
`qwen38_answer_budget` = 2048
`qwen38_max_tokens` = 32048

Server kept up for the budget block.
Files: `hardware/kamaji/calibrations/calibration-qwen38-bartowski-xhigh-budget.json`, `hardware/kamaji/benchmarks/bench22/results/qwen38-bartowski-calibrate-xhigh/`.
Deviation: none beyond the cold-cache load delay noted above.

### evalplus qwen3.8-27b xhigh budget-30000 — running

Served with the budget: `--reasoning-budget 30000 --reasoning-budget-message "$BUDGET_MSG"`, `-c 32768`. Verified with a real request (`finish_reason: stop`). Wired after load: ~22398 MB, under the 25000 limit.

Watcher started (pid 97728). Codegen started (pid 97975), `EVALPLUS_MAX_NEW_TOKENS=32048`. MBPP cache already fixed from the earlier block, no repeat of that deviation.

still running.
Files: `hardware/kamaji/benchmarks/bench22/results/qwen38-bartowski-budget-xhigh/`.
Deviation: none.
