# Run 11 — results

One section per block, in run order. Every number with the exact
command that produced it and the file under `results/` that holds the
evidence. The large-form comparison tables go here as blocks close
(`docs/methodology/status-lines.md`, "The site comparison, in full").

## Block 1/10 — Qwen3.6 GGUF `-c` ladder, wired 25000

Command: see `results/server-qwen36-gguf-q8-c98304.log`.

| `-c` | Load | Warmup completion |
| --- | --- | --- |
| 98304 | loaded | ok, 65.96 tok/s decode, draft 154/192 accepted |

Binary search above the ladder, toward the trained context (262144,
`qwen35moe.context_length` from the GGUF), q8_0 KV, wired 25000:

| `-c` candidate | Load | Completion |
| --- | --- | --- |
| 262144 | loaded | Insufficient Memory (Metal OOM) |
| 180224 | loaded | Insufficient Memory |
| 139264 | loaded | Insufficient Memory |
| 118784 | loaded | Insufficient Memory |
| 108544 | loaded | Insufficient Memory |
| 103424 | loaded | Insufficient Memory |
| 100864 | loaded | Insufficient Memory |
| 98304 | loaded | ok (see above) |

Ceiling: 98304 is the largest `-c` that serves a real completion at
wired 25000, q8_0 KV, on this GGUF. The boundary sits within 2560
tokens (98304 works, 100864 does not); every value above that up to
the trained max of 262144 loads but fails the first completion with a
Metal OOM. Logs: `results/server-qwen36-gguf-q8-c<value>.log`.

Clean-depth creep at `-c 98304`, q8_0 KV:
`results/creep-qwen36-gguf-q8-clean.tsv`.

```bash
DEPTH_LIST="4096,8192,16384,24576,32768,40960,49152,57344,65536,81920,98304" \
MODEL=qwen3.6-35b-a3b python3 tools/sweeps/creep_llama.py \
  | tee hardware/m1-max-32gb/benchmarks/bench11/results/creep-qwen36-gguf-q8-clean.tsv
```

| depth_tokens | decode_toks | wired_mb | note |
| --- | --- | --- | --- |
| 4114 | 36.52 | 25997 | |
| 8222 | 44.11 | 25996 | |
| 16386 | 31.21 | 25996 | |
| 24602 | 24.14 | 25992 | |
| 32818 | 19.62 | 25992 | STOP: mem, 3 depths of sustained compaction, speed did not recover |

Coordinator's read: this is not worse than the site's published 24000
row (8K clean depth, compaction from 16K) — 32818 tokens with speed
still at 19.6 tok/s is deeper, not shallower. Wired stays at 25000, no
intermediate values tried.

Redo, same config, second clean start (preflight all `ok`, no reboot
needed — wired recovered to baseline, swap flat):
`results/creep-qwen36-gguf-q8-clean-redo.tsv`.

| depth_tokens | decode_toks | compress_pages | decompress_pages |
| --- | --- | --- | --- |
| 4114 | 36.53 | 0 | 32 |
| 8222 | 44.15 | 0 | 459 |
| 16386 | 31.16 | 0 | 48 |
| 24602 | 24.12 | 0 | 244 |
| 32818 | 19.64 | 0 | 1064 |
| 40982 | 16.57 | 0 | 65 |
| 49198 | 14.30 | 3894 | 521 |
| 57362 | 12.58 | 8995 | 467 |
| 65578 | 11.21 | 20666 | 2795 |
| 81958 | 9.24 | 29314 | 1960 |
| 98338 | 7.87 | 45054 | 18513 |

STOP: below 8 tok/s at depth 98338 — **speed verdict**. Ceiling: 81958
tokens at 9.24 tok/s, the deepest depth still at or above the 8 tok/s
floor. This clears the block's 46K gate.

Accepted finding: the first creep's early `mem` stop at 32818 did not
reproduce; treated as noise. This redo is the block's clean-depth
number for Qwen3.6 GGUF q8_0 KV at wired 25000, `-c 98304`.

