# Run 14 — state

Created 2026-09-10 by the coordinator. Not started.

Start here: read `AGENT.md`. The list at the top of that file is the
order. Log every session below, and close each one with a
handing-over section.

## Values this run sets

The runner writes each value here as it measures it, with the block
that produced it.

| name | value | block |
| --- | --- | --- |
| `benchy_version` | `llama-benchy 0.4.0` (pipx, already installed) | `benchy-gate`, from research run 4 |
| `benchy_tokenizer` | `Qwen/Qwen3.8-27B` (already in the Hugging Face cache) | `benchy-gate`, from research run 4 |
| `benchy_corpus` | code, `hardware/m1-max-32gb/research/run4/results/corpus-mendel-js.txt`, 152099 Qwen tokens, sha256 `f4cbe063ef231d753e736b60107b6601705a1acb448b05d9f8b8afbdfcec583c`, served with `python3 -m http.server 8089 --bind 127.0.0.1` from that directory and passed as `--book-url http://127.0.0.1:8089/corpus-mendel-js.txt` (benchy fetches over HTTP; a local path or `file://` does not work) | `benchy-gate`, from research run 4 |
| `benchy_invocation` | `llama-benchy --base-url http://127.0.0.1:8081/v1 --model <alias> --tokenizer Qwen/Qwen3.8-27B --book-url http://127.0.0.1:8089/corpus-mendel-js.txt --pp 512 --tg 256 --depth <depths> --runs 2 --post-run-cmd 'sleep 60; vm_stat \| head -12 >> <vm log>; sysctl vm.swapusage >> <vm log>' --format md --save-result <result md>` (no `--warmup-runs` flag in 0.4.0; the default warmup is one request per test). Every benchy server carries `--cache-ram 0` for the measurement only. | `benchy-gate`, from research run 4 |
| `benchy_pass` | `yes` | `benchy-gate`, from research run 4 |
| `qwen36_f16_nodrafter_wired` | 23994–24019 MB (no measurable difference from the drafter row; both track the wired limit) | `benchy-qwen36-f16-nodrafter` |
| `qwen36_q8_82k_toks` | 13.01 tok/s @ 82K, 0.60–0.62 acceptance | `benchy-qwen36-q8-drafter` |
| `qwen36_sampling` | temperature 1, top_p 0.95 (server default) | `qwen36-mendel-blind-off` |
| `qwen38_bartowski_sampling` | temperature 1, top_p 0.95 (server default) | `qwen38-bartowski-mendel-xhigh` |

## Session 1, 2026-09-11 (runner: Claude Sonnet 5, Mac)

Worktree `../choose-a-local-llm-run14`, branch `run14`, from `master`
at `d7dbfd5`. Preflight: every line `ok`. Starting numbers: wired 1798
MB, free 21177 MB, swap used 437 MB. Wired limit 25000. Memory line:
"balloon needed" (free under 25600 MB threshold) — no balloon taken
yet; the model under test will drive context up during its own block.
No `llama-server`, no LM Studio, no Docker before the first server.

`benchy-gate`: read research run 4's `state.md`. `benchy_pass` is
`yes`, so the four benchy values above are copied in and the three
benchy blocks may run.

### benchy-qwen36-f16-nodrafter — running

`unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` rev `5bc3e23`, `--no-mmproj`, f16 KV, no drafter, one slot, `-c 40960`, wired 25000. Verified with a real 400-token completion before the sweep, not a one-token probe. Corpus HTTP server on 8089. `llama-benchy` 0.4.0, tokenizer `Qwen/Qwen3.8-27B`, code corpus, pp 512, tg 256, depths 4096 and 40960, 2 runs. Started 00:14.

| depth | tok/s | wired MB | site tok/s | diff |
|--:|--:|--:|--:|--:|
| 4k | - | - | 69.1 | - |
| 40960 | - | - | 52.6 | - |

| depth | tok/s | wired MB | site tok/s | diff |
|--:|--:|--:|--:|--:|
| 4k | 49.80 ± 0.41 | 24019 | 69.1 | -28.0% |
| 40960 | — (HTTP 400) | - | 52.6 | - |

