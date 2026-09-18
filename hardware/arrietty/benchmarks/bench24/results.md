# Run 24 — results

One section per block: the two KV picks with their ladders, the two
speed tables, the calibration with its derived budgets, the budget
block with score, empties, forced count and wall, the forced re-run
with its report table, and the blind row with its peak context and
tool-call count.

Every row of this run is served with the publisher's llama.cpp fork.
The stock binary produces garbage on these files, so the fork and its
commit belong in every config note.

## `bonsai2-pq2-kvpick`

`Ternary-Bonsai-2-27B-PQ2_0.gguf` rev `6ed5e12`, fork `prism-b10685-7dffb15` (commit `7dffb158d`), `--no-mmproj --parallel 1 -ngl 999 --fit off -fa on`, port 8081.

Ladder, `--cache-type-k q8_0 --cache-type-v q8_0`:

| `-c` | result |
|--:|---|
| 262144 | fail, CUDA OOM allocating 8704 MiB |
| 131072 | pass |
| 196608 | pass |
| 229376 | fail, CUDA OOM allocating 1210 MiB |
| 212992 | pass |

`bonsai2_27b_pq2_c_q8` = 212992. Verified with one real chat completion (200 OK, correct answer).

Ladder, `--cache-type-k f16 --cache-type-v f16`:

| `-c` | result |
|--:|---|
| 131072 | fail, CUDA OOM allocating 262 MiB |
| 65536 | pass |
| 98304 | pass |
| 114688 | pass |
| 122880 | pass |

`bonsai2_27b_pq2_c_f16` = 122880 (131072 not retried; the 5-load budget was spent finding the largest multiple of 8192 below the known fail). Verified with one real chat completion (200 OK, correct answer).

**Pick**: q8_0, larger serving `-c` (212992 vs 122880). `bonsai2_27b_pq2_kv` = `q8_0`, `bonsai2_27b_pq2_c` = 212992.

Sampling defaults the server actually applies (from `/props` at load): `temperature 1.0, top_p 0.95, top_k 20, min_p 0.05`. Note: the runbook's Essentials line names `min_p 0.0` from the GGUF metadata; the served default is `min_p 0.05`. Recorded as measured, not corrected.

Files: `results/server-kvpick-pq2-q8-*.log`, `results/server-kvpick-pq2-f16-*.log`, `results/kvpick-pq2-*-probe.json`.

## `sweep-bonsai2-pq2`

`Ternary-Bonsai-2-27B-PQ2_0.gguf` rev `6ed5e12`, fork `prism-b10685-7dffb15`, pick q8_0, `-c 212992`, `--cache-ram 0` for the measurement. Tokenizer `unsloth/Qwen3.8-27B`. Corpus `corpus-mendel-js.txt`. Tool `local-llm-eval-tools` at `204acec`. Depths 4096, 24576, 65536, 211968 (= 212992 − 1024).

| arm | depth | tok/s (tg256) | prompt tok/s (pp512) | VRAM used | MemAvailable |
|---|--:|--:|--:|--:|--:|
| q8 | 4096 | 46.04 ± 0.04 | 951.06 ± 0.29 | 15735 MiB | ~18.9 GB |
| q8 | 24576 | 38.17 ± 0.01 | 886.72 ± 0.03 | 15735 MiB | ~18.9 GB |
| q8 | 65536 | 28.23 ± 0.02 | 747.84 ± 0.14 | 15735 MiB | ~18.9 GB |
| q8 | 211968 | 14.51 ± 0.00 | 472.40 ± 0.01 | 15735 MiB | ~18.9 GB |

VRAM flat across every depth (15735 MiB), no swap growth. Every depth clears the 8 tok/s floor; the deepest tested depth is the deepest clean depth.

`bonsai2_pq2_clean` = 211968 (deepest tested depth, still above the floor at 14.51 tok/s; the sweep did not find a depth below the floor).

