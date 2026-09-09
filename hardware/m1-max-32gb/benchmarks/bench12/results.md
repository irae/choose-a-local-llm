# Run 12 — results

One section per block, in run order. Every number with the exact
command that produced it and the file under `results/` that holds the
evidence.

## Pre-block prep — wired 24000 ceilings for Qwen3.6 GGUF, q8_0 and f16 (2026-09-07)

Not a scored block. This answers `AGENT.md`'s open wired-limit
question (`24000 or 25000`) with fresh numbers at 24000, found while
debugging a `local-llm-eval-tools` compaction issue on the same
machine, same day. Full tool-side evidence, both false-positive and
real findings, is on that repo's `creep-ab-verdict` and
`creep-configurable-thresholds` branches (not part of this repo).

Server command for both arms, wired 24000:
```
llama-server -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
  --alias qwen3.6-35b-a3b --no-mmproj \
  --spec-type draft-mtp --spec-draft-n-max 3 --parallel 1 \
  -ngl 999 -fa on -c <value> \
  --cache-type-k <q8_0|f16> --cache-type-v <q8_0|f16> \
  --jinja --port 8081 --offline
```

**q8_0 KV.** Binary search the same way as run11's block 1, but with a
real sweep step as the completion test, not a one-token warmup: a
one-token probe passed at `-c 49920` and failed at `-c 50368`
(`results/server-qwen36-gguf-q8-c49920-w24000-oom.log`), but the first
real creep step at `-c 49920` still hit a Metal OOM
(`kIOGPUCommandBufferCallbackErrorOutOfMemory`) on the actual sweep
prompt size. **`-c 40960` is the value confirmed to serve real sweep
traffic at wired 24000** — a one-token probe is not a safe ceiling
test for this config; use a real request the size of the intended
workload.

Creep, q8_0, `-c 40960`, wired 24000, `STEP_PAUSE_S=60`, default
`COMPACT_PAGES`/`RECOVERY_FRACTION`/`MAX_COMPACTING_STEPS` (the
published thresholds, unmodified):
`results/creep-qwen36-gguf-q8-w24000-c40960.tsv` (old tool),
`results/creep-qwen36-gguf-q8-w24000-c40960-newtool.tsv` (new tool,
`local-llm-eval-tools`). Both tools agree row for row:

| depth_tokens | decode_toks (old) | decode_toks (new) |
| --- | --- | --- |
| 4114 | 36.66 | 36.60 |
| 8222 | 44.17 | 43.85 |
| 16386 | 31.25 | 31.04 |
| 24602 | 24.18 | 24.15 |
| 32818 | 19.65 | 19.60 |

Both stop at depth 32818 with a `mem` verdict (sustained
compress/decompress above 200 pages, 3 steps, speed did not recover).
**This point is flagged, not accepted at face value**: the same
compaction check fires from ordinary speed decay at this depth range
even with no real memory problem (see the `local-llm-eval-tools`
branches above for the same-day evidence and the env-configurable fix
for `RECOVERY_FRACTION`/`MAX_COMPACTING_STEPS`). Zero swap growth in
either run at wired 24000. **Recommend re-running this creep with
loosened thresholds before treating 32818 as a hard ceiling for
gating**; `-c 40960` itself is confirmed safe to serve.

**f16 KV.** Binary search at wired 24000 (same method): `-c 33792`
loads and serves a real completion; `-c 33920` fails the same Metal
OOM way (`results/server-qwen36-gguf-f16-c33792-w24000.log`). Compare
run11's f16 arm at wired 25000, which reached `-c 40960` — 1000 MB
less wired limit costs about 7100 tokens of window on this model.