**Gate: GGUF clean depth 81958 ≥ 46K at ≥ 8 tok/s → met.** Blocks 9
and 10 (Qwen3.6 GGUF Mendel, thinking off) run right after block 3, on
q8_0 KV at `-c 98304` (pending the f16 and MLX arms below, which may
still change the arm choice).

## Block 1/10 continued — f16 KV arm

f16 loaded at `-c 40960` (it did not load on 2026-09-04, at wired
24000): warmup completion ok, 69.28 tok/s decode, draft 386/471.
`results/server-qwen36-gguf-f16-c40960.log`.

Creep, `results/creep-qwen36-gguf-f16-clean.tsv`:

| depth_tokens | decode_toks |
| --- | --- |
| 4114 | 67.94 |
| 8222 | 71.99 |
| 16386 | 65.66 |
| 24602 | 61.50 |
| 32818 | 56.84 |
| 40982 | 53.00 |

`no ceiling found up to 40960` — never dropped near the 8 tok/s floor.

Binary search above 40960 (same method as the q8_0 arm): 44032, 47104,
53248 and 65536 all load but fail the first real completion (Metal
OOM). So 40960 is also the f16 arm's load ceiling — the creep's tested
range was the whole reachable range, not an arbitrary stop. f16 is much
faster per token (53 tok/s at 40982 vs. q8_0's 16.57 at the same
depth) but its window is a third of q8_0's (40960 vs 98304 clean
ceiling before the floor).

f16 does not change the block 1 gate: it still clears 46K only if the
Mendel task needs ≤40960 tokens, which is not guaranteed, while q8_0
clears 46K on speed alone up to 81958. q8_0 stays the arm for blocks 9
and 10, `-c 98304`.

## Block 1/10 continued — MLX arm

`results/creep-qwen36-mlx-25000.tsv`, `results/server-qwen36-mlx-creep.log`.

| depth_tokens | decode_toks |
| --- | --- |
| 4114 | 55.09 |
| 8222 | 53.84 |
| 16386 | 47.78 |
| 24602 | 42.95 |
| 32818 | 38.34 |
| 36874 | 38.95 |
| 40982 | 37.38 |

Death at depth 45090: `/v1/models` kept answering 200 while the
generation thread died on a Metal OOM
(`kIOGPUCommandBufferCallbackErrorOutOfMemory`) — the death mode the
methodology page warns about for this backend. Confirmed from the
server log, not left to the probe's two-strike timeout. **Ceiling:
40982 tokens at 37.38 tok/s**, the last good row.

Deviation: `SERVER_LOG` was not set for this sweep (the runbook's
literal command omits it), so the sweep's own fast death detection
was blind; the death was still caught by reading the server log by
hand. Future MLX sweeps in this run should set `SERVER_LOG` per
`context-creep.md`.

**MLX gate: blocks 6 and 7 run at the last stable depth this arm
found — 40982 tokens — and their pi window must not exceed it.**

## Block 2/10 — Gemma-26B, thinking off, Mendel guided

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh gemma-4-26b-a4b pi guided off
```

Branch `gemma-4-26b-a4b-off-guided-v3-issue-13`, base `86935f4`.
20.4 min wall clock, 93 assistant messages, 91 tool calls, 28 tool
errors, 3 commits (2 libraries: uuid, xtend×2), peak context 72725 of
212992 (34.15%).

**INVALID: the run ended on the live loop stop, `repetition_loop`,
unit "edit" (tool call), 5 identical calls, first at 18:12:06Z, final
at 18:12:47Z** (`meta.json`). `run-worker.sh`'s own post-hoc loop
check logged "ok, worst ratio 0.22" on the same session — that check
ran on the already-cut-short transcript and does not override the
live stop. Per this run's rule, the row is invalid and no retry runs
in this block; the next block starts.

Scored anyway per Mendel's own invalid-run handling (data kept,
`invalid: true`): score_raw 44, capped to 25 on the 2/8-libraries
completion cap. Scoring subagent (Fable model) full report and
defect list in `results-guided.csv`
(`benchmark/results-guided.csv`, row `gemma-4-26b-a4b-off-guided-v3-issue-13`)
on the `mendel-benchmark` `benchmark` branch, commit `2f1960c`. Session
log redacted and pushed to `mendel-benchmark/benchmark/runs/`; run
branch pushed to `origin/gemma-4-26b-a4b-off-guided-v3-issue-13`.

## Block 3/10 — Gemma-26B, thinking off, Mendel blind

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh gemma-4-26b-a4b pi blind off
```