Files: `results/benchy-bonsai2-pq2-q8.md`, `results/benchy-bonsai2-pq2-q8.out.log`, `results/benchy-bonsai2-pq2-q8-vm.log`, `results/server-sweep-pq2-q8.log`.

**A table and no pick.**

## `bonsai2-pq2-smoke-xhigh`

`bonsai2_pq2_window` = 208896 (`bonsai2_pq2_clean` 211968 rounded down to a multiple of 4096, at or under `-c` 212992). Registered `bonsai2-27b-pq2` in `~/.pi/agent/models.json` (llama provider, `qwen35`-family template, `reasoning_effort` chat-template kwarg — same pattern as `qwen3.8-27b-iq3s`; backup kept at `~/.pi/agent/models.json.bak-run24`).

`SMOKE_MENDEL_CONTEXT_WINDOW=208896 benchmarks/mendel-smoke.sh bonsai2-27b-pq2 xhigh`: task xtend, 12 tool calls (12 distinct), 1 commit, clean tree, no repetition loop, 0 compactions, peak 4418 tokens, wall 37s. **verdict: pass.** Session log carries 8 reasoning blocks — the thinking-on entry reached the server.

Files: `results/mendel-smoke-bonsai2-pq2.log`.

## `bonsai2-pq2-mendel-blind-xhigh`

`model`: `bonsai2-27b-pq2 (prism-ml PQ2_0, xhigh, arrietty)`. `model_id`: `prism-ml/Ternary-Bonsai-2-27B-gguf`, file `Ternary-Bonsai-2-27B-PQ2_0.gguf`, revision `6ed5e12bf84b7a63069882c91dd9e9218647d17b`. `hardware`: `arrietty`.

Config note: fork `PrismML-Eng/llama.cpp` release `prism-b10685-7dffb15` (commit `7dffb158d`) — **the stock llama.cpp binary produces garbage on this file**; `-c 212992`, cache type q8_0 (`bonsai2-pq2-kvpick`); window 208896 (`bonsai2_pq2_clean` 211968 rounded to a multiple of 4096, `bonsai2-pq2-smoke-xhigh`); reserve 8192, keep-recent pi's default (window > 65536); 0 compactions; `vram 16311 MiB`; sampling as the server applies it, temperature 1.0, top_p 0.95, top_k 20, min_p 0.05 (`bonsai2-pq2-kvpick`, `/props`).

Branch `bonsai2-27b-pq2-xhigh-issue-13`, base commit `2652ed6c`. Started `2026-09-18T08:04:13Z`, ended `2026-09-18T09:36:40Z`, wall 1:32:27. `end_reason`: complete. Loop flag: ok, worst ratio 0.27 (thinking). 16 commits (16 non-chore, 0 multi-package, 0 TASKS.md leaks). 0 nudges (tooling or model), 0 respawns, 0 retries.

| field | value |
|---|--:|
| score | 60/100 |
| tasks | 1/1 (single blind task) |
| worst defect | CRITICAL |
| stop reason | complete |
| tool calls | 245 |
| peak ctx | 192679/208896 (92.2%) |
| known events | 0 |
| elapsed | 1:32:27 |

`peak_context` verified with `benchmark/count-tool-calls.mjs` against the session log: `tool_calls 245, assistant_msgs 216, peak_context 192679` — agrees with the worker's own `contextUsage.tokens`.

**Score: 60/100.** Scored by a judgment subagent from the evidence pack, the session log, and the worktree diff — never from the model's own claims.

**Worst defect: CRITICAL.** Commit `ede1f89c` (`packages/mendel-development/validate-manifest.js`) adds `process.on('exit', () => fs.rmSync(tempDir, {recursive:true, force:true}))` right after the code writes and prints the debug manifest path — the exact trap-C regression the rubric warns about: the file the user needs to inspect is deleted before they can read it.

Per-criterion breakdown (criterion / max / scored / evidence):

