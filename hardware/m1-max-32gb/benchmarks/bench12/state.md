# Run 12 — state

Started 2026-09-08. `tool-check` pinned `local-llm-eval-tools` at
`2344f00`. Wired limit confirmed 25000 (per `AGENT.md`; the machine
file's 24000/22000 is stale, a known false positive on preflight).

`gemma12_2x_clean` = **81958** tokens per slot (redo, creep-judged,
2026-09-08). The coordinator caught that the first reading (8222 at
`-c 770048`) measured a load ceiling, not a window: that `-c`'s KV
allocation alone left ~68 MB free, so its creep mem-stopped almost
immediately. Redo at four `-c` values (262144, 245760, 221184, 196608)
all hit the same wall — swap growth at depth 81958 — whenever the
window was large enough to reach it. This ceiling does not move with a
bigger `-c`; it is the real per-slot limit. See `results.md`,
`gemma12-gguf-2slot redo`.

`gemma12-gguf-1slot-131072`: clean depth 114718, hit the `-c` boundary
at 131072 (HTTP 400, not OOM) at the top.

Draft kit, not started as a scored run. Pre-block prep landed
2026-09-07: wired 24000 ceilings for Qwen3.6 GGUF q8_0 and f16,
found while debugging a `local-llm-eval-tools` compaction issue on
this machine. See `results.md`, "Pre-block prep" section, for the
numbers, the two open questions (a false-positive compaction stop at
depth 32818, and swap growth under wired 25000 with no recovery gap
between sweeps), and links to the full tool-side evidence on
`local-llm-eval-tools`'s `creep-ab-verdict` and
`creep-configurable-thresholds` branches.

Follow-up landed same day: two clean single-sweep creeps at wired
25000, fresh server each time (`-c 98304` q8_0, `-c 40960` f16), both
zero swap growth and matching run11's original numbers. The swap
growth from the pre-block prep section only ever showed up under
several sweeps stacked back to back with no recovery gap — a pattern
a normal scoring block does not hit. See `results.md`, "Follow-up",
before reading the earlier section's working conclusion; that section
leaned toward 24000, this one weakens that case.

Handing over: the coordinator sets `AGENT.md`'s wired-limit line
(24000 or 25000) after reading both `results.md` sections in full,
then the run proper starts.

## Status log (status-lines.md form)

### creep gemma-4-12b 2slot ctx 82k

`unsloth/gemma-4-12b-it-GGUF:Q4_K_XL` (`--no-mmproj`), f16 KV, `--parallel 2`, wired 25000. Tool `2344f00`. Ladder judged the load only (770048 served); the creep judges the window.

| depth | tok/s (A) | tok/s (B) | wired MB | swap Δ |
|--:|--:|--:|--:|--:|
| 4k | 25.0 | 25.0 | 13795 | 0 |
| 8k | 24.1 | 24.1 | 13808 | -8 |
| 16k | 22.8 | 22.9 | 13810 | -8 |
| 25k | 21.5 | 21.5 | 13823 | -8 |
| 33k | 20.6 | 20.5 | 13793 | -8 |
| 41k | 19.5 | 19.3 | 13793 | -8 |
| 49k | 18.6 | 18.5 | 13651 | -16 |
| 66k | 16.9 | 17.0 | 13516 | -16 |
| 82k | 15.7 | 15.7 | 13637 | -24, then +143 at next `-c` |

**mem**, ceiling 82k @ 15.7 tok/s per slot. Four `-c` values (262144, 245760, 221184, 196608) all hit the same wall at depth 81958; only 196608's own window boundary (98304) intervened before the memory wall could grow further at that `-c`, but no `-c` reached deeper before it.
Files: `results/creep-gemma12-gguf-2x-redo-c196608.tsv`, `results/creep-gemma12-gguf-2x-redo-c221184.tsv`, `results/creep-gemma12-gguf-2x-redo-c245760.tsv`, `results/creep-gemma12-gguf-2x-redo-c262144.tsv`, `results/server-gemma12-gguf-2x-redo-c196608.log`.
Deviation: none.

### creep gemma-4-12b 1slot ctx 131k

`unsloth/gemma-4-12b-it-GGUF:Q4_K_XL` (`--no-mmproj`), f16 KV, `--parallel 1`, `-c 131072`, wired 25000. Tool `2344f00`.

| depth | tok/s | wired MB | swap Δ |
|--:|--:|--:|--:|
| 4k | 25.0 | ~12000 | 0 |
| 8k | 24.1 | ~12000 | 0 |
| 16k | 22.8 | ~12000 | 0 |
| 25k | 21.7 | ~12000 | 0 |
| 33k | 20.6 | ~12000 | 0 |
| 41k | 19.5 | ~12000 | 0 |
| 49k | 18.6 | ~12000 | 0 |
| 66k | 17.0 | ~12000 | 0 |
| 82k | 15.7 | ~12000 | 0 |
| 98k | 14.6 | ~12000 | 0 |
| 115k | 13.6 | ~12000 | 0 |

**window**, hit the `-c` boundary at 131072 (HTTP 400, not OOM). Ceiling 114718 @ 13.59 tok/s.
Files: `results/creep-gemma12-gguf-1x-c131072-f16.tsv`, `results/server-gemma12-gguf-1x-c131072.log`.
Deviation: none.

### creep bonsai-27b f16 ctx 131k — running

`Ternary-Bonsai-27B-Q2_g64.gguf` (prism-ml fork, rev `abbae72`), `LLAMA_ATTN_ROT_DISABLE=1`, no drafter, `--parallel 1`, `-c 131072`, f16 KV, wired 25000. Tool `2344f00`. Ladder: 131072 served on the first candidate (no lower step tried). Started 12:08, last row 8k.

| depth | tok/s | wired MB | swap Δ | compress | decompress |
|--:|--:|--:|--:|--:|--:|
| 4k | 14.95 | 18291 | 0 | 0 | 65 |
| 8k | 16.25 | 18288 | 0 | 0 | 118 |
| ... | | | | | |
| 131k | - | - | - | - | - |

still running, next depth 16k. No stop condition met. First completion (pre-creep warmup, 4096 tok, 16.93 tok/s) discarded per rule 2; creep's own 4k row (14.95 tok/s) is the recorded shallow number.
Files: `results/creep-bonsai-fork-f16.tsv`, `results/server-bonsai-fork-f16-c131072.log`.
Deviation: none.

`bonsai_fork_f16_clean` = **131072** (no ceiling found up to the `-c`
boundary; deepest step 131098 still decoded at 9.67 tok/s, above the
8 tok/s floor). See `results.md`, `bonsai-fork-f16`.

**Branch collision, resolved without touching the old branch.**
`run-worker.sh` derives its branch name from the model alias alone
(`bonsai-prism-high-guided-v3-issue-13`), with no version bump. That
name was already taken by the earlier, already-scored q4_0 KV run
(`mendel-benchmark` commit `c403b07`, "Score bonsai-prism guided high:
wall_clock partial ... 31.5"). Left that branch alone. Instead added a
sibling pi model entry, `bonsai-prism-f16`, to `~/.pi/agent/models.json`
under the `mlx` provider (copied from `bonsai-prism`, f16 KV,
`contextWindow` 131072, decode 14.95-9.67 tok/s to 131k). Re-served
the fork under `--alias bonsai-prism-f16`
(`results/server-bonsai-fork-f16-mendel.log`) and re-ran the worker
against that model id: new branch
`bonsai-prism-f16-high-guided-v3-issue-13`, no collision.

Mendel guided-high run started, `bonsai-prism-f16`, `MENDEL_CONTEXT_WINDOW=131072`,
reserve 8192, keep-recent pi default (window above 65536). Watcher
running (`results/mem-bonsai-prism-f16-guided-high.log`).
Up to 300 min wall clock. — running.

**Tool bug found, corrected by the coordinator: `run-worker.sh`'s
close-time repetition check came back `unchecked` on this row.**
`$RUNS/$fslug-session.jsonl` is a real, normal output — `run-pi-rpc.mjs`
writes it (line 686) — not a stale path as first suspected. The write
is conditional (`if (meta._session_path && existsSync(...))`), and it
silently skipped for this row, so `run_loop_check()` found no file,
printed one stderr warning, and the row would have committed with
`loop_flag: unchecked`. This is the first row of twelve committed
local rows to hit it (per the coordinator's check); nothing earlier is
in doubt. No resume or respawn happened on this run (checked
`/tmp/mendel-bonsai-f16-guided-high.log`, no resume/respawn lines),
which the coordinator flagged as one hypothesis for the failure — so
that hypothesis does not explain it here; cause still open, filed with
the coordinator for the owner, not fixed mid-run. Worked around by
hand: ran `benchmarks/loop-check.py` against the real events file
directly — `text_delta 0.68 ok, thinking_delta 0.62 ok, toolcall_delta
0.33 ok`, no loop, at 108k ctx / ~85 min elapsed. Will re-run the same
manual check at close and record it in `results.md` alongside the
built-in check's `unchecked` result, per the coordinator's guidance.

`docs/methodology/mendel.md` is correct as written and needs no
correction: the close-time flag (`loop-check.py`, landed 2026-09-05)
and the live stop (`repetition_loop`/`degenerate_output` inside the pi
harness, landed 2026-09-06) are two separate, correctly-dated
mechanisms, both described accurately on that page.

**Live repetition-loop guard added, not just a close-time check.**
Since the built-in check only fires at close and its file path is
broken (above), running `benchmarks/loop-check.py` in a poll loop
every 180s against the real events file directly, for the duration of
this row: `pi` pid 55582, `run-worker.sh` pid 55209. Kills both the
moment any kind reads other than `ok`. Re-armed at each heartbeat
since a single poll loop caps at 60 min and this row can run up to
300. Never fired — the run finished on its own first.

**`bonsai-prism-f16` guided-high run closed clean.** `end_reason:
complete`, started 13:10, ended ~16:25 (about 195 min, well inside the
300-min wall clock). 2 commits, 1 compaction, 1 model nudge
(uncommitted changes at the very end). This time the built-in
`session.jsonl` write worked — `loop verdict ok, worst ratio 0.33 on
tool call`, matching the manual mid-run check. `tool_calls 376`,
`peak_context 127120` (window 131072, no overflow). Scoring dispatched
to a subagent on Opus per `PLAN.md`'s scoring rule (never a smaller
model); result lands in `mendel-benchmark`'s `benchmark` branch, not
here — this repo never carries Mendel scores directly. Server stopped
(pid 54961), no Mendel Daemon process was running. Wired recovery
starts.

## `qwen38-ista-evalplus` — running

Served `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf`
(built-in MTP head confirmed at load), alias `qwen3.8-27b` (shared pi
entry), `--spec-type draft-mtp --spec-draft-n-max 3 --parallel 1`, f16
KV, `-c 131072` (ladder already cleared at this value, research run 3,
same wired limit 25000 — no re-ladder needed). `results/server-qwen38-ista-evalplus.log`.

Calibration (`benchmarks/calibrate.py qwen38-ista-mtp qwen3.8-27b
'{"chat_template_kwargs":{"reasoning_effort":"medium"}}'`): 10/10
converge (`stop`), max completion 2347 tokens, budget = max(2347×1.5,
8192) = **8192** — same floor as the control row, so the two scores
compare directly. `benchmarks/calibration-qwen38-ista-mtp.json`.

Full EvalPlus launched: `RESULTS_BASE=hardware/m1-max-32gb/benchmarks/bench12/results
EVALPLUS_MAX_NEW_TOKENS=8192 benchmarks/run-humaneval.sh qwen38-ista-mtp
qwen3.8-27b '{"chat_template_kwargs":{"reasoning_effort":"medium"}}'`.
Watcher running (`results/mem-qwen38-ista-evalplus.log`). Output:
`results/qwen38-ista-mtp/humaneval/qwen3.8-27b_openai_temp_0.0.jsonl`.
— running.
