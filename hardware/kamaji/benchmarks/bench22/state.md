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

### `fast-bonsai2-ptq1-mac-xhigh` — running

Served: `~/.local/share/choose-a-local-llm/llama.cpp-prism/release/bin/llama-prism-b10685-7dffb15/llama-prism-b10685-7dffb15/llama-server` (fork, Metal build, from bench26), `-m` the cached `Ternary-Bonsai-2-27B-PTQ1_0.gguf` (resolved by hand from `~/.cache/huggingface/hub`, since `hf` is not on this session's PATH; `hf download` printed nothing and the first attempt started the server with an empty `-m`, in router mode — killed at once, no data written, restarted with the direct cache path), `--alias bonsai2-27b-ptq1-mac --no-mmproj --parallel 1 -ngl 999 -fa on -c 32768 --cache-type-k f16 --cache-type-v f16 --jinja --port 8081 --reasoning-budget 8192 --reasoning-budget-message "$BUDGET_MSG"`, effort xhigh. Both flags confirmed present on this fork build. Probe: `finish_reason: stop`, content 175 characters, reasoning 161 characters, no server error.

Splice from `bench26/results/bonsai2-budget-xhigh-mac`: kept 154, regenerate 10, matching the table's planning count. Watcher at `RUNWATCH_SILENCE=2700`. Codegen started 04:38 UTC, `EVALPLUS_MAX_NEW_TOKENS=16384`.

still running.
Files: `hardware/kamaji/benchmarks/bench22/results/fast-bonsai2-ptq1-mac-xhigh/`.
Deviation: the empty-`-m` false start above; no data lost, caught before any request was sent.

Close: HumanEval base 0.988, plus 0.939 (matches the bench26 budget-16056 row exactly), 0/164 empty, 10/10 regenerated problems forced. New-generation wall 1:12:08 (04:47–05:59 UTC), plus 217.2 min of spliced-source time for the 154 kept problems. Server and watcher stopped, wired recovered quickly.
Files: `hardware/kamaji/benchmarks/bench22/results/fast-bonsai2-ptq1-mac-xhigh/`.

### `fast-qwen38-gguf-unsloth-iq3s-xhigh` — running

Served: `llama-server -hf unsloth/Qwen3.8-27B-GGUF:UD-IQ3_S --alias qwen3.8-27b-iq3s --no-mmproj --parallel 1 -ngl 999 -fa on -c 32768 --cache-type-k f16 --cache-type-v f16 --jinja --port 8081 --reasoning-budget 8192 --reasoning-budget-message "$BUDGET_MSG"`, effort xhigh. Same benign `get_repo_commit` metadata line as earlier blocks; file already cached, no download. Probe: `finish_reason: stop`, content 108 characters, reasoning 172 characters.

No splice source. Watcher at `RUNWATCH_SILENCE=2700`. Codegen started 06:10 UTC, `EVALPLUS_MAX_NEW_TOKENS=16384`, 164 to generate.

still running.
Files: `hardware/kamaji/benchmarks/bench22/results/fast-qwen38-gguf-unsloth-iq3s-xhigh/`.
Deviation: none.

Close: HumanEval base 0.976, plus 0.945, up from the unbudgeted 0.945/0.927 in `models.json`. 0/164 empty, 17/164 forced. Wall 6:28:36 (06:11–12:39 UTC). Server and watcher stopped, wired recovered quickly.
Files: `hardware/kamaji/benchmarks/bench22/results/fast-qwen38-gguf-unsloth-iq3s-xhigh/`.

### `fast-qwen38-gguf-ista-nodrafter-xhigh` — running

Served: `llama-server -hf ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp --alias qwen3.8-27b-ista --no-mmproj --parallel 1 -ngl 999 -fa on -c 32768 --cache-type-k f16 --cache-type-v f16 --jinja --port 8081 --reasoning-budget 8192 --reasoning-budget-message "$BUDGET_MSG"`, effort xhigh, no drafter (row config says so). Same benign `get_repo_commit` metadata line; file already cached. Probe: `finish_reason: stop`, content 143 characters, reasoning 159 characters.

No splice source. Watcher at `RUNWATCH_SILENCE=2700`. Codegen started 12:51 UTC, `EVALPLUS_MAX_NEW_TOKENS=16384`, 164 to generate.

still running.
Files: `hardware/kamaji/benchmarks/bench22/results/fast-qwen38-gguf-ista-nodrafter-xhigh/`.
Deviation: none.

Close: HumanEval base 0.976, plus 0.945, up from the unbudgeted 0.945/0.921 in `models.json`. 0/164 empty, 13/164 forced. Wall 5:31:42 (12:52–18:23 UTC). Server and watcher stopped, wired recovered quickly.
Files: `hardware/kamaji/benchmarks/bench22/results/fast-qwen38-gguf-ista-nodrafter-xhigh/`.

### `fast-qwen36-gguf-think` — running

Served: `llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL --alias qwen3.6-35b-a3b --no-mmproj --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 -ngl 999 -fa on -c 32768 --cache-type-k q8_0 --cache-type-v q8_0 --jinja --port 8081 --reasoning-budget 8192 --reasoning-budget-message "$BUDGET_MSG"`, thinking on. Same benign `get_repo_commit` metadata line as earlier blocks; file already cached. Probe: `finish_reason: stop`, content 922 characters, reasoning 2663 characters.

No splice source. Watcher at `RUNWATCH_SILENCE=2700`. Codegen started 18:39 UTC, `EVALPLUS_MAX_NEW_TOKENS=16384`, 164 to generate. Last block of the fast table; `qwen36-gguf-f16` and `qwen36-gguf-f16-nodrafter` share this score under the shared-score rule, for the coordinator to write.

still running.
Files: `hardware/kamaji/benchmarks/bench22/results/fast-qwen36-gguf-think/`.
Deviation: none.

Close: HumanEval base 0.976, plus 0.939 (plus unchanged from the unbudgeted 0.957/0.939, base up one problem). 0/164 empty, 17/164 forced. Wall 2:27:26 (18:39–21:07 UTC). Server and watcher stopped, wired recovered. This is the last row of the fast table; `bonsai-fork-budget-mendel-guided` is next.
Files: `hardware/kamaji/benchmarks/bench22/results/fast-qwen36-gguf-think/`.

## `bonsai-fork-budget-mendel-guided` — stop and ask

`gh auth status` passed, `git stash clear` ran clean. Served the fork at `-c 65536` (the scored 31.5 row's own serving `-c`) with `$FAST_FLAGS`; probe passed (`finish_reason: stop`, content 794 characters, reasoning 2967 characters), wired ~11534 MB, under the 25000 limit.

`./run-worker.sh bonsai-prism pi guided high` aborts: `branch bonsai-prism-high-guided-v3-issue-13 exists`. That branch is not a stray: it is the already-scored 31.5 row's own branch (`docs/setups/kamaji/reports/bonsai-27b.md`, guided-v3.0, 31.5/100). `run-worker.sh`'s branch suffix for a guided pi run is fixed in code (`-guided-v3-issue-13`) with no override flag, so a second attempt of the same model/level/bench collides by name. `PLAN.md` says a fresh attempt of the same config needs a new worktree with a suffix, and separately that a branch is never deleted before its row is scored — but this branch's row is already scored and published, so the two rules do not obviously resolve the collision the same way.

No worker run started; no GPU time or evidence lost. Server and watcher stopped after the probe.

Candidate answer for the coordinator: move the old branch aside with a timestamp (for example `bonsai-prism-high-guided-v3-issue-13-old-31p5-nobudget`) on both the mendel-benchmark repo and its origin, keeping it as the record of the no-budget row, then re-run `run-worker.sh` so it creates a fresh branch under the same fixed suffix for the budgeted row. This is the coordinator's or the owner's call, not the runner's, since it touches another repo's branch history outside this run's own worktree.

Files: `hardware/kamaji/benchmarks/bench22/results/bonsai-fork-budget-mendel-guided/`.
Deviation: stop-and-ask, no data lost.

### `bonsai-fork-budget-mendel-guided` — resumed and running

Coordinator's fix for the branch collision: a temporary pi entry `bonsai-prism-tb8192`, a copy of `bonsai-prism` in every field, added to `~/.pi/agent/models.json` under the `llama` provider (backup at `~/.pi/agent/models.json.bak-run22`). Server keeps the alias `bonsai-prism` (same server, same alias, per the coordinator); only the pi id differs, so `run-worker.sh`'s branch name comes out as `bonsai-prism-tb8192-high-guided-v3-issue-13`, distinct from the scored 31.5 branch `bonsai-prism-high-guided-v3-issue-13`, which was not touched.

Re-served the fork at `-c 65536` with `$FAST_FLAGS`; probe passed (`finish_reason: stop`, content 919 characters, reasoning 2938 characters). Watcher started at `RUNWATCH_SILENCE=2700`. Worker started: `MENDEL_CONTEXT_WINDOW=65536 ./run-worker.sh bonsai-prism-tb8192 pi guided high`. New worktree `../mendel-bench-guided-bonsai-prism-tb8192-high`, new branch `bonsai-prism-tb8192-high-guided-v3-issue-13`, clean start, `contextWindow` 65536 pinned, compaction reserve 8192.

The comparison row: `bonsai-prism` guided v3.0, thinking high, q4_0 KV + bias, no budget, scored 31.5/100 (`docs/setups/kamaji/reports/bonsai-27b.md`). This row is the same file, the same fork release and the same serving command, with the fast-mode flags added: `--reasoning-budget 8192`, `max_tokens` as the agent harness sets it (no `EVALPLUS_MAX_NEW_TOKENS`, that variable does not apply to a Mendel row).

still running.
Files: `hardware/kamaji/benchmarks/bench22/results/bonsai-fork-budget-mendel-guided/`.
Deviation: the branch-collision stop-and-ask above; resolved by the coordinator's temporary pi id, no rename of the scored branch.

Close: worker ended `complete`, 0 nudges, exit 0. Loop verdict `ok`, ratio 0.37. Peak context 61505/65536, 181 tool calls. Scored in a subagent on the best available model, per `PLAN.md`: score_total 44.5/100 (raw 44.5, cap 62.5 from 5/8 libraries, cap does not bind), worst defect critical (a broken `chalk` shim, a `glob` replacement that always returns empty). Above the no-budget row's 31.5/100 (raw 36, 1/8 libraries). 0 of 369 session lines carry the budget message: the budget never fired on this row. Wall 1:30:09 (21:24–22:54 UTC).

Temporary pi entry `bonsai-prism-tb8192` removed from `~/.pi/agent/models.json`; file now matches the pre-block backup exactly (`diff` clean). `pkill -f "Mendel Daemon"` run. Server and watcher stopped, wired recovered.

Full report and scoring rubric breakdown in the subagent's hand-back; the summary table is in `results.md`.
Files: `hardware/kamaji/benchmarks/bench22/results/bonsai-fork-budget-mendel-guided/`.
Deviation: the branch-collision stop-and-ask, resolved by the coordinator's temporary-pi-id fix; no other deviation.

## Handing-over — run 22 complete, 2026-09-22

Every block in the runbook's order ran and closed. `retry-sweep` had nothing queued: every stop-and-ask this run hit (the MBPP cache hang, the false `SERVER DEAD` watcher verdict, the branch-name collision) got a same-session fix and no row was deferred to a human.

**What ran, in order, with its result:**
- `machine-setup`: pass, both probes pass, fork has the reasoning-budget flag.
- `gemma26-gguf-calibrate-think` → `gemma26-gguf-budget-think` (0.988/0.957, 0/164 empty, 16/164 forced) → `gemma26-gguf-forced-rerun` (unchanged, budget confirmed correct).
- `qwen38-bartowski-calibrate-xhigh` → `qwen38-bartowski-budget-xhigh` (0.982/0.951, 0/164 empty, 3/164 forced) → `qwen38-bartowski-forced-rerun` (0.976/0.951, plus unchanged).
- `bonsai-fork-calibrate-think`: budgets 7488/2048/9536. Run paused here on owner request 2026-09-17, resumed 2026-09-21 under fast mode (owner, 2026-09-19): the derived-budget blocks `bonsai-fork-budget-think` and `bonsai-fork-forced-rerun` never ran; fast mode replaced them.
- `bonsai-fork-fast-think` (0.951/0.915, 0/164 empty, 4/164 forced).
- `fast-qwen38-gguf-xhigh` (0.982/0.951, matches the old budget-30000 row, spliced 153/11, 9/11 regenerated forced).
- `fast-gemma26-gguf` (0.988/0.957, matches the old budget-19491 row, spliced 145/19, 19/19 regenerated forced).
- `fast-bonsai2-ptq1-mac-xhigh` (0.988/0.939, matches the bench26 row, spliced 154/10, 10/10 regenerated forced).
- `fast-qwen38-gguf-unsloth-iq3s-xhigh` (0.976/0.945, up from 0.945/0.927 unbudgeted, 0/164 empty, 17/164 forced).
- `fast-qwen38-gguf-ista-nodrafter-xhigh` (0.976/0.945, up from 0.945/0.921 unbudgeted, 0/164 empty, 13/164 forced).
- `fast-qwen36-gguf-think` (0.976/0.939, plus unchanged from 0.957/0.939 unbudgeted, base up one problem, 0/164 empty, 17/164 forced). Last row of the fast table; `qwen36-gguf-f16`, `qwen36-gguf-f16-nodrafter` and `gemma26-gguf-2x`, `bonsai-fork-2x` share their blocks' scores under the shared-score rule, for the coordinator to write.
- `bonsai-fork-budget-mendel-guided` (44.5/100, up from the no-budget row's 31.5/100; 5/8 libraries against 1/8; the budget never fired on any turn of this row).

**What a gate dropped, and why:** nothing was dropped. Three deviations were caught and fixed in the same block, all recorded above at their own point in this file: the MBPP dataset cache hang in `gemma26-gguf-budget-think` (fixed by hand-filling the cache file, no tool change); a false `SERVER DEAD` watcher verdict in `qwen38-bartowski-budget-xhigh` from a one-slot server queued behind a long turn (watcher restarted with a longer `RUNWATCH_SILENCE`, server never touched); the `bonsai-fork-budget-mendel-guided` branch-name collision (resolved by the coordinator with a temporary pi id, `bonsai-prism-tb8192`, removed at block close, file matches its backup).

**Machine state left behind:** no server, no watcher, no Mendel Daemon. Wired memory at baseline (~2.2 GB). `~/.pi/agent/models.json` matches its pre-run-22 backup (`~/.pi/agent/models.json.bak-run22`, safe to remove). `tools/archive-evidence.sh` found nothing to archive; every result file is already committed under `hardware/kamaji/benchmarks/bench22/results/`.

**Evidence:** every run and calibration file is committed on `run22`; nothing lives only in `~/.local/share/`.

The coordinator writes `report.md`, adds the findings to `hardware/kamaji/benchmarks/INDEX.md`, decides what reaches the site (including the agent-row publish question already raised: the site has no field yet for a thinking-budget agent row), and merges `run22` into `master`.
