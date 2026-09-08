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