| # | criterion | max | scored | evidence |
|--:|---|--:|--:|---|
| 1 | Bugs remaining | 25 | 10 | Critical: exit-hook trap-C regression. Medium: chalk port drops `enableColor` handling entirely (commit `55398f75` removes the level-set line with no replacement; `cli.js:55` and tests still pass `enableColor`). Trap A passed (`trap_a.ok: true`). |
| 2 | Task completion | 20 | 13 | All 8 libraries touched, but `static_completeness.clean: false` — 2 stale `require('rimraf')` in `legacy-packages/mendel-requirify` (trap B, missed, not in TASKS.md), plus stale `rimraf`/`tmp` entries in two `package.json` files. |
| 3 | node_modules pruned | 8 | 0 | `lockfile.numstat: "no change"`, `shrank: false`; no `pnpm install` in the session log; `root_devdeps.removed: false` (`tmp` still declared). |
| 4 | Prettier/ESLint | 5 | 2 | `runtime_checks.eslint.ok: true`; `runtime_checks.prettier.ok: false` (`[warn] TASKS.md`, never reformatted). |
| 5 | Commit craft | 12 | 8 | 16/16 commits `fix(...)`, not `chore`; one package per commit (4/4); no `--no-verify`, no `git add -A`, no TASKS.md leak. |
| 6 | Right the first time | 8 | 8 | No repair/fixup commits; 0 model nudges, 0 tooling nudges. |
| 7 | Test discipline | 10 | 9 | `full_suite_runs: 7` over 16 commits (beats the every-5 mandate); `lint_self_runs: 13`. |
| 8 | House conventions | 5 | 4 | Diffs minimal, style-matched (kept `var`, function shape); one added comment is explanatory, not churn. |
| 9 | Task list | 4 | 4 | TASKS.md lists all 8 libraries upfront, ticked, with discovery notes. |
| 10 | Truncated noisy commands | 3 | 1.5 | `truncation_share: 65%` (50/77 noisy commands piped through tail/head). |

Sum 59.5, rounds to **60/100**.

## `bonsai2-pq2-f16-kvpick`

`Ternary-Bonsai-2-27B-PQ2_0.gguf` rev `6ed5e12`, fork `prism-b10685-7dffb15`, `--cache-type-k f16 --cache-type-v f16`, `--no-mmproj --parallel 1 -ngl 999 --fit off -fa on --cache-ram 0`, port 8081. Type fixed to f16; only the serving ceiling was open.

Planning value 122880 — the f16 ceiling `bonsai2-pq2-kvpick` already measured for this file, where 131072 failed. Loaded at 122880: pass. The gap to the known fail (131072) is already 8192, the ladder's finest step, so no further bisection is possible or needed.

`bonsai2_pq2_f16_c` = 122880. Verified with one real chat completion (200 OK, correct answer).

Files: `results/server-kvpick-pq2-f16-arm-122880.log`, `results/kvpick-pq2-f16-arm-122880-probe.json`.

## `sweep-bonsai2-pq2-f16`

`Ternary-Bonsai-2-27B-PQ2_0.gguf` rev `6ed5e12`, fork `prism-b10685-7dffb15`, f16 KV, `-c 122880`, `--cache-ram 0` for the measurement. Tokenizer `unsloth/Qwen3.8-27B`. Corpus `corpus-mendel-js.txt` (restarted for this block). Tool `local-llm-eval-tools` at `204acec`. Depths 4096, 24576, 65536, 121856 (= 122880 − 1024).

| arm | depth | tok/s (tg256) | prompt tok/s (pp512) | VRAM used | MemAvailable |
|---|--:|--:|--:|--:|--:|
| f16 | 4096 | 46.29 ± 0.01 | 969.88 ± 0.52 | 15464 MiB | ~18.6 GB |
| f16 | 24576 | 40.47 ± 0.08 | 899.59 ± 0.29 | 15464 MiB | ~18.6 GB |
| f16 | 65536 | 32.17 ± 0.03 | 761.47 ± 0.13 | 15464 MiB | ~18.6 GB |
| f16 | 121856 | 25.09 ± 0.00 | 625.61 ± 0.04 | 15464 MiB | ~18.6 GB |