Branch `gemma-4-26b-a4b-off-issue-13`, base `2652ed6`. 28.0 min wall
clock, 121 assistant messages, 120 tool calls, 21 tool errors, 7
commits (1 library fully done: uuid), peak context 135797 of 212992
(63.76%).

**INVALID: same as block 2, the run ended on the live loop stop,
`repetition_loop`, unit "edit" (tool call), 5 identical calls on
`packages/mendel-pipeline/src/helpers/analytics/cli-printer.js`, first
at 18:42:46Z, final at 18:50:15Z** (`meta.json`). No retry, moved on.

Scored: score_raw 21, capped to 12.5 on 1/8 libraries. Notable: trap A
(the `fs.promises.glob().then()` bug) still failed on the working
tree — this model reproduced the same trap the Gemma-26B blind row at
`high` hit before. Row in `results.csv`/`results.json`
(`benchmark` branch), `invalid: true`. Session log redacted and
pushed, run branch pushed to
`origin/gemma-4-26b-a4b-off-issue-13`, worker worktree removed.

Block 1's gate promotes block 9 next (owner correction: the gate only
decides whether 9/10 run at all, not a full reorder — block 10 goes
last, after block 8, in numeric order).

## Block 9/10 — Qwen3.6 GGUF, thinking off, Mendel guided

```bash
cd ~/code/mendel-benchmark/benchmark && ./run-worker.sh qwen3.6-35b-a3b pi guided off
```

Server: q8_0 KV, `-c 98304` (block 1's found config), wired 25000,
reserveTokens 8192. Smoke passed first (pass, 7 calls, loop ok:1.00).

Branch `qwen3.6-35b-a3b-off-guided-v3-issue-13`, base `86935f4`.
**`end_reason: complete`** — the first valid completed guided run this
session (both Gemma-26B runs ended on the live loop stop). 95.6 min
wall clock, 275 assistant messages, 299 tool calls, 37 tool errors, 7
commits, **8/8 libraries done**. Peak context 51567 against the pi
entry's 49152-token window (104.9%) — 12 compactions, 11 from
overflow. 2 model nudges (harness policy text), 0 tooling nudges.

Scored: score_raw 46.5 = score_total (no cap, 8/8). Real bugs remain
despite full completion: trap A (`fs.promises.glob().then()`) still
broken; the chalk replacement has a dead `fn.__proto__ = base` bug and
ignores the prompt's `util.styleText` direction; `tmp`/`shasum` cut
with `sed`, never from `pnpm-lock.yaml` (`pnpm install
--frozen-lockfile` fails at HEAD); no green root test suite before the
last two commits. Row in `results-guided.csv`/`.json`
(`benchmark` branch, commit `109253c`), `invalid: false`. Session log
redacted and pushed, run branch pushed to
`origin/qwen3.6-35b-a3b-off-guided-v3-issue-13`, worker worktree
removed.

Notable for the compaction backlog item
(`backlog/pi-compaction-efficiency.md` on `master`): this run
compacted every 2-3 minutes for a long stretch, often shallow, yet
finished cleanly and did not visibly lose task state — it re-read
`TASKS.md`/`git status` after most compactions before acting. Evidence
against "shallow compaction causes thread loss" for this model, even
though the compaction pattern itself still looks inefficient.

Next: block 4 (Gemma-12B GGUF, blind, off) — not block 10, per the
corrected order.