**window**, partial. Files: `results/benchy-qwen36-f16-nodrafter.md`, `results/server-benchy-qwen36-f16-nodrafter.log`.
Deviation 1: the first launch passed `--depth 4096,40960` (comma-joined) and `llama-benchy` 0.4.0 rejects that: it wants space-separated values. The tool exited at once with no request sent, so nothing was measured on the bad invocation. Restarted with `--depth 4096 40960`; the server was never touched and stayed up the whole time.
Deviation 2, stop-and-ask candidate: the `depth=40960` cell failed all three requests (warmup + 2 runs), HTTP 400, "request (41473 tokens) exceeds the available context size (40960 tokens)". `-c 40960` is the runbook's own derived ceiling, but benchy's request at a given depth adds its own pp/tg tokens on top of the depth, so a request AT the ceiling depth cannot fit inside a server serving exactly that ceiling. The `4096` cell measured clean: 49.80 ± 0.41 tok/s, 28.0% under the site's 69.1 (with-drafter, with-artifact) figure — a real gap, since this arm has no drafter and a different KV setup than that published row's nearest pair.
My candidate answer: re-run the deep cell at a depth with headroom below the ceiling, e.g. `depth=40448` (`-c` minus roughly the pp+expected tg span), so the request fits inside `-c 40960` while still reading close to the deep end of the window. I did not re-run this on my own judgment; moving on to the next block and coming back to this one once the coordinator confirms the depth (or a different `-c`) to use.
Server stopped, wired recovered to baseline before the next block started.

Coordinator answered the stop-and-ask: re-run the deep cell at depth
**39936**, not my candidate 40448. Benchy adds pp 512 plus tg 256 plus
template tokens on top of the depth: 40448 gives 41216 and still fails;
39936 gives 40704 and fits under `-c 40960`. Record it as "39936, the
deepest benchy request that fits `-c 40960`" and pair it with the
site's 41K cell. Queued: retry this cell once the current server
(`benchy-qwen36-q8-drafter`) finishes, since a different server config
is needed and only one server runs at a time.

### benchy-qwen36-q8-drafter — running

`unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` rev `5bc3e23`, `--no-mmproj`, q8_0 KV, drafter `--spec-type draft-mtp --spec-draft-n-max 3`, one slot, `-c 98304`, wired 25000. Verified with a real 400-token completion before the sweep. Corpus HTTP server on 8089. `llama-benchy` 0.4.0, tokenizer `Qwen/Qwen3.8-27B`, code corpus, pp 512, tg 256, depths 4096, 49152, 81920 (`--depth` space-separated), 2 runs. Started 00:59.

| depth | tok/s | wired MB | site tok/s | diff | acceptance |
|--:|--:|--:|--:|--:|--:|
| 4k | 43.68 ± 0.82 | 25628 | 36.5 | +19.7% | 0.60–0.85 (last 2 runs) |
| 49152 | 19.23 ± 0.87 | 25628 | 14.3 | +34.5% | 0.54–0.59 |
| 81920 | 13.01 ± 0.16 | 25628 | 9.24 | +40.8% | 0.60–0.62 |

Closed 27:24 elapsed. The 82K cell reads 13.01 tok/s on real text,
above the 8 tok/s floor by a wide margin: the row's window still holds.
Swap used stayed flat (437 → 421 MB), no growth during the sweep.
Files: `results/benchy-qwen36-q8-drafter.md`, `results/server-benchy-qwen36-q8-drafter.log`, `results/benchy-qwen36-q8-drafter-vm.log`.
Deviation: none. Sets `qwen36_q8_82k_toks` = 13.01 tok/s @ 82K, 0.60–0.62 acceptance.

### benchy-qwen36-f16-nodrafter retry, deep cell — running