VRAM flat across every depth (15464 MiB), no swap growth. Every depth clears the 8 tok/s floor; the deepest tested depth is the deepest clean depth.

`bonsai2_pq2_f16_clean` = 121856 (deepest tested depth, still above the floor at 25.09 tok/s).

Files: `results/benchy-bonsai2-pq2-f16.md`, `results/benchy-bonsai2-pq2-f16.out.log`, `results/benchy-bonsai2-pq2-f16-vm.log`, `results/server-sweep-pq2-f16-arm.log`.

**A table and no pick.**

Files: `results/mendel-blind-bonsai2-pq2.out.log`, `results/mendel-blind-bonsai2-pq2-evidence.json`, session `~/.local/share/mendel-benchmark/runs/bonsai2-27b-pq2-xhigh-blind-session.jsonl`, meta `~/.local/share/mendel-benchmark/runs/bonsai2-27b-pq2-xhigh-blind-meta.json`.

## `bonsai2-pq2-calibrate-think`

`Ternary-Bonsai-2-27B-PQ2_0.gguf` rev `6ed5e12`, fork `prism-b10685-7dffb15`, pick q8_0, `-c 32768`, no reasoning-budget flag. Calibration name `bonsai2-pq2-xhigh-think`, extra body `{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}`. All 10 rows resolve `resolved_reasoning_effort: "xhigh"` from the request; no level mismatch.

| task_id | finish_reason | reasoning_len (chars) | wall_s |
|---|---|--:|--:|
| HumanEval/0 | stop | 2474 | 15.6 |
| HumanEval/10 | stop | 41282 | - |
| HumanEval/26 | stop | 3395 | - |
| HumanEval/32 | length | 84642 | 721.0 |
| HumanEval/38 | stop | 4425 | - |
| HumanEval/39 | stop | 9363 | - |
| HumanEval/76 | stop | 48380 | - |
| HumanEval/99 | length | 33429 | 719.8 |
| HumanEval/124 | stop | 11191 | - |
| HumanEval/145 | length | 99016 | 719.1 |

7 converged, 3 cut at the generous wall-clock cap (~720s each, non-convergence, not a token cap). No converged row had an empty answer.

`thinking-budget.py derive`: converged 7, cut 3, max_reasoning_tokens 16806, max_answer_tokens 453, think_budget 25209, answer_budget 2048 (floor), max_tokens 27257.

`bonsai2_pq2_think_budget` = 25209, `bonsai2_pq2_answer_budget` = 2048, `bonsai2_pq2_max_tokens` = 27257.

Files: `hardware/arrietty/calibrations/calibration-bonsai2-pq2-xhigh-think.json`, `results/server-bonsai2-pq2-calibrate-think.log`.

## `bonsai2-pq2-budget-xhigh`

`Ternary-Bonsai-2-27B-PQ2_0.gguf` rev `6ed5e12`, fork `prism-b10685-7dffb15`, pick q8_0, `-c 32768`, `--reasoning-budget 25209 --reasoning-budget-message "Thinking budget reached. Give the final answer now."`, extra body `{"chat_template_kwargs":{"reasoning_effort":"xhigh"}}`, `EVALPLUS_MAX_NEW_TOKENS=27257`. Full 164-problem HumanEval run, `2026-09-18T03:03:04Z` to `2026-09-18T05:58:51Z`, wall 2:56:03. VRAM 8871 MiB stable.

| metric | value |
|---|--:|
| HumanEval base pass@1 | 0.982 |
| HumanEval plus pass@1 | 0.939 |
| completion rate | 100% |
| empty (from samples) | 0/164 |
| forced (budget fired) | 7/164 |

Forced task ids: `HumanEval/32`, `HumanEval/64`, `HumanEval/80`, `HumanEval/91`, `HumanEval/99`, `HumanEval/137`, `HumanEval/145`. Correction: "0 empty" means no sample was blank, not that every forced problem passed its test — `bonsai2-pq2-forced-rerun` below found 4 of the 7 forced problems failed their tests (non-empty wrong answers).

