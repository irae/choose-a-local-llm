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

Deviation: the watcher exited with a `SERVER DEAD` verdict at 39/164 problems, but the server was not dead: `/health` answered `ok`, `server.log` showed steady `n_gen` growth on the live task, and no death signature printed. Cause: `--parallel 1` gives the server one slot; the watcher's probe request queues behind a long xhigh turn near the 30000-token budget and cannot get a slot before its own 300s timeout, twice in a row, so the watcher reads "no probe answered" as death. This matches the checklist's own warning ("a probe queued behind a long turn on a one-slot server fails the same way") but the watcher's two-probe escalation still fired. Did not kill the healthy, still-generating server; restarted only the watcher, first at `RUNWATCH_SILENCE=2700`, then at `RUNWATCH_SILENCE=3600` (a full single-slot turn at the worst observed pace, ~9 tok/s over a 32048-token budget, can run close to an hour). No data lost, no server restart. Flag for a future run: a budget block with `--parallel 1` and a budget near or above 20000 tokens needs a `RUNWATCH_SILENCE` sized to the worst-case single-turn wall time, not the 600s default.

Close: HumanEval base 0.982, plus 0.951, 0/164 empty, 3/164 forced (budget message fired, none came back empty). Codegen wall 7:27:46 (23:52 16 Sep – 07:19 17 Sep UTC). Server and watcher stopped.
Files: `hardware/kamaji/benchmarks/bench22/results/qwen38-bartowski-budget-xhigh/`.

### `qwen38-bartowski-forced-rerun` — running

`prepare` found 3 forced, 1 forced-failed: `HumanEval/99`. Served the same config without the two reasoning flags, generous budget `EVALPLUS_MAX_NEW_TOKENS=30000`. Watcher started at `RUNWATCH_SILENCE=2700` from the start this time. Codegen resuming cleanly from the 163-line jsonl seeded by `prepare`.

Close: 1 forced-failed problem re-run (`HumanEval/99`, forced-fail-loop, hits the 30000 cap naturally too). Score base 0.976, plus 0.951 (plus unchanged from the budget block; base moved by one task on a cutoff-content difference, not a real regression). Re-run wall 27 min 30 s. `corrected_think_budget`: unchanged (30000). Server and watcher stopped.
Files: `hardware/kamaji/benchmarks/bench22/results/qwen38-bartowski-forced-rerun/`.
Deviation: none.

## `bonsai-fork-calibrate-think` — running

Served: `LLAMA_ATTN_ROT_DISABLE=1 ~/prism-llama/llama-server -m .../Ternary-Bonsai-27B-Q2_g64.gguf --alias bonsai-prism -ngl 999 -fa on -c 32768 --parallel 1 --cache-type-k q4_0 --cache-type-v q4_0 --kv-mean-center ~/.local/share/choose-a-local-llm/Ternary-Bonsai-27B-kv-bias.gguf --jinja --port 8081`, thinking on (default), no extra body. Verified with a real request.

Calibration done, 10/10 problems. Derive: converged 10, cut 0, max_reasoning_tokens 4992, max_answer_tokens 760.

`bonsai_fork_think_budget` = 7488
`bonsai_fork_answer_budget` = 2048
`bonsai_fork_max_tokens` = 9536

Files: `hardware/kamaji/calibrations/calibration-bonsai-fork-think-budget.json`, `hardware/kamaji/benchmarks/bench22/results/bonsai-fork-calibrate-think/`.
Deviation: none.

## Pause (owner request, 2026-09-17)

The owner asked to pause after this calibration closes and needs the Mac
for other work. Server and watcher stopped, GPU freed. Resume at
`bonsai-fork-budget-think` when the owner says go: serve the fork with
`--reasoning-budget 7488 --reasoning-budget-message "$BUDGET_MSG"` added
to the calibrate command above, verify, start the watcher
(`RUNWATCH_SILENCE` generous, single-slot server), then the full 164 run
at `EVALPLUS_MAX_NEW_TOKENS=9536`. No block is mid-run; nothing to
resume mid-block.

## Resume (owner, 2026-09-21)

Coordinator message and owner go-ahead. Merged `origin/master` (`d203bc0`) into `run22`. Coordinator session is now `local-llm coordinator sept-20`. The runbook "Fast mode" replaces the old Pause note. Preflight all `ok`, wired limit 25000, start numbers wired 2198 MB, free 17949 MB, swap used 1486 MB.

### `bonsai-fork-fast-think` — running