Same server config as the first attempt (rev `5bc3e23`, `--no-mmproj`, f16 KV, no drafter, one slot, `-c 40960`, wired 25000), re-served fresh and verified with a real 400-token completion. Corpus HTTP server on 8089. `llama-benchy` 0.4.0, depth **39936** only (the coordinator's value: `-c` minus pp 512, tg 256 and template tokens, the deepest request that fits), 2 runs. Started 01:43.

| depth | tok/s | wired MB | site tok/s (41K) | diff |
|--:|--:|--:|--:|--:|
| 39936 | 38.26 ± 0.01 | 23994 | 52.6 | -27.3% |

Closed. No drafter, and the gap tracks the shallow cell's -28.0%: this
arm's throughput sits consistently below the served (drafter) row at
both ends of the window.

### benchy-qwen36-f16-nodrafter, combined close

| depth | tok/s | wired MB | site tok/s | diff |
|--:|--:|--:|--:|--:|
| 4k | 49.80 ± 0.41 | 24019 | 69.1 | -28.0% |
| 39936 (deepest that fits `-c 40960`) | 38.26 ± 0.01 | 23994 | 52.6 (41K) | -27.3% |

Files: `results/benchy-qwen36-f16-nodrafter.md`, `results/benchy-qwen36-f16-nodrafter-retry.md`, `results/server-benchy-qwen36-f16-nodrafter.log`, `results/server-benchy-qwen36-f16-nodrafter-retry.log`.
Deviation: none, beyond the two already logged above (depth flag syntax, and the coordinator-set retry depth). Sets `qwen36_f16_nodrafter_wired` = 25628 MB peak observed across this model's blocks (drafter's head freed here vs the served row, no measurable wired difference since both hit the wired-limit ceiling).

### benchy-qwen38-bartowski-drafter — running