**The agent gate**: base pass@1 0.982 ≥ 0.800 — pass. `bonsai2-pq2-smoke-xhigh` and the blind row proceed.

Files: `results/bonsai2-pq2-budget-xhigh/`, `results/server-bonsai2-pq2-budget-xhigh.log`, `results/watcher-bonsai2-pq2-budget-xhigh.log`, `results/run-bonsai2-pq2-budget-xhigh.out.log`.

## `bonsai2-pq2-forced-rerun`

Natural re-run (no reasoning-budget flags), same config, `EVALPLUS_MAX_NEW_TOKENS=30000`. Prepared from `bonsai2-pq2-budget-xhigh`: 7 forced, 4 forced-failed (`HumanEval/32`, `91`, `99`, `145`), regenerated only those 4. Wall 0:48:28.

| task_id | cell | forced_tokens | natural_finish | natural_tokens | natural_reasoning_tokens |
|---|---|--:|---|--:|--:|
| HumanEval/32 | forced-fail-loop | 26055 | length | 30000 | 30000 |
| HumanEval/64 | forced-pass | 27257 | | | |
| HumanEval/80 | forced-pass | 25425 | | | |
| HumanEval/91 | forced-fail-loop | 25519 | length | 30000 | 30000 |
| HumanEval/99 | forced-fail-loop | 25421 | length | 30000 | 30000 |
| HumanEval/137 | forced-pass | 25621 | | | |
| HumanEval/145 | forced-fail-loop | 25323 | length | 30000 | 30000 |

Summary: forced-pass=3, forced-fail-late=0, forced-fail-loop=4, forced-fail-wrong=0. `corrected_think_budget`: unchanged, no late answer (every forced-failed problem still hit the 30000-token generous cap unconverged — the budget was not too small, these four are genuine non-convergence).

Files: `results/bonsai2-pq2-forced-rerun/`, `results/server-bonsai2-pq2-forced-rerun.log`, `results/watcher-bonsai2-pq2-forced-rerun.log`, `results/run-bonsai2-pq2-forced-rerun.out.log`.

## `bonsai2-ptq1-kvpick`

`Ternary-Bonsai-2-27B-PTQ1_0.gguf` rev `6ed5e12`, fork `prism-b10685-7dffb15`, `--no-mmproj --parallel 1 -ngl 999 --fit off -fa on`, port 8081.

Ladder, `--cache-type-k q8_0 --cache-type-v q8_0`:

| `-c` | result |
|--:|---|
| 262144 | fail, CUDA OOM allocating 1370 MiB |
| 131072 | pass |
| 196608 | pass |
| 229376 | pass |
| 245760 | pass |
| 253952 | fail, CUDA OOM allocating 1330 MiB |

`bonsai2_27b_ptq1_c_q8` = 245760. Verified with one real chat completion (200 OK, correct answer).

Ladder, `--cache-type-k f16 --cache-type-v f16`:

| `-c` | result |
|--:|---|
| 131072 | pass |
| 196608 | fail, CUDA OOM allocating 12288 MiB |
| 163840 | fail, CUDA OOM allocating 10240 MiB |
| 147456 | fail, CUDA OOM abort during first eval (compute buffer, not the load itself — a live crash, not a clean "model loaded" reject) |
| 139264 | pass |

`bonsai2_27b_ptq1_c_f16` = 139264. Verified with one real chat completion (200 OK, correct answer).

**Pick**: q8_0, larger serving `-c` (245760 vs 139264). `bonsai2_27b_ptq1_kv` = `q8_0`, `bonsai2_27b_ptq1_c` = 245760.

Files: `results/server-kvpick-ptq1-q8-*.log`, `results/server-kvpick-ptq1-f16-*.log`, `results/kvpick-ptq1-*-probe.json`.

## `sweep-bonsai2-ptq1`