Creep, f16, `-c 33792`, wired 24000, ladder to 32768, four runs (old,
new, old, new), loosened thresholds
(`COMPACT_PAGES=5000 RECOVERY_FRACTION=0.75 MAX_COMPACTING_STEPS=6`),
`STEP_PAUSE_S=60`:
`results/creep-qwen36-gguf-f16-w24000-c33792.tsv` (old, run 1),
`results/creep-qwen36-gguf-f16-w24000-c33792-newtool-run1.tsv` (new,
run 1), `results/creep-qwen36-gguf-f16-w24000-c33792-run2.tsv` (old,
run 2), `results/creep-qwen36-gguf-f16-w24000-c33792-newtool-run2.tsv`
(new, run 2). All four runs: `no ceiling found up to 32768`, zero or
negative `swap_delta_mb` on every row, both tools agree the refactor
is not the cause of anything seen. Decode speed and page-churn swing
widely run to run even on identical unmodified code (old tool alone:
40-54 tok/s one run, 21-27 tok/s the next) — read this as machine
noise between runs, not a tool or config signal.

**Working conclusion, not yet a gate decision:** wired 24000 served
both arms today with zero swap growth, at smaller windows than wired
25000 (`-c 40960` vs `-c 98304` for q8_0's confirmed-safe ceiling;
`-c 33792` vs `-c 40960` for f16). Wired 25000 produced real swap
growth under sustained back-to-back sweeps with no recovery gap
between them (see the `local-llm-eval-tools` branches); it has not
been tested with proper recovery gaps between sweeps, so "25000 always
swaps" is not established, only "25000 swapped under the stacking
pattern tested so far." The coordinator should read the linked
branches in full before setting `AGENT.md`'s wired-limit line for this
run.

## Follow-up — wired 25000 looks clean after all, single sweeps (2026-09-07, later)

New evidence changes the working conclusion above. Two single-sweep
creeps at wired 25000, each on a freshly restarted server, both fully
clean:

- q8_0, `-c 98304`: full ladder to depth 98338, stop on the speed
  floor (`< 8 tok/s`), not a memory verdict.
  `results/creep-qwen36-gguf-q8-w25000-c98304-clean.tsv`. Zero swap
  growth on every row.
- f16, `-c 40960`: `no ceiling found up to 40960`.
  `results/creep-qwen36-gguf-f16-w25000-c40960-clean.tsv`. Zero swap
  growth on every row.