Served: fork binary, Q2_g64 file, bias file, `-c 32768`, q4_0/q4_0 KV, no drafter, alias `bonsai-prism`, `--reasoning-budget 8192 --reasoning-budget-message "$BUDGET_MSG"`. Wired after load: about 2201 MB plus model, read at 140830 pages at load start. Probe: reasoning field present, content 697 characters, `finish_reason: stop`, no server error. The probe converged early, so no budget message shows in it. No splice source. Watcher at `RUNWATCH_SILENCE=2700`. Codegen started 16:10 UTC, `EVALPLUS_MAX_NEW_TOKENS=16384`, 164 to generate.

still running.
Files: `hardware/kamaji/benchmarks/bench22/results/bonsai-fork-fast-think/`.
Deviation: none.

Close: HumanEval base 0.951, plus 0.915, 0/164 empty, 4/164 forced (`HumanEval/47`, `84`, `97`, `129`; none empty). Wall 9:11:23 (16:12 21 Sep – 01:23 22 Sep UTC). Server and watcher stopped, wired recovered.
Files: `hardware/kamaji/benchmarks/bench22/results/bonsai-fork-fast-think/`.

### `fast-qwen38-gguf-xhigh` — running

Served: `llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M --alias qwen3.8-27b --no-mmproj --parallel 1 -ngl 999 -fa on -c 32768 --cache-type-k f16 --cache-type-v f16 --jinja --port 8081 --reasoning-budget 8192 --reasoning-budget-message "$BUDGET_MSG"`, effort xhigh, no drafter (row spec carries none). One benign load-time line, `get_repo_commit: error: HTTPLIB failed: SSL connection failed` (a metadata check, not the model file; the file was already on disk and the server loaded and answered clean). Probe: `finish_reason: stop`, content 119 characters, reasoning 169 characters, no other server error.

Splice from `bench22/results/qwen38-bartowski-budget-xhigh`: kept 153, regenerate 11 (`HumanEval/2, 32, 39, 75, 76, 99, 116, 127, 129, 132, 137`), matching the table's planning count. Watcher at `RUNWATCH_SILENCE=2700`. Codegen started 01:52 UTC, `EVALPLUS_MAX_NEW_TOKENS=16384`.

still running.
Files: `hardware/kamaji/benchmarks/bench22/results/fast-qwen38-gguf-xhigh/`.
Deviation: none.

Close: HumanEval base 0.982, plus 0.951 (matches the old budget-30000 row exactly), 0/164 empty, 9/164 forced of the 11 regenerated (`HumanEval/75`, `127` converged inside 8192). New-generation wall 1:35:41 (02:02–03:38 UTC), plus 208.7 min of spliced-source time for the 153 kept problems. Server and watcher stopped; wired took about 3 minutes to drop from ~3.3 GB to the ~2.2 GB baseline after stop, longer than earlier blocks but no stray process was found while it held.
Files: `hardware/kamaji/benchmarks/bench22/results/fast-qwen38-gguf-xhigh/`.

### `fast-gemma26-gguf` — running

Served: `llama-server -hf unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL --alias gemma-4-26b-a4b --no-mmproj --spec-type draft-mtp --spec-draft-n-max 2 --parallel 1 -ngl 999 -fa on -c 32768 --cache-type-k f16 --cache-type-v f16 --jinja --port 8081 --reasoning-budget 8192 --reasoning-budget-message "$BUDGET_MSG"`, thinking on. Same benign `get_repo_commit` metadata line as the qwen38 block; server loaded and answered clean. The `Gemma4Assistant requires ctx_other` line during memory fitting is the server's own logged note that it is normal. Probe: `finish_reason: stop`, content 1569 characters, reasoning 1756 characters.

Splice from `bench22/results/gemma26-gguf-budget-think`: kept 145, regenerate 19, matching the table's planning count. Watcher at `RUNWATCH_SILENCE=2700`. Codegen started 03:54 UTC, `EVALPLUS_MAX_NEW_TOKENS=16384`.

still running.
Files: `hardware/kamaji/benchmarks/bench22/results/fast-gemma26-gguf/`.
Deviation: none.

Close: HumanEval base 0.988, plus 0.957 (matches the old budget-19491 row exactly), 0/164 empty, 19/19 regenerated problems forced. New-generation wall 0:38:25 (03:56–04:34 UTC), plus 78.6 min of spliced-source time for the 145 kept problems. Server and watcher stopped, wired recovered quickly this time (~112681 pages).
Files: `hardware/kamaji/benchmarks/bench22/results/fast-gemma26-gguf/`.