`Ternary-Bonsai-2-27B-PTQ1_0.gguf` rev `6ed5e12`, fork `prism-b10685-7dffb15`, pick q8_0, `-c 245760`, `--cache-ram 0` for the measurement. Tokenizer `unsloth/Qwen3.8-27B`. Corpus `corpus-mendel-js.txt`. Tool `local-llm-eval-tools` at `204acec`. Depths 4096, 24576, 65536, 244736 (= 245760 − 1024).

| arm | depth | tok/s (tg256) | prompt tok/s (pp512) | VRAM used | MemAvailable |
|---|--:|--:|--:|--:|--:|
| q8 | 4096 | 41.69 ± 0.00 | 452.74 ± 0.06 | 15837 MiB | ~18.7 GB |
| q8 | 24576 | 34.89 ± 0.00 | 439.02 ± 0.02 | 15837 MiB | ~18.7 GB |
| q8 | 65536 | 26.48 ± 0.00 | 402.04 ± 0.02 | 15837 MiB | ~18.7 GB |
| q8 | 244736 | 12.79 ± 0.00 | 288.05 ± 0.17 | 15837 MiB | ~18.7 GB |

VRAM flat across every depth (15837 MiB), no swap growth. Every depth clears the 8 tok/s floor; the deepest tested depth is the deepest clean depth.

`bonsai2_ptq1_clean` = 244736 (deepest tested depth, still above the floor at 12.79 tok/s).

Files: `results/benchy-bonsai2-ptq1-q8.md`, `results/benchy-bonsai2-ptq1-q8.out.log`, `results/benchy-bonsai2-ptq1-q8-vm.log`, `results/server-sweep-ptq1-q8.log`.

**A table and no pick.**

## `bonsai2-pq2-mendel-blind-xhigh-f16`

`model`: `bonsai2-27b-pq2-f16 (prism-ml PQ2_0, xhigh, arrietty)`. `model_id`: `prism-ml/Ternary-Bonsai-2-27B-gguf`, file `Ternary-Bonsai-2-27B-PQ2_0.gguf`, revision `6ed5e12bf84b7a63069882c91dd9e9218647d17b`. `hardware`: `arrietty`.

