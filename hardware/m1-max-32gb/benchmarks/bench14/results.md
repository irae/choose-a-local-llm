# Run 14 — results

One section per block, in run order. Every number with the exact
command that produced it and the file under `results/` that holds the
evidence.

A benchy table has one row per depth: depth, benchy tok/s, its
standard deviation across the repeats, the site's current tok/s at
the nearest depth, the difference in percent, and the draft
acceptance read from the server log. A cell without acceptance is not
a drafter measurement. A table carries no pick.

## benchy-qwen36-f16-nodrafter

`unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` rev `5bc3e23`, `--no-mmproj`, f16 KV, no drafter, one slot, `-c 40960`, wired 25000.

```
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj --parallel 1 \
  -ngl 999 -fa on -c 40960 \
  --cache-type-k f16 --cache-type-v f16 --cache-ram 0 \
  --jinja --port 8081 --offline
```

The `40960` cell failed at that exact depth: a benchy request adds
pp/tg tokens on top of the depth, so a request at the ceiling depth
does not fit inside a server serving exactly that ceiling (HTTP 400,
"exceeds the available context size"). Retried at depth 39936, the
deepest request that fits `-c 40960`, on the coordinator's answer.

| depth | benchy tok/s | sd | site tok/s | diff | acceptance |
|--:|--:|--:|--:|--:|--:|
| 4096 | 49.80 | 0.41 | 69.1 | -28.0% | — (no drafter) |
| 39936 | 38.26 | 0.01 | 52.6 (41K) | -27.3% | — (no drafter) |

Files: `results/benchy-qwen36-f16-nodrafter.md`, `results/benchy-qwen36-f16-nodrafter-retry.md`, `results/server-benchy-qwen36-f16-nodrafter.log`, `results/server-benchy-qwen36-f16-nodrafter-retry.log`.

## benchy-qwen36-q8-drafter

`unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` rev `5bc3e23`, `--no-mmproj`, q8_0 KV, drafter `--spec-type draft-mtp --spec-draft-n-max 3`, one slot, `-c 98304`, wired 25000.

```
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 98304 \
  --cache-type-k q8_0 --cache-type-v q8_0 --cache-ram 0 \
  --jinja --port 8081 --offline
```

| depth | benchy tok/s | sd | site tok/s | diff | acceptance |
|--:|--:|--:|--:|--:|--:|
| 4096 | 43.68 | 0.82 | 36.5 | +19.7% | 0.60–0.85 |
| 49152 | 19.23 | 0.87 | 14.3 | +34.5% | 0.54–0.59 |
| 81920 | 13.01 | 0.16 | 9.24 | +40.8% | 0.60–0.62 |

The 82K cell reads 13.01 tok/s on real text, above the 8 tok/s floor
by a wide margin: the row's window still holds.
Files: `results/benchy-qwen36-q8-drafter.md`, `results/server-benchy-qwen36-q8-drafter.log`, `results/benchy-qwen36-q8-drafter-vm.log`.

## benchy-qwen38-bartowski-drafter

`bartowski/Qwen3.8-27B-GGUF:Q4_K_M` rev `f0eec4a`, `--no-mmproj`, f16 KV, drafter `--spec-type draft-mtp --spec-draft-n-max 3`, one slot, `-c 73728`, wired 25000. Tokenizer `Qwen/Qwen3.8-27B`, this build's own base model, so `benchy_tokenizer` from research run 4 applies as-is.

```
llama-server -hf bartowski/Qwen3.8-27B-GGUF:Q4_K_M \
  --alias qwen3.8-27b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c 73728 \
  --cache-type-k f16 --cache-type-v f16 --cache-ram 0 \
  --jinja --port 8081 --offline
```

| depth | benchy tok/s | sd | site tok/s | diff | acceptance |
|--:|--:|--:|--:|--:|--:|
| 4096 | 11.77 | 1.09 | 20.0 | -41.2% | 0.46–0.54 |
| 65536 | 8.57 | 1.39 | 13.7 | -37.4% | 0.37–0.63 |

Wired 25022 MB, swap flat (437 → 421 MB across the session, no growth).
Files: `results/benchy-qwen38-bartowski-drafter.md`, `results/server-benchy-qwen38-bartowski-drafter.log`.

## qwen36-smoke-off, qwen36-mendel-blind-off

Smoke: `smoke: simulator(mendel-blind) qwen-3.6-35b-a3b q8/off: 10 calls, 1 commit, clean, 20s. pass.`