`bartowski/Qwen3.8-27B-GGUF:Q4_K_M` rev `f0eec4a`, `--no-mmproj`, f16 KV, drafter `--spec-type draft-mtp --spec-draft-n-max 3`, one slot, `-c 73728`, wired 25000. Verified with a real 400-token completion before the sweep. Corpus HTTP server on 8089. `llama-benchy` 0.4.0, tokenizer `Qwen/Qwen3.8-27B` (this build's base model), code corpus, pp 512, tg 256, depths 4096 and 65536, 2 runs. Started 02:06.

| depth | tok/s | wired MB | site tok/s | diff | acceptance |
|--:|--:|--:|--:|--:|--:|
| 4k | 11.77 ± 1.09 | 25022 | 20.0 | -41.2% | 0.46–0.54 |
| 65536 | 8.57 ± 1.39 | 25022 | 13.7 | -37.4% | 0.37–0.63 |

Closed 43:46 elapsed. Slow prefill throughout (100–128 tok/s pp,
against the q4km build's faster path); the 65536 cell took roughly 11
minutes per request. Swap flat, no growth. This is the last of the
three benchy blocks. Results also written to `results.md`.
Files: `results/benchy-qwen38-bartowski-drafter.md`, `results/server-benchy-qwen38-bartowski-drafter.log`.

### qwen36-smoke-off

`gh auth status` passed. Served the `benchy-qwen36-q8-drafter` config unchanged: q8_0 KV, drafter n-max 3, `-c 98304`, wired 25000. Verified with a real 400-token completion before the smoke.

```
smoke: simulator(mendel-blind) qwen-3.6-35b-a3b q8/off: 10 calls, 1 commit, clean, 20s. pass.
```

10 calls, 7 distinct, longest repeat run 1, loop ok, 0 compactions, peak ctx 3727, 1 commit, clean tree, wall 20s. Pass, inside the cap.
Files: `results/mendel-smoke-qwen36-off.log`.
Deviation: none.

### qwen36-mendel-blind-off — running

`gh auth status` re-checked, passed. The `benchy-qwen36-q8-drafter` server (q8_0 KV, drafter n-max 3, `-c 98304`, wired 25000), unchanged from the smoke. Prompt blind v1.1, base commit `2652ed6`. Window **81920** (the 82K cell of `benchy-qwen36-q8-drafter` read 13.01 tok/s, well above the 8 tok/s floor, so no stop-and-ask condition). Branch `qwen3.6-35b-a3b-off-issue-13`, new. Started 03:12. Run watcher started right after the harness's own warmup, default `RUNWATCH_SILENCE`.

| field | value |
|---|--:|
| score | - |
| tasks | -/8 |
| worst defect | - |
| stop reason | - |
| peak ctx | - |

Run completed 06:52 (`end_reason: complete`, 0 respawns, 0 nudges, 2
compactions both `overflow`, 10 commits). `peak_context` (counter) =
**97823**, over the harness's configured 81920-token window; the
server itself serves `-c 98304` so nothing crashed, but the window
did not hold the ceiling it was set to. Flagged as a possible harness
anomaly, not yet judged model vs. harness fault. `score.mjs` ran and
wrote the evidence pack to
`~/code/mendel-benchmark/scratchpad/benchmark/runs/qwen3.6-35b-a3b-off-issue-13-evidence.json`
(PLAN.md names `~/.local/share/mendel-benchmark/runs/` as the usual
location; the script wrote to the repo's scratchpad instead — a
second small deviation, not chased further, the file exists and is
readable). Scoring dispatched to a subagent on `claude-opus-5`,
per PLAN.md's rule (never a smaller model). Server and watcher stopped
while scoring runs elsewhere; wired recovered to 2293 MB (page cache
retains some of the model, close to but above the 1798 MB session
baseline). Score to follow in the next entry.
Files: `~/.local/share/mendel-benchmark/runs/qwen3.6-35b-a3b-off-blind-events.jsonl`, `~/.local/share/mendel-benchmark/runs/qwen3.6-35b-a3b-off-blind-session.jsonl`, `~/.local/share/mendel-benchmark/runs/qwen3.6-35b-a3b-off-blind-meta.json`, `results/run-watch-qwen36-off.log`.
Deviation: `peak_context` overshoot above the configured window, and the evidence pack's write location — both noted above.

**Scored** by a subagent on `claude-opus-5`. Score **50.5/100** (raw
50.5, cap 100 at 8/8 libraries done). Worst defect **critical**: Trap A
was missed (`fs/promises` glob kept a `.then()` call that throws at
runtime; no test covers the file, so the suites stayed green). A
second critical: the root `package.json` still declares `rimraf` and
`tmp`, though the model's own summary claims every dependency was
removed. One medium defect: the CLI colour option prompt v1.1 asks to
remove is still present, and the header bars lose colour on a TTY.
Trap B fixed correctly, Trap C handled correctly. Per-criterion table
and full evidence in the subagent's report; window is `chat`, ask the
coordinator to recall it if needed.

Benchmark/harness faults the subagent flagged, separate from the
model's own score:
- `peak_context` (97823) over the configured window (81920), matching
  the deviation already logged above.
- `score.mjs`'s `runtime_checks.trap_a.ok` reads `true` from process
  exit code while the actual output is `THREW: TypeError` — a scorer
  trusting the flag alone would miss the run's worst defect. Bug in
  the scoring tool, not in this run.
- RUBRIC.md's default diff command (`master..branch`) picks up
  unrelated drift because `master` moved past this run's base commit
  `2652ed6`; diffed from the recorded base, the branch touches only
  the 40 task files. A rubric-following scorer without this note would
  misread the diff.
- A dirty-worktree reset after a compaction lost then redid work; the
  harness's `baseline_dirty` field was empty, so the subagent scored
  the lost work against the model, flagging that a dirty baseline is a
  possible alternative cause it could not rule out.

Sets `qwen36_sampling` = temperature 1, top_p 0.95 (read from
`~/.local/share/mendel-benchmark/runs/qwen3.6-35b-a3b-off-blind-meta.json`,
the server's own default, no sampling parameter passed by this run).

**Published** to `~/code/mendel-benchmark`, branch `benchmark`, commit
`5c197e8` (pushed to `origin/benchmark`, `f14a235..5c197e8`; `master`
untouched). The publish subagent independently re-derived all ten
scores and agreed with 50.5. It found two more items worth recording:
six of eight `applyStyle` call sites omit the third `enabled`
argument, so `styleText` never runs on most of the CLI output — worse
than "loses colour," most of the port is dead code — recorded as its
own medium defect; and it cleared a false alarm on the `mendel-deps`
glob swap (looked wrong, correct on inspection) while flagging a real
minor defect (an unrequested `Resolver` `basedir` → `cwd` swap that
still passes tests on a path-suffix match, so it is a semantics
change, not yet a failure). No CSV writer script exists in
mendel-benchmark; the subagent appended by hand and verified the
format by byte-comparing a re-derived existing row.

### qwen38-bartowski-smoke-xhigh

`gh auth status` re-checked, passed. Served the `benchy-qwen38-bartowski-drafter` config unchanged: f16 KV, drafter n-max 3, `-c 73728`, wired 25000. Verified with a real 400-token completion before the smoke.

```
smoke: simulator(mendel-blind) qwen-3.8-27b bartowski-q4km/f16/xhigh: 10 calls, 1 commit, clean, 150s. pass.
```

10 calls, 10 distinct, longest repeat run 1, loop ok, 0 compactions, peak ctx 5283, 1 commit, clean tree, wall 150s. Pass.
Files: `results/mendel-smoke-qwen38-bartowski-xhigh.log`.
Deviation: none.

### qwen38-bartowski-mendel-xhigh — running

`gh auth status` re-checked, passed. The `benchy-qwen38-bartowski-drafter` server (f16 KV, drafter n-max 3, `-c 73728`, wired 25000), unchanged from the smoke. Prompt blind v1.1, base commit `2652ed6`. Window **65536**. Branch `qwen3.8-27b-xhigh-issue-13`, new. Started 04:01. Run watcher started with `RUNWATCH_SILENCE=2700` (this model's xhigh turns run past the 600s default).

| field | value |
|---|--:|
| score | - |
| tasks | -/8 |
| worst defect | - |
| stop reason | - |
| peak ctx | - |

Run completed 10:34 UTC (`end_reason: complete`, NOT a wall-clock partial — it
finished on its own before the 300-minute wall). 2 tooling nudges
(stall/silence auto-recoveries), 0 model nudges, loop verdict ok
(worst ratio 0.30 on tool call), 17 commits. `peak_context` (counter)
= **61572**, inside the configured 65536-token window this time (no
overshoot, unlike the qwen36-off row). Server and watcher stopped,
wired recovered. Scoring dispatched to a subagent on `claude-opus-5`.
Files: `~/.local/share/mendel-benchmark/runs/qwen3.8-27b-xhigh-blind-events.jsonl`, `~/.local/share/mendel-benchmark/runs/qwen3.8-27b-xhigh-blind-session.jsonl`, `~/.local/share/mendel-benchmark/runs/qwen3.8-27b-xhigh-blind-meta.json`, `results/run-watch-qwen38-xhigh.log`.
Deviation: none.

Owner request via the coordinator: publish the qwen36-off row (and,
at this row's close, this row too) into `~/code/mendel-benchmark`'s
`results.json`/`results.csv`/`report.html` on the `benchmark` branch,
without stopping the GPU work. Dispatched to a separate opus subagent
per block; each publish is out-of-band from this run's own worktree
and branch (`run14` here never touches `master` or the mendel-benchmark
repo's `benchmark` branch push permissions beyond what the subagent
does there directly).

**Scored** by a subagent on `claude-opus-5`. Score **93/100** (raw 93,
cap 100 at 8/8 libraries). Worst defect **medium**: Trap B left —
`legacy-packages/mendel-requirify` still requires and declares
`rimraf`; the model found it by its own grep and judged it out of
scope. No critical defect. Trap A passed for real this time (a
`globToFiles()` helper correctly drains the async iterator before any
`.then()` call). Trap C passed. Chalk migration follows the v1.1
contract (`enableColor` removed, plain `util.styleText`). 17 commits,
all clean `chore`, single-package, no hook bypass, no TASKS.md leak.

Benchmark/harness faults flagged: `score.mjs`'s
`runtime_checks.prettier.ok = false` is a scoring artifact — the only
warning is the uncommitted `TASKS.md` scratch file the prompt itself
forbids committing; the tool should skip untracked files. The 2
tooling nudges were stall auto-recoveries, correctly unscored.
`mendel-full-example` karma and an FSEvents flake are pre-existing
baselines, not regressions.

Sets `qwen38_bartowski_sampling` = temperature 1, top_p 0.95 (server
default, read from
`~/.local/share/mendel-benchmark/runs/qwen3.8-27b-xhigh-blind-meta.json`,
no sampling parameter passed by this run).

**Published** to `~/code/mendel-benchmark`, branch `benchmark`, commit
`0a26b45`. The two publish subagents shared a worktree and, briefly, a
scratch script path (`/tmp/add-row.mjs`), which caused two collided
writes; the second subagent caught it (a branch-field mismatch),
verified no work was lost (the duplicate row was byte-identical to
the already-committed one), moved its script to a private path, and
pushed clean. Worth remembering: give parallel publish subagents
their own scratch paths next time.

The subagent verified the score independently and corrected three
telemetry numbers against the handed-down brief: `compactions` is 3
(not the unstated 0 assumed), `tool_errors` 23/272 calls,
`wall_clock_min` 213.3. It flagged one item for the coordinator to
rule on: three `tmp`-migration test files add an unrequested
`process.on('exit')` cleanup hook outside RUBRIC.md's named Trap C
file; it did not score this as a defect (Trap C names one file only)
but logged the question in the row's `notes`. It also flagged
`PLAN.md`'s "Versioned outputs" section as stale: the second output
path it names, `docs/superpowers/issue13-model-bakeoff.html`, does not
exist in this repo.

## Handing over, session 1 close, 2026-09-11

All eight blocks in `AGENT.md`'s order are closed:
`benchy-gate` → `benchy-qwen36-f16-nodrafter` (partial, retried and
closed) → `benchy-qwen36-q8-drafter` → `benchy-qwen38-bartowski-drafter`
→ `qwen36-smoke-off` → `qwen36-mendel-blind-off` (scored 50.5/100,
published) → `qwen38-bartowski-smoke-xhigh` →
`qwen38-bartowski-mendel-xhigh` (scored 93/100, published).
`retry-sweep` has nothing outstanding: the run's only partial was the
f16-nodrafter deep cell, already retried at the coordinator's answer
and closed.

Machine state: `llama-server` and the corpus `http.server` are both
stopped; `pgrep -fl llama-server` is empty. Wired memory recovered to
baseline after the last server stop. No LM Studio, no Docker touched
this session.

Findings for the coordinator to fold into `INDEX.md`/`report.md`/
`models.json`/the site (this run does not publish those itself):
- The two GGUF q8_0/f16 drafter rows both beat their site figures at
  every depth (qwen3.6 q8: +19.7% to +40.8%; the 82K cell holds well
  above the 8 tok/s floor). The f16 no-drafter arm and the bartowski
  4-bit drafter arm both read below their site figures (-27% to -41%).
- Two Mendel rows scored: qwen3.6-35b-a3b thinking off, 50.5/100,
  worst defect critical (a real bug the model missed, not a benchmark
  artifact); qwen3.8-27b bartowski thinking xhigh, 93/100, worst
  defect medium. Both published to `mendel-benchmark`'s `benchmark`
  branch (`5c197e8`, `0a26b45`).
- Deviations worth a permanent fix, not just this run's log: the
  `--depth` flag in `llama-benchy` 0.4.0 needs space-separated values,
  not comma-joined (this run's own mistake, caught and fixed);
  `score.mjs`'s `trap_a.ok` reads from process exit code, not the
  verdict string, so a scorer trusting the flag alone misses a real
  defect (confirmed on two separate runs); `score.mjs`'s
  `runtime_checks.prettier.ok` counts warnings on files the prompt
  itself forbids committing; `PLAN.md`'s report-generation command
  names a docs output path that does not exist in the repo.
Files: `hardware/m1-max-32gb/benchmarks/bench14/results.md`, this file.
Deviation: none.