Config note: fork `PrismML-Eng/llama.cpp` release `prism-b10685-7dffb15` (commit `7dffb158d`) — the stock llama.cpp binary produces garbage on this file; `-c 122880`, cache type **f16** (`bonsai2-pq2-f16-kvpick`); window 118784 (`bonsai2_pq2_f16_clean` 121856 rounded to a multiple of 4096, never the q8_0 row's window); reserve 8192, keep-recent pi's default (window > 65536); 1 compaction; `vram 16311 MiB`; sampling as the server applies it, temperature 1.0, top_p 0.95, top_k 20, min_p 0.05. **No smoke: the same file passed its smoke at q8_0 in this run (owner, 2026-09-18).**

Branch `bonsai2-27b-pq2-f16-xhigh-issue-13`, base commit `2652ed6c`. Started `2026-09-18T12:45:31Z`, ended `2026-09-18T14:00:15Z`, wall 1:14:44. `end_reason`: complete. Loop flag: ok, worst ratio 0.35 (thinking). 13 commits, 1 compaction (at threshold, `2026-09-18T13:25:29Z`). 0 nudges, 0 retries.

| field | value |
|---|--:|
| score | 72/100 |
| tasks | 1/1 (single blind task) |
| worst defect | MEDIUM |
| stop reason | complete |
| tool calls | 230 |
| peak ctx | 110354/118784 (92.9%) |
| known events | 1 compaction |
| elapsed | 1:14:44 |

`peak_context` verified with `benchmark/count-tool-calls.mjs` against the session log: `tool_calls 230, assistant_msgs 231, peak_context 110354`. This is the peak over the session, not the post-compaction figure the worker's own `contextUsage.tokens` (99991) reports — the rule is never the value after a compaction.

**Score: 72/100.** Scored by a judgment subagent from the evidence pack, the session log, and the worktree diff — never from the model's own claims. **Correction**: the subagent's own final line claimed 78/100, but its ten-criterion breakdown sums to 72; this run recomputed the sum and used the verified total, 72, not the subagent's unsupported round-up.

**Worst defect: MEDIUM.** The chalk swap keeps `enableColor` forcing (`cli-printer.js:18`, `this._colorEnabled = options.enableColor !== false`; `cli.js:55` still passes `enableColor: true`), against the blind prompt's requirement that color follow Node's own defaults with no forced enable/disable. **The CRITICAL exit-hook regression from the sibling q8_0 row does not repeat here** — `validate-manifest.js` switches cleanly to `fs.mkdtempSync` with no exit hook (confirmed in the worktree diff).

Per-criterion breakdown (criterion / max / scored / evidence):

| # | criterion | max | scored | evidence |
|--:|---|--:|--:|---|
| 1 | Bugs remaining | 25 | 19 | One medium bug, the chalk `enableColor` forcing above. Trap A passes clean (`trap_a.ok: true`). |
| 2 | Task completion | 20 | 15 | 7/8 libraries fully done; `mendel-requirify` still requires `rimraf` in two test files and its `package.json` (trap B missed, `static_completeness.stale_requires`/`stale_package_json`). |
| 3 | node_modules pruned | 8 | 7 | Lockfile shrank by 96 lines; `pnpm install` run and committed, though its output was piped through `tail`. |
| 4 | Prettier/ESLint | 5 | 3 | ESLint clean; Prettier fails on `TASKS.md` only (`runtime_checks.prettier.ok: false`). Model self-ran lint once (`lint_self_runs: 1`). |
| 5 | Commit craft | 12 | 4 | All 13 commits `fix:`, none `chore`; 2 multi-package commits; `git add -A` used in every commit (no `--no-verify`, no TASKS.md leak). |
| 6 | Right the first time | 8 | 8 | No repair/fixup commits; 0 model nudges. |
| 7 | Test discipline | 10 | 8 | `full_suite_runs: 7` across 13 commits, roughly every 2 commits — denser than the every-5 mandate. |
| 8 | House conventions | 5 | 4 | Minimal, style-matched diff (39 files); one explanatory drive-by comment. |
| 9 | Task list | 4 | 3 | Not directly inspectable from the evidence pack; session log shows a per-package commit cadence consistent with progressive discovery. |
| 10 | Truncated noisy commands | 3 | 1 | `truncation_share: 55%` (42/76 noisy commands piped through tail/head). |

Sum 72, exact (subagent's own arithmetic; its reported headline of 78 was not supported and is not used).

Files: `results/mendel-blind-bonsai2-pq2-f16.out.log`, `results/mendel-blind-bonsai2-pq2-f16-evidence.json`, session `~/.local/share/mendel-benchmark/runs/bonsai2-27b-pq2-f16-xhigh-blind-session.jsonl`, meta `~/.local/share/mendel-benchmark/runs/bonsai2-27b-pq2-f16-xhigh-blind-meta.json`.

## `bonsai2-ptq1-f16-kvpick`

`Ternary-Bonsai-2-27B-PTQ1_0.gguf` rev `6ed5e12`, fork `prism-b10685-7dffb15`, `--cache-type-k f16 --cache-type-v f16`, `--no-mmproj --parallel 1 -ngl 999 --fit off -fa on --cache-ram 0`, port 8081. Type fixed to f16; only the serving ceiling was open.

Planning value 139264 — the f16 ceiling `bonsai2-ptq1-kvpick` already measured for this file, where 147456 aborted on a live CUDA out-of-memory. Loaded at 139264: pass. The gap to the known fail (147456) is already 8192, the ladder's finest step, so no further bisection is possible or needed.

`bonsai2_ptq1_f16_c` = 139264. Verified with one real chat completion (200 OK, correct answer).

Files: `results/server-kvpick-ptq1-f16-arm-139264.log`, `results/kvpick-ptq1-f16-arm-139264-probe.json`.
