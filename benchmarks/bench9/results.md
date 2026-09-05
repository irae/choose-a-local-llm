# Run 9 — results

One table per block, filled by the runner as results land. Every number
carries the exact command that produced it. The coordinator publishes
from here.

## Block A1 — short creeps, both KV types (one table per model)

| model | depth | q8_0 tok/s | f16 tok/s | wired q8 / f16 | acceptance q8 / f16 |
| --- | --- | --- | --- | --- | --- |

Prediction and pick per model:

| model | kv_per_token q8 / f16 (MB) | predicted wired at window q8 / f16 | pick | reason |
| --- | --- | --- | --- | --- |

## Block A1b — full creep on the pick

| model | KV | depth | tok/s | acceptance | wired | verdict |
| --- | --- | --- | --- | --- | --- | --- |

## Block A1 — short creeps, both KV types (one table per model)

| model | depth | q8_0 tok/s | f16 tok/s | wired q8 / f16 | acceptance q8 / f16 |
| --- | --- | --- | --- | --- | --- |

Prediction and pick per model:

| model | kv_per_token q8 / f16 (MB) | predicted wired at window q8 / f16 | pick | reason |
| --- | --- | --- | --- | --- |

## Block A1b — full creep on the pick

| model | KV | depth | tok/s | acceptance | wired | verdict |
| --- | --- | --- | --- | --- | --- | --- |

## Block A3 — Gemma-12B GGUF f16 to 262144

| depth | tok/s | acceptance | wired |
| --- | --- | --- | --- |

## Block B1 — Gemma-12B GGUF thinking off, EvalPlus

| budget | base | plus | empty | wall |
| --- | --- | --- | --- | --- |

## Blocks B3, C, E — Mendel rows

| block | model / entry | test | thinking | score | libraries | end reason |
| --- | --- | --- | --- | --- | --- | --- |

## Block A1 — Qwen3.6-35B-A3B GGUF (short creep, KV pick)

Command: published qwen3.6-gguf command, `-c 40960`, ports/log per AGENT.md.

### q8_0 arm

`creep-qwen36-gguf-short-q8.tsv`, `server-qwen36-gguf-short-q8.log`

| depth | decode tok/s | wired_mb | draft acceptance |
| --- | --- | --- | --- |
| 4114 | 36.63 | 25029 | 0.26 (task 0, warming) |
| 8222 | 43.91 | 25019 | 0.52 (task 12) |
| 16386 | 31.22 | 25008 | 1.00 (task 42) |
| 24602 | 24.16 | 24994 | 1.00 (task 63) |
| 32818 | 19.63 | 24973 | 1.00 (task 109) |

Verdict: **mem** — `STOP: 200 or more pages compressed or decompressed on 3
steps in a row, and speed did not come back, by depth 32818`.