Both numbers match run11's original wired-25000 results closely
(q8_0: 36.5→7.86 tok/s here vs. run11's 36.5→7.87; f16: 69.1→52.6 here
vs. run11's 67.9→53.0).

**The swap growth seen earlier only ever showed up under one specific
condition: several sweeps run back to back, on the same server
process, with no recovery gap between them.** Every single-sweep test
at wired 25000, on a freshly started server — today's two, plus
run11's own historical runs — came back clean. This suggests wired
25000 itself is not the cause; something that accumulates across
unbroken sweep sequences on one long-lived server is. A background
process independent of the sweep (`mediaanalysisd` drained free RAM
during run11 unrelated to any block, per that run's own history) is a
plausible cause, but this was not directly confirmed today — nobody
checked the process list at the time the swap growth happened, so
this is a lead, not a finding.

**Revised working picture:** `-c 98304` (q8_0) and `-c 40960` (f16)
both look stable at wired 25000 for a normal single-sweep or
single-session workload. The failure mode we chased all day needs
several unbroken sweeps stacked with no gap to reproduce, which is not
how a normal scoring block runs. Recommend the coordinator re-reads
this section before finalizing the wired-limit line; the case for
24000 over 25000 is weaker than the earlier section suggested.

## `gemma12-gguf-2slot` — Gemma-12B GGUF, two slots

Ladder: `unsloth/gemma-4-12b-it-GGUF:Q4_K_XL`, f16 KV, `--parallel 2`,
real 4096-token completions on both slots at each rung.

| `-c` | slot0 result | slot1 result | wired |
| --- | --- | --- | --: |
| 262144 | served, 4096 tok, hit cap | served, 789 tok, EOS | — |
| 278528 | served | served | — |
| 294912 | served | served | — |
| 393216 | served | served | — |
| 524288 | served | served | ~20.5 GB |
| 655360 | served | served | ~23.0 GB |
| 671744 | served | served | ~23.3 GB |
| 688128 | served | served | ~23.3 GB |
| 704512 | served | served | ~24.0 GB |
| 720896 | served | served | ~24.3 GB |
| 737280 | served | served | ~24.6 GB |
| 753664 | served | served | ~24.9 GB |
| **770048** | served | served | ~25.2 GB, ~68 MB free |

Stopped climbing at 770048: wired reached the machine's practical
ceiling with almost no free memory left, and pushing further risked a
system-level lockup rather than a clean OOM. Treated as the ladder's
top rather than searching for a true failure point.

Content note: slot0's raw-completion output ("Write a Python function
that parses ISO dates.") was degenerate ("1.1.1.1...") at every rung,
including the lowest (262144) — this is a property of the raw
`/completion` endpoint with no chat template on this prompt, not a
memory or depth effect, and does not affect the ladder or creep
measurement (both only read `.timings`, never content).

Round-robin creep at `-c 770048`, `N_CONTEXTS=2`, see
`results/creep-gemma12-gguf-2x-f16.tsv`:

| depth | tok/s (A) | tok/s (B) |
| --: | --: | --: |
| 4114 | 25.0 | 24.7 |
| 8222 | 23.81 | 23.89 |
| 16386 | 22.96 | 22.86 |

Stop: swap grew 144 MB by depth 16386 on slot B. **Clean per-slot
depth: 8222** — far short of the ladder's 770048, because the KV
allocation for both slots at that `-c` already consumes nearly all of
the wired budget before any real depth is used.


## `gemma12-gguf-1slot-131072` — Gemma-12B GGUF, one slot

Same files, KV type, no drafter. `--parallel 1`, `-c 131072`.

Creep, see `results/creep-gemma12-gguf-1x-c131072-f16.tsv`:

4k @ 25.0 → 8k @ 24.1 → 16k @ 22.8 → 25k @ 21.7 → 33k @ 20.6 → 41k @
19.5 → 49k @ 18.6 → 66k @ 17.0 → 82k @ 15.7 → 98k @ 14.6 → 115k @ 13.6
tok/s. Wired ~12 GB flat throughout. Stop: hit the `-c` boundary at
131072 (HTTP 400, not OOM). **Clean ceiling: 114718 tokens**, 13.59
tok/s.

Comparison, one slot vs two slots (each column its own tok/s):

| depth | 1 slot | 2 slots (A) | 2 slots (B) |
| --: | --: | --: | --: |
| 4096 | 25.0 | 25.0 | 24.7 |
| 8222 | 24.1 | 23.81 | 23.89 |
| 16386 | 22.8 | 22.96 | 22.86 |

**Note on `gemma12-gguf-2slot`'s first attempt.** That block's purpose
is to compare two slots each holding window W against one slot holding
the same W. The ladder climbed to `-c 770048` because a short
completion kept succeeding there, but that config's own creep
mem-stopped at depth 16386 (68 MB free at load, before any real
depth). A `-c` whose creep cannot reach depth is not a window
measurement — it answers "does this load," not "can two agents each
hold this window." The 770048 load result stands as a real finding
(this machine loads a 12B on two slots at that `-c`), but the block's
comparison value has to come from a `-c` whose creep itself runs
clean. Redo below, judged by the creep, not the ladder's short
completion.


## `gemma12-gguf-2slot` redo — creep-judged, not ladder-judged

The coordinator's correction: the block's question is "can two agents
each hold the same window one agent holds," so the value has to come
from a `-c` whose **creep** runs clean, never from a `-c` that only
loads and serves one short completion. Redo below.

| `-c` (per-slot window) | creep result |
| --- | --- |
| 262144 (131072) | mem stop, swap +923 MB at depth 81958 |
| 245760 (122880) | mem stop, swap +310 MB at depth 81958 |
| 221184 (110592) | mem stop, swap +143 MB at depth 81958 |
| 196608 (98304) | clean to depth 81958, then hit its own window boundary at 98338 (HTTP 400, not a memory stop) |

**Four separate attempts hit the same wall: depth 81958, every time
the window is large enough to reach it.** The stop is memory-driven
(swap growth), not window-driven, at every `-c` from 221184 up. Only
196608's own window boundary (98304) intervened before the real
memory limit could show up — that "clean" reading is genuine (no swap
growth was ever measured), but it did not test past depth 81958
either; the DEPTH_LIST jumped straight from 81920 to the window's own
edge.

**Finding: this machine's real per-slot clean ceiling for two Gemma-12B
slots is 81958 tokens, and it does not move once `-c` is large enough
to reach it.** Setting a bigger `-c` than needed for 81958 per slot
(about 172032 total) buys no real depth, only wasted KV allocation.
`gemma12_2x_clean` = **81958**, superseding the earlier 8222 reading
(that one was an artifact of `-c 770048`'s KV allocation alone eating
almost the entire wired budget before any depth was used).

Comparison, one slot (114718 clean) vs two slots (81958 clean each):
two slots holds about 71% of one slot's clean depth per agent, at
roughly proportional wired cost.

## `bonsai-fork-f16` — Bonsai on the PrismML fork, f16 KV

`Ternary-Bonsai-27B-Q2_g64.gguf`, prism-ml fork rev `abbae723028d71be674e71e1a71201a6f43fab22`,
`LLAMA_ATTN_ROT_DISABLE=1`, no drafter, `--parallel 1`, f16 KV, wired 25000.

Ladder: `-c 131072` served on the first candidate (loaded, one real
4096-token completion, `stop_type` `limit`, 16.93 tok/s). No lower
step needed.
`results/server-bonsai-fork-f16-c131072.log`.

Creep, `-c 131072`, one context, `results/creep-bonsai-fork-f16.tsv`:

| depth | tok/s | wired MB | swap Δ |
| --: | --: | --: | --: |
| 4114 | 14.95 | 18291 | 0 |
| 8222 | 16.25 | 18288 | 0 |
| 16386 | 15.62 | 18312 | 0 |
| 24602 | 15.07 | 18322 | 0 |
| 32818 | 14.45 | 18307 | 0 |
| 40982 | 13.92 | 18302 | -8 |
| 49198 | 13.40 | 18297 | -8 |
| 65578 | 12.50 | 18289 | -8 |
| 81958 | 11.45 | 18593 | -8 |
| 98338 | 10.76 | 18585 | -8 |
| 114718 | 10.24 | 18215 | -24 |
| 131098 | 9.67 | 18182 | -24 |

**speed** verdict (no memory stop; wired flat ~18.3 GB, swap never
grows). No ceiling found up to 131072: the deepest step, 131098
tokens, still decoded at 9.67 tok/s, above the block's 8 tok/s floor
the whole way. **Deepest step at or above 8 tok/s: 131072** (the `-c`
boundary itself, not a speed or memory floor).

The first request against this server (before the creep started, one
4096-token completion at 4-token depth) is discarded as warmup per
`common-rules.md` rule 2; the creep's own 4k row (14.95 tok/s) is the
recorded shallow number.

### `bonsai-fork-f16` agent task — Mendel guided, thinking high

Ran under a fresh model id, `bonsai-prism-f16` (not `bonsai-prism`, to
avoid a branch-name collision with the earlier, already-scored q4_0
KV row — see `state.md`). `MENDEL_CONTEXT_WINDOW=131072`, reserve
8192. Branch `bonsai-prism-f16-high-guided-v3-issue-13`, `end_reason:
complete`, 194.7 min elapsed, 2 commits, 1 hook-rejected commit
attempt, 1 compaction, 0 tooling nudges, 1 model nudge, 376 tool
calls, 74 tool errors, peak context 127120/131072. Loop verdict: ok,
worst ratio 0.33 on tool call (confirmed twice: mid-run by hand
against the events file, and by the worker's own `worker.json` at
close — the built-in check's `session.jsonl` write worked this time).

Scored on Opus, per `PLAN.md`'s scoring rule:

**Score 36 raw, 12.5 capped** (cap = 100 × 1/8 libraries done).
Libraries done: 1 of 8 (chalk only). Worst defect: **critical** — the
chalk-removal commit dropped `rimraf` from
`packages/mendel-pipeline/package.json` while `test/helpers/index.js`
still requires it, and the lockfile commit carried the drop; `eslint .`
fails at the tip (clean at base) because the pre-commit hook only
checked staged files. Second critical: 7 of 8 libraries never started.
The model's own closing claims (`TASKS.md` ticking all 32 sub-items,
"all 8 dependencies replaced") are both false — the bulk tick was one
edit written before the first commit, not verified against real
progress.

Result committed to `mendel-benchmark`'s `benchmark` branch, commit
`73b9bd3` (results JSON/CSV, regenerated `report-guided.html`,
redacted session log, `SESSIONS.md`). No other branch touched. This
repo does not carry the row's data directly — the config note in the
site comparison names the build.

`bonsai-fork-f16` block is fully done: ladder, creep, agent task, all
committed.


## `qwen38-ista-evalplus` — ISTA IQ3_S-mtp, full EvalPlus

`ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf`,
built-in MTP head, f16 KV, `--parallel 1`, `-c 131072` (ladder cleared
at this value, research run 3, same wired limit 25000), thinking
medium, wired 25000.

Calibration: 10/10 converge, max completion 2347 tokens, budget
max(2347×1.5, 8192) = **8192** (same floor as the control).
`benchmarks/calibration-qwen38-ista-mtp.json`.

Full run: `RESULTS_BASE=hardware/m1-max-32gb/benchmarks/bench12/results
EVALPLUS_MAX_NEW_TOKENS=8192 benchmarks/run-humaneval.sh qwen38-ista-mtp
qwen3.8-27b '{"chat_template_kwargs":{"reasoning_effort":"medium"}}'`.

| metric | value |
| --- | --: |
| HumanEval base | 0.976 |
| HumanEval plus | 0.945 |
| completion rate | 100% |
| empty | 1/164 |
| wall | 3:07:36 |

Files: `results/qwen38-ista-mtp/humaneval/`,
`results/server-qwen38-ista-evalplus.log`.

Comparison against the control row deferred to `qwen38-gguf-blind-medium`
(this run's own control re-measurement, at pi's current 8192 reserve).

## Projector cleanup and model cache inventory

Deleted (symlink + underlying blob), per the coordinator's mid-run
handoff note (`de79d22`): every served row in this run passes
`--no-mmproj`, so no projector file is needed.

| file | size | model |
| --- | --: | --- |
| `mmproj-Qwen3.8-27B-bf16.gguf` | 888M | `bartowski/Qwen3.8-27B-GGUF` |
| `mmproj-BF16.gguf` | 1.1G | `unsloth/gemma-4-26b-a4b-it-GGUF` |
| `mmproj-BF16.gguf` | 861M | `unsloth/Qwen3.6-35B-A3B-MTP-GGUF` |

~2.9 GB freed. `unsloth/Qwen3.8-27B-GGUF`'s own mmproj was NOT
touched, per the coordinator's note (kept as the K-quant control for
the i-quant speed question, alongside the model file itself).

Model cache inventory, `~/.cache/huggingface/hub`:

| model | revision | size |
| --- | --- | --: |
| `prism-ml/Ternary-Bonsai-27B-gguf` | `abbae72` | 29G |
| `unsloth/Qwen3.6-35B-A3B-MTP-GGUF` | `5bc3e23` | 21G |
| `mlx-community/Qwen3.6-35B-A3B-4bit` | `38740b8` | 19G |
| `bartowski/Qwen3.8-27B-GGUF` | `f0eec4a` | 17G |
| `unsloth/gemma-4-26b-a4b-it-GGUF` | `c099eb4` | 16G |
| `mlx-community/Qwen3.8-27B-4bit` | `3e6447f` | 15G |
| `unsloth/Qwen3.8-27B-GGUF` | `4ca7207` | 14G |
| `mlx-community/gemma-4-26b-a4b-it-4bit` | `0d77464` | 14G |
| `AtomicChat/Qwen3.8-27B-GGUF` | `ca10ebc` | 13G |
| `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF` | `d562806` | 11G |
| `prism-ml/Ternary-Bonsai-27B-mlx-2bit` | `70f75f3` | 7.9G |
| `unsloth/gemma-4-12b-it-GGUF` | `fc034cf` | 7.5G |
| `mlx-community/gemma-4-12B-it-4bit` | `73bcf09` | 6.3G |
| `mlx-community/Qwen3.8-27B-MTP-4bit` | `b643c01` | 253M |
| `lmstudio-community/gemma-4-12B-it-MLX-4bit` | `f45bda5` | 31M |
| `mlx-community/gemma-4-12B-it-qat-OptiQ-4bit` | `63912b8` | 76K |

Every MLX entry above is unreferenced by this run (this run serves no
MLX row: every MLX item moved to `../unscheduled/`), but nothing else
deleted this pass, per the coordinator's instruction ("Delete nothing
else this pass").

## `qwen38-atomicchat-evalplus` — AtomicChat AD-IQ3_S, full EvalPlus

`AtomicChat/Qwen3.8-27B-GGUF:AD-IQ3_S`, MTP drafter active
(`--spec-type draft-mtp --spec-draft-n-max 3`, carried over from the
control's own sweep, n-max not yet confirmed for this build — see the
deferred-sweep note in `state.md`), f16 KV, `--parallel 1`, `-c 106496`
(ladder cleared at this value, research run 3, same wired limit
25000), thinking medium, wired 25000.

Calibration: 10/10 converge, max completion 5924 tokens, budget
max(5924×1.5, 8192) = **8886**.
`benchmarks/calibration-qwen38-atomicchat.json`.

Full run: `RESULTS_BASE=hardware/m1-max-32gb/benchmarks/bench12/results
EVALPLUS_MAX_NEW_TOKENS=8886 benchmarks/run-humaneval.sh qwen38-atomicchat
qwen3.8-27b '{"chat_template_kwargs":{"reasoning_effort":"medium"}}'`.

| metric | value |
| --- | --: |
| HumanEval base | 0.988 |
| HumanEval plus | 0.927 |
| completion rate | 100% |
| empty | 0/164 |
| wall | 3:10:32 |

Files: `results/qwen38-atomicchat/humaneval/`,
`results/server-qwen38-atomicchat-evalplus.log`.

Comparison against the control row deferred to `qwen38-gguf-blind-medium`
(this run's own control re-measurement, at pi's current 8192 reserve).

## `qwen38-gguf-blind-medium` — ladder and creep

`bartowski/Qwen3.8-27B-GGUF:Q4_K_M`, MTP n-max 3, f16 KV, `--parallel 1`,
wired 25000. Old published ceiling (49152) was measured at wired
24000 (run 9); real ladder from `-c 49152` upward in 8192 steps, real
4096-token completions.

| `-c` | result | tok/s | draft accept |
| --- | --- | --: | --: |
| 49152 | served | 20.32 | 3070/3075 (99.8%) |
| 57344 | served | 20.37 | 3070/3075 (99.8%) |
| 65536 | served | 20.38 | 3070/3075 (99.8%) |
| 73728 | served | 20.40 | 3070/3075 (99.8%) |
| 81920 | **OOM**, `kIOGPUCommandBufferCallbackErrorOutOfMemory` | - | - |

**Ladder value: `-c 73728`.** Flat decode speed and draft acceptance
across the whole served range — purely a memory boundary here.

Creep, `-c 73728`, `results/creep-qwen38-gguf-blind-medium.tsv`:

| depth | tok/s | wired MB | swap Δ | compress | decompress |
| --: | --: | --: | --: | --: | --: |
| 4114 | 19.97 | 25400 | 0 | 0 | 104 |
| 8222 | 18.21 | 25427 | 0 | 0 | 248 |
| 16386 | 16.08 | 25410 | 0 | 0 | 257 |
| 24602 | 17.22 | 25390 | 0 | 9 | 299 |
| 32818 | 16.40 | 25383 | 0 | 5674 | 310 |
| 40982 | 15.61 | 25386 | 0 | 622894 | 383166 |
| 49198 | 14.97 | 25386 | 0 | 0 | 9841 |
| 57362 | 14.30 | 25367 | 0 | 27413 | 3004 |
| 65578 | 13.71 | 25404 | -56 | 183975 | 68144 |
| 73742 | 13.15 | 25380 | 2365 | 997023 | 857207 |

**mem** verdict at 73742 (swap grew 2365 MB, real growth). The 40982
compress/decompress spike is flagged, not accepted at face value: zero
swap growth there, matching the known false-positive pattern from this
run's pre-block prep. **Clean ceiling: 65578 tokens, 13.71 tok/s.
Mendel window: 65536.**

## `qwen38-gguf-blind-medium` — Mendel blind, thinking medium (control re-run)

Ran under a fresh model id, `qwen3.8-27b-reserve8192` (not
`qwen3.8-27b`, to avoid a branch-name collision with the published
control row at reserve 16384 — see `state.md`). `MENDEL_CONTEXT_WINDOW=65536`,
reserve 8192. Branch `qwen3.8-27b-reserve8192-medium-issue-13`,
`end_reason: complete`, ~98 min, 12 commits, 2 tooling stall nudges, 1
compaction, `tool_calls 173`, `peak_context 60261/65536`. Loop verdict
ok, worst ratio 0.52.

Scored on Opus: **76/100, 8/8, no cap.** Worst defect critical (trap A
failed: `fs.promises.glob` `.then()` chain, `TypeError` on the real
repro, uncovered by tests). Second defect medium (trap B left,
rimraf still required in two test files). No `reruns` penalty
(harness correction, not a model retry).

**Below the published control's 87** (reserve 16384) — a real
regression (trap A), not measurement noise. Which row is canonical is
an owner decision, flagged in `state.md`, not decided here. Both rows
live on `mendel-benchmark`'s `benchmark` branch: this row at commit
`104a75e`, the old row untouched at `qwen3.8-27b-medium-issue-13`.

## n-max sweeps — ISTA and AtomicChat

One real completion each (1024 tokens, coding prompt, `-c 4096`,
temperature 0), n-max 4 and 6, sweeping up only from the creep's
n-max 3 (per `common-rules.md` rule 11 and the coordinator's
`8364148`):

| build | n-max 3 (creep, shallow) | n-max 4 | n-max 6 |
| --- | --: | --: | --: |
| ista gsq-iq3s | 15.1 tok/s | 13.14 tok/s (75.5%) | 11.27 tok/s (63.3%) |
| atomicchat ad-iq3s | 15.79 tok/s | 12.92 tok/s (74.5%) | 11.13 tok/s (62.8%) |

**n-max 3 stays the served value for both builds** — sweeping up
only made both slower. `qwen38-ista-mendel` and
`qwen38-atomicchat-mendel` proceed at n-max 3, windows 114688 and
98304.

## `qwen38-ista-mendel` — Mendel blind, thinking medium

Long-prompt completion check at window 114688: PASS (27-token coherent
summary, `stop_type eos` normal finish). Served under fresh alias
`qwen3.8-27b-ista` (control's own alias already used); one invalid
row (`qwen3.8-27b-ista`, killed in seconds by a bug in the runner's
own live loop guard, zero commits, left untouched, no penalty),
retried clean under `qwen3.8-27b-ista2`. `-c 131072`, window 114688,
n-max 3 (confirmed by this run's own sweep, not the control's).

Branch `qwen3.8-27b-ista2-medium-issue-13`, `end_reason: complete`, 17
commits, `tool_calls 195`, `peak_context 89386/114688`. Loop verdict
ok, worst ratio 0.52.

**Score: 76.5/100, 8/8, no cap.** Worst defect critical: trap A failed
(`apply-extra-options.js` swaps to `require('fs').promises` but keeps
the `.then()` chain, `TypeError` on the real repro). Same failure
shape as the control re-run's own trap A. Config note: build, revision,
f16 KV, `-c 131072`, window 114688, `n-max 3`, `wired 25000`, not the
row we serve today.

Result on `mendel-benchmark`'s `benchmark` branch, commit
`79e5f0976cfea3e1f2ad86bb9f8bbf964bfd8fa0`. Dead branch
`qwen3.8-27b-ista-medium-issue-13` and the published control branch
both untouched.

**Bug found: `score.mjs`'s `trap_a.ok` flag reads `true` while its own
captured output says `THREW`.** Flagged for the coordinator, not
fixed mid-run.