Mendel blind, thinking off, on the `benchy-qwen36-q8-drafter` server (q8_0 KV, drafter n-max 3, `-c 98304`, wired 25000). Prompt blind v1.1, base `2652ed6`, window 81920. Branch `qwen3.6-35b-a3b-off-issue-13`. Sampling: temperature 1, top_p 0.95 (server default, read from the run's `meta.json`; no sampling parameter passed by this run).

```
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=81920 ./run-worker.sh qwen3.6-35b-a3b pi blind off
```

Scored by a subagent on `claude-opus-5`.

| test | model | serving | score | worst defect |
|---|---|---|--:|---|
| blind | qwen3.6-35b-a3b, GGUF q8_0 -c 98304, thinking off | llama-server | 50.5/100, 8/8 libraries | critical |

Worst defect: Trap A missed — `fs/promises`'s `glob` kept a `.then()` call that throws at runtime, and no test covers the file, so the suites stayed green. Second critical: root `package.json` still declares `rimraf` and `tmp` though the model's own summary claims every dependency removed. One medium: the CLI colour option prompt v1.1 asks removed is still present. Trap B fixed, Trap C handled correctly. `peak_context` (counter) 97823, above the configured 81920-token window; the server's own `-c` (98304) absorbed it, so nothing crashed, but the window did not hold.

Benchmark/harness faults flagged by the scorer, separate from the model's score: `score.mjs`'s `trap_a.ok` reads `true` from process exit while the actual output is a thrown `TypeError` (a tool bug, not a model fault); RUBRIC.md's default diff (`master..branch`) picks up unrelated drift since `master` moved past this run's base commit (diffed from the recorded base, the branch touches only its 40 task files); a dirty-worktree reset after a compaction may have cost the model work it had already done, and the harness's `baseline_dirty` field was empty so this could not be ruled out.

Files: `~/.local/share/mendel-benchmark/runs/qwen3.6-35b-a3b-off-blind-session.jsonl`, `~/code/mendel-benchmark/scratchpad/benchmark/runs/qwen3.6-35b-a3b-off-issue-13-evidence.json`, `results/mendel-smoke-qwen36-off.log`.

## qwen38-bartowski-smoke-xhigh

Smoke: `smoke: simulator(mendel-blind) qwen-3.8-27b bartowski-q4km/f16/xhigh: 10 calls, 1 commit, clean, 150s. pass.`

Served on the `benchy-qwen38-bartowski-drafter` config (f16 KV, drafter n-max 3, `-c 73728`, wired 25000). `qwen38-bartowski-mendel-xhigh` may run next.
Files: `results/mendel-smoke-qwen38-bartowski-xhigh.log`.

## qwen38-bartowski-mendel-xhigh

Mendel blind, thinking effort xhigh (this model's own published default), on the `benchy-qwen38-bartowski-drafter` server (f16 KV, drafter n-max 3, `-c 73728`, wired 25000). Prompt blind v1.1, base `2652ed6`, window 65536. Branch `qwen3.8-27b-xhigh-issue-13`. Sampling: temperature 1, top_p 0.95 (server default, read from the run's `meta.json`).

```
cd ~/code/mendel-benchmark/benchmark && MENDEL_CONTEXT_WINDOW=65536 ./run-worker.sh qwen3.8-27b pi blind xhigh
```

Scored by a subagent on `claude-opus-5`. Completed on its own (`end_reason: complete`), not a wall-clock partial. 2 tooling nudges (stall auto-recoveries), 0 model nudges, loop ok, 17 commits. `peak_context` (counter) 61572, inside the configured 65536 window.

| test | model | serving | score | worst defect |
|---|---|---|--:|---|
| blind | qwen3.8-27b, bartowski Q4_K_M -c 73728, thinking xhigh | llama-server | 93/100, 8/8 libraries | medium |

Worst defect: Trap B left — `legacy-packages/mendel-requirify` still requires and declares `rimraf`; the model found it by its own grep and judged it out of scope, same deduction the sibling rows made. No critical defect. Trap A passed for real this time (a `globToFiles()` helper drains the async iterator correctly before any `.then()`). Trap C passed. Chalk migration follows the v1.1 contract. 17 clean single-package `chore` commits, no hook bypass, no TASKS.md leak.

Benchmark/harness faults flagged, separate from the model's score: `score.mjs`'s `runtime_checks.prettier.ok = false` is a scoring-tool artifact — the only warning is the uncommitted `TASKS.md` scratch file the prompt itself forbids committing; the tool should skip untracked files. The 2 tooling nudges were stall auto-recoveries, correctly unscored. `mendel-full-example` karma and an FSEvents flake are pre-existing baselines, not regressions from this run.

Files: `~/.local/share/mendel-benchmark/runs/qwen3.8-27b-xhigh-blind-session.jsonl`, `~/code/mendel-benchmark/scratchpad/benchmark/runs/qwen3.8-27b-xhigh-issue-13-evidence.json`, `results/mendel-smoke-qwen38-bartowski-xhigh.log`.