Per the mem-verdict reporting rule ("the last clean row carries the
tok/s" — context-creep.md), the compacting streak is depths 16386,
24602, 32818 (each ≥200 pages moved, each below 0.85× the previous
step's speed). The last clean row is **8222, 43.91 tok/s** — that is
the number to publish for this arm, not the STOP-line row.

### f16 arm

`server-qwen36-gguf-short-f16.log`

Server logs `model loaded` and `listening`, but every request returns
`{"error":{"code":500,"message":"Compute error."}}`. The log shows
`Insufficient Memory (kIOGPUCommandBufferCallbackErrorOutOfMemory)`
starting at 0.02s, before any completion request — the KV buffer alone
does not fit at `-c 40960` under `iogpu.wired_limit_mb=24000`. No sweep
run; the server cannot serve a single token.

### Pick: q8_0

Rule 6 step 4: "q8_0 when f16 does not fit at a useful context." f16
fails to fit even at model load, so this is decisive without the
arithmetic in step 3. Research (AGENT.md) already says Qwen3.6 stays
near-lossless at q8_0, so quality is not a blocker.

## Block A1 — Qwen3.8-27B GGUF (short creep, KV pick)

Command: published qwen3.8-gguf command, `-c 40960`, ports/log per AGENT.md.

### q8_0 arm

`creep-qwen38-gguf-short-q8.tsv`, `server-qwen38-gguf-short-q8.log`

| depth | decode tok/s | wired_mb |
| --- | --- | --- |
| 4114 | 16.71 | 21578 |
| 8222 | 13.07 | 21576 |
| 16386 | 9.37 | 21706 |
| 24602 | 8.52 | 21728 |
| 32818 | 7.13 | 21691 |

Verdict: **speed** — `STOP: below 8 tok/s at depth 32818`.

### f16 arm

`creep-qwen38-gguf-short-f16.tsv`, `server-qwen38-gguf-short-f16.log`

| depth | decode tok/s | wired_mb | draft acceptance |
| --- | --- | --- | --- |
| 4114 | 20.02 | 22879 | 1.00 (task 9) |
| 8222 | 18.14 | 22878 | 0.94 (task 19) |
| 16386 | 16.04 | 22877 | 0.85 (task 41) |
| 24602 | 17.20 | 22874 | 1.00 (task 66) |
| 32818 | 16.38 | 22874 | 1.00 (task 89) |

Verdict: **window** — `no ceiling found up to 32768`.

### Pick: f16

Rule 6 step 4: f16 fits (wired steady ~22.9 GB, well under the 24000 MB
limit) and is faster at 32K (16.38 vs 7.13 tok/s, more than 2x). f16
wins outright, no arithmetic needed.

## Block A1 — Gemma-4-26B-A4B GGUF (short creep, KV pick)

Command: published gemma26-gguf command, `-c 40960`, ports/log per AGENT.md.

### q8_0 arm

`creep-gemma26-gguf-short-q8.tsv`, `server-gemma26-gguf-short-q8.log`

| depth | decode tok/s | wired_mb | draft acceptance |
| --- | --- | --- | --- |
| 4114 | 24.85 | 19964 | 0.78 (task 8) |
| 8222 | 17.14 | 19964 | 0.79 (task 38) |
| 16386 | 10.24 | 19961 | 0.74 (task 68) |
| 24602 | 8.08 | 19959 | 0.87 (task 101) |
| 32818 | 6.33 | 19957 | 0.87 (task 132) |

Verdict: **speed** — `STOP: below 8 tok/s at depth 32818`.

### f16 arm

`creep-gemma26-gguf-short-f16.tsv`, `server-gemma26-gguf-short-f16.log`

| depth | decode tok/s | wired_mb | draft acceptance |
| --- | --- | --- | --- |
| 4114 | 60.31 | 20398 | 0.73 (task 9) |
| 8222 | 64.19 | 20395 | 0.87 (task 40) |
| 16386 | 56.48 | 20393 | 0.85 (task 68) |
| 24602 | 52.22 | 20394 | 0.87 (task 99) |
| 32818 | 45.89 | 20396 | 0.83 (task 129) |

Verdict: **window** — `no ceiling found up to 32768`.

### Pick: f16

Rule 6 step 1: Gemma-26B loses quality at q8_0 (research already in
AGENT.md). AGENT.md pick rule, second bullet: f16 wins if it fits at
32K or more, regardless of speed. f16 fits (wired steady ~20.4 GB, no
mem/OOM stop through 32818) and is also faster (45.89 vs 6.33 tok/s at
32K) — both reasons agree.

Block A1 closed. Picks: Qwen3.6 GGUF = q8_0, Qwen3.8 GGUF = f16,
Gemma-26B GGUF = f16.

## Block A1b — Qwen3.6-35B-A3B GGUF full creep (pick: q8_0)

Published `-c` is 98304. It OOMs at model load (Metal
`Insufficient Memory`, before any request) — `server-qwen36-gguf-full-q8.log`.
`-c 65536` OOMs the same way — `server-qwen36-gguf-full-q8-c65536.log`.
`-c 49152` loads and serves — `server-qwen36-gguf-full-q8-c49152.log`.
The full creep ran at **`-c 49152`**, not the published 98304.

`creep-qwen36-gguf-full-q8.tsv`

| depth | decode tok/s | wired_mb | draft acceptance |
| --- | --- | --- | --- |
| 4114 | 36.35 | 25062 | 0.26 (task 0, warming) |
| 8222 | 43.80 | 25055 | 0.52 (task 9) |
| 16386 | 31.01 | 25051 | 1.00 (task 39) |
| 24602 | 24.04 | 25047 | 1.00 (task 60) |
| 32818 | 19.56 | 25047 | 1.00 (task 83) |

Verdict: **mem** — same STOP as the short creep, at depth 32818. The
compacting streak (≥200 pages moved, speed not recovering) starts at
16386. Last clean row: **8222, 43.80 tok/s**.

Published row: **q8_0 KV, `-c 49152` (not 98304 — published `-c` OOMs
at load), ceiling 8222 tokens at 43.80 tok/s.** This is far shallower
than the published context suggested; the daily-driver row needs a
`-c` correction independent of the KV-type question this run set out
to answer.

## Block A1b — Qwen3.8-27B GGUF full creep (pick: f16)

Published `-c 32768` loads and serves fine — no deviation needed.

`creep-qwen38-gguf-full-f16.tsv`, `server-qwen38-gguf-full-f16.log`

| depth | decode tok/s | wired_mb | draft acceptance |
| --- | --- | --- | --- |
| 4114 | 20.02 | 22242 | 1.00 (task 9) |
| 8222 | 18.14 | 22241 | 0.94 (task 19) |
| 16386 | 16.05 | 22226 | 0.85 (task 41) |
| 24602 | 17.21 | 22229 | 1.00 (task 66) |
| 32818 | 16.39 | 22226 | 1.00 (task 89) |

Verdict: **window** — `no ceiling found up to 32768`. No compacting
streak (only one row crosses 200 pages moved, not three in a row), so
no correction needed here.

Published row: **f16 KV, `-c 32768` (matches published), no ceiling
found to the window, 16.39 tok/s at 32818.**

## Block A1b — Gemma-4-26B-A4B GGUF full creep (pick: f16)

Published `-c 262144` OOMs immediately: the first depth step (4114)
returns HTTP 500, and the log shows `Insufficient Memory` even before
that request (wired already 25048 MB at start, over the 24000 MB limit
before any KV growth) — `server-gemma26-gguf-full-f16.log`. `-c 131072`
loads and serves cleanly — `server-gemma26-gguf-full-f16-c131072.log`.
The full creep ran at **`-c 131072`**, not the published 262144.

`creep-gemma26-gguf-full-f16-c131072.tsv`

| depth | decode tok/s | wired_mb | draft acceptance |
| --- | --- | --- | --- |
| 4114 | 61.25 | 23170 | — |
| 8222 | 64.95 | 23186 | — |
| 16386 | 56.65 | 23186 | — |
| 24602 | 52.72 | 23195 | — |
| 32818 | 46.46 | 23195 | 0.87 (task 160) |
| 49198 | 41.04 | 23195 | — |
| 65578 | 36.22 | 23194 | 0.87 (task 195) |
| 81958 | 33.25 | 23210 | — |
| 98338 | 28.73 | 23186 | 0.93 (task 230) |
| 114718 | 26.25 | 23180 | 0.93 (task 265) / 0.89 (task 299) |

Verdict: **window**, not mem. `STOP: request failed at depth 131098:
HTTP Error 400` — the server log says
`request (136781 tokens) exceeds the available context size (131072
tokens)`, a clean context-boundary message, not the `Compute error` /
`Insufficient Memory` signature used elsewhere in this run for a real
OOM. Checked for a compacting streak (three consecutive rows ≥200
pages moved with speed not recovering, the correction applied to
Qwen3.6): none found — every compaction spike is followed by tok/s
still ≥85% of the previous step, so the streak counter never reaches 3.
No correction needed; the runner's own last good row is the ceiling.

Published row: **f16 KV, `-c 131072` (not 262144 — published `-c` OOMs
at load), ceiling 114718 tokens at 26.25 tok/s.**

Block A1b closed. Full-creep rows: Qwen3.6 q8_0 at `-c 49152` (not
98304), ceiling 8222/43.80 tok/s. Qwen3.8 f16 at published `-c 32768`,
window, 16.39 tok/s at 32818. Gemma-26B f16 at `-c 131072` (not
262144), window, 26.25 tok/s at 114718. All three daggered rows need a
`-c` correction on the published pages independent of the KV-type
question this run set out to answer.

## Block A1b — Qwen3.8-27B GGUF full creep, CORRECTED (supersedes the
## entry above that used published `-c 32768`)

The earlier entry above ("no ceiling found up to 32768") stopped
because `-c 32768` was too small, not because the model hit a real
limit — the GGUF metadata says `qwen35.context_length` = 262144 (256K
trained), and a window verdict caused only by an undersized `-c` is
not a finding (methodology correction, this session). Redone here by
binary-searching the largest loadable `-c` toward the trained max, then
a prefill-jump creep (`research/run2/results/gemma12-depth.md`) from
the last verified depth instead of re-creeping from 4K.

### `-c` search (f16 KV)

| `-c` tried | result | log |
| --- | --- | --- |
| 262144 (trained max) | OOM at load | `server-qwen38-gguf-full-f16-c262144.log` |
| 131072 | OOM at load | `server-qwen38-gguf-full-f16-c131072.log` |
| 65536 | OOM at load | `server-qwen38-gguf-full-f16-c65536.log` |
| 49152 | loads, serves | `server-qwen38-gguf-full-f16-c49152.log` |

All three failures show `Insufficient Memory
(kIOGPUCommandBufferCallbackErrorOutOfMemory)` before any request
completes. **49152 is the real hardware ceiling for this model at f16
KV under `iogpu.wired_limit_mb=24000`** — not a convenient stopping
point, the largest `-c` this machine can load for this config.

### Prefill-jump creep at `-c 49152`

`creep-qwen38-gguf-full-f16-c49152.tsv`, DEPTH_LIST jumped straight to
`32768,49152` (32768 as a control point, re-measuring a depth already
seen at `-c 32768`).

| depth | decode tok/s | wired_mb | draft acceptance |
| --- | --- | --- | --- |
| 32818 | 16.42 | 23571 | 0.25 (task 0, warming) |
| 49198 | 14.98 | 23489 | 1.00 (task 12) |

Control check: 16.42 tok/s here vs 16.39 tok/s measured the slow way
at the same depth in the published-`-c` run — 0.2% apart, well inside
the 2.8%/5% tolerance the prefill-jump method carries. The jump is
valid.

Verdict: **window**, but now a real one — `-c` cannot go higher on this
hardware (the search above), so 49152 is the ceiling, not an artifact.

**Corrected published row: f16 KV, `-c 49152` (not the published
32768, and not the model's 262144 trained window — hardware-limited),
14.98 tok/s at 49198, no floor/OOM/mem hit within the reachable
window.**

## Block A1b — Gemma-4-26B-A4B GGUF full creep, CORRECTED (supersedes
## the `-c 131072` entry above)

The `-c 131072` entry above stopped on the `-c` boundary, not a real
limit — same artifact as Qwen3.8's. Redone by binary-searching higher
toward the model's 262144 trained window, then a prefill-jump creep
from the last verified depth.

### `-c` search (f16 KV)

| `-c` tried | result | log |
| --- | --- | --- |
| 262144 (trained max) | OOM at load | `server-gemma26-gguf-full-f16.log` |
| 229376 | OOM at load | `server-gemma26-gguf-full-f16-c229376.log` |
| 212992 | loads, serves | `server-gemma26-gguf-full-f16-c212992.log` |

(131072 also loads, established earlier.) 212992 is the largest `-c`
found; 229376 fails the same way as 262144 (`Insufficient Memory` at
load, before any request).

### Prefill-jump creep at `-c 212992`

`creep-gemma26-gguf-full-f16-c212992.tsv`, DEPTH_LIST jumped to
`114688,131072,147456,163840,180224,196608,212992` (114688 is a control
point re-measuring the previously-verified 114718/26.25 tok/s row).

| depth | decode tok/s | wired_mb | draft acceptance |
| --- | --- | --- | --- |
| 114718 | 26.38 | 25590 | 0.82 (task 0, warming) |
| 131098 | 25.17 | 25590 | 0.89 (task 9) |
| 147478 | 22.07 | 25573 | 0.95 (task 93) |
| 163858 | 21.25 | 25567 | 0.89 (task 127) |
| 180238 | 20.73 | 25557 | 0.93 (task 162) |
| 196618 | 17.30 | 25549 | 1.00 (task 196) |

Control check: 26.38 tok/s here vs 26.25 tok/s measured the slow way
at the same depth — 0.5% apart, well inside the 2.8%/5% prefill-jump
tolerance. Wired sits at ~25.5-25.6 GB throughout, over the 24000 MB
limit but stable (not escalating) — the machine is running this config
under pressure but not compacting: checked for a 3-consecutive-step
compacting streak (≥200 pages moved and speed below 0.85× the previous
step) and found none; every step that shows heavy paging still recovers
above that threshold next step. No last-clean-row correction needed.

Verdict: **window**, and real this time — `STOP: request failed at
depth 212998: HTTP Error 400`, log says `request (221575 tokens)
exceeds the available context size (212992 tokens)`, the same
clean context-boundary message as Qwen3.8's, not a Metal OOM. `-c`
cannot go higher (229376 OOMs at load), so 196618 is the deepest
depth actually measured.

**Corrected published row: f16 KV, `-c 212992` (not the published
262144, and not the earlier fallback 131072 — both wrong), 17.30
tok/s at 196618, no floor/OOM/mem hit within the reachable window.**

Block A1b closed (corrected). Final full-creep rows:
- Qwen3.6 GGUF q8_0, `-c 49152` (not 98304): mem stop, ceiling 8222
  tokens at 43.80 tok/s. Unaffected by this session's correction — a
  real stop condition reached well under its `-c`.
- Qwen3.8 GGUF f16, `-c 49152` (not 32768): real hardware ceiling
  (65536/131072/262144 all OOM at load), 14.98 tok/s at 49198, no
  floor/OOM/mem hit.
- Gemma-26B GGUF f16, `-c 212992` (not 262144): real hardware ceiling
  (229376/262144 OOM at load), 17.30 tok/s at 196618, no floor/OOM/mem
  hit.

All three daggered rows need a `-c` correction in `models.json`
independent of the KV-type question this run set out to answer — see
the planner note in `state.md`.

## Block B0 — EvalPlus smoke on the two f16 picks

Budget for the Qwen3.8 pair: `benchmarks/calibration-qwen38-mlx-medium.json`
(MLX effort-medium baseline, converged, observed max 2604 → budget
8192, same on every side). Same extra body on every side:
`{"chat_template_kwargs":{"reasoning_effort":"medium"}}`.

### Qwen3.8-27B GGUF: self-check, then f16 vs q8_0

Server f16: qwen38-gguf command, `-c 49152`, both cache types f16
(the corrected A1b ceiling). Server q8_0: same command, `-c 32768`
(published), both cache types q8_0.

```
SMOKE label=qwen38-gguf-f16-a problems=4 passed=4 empty=0 completion_tokens=3506 max_tokens=8192 wall_s=284.7
SMOKE label=qwen38-gguf-f16-b problems=4 passed=4 empty=0 completion_tokens=3464 max_tokens=8192 wall_s=283.4
SMOKE label=qwen38-gguf-q8    problems=4 passed=4 empty=0 completion_tokens=3186 max_tokens=8192 wall_s=282.6
```

Self-check (a vs b): identical `passed`/`empty` — **level**, the tool
passes its own check. All three runs land comfortably under budget
(max single completion 2957/8192, ~36%), so none of these results are
budget-limited — a 0-empty reading here is not a calibration artifact.

Verdict: **f16 level with q8_0** (same `passed`=4, same `empty`=0).

### Gemma-4-26B-A4B GGUF: f16 vs q8_0, thinking on

`benchmarks/calibration-gemma26-think.json` has two `length` stops (does
not converge), so the budget is set by hand per AGENT.md:
`SMOKE_MAX_TOKENS=30000` on both sides. The published baseline itself
runs at 46/164 (~28%) empty on the full gate for exactly this reason
(thinking non-convergence) — a nonzero empty count on this pair is
expected, not a bug; the comparison is f16's empty count against
q8_0's at the same 30000 budget, not against zero.
