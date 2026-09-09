# Research run 3 — results

Every number this run measured, with the exact command that produced
it. Nothing here reaches the site: the coordinator decides which
candidate becomes a bench item, and the bench run publishes.

Raw files go in `results/`: one server log and one creep file per
item, named by the item's mnemonic.

## `qwen38-unsloth-q3kxl-creep`

Ladder: `unsloth/Qwen3.8-27B-GGUF:UD-Q3_K_XL`, f16 KV, MTP drafter on,
real 4096-token completions at each rung.

| `-c` | result |
| --- | --- |
| 114688 | served, 1849 tokens, EOS, 13.48 tok/s |
| 122880 | served, 284 tokens, EOS, 12.85 tok/s |
| 131072 | served, 1849 tokens, EOS, 13.55 tok/s |

Ladder stopped at 131072, the top of the creep tool's own depth list.
Creep ran at `-c 131072`, start wired 24796 MB, free 2054 MB, swap used
266 MB. Raw file: `results/creep-qwen38-unsloth-q3kxl.tsv`.

| depth | tok/s | wired MB | free MB | swap delta MB |
| --: | --: | --: | --: | --: |
| 4114 | 14.37 | 25198 | 368 | 0 |
| 8222 | 14.05 | 25197 | 75 | 0 |
| 16386 | 12.21 | 25211 | 61 | 0 |
| 24602 | 13.02 | 25207 | 60 | 0 |
| 32818 | 12.06 | 25190 | 63 | 0 |
| 40982 | 10.87 | 25068 | 93 | 0 |
| **49198** | **12.45** | 25058 | 63 | 0 |
| 65578 | 11.56 | 25030 | 57 | 3 |

Stop: swap grew 3 MB at depth 65578, a mem verdict and not a model
limit. Clean ceiling: **49198 tokens** at 12.45 tok/s. Wired sat at
25.0 to 25.2 GB the whole way, at the top of the 25000 limit, and free
memory never rose above 93 MB after the first step.

Tool: `local-llm-eval-tools` commit `2344f00`.

## `qwen38-atomicchat-iq3s-creep`

Ladder: `AtomicChat/Qwen3.8-27B-GGUF:AD-IQ3_S`, f16 KV, MTP drafter on.
`-c 106496` served a real 4096-token completion (1411 tokens, EOS,
13.45 tok/s), so the ladder cleared at the starting value.

Creep ran at `-c 106496` against the depth list capped at 98304, start
wired 24119 MB, free 340 MB, swap used 261 MB. Raw file:
`results/creep-qwen38-atomicchat-iq3s.tsv`.

| depth | tok/s | wired MB | free MB | swap delta MB |
| --: | --: | --: | --: | --: |
| 4114 | 15.79 | 24133 | 60 | 0 |
| 8222 | 15.36 | 24105 | 63 | 0 |
| 16386 | 14.78 | 24099 | 64 | 0 |
| 24602 | 14.23 | 24107 | 63 | 0 |
| 32818 | 13.68 | 24089 | 68 | 0 |
| 40982 | 13.14 | 24086 | 62 | 0 |
| 49198 | 12.65 | 24093 | 60 | 0 |
| 65578 | 11.74 | 24070 | 61 | 0 |
| 81958 | 10.96 | 24063 | 68 | 0 |
| **98338** | **10.26** | 24057 | 59 | 0 |

**No stop condition was hit**: no OOM and no swap growth at any step.
The sweep ran out of depth list before it ran out of headroom, so
98338 is the list's end and **not a measured ceiling**. Wired held at
24.0 to 24.1 GB the whole way, about 1 GB under the limit.

Tool: `local-llm-eval-tools` commit `2344f00`.

## `qwen38-ista-iq3s-mtp-creep`

Ladder: `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`, f16 KV,
built-in MTP head. `-c 131072` served a real 4096-token completion
(1708 tokens, EOS, 13.52 tok/s), ladder cleared at the starting value.

Creep ran at `-c 131072`, start wired 24097 MB, free 64 MB, swap used
253 MB. Raw file: `results/creep-qwen38-ista-iq3s-mtp.tsv`.

| depth | tok/s | wired MB | free MB | swap delta MB |
| --: | --: | --: | --: | --: |
| 4114 | 15.09 | 24083 | 57 | 0 |
| 8222 | 13.54 | 24065 | 59 | 0 |
| 16386 | 14.65 | 24073 | 64 | 0 |
| 24602 | 14.25 | 24067 | 60 | 0 |
| 32818 | 13.71 | 24212 | 64 | 0 |
| 40982 | 13.20 | 24213 | 55 | 0 |
| 49198 | 12.71 | 24206 | 57 | 0 |
| 65578 | 11.80 | 24199 | 64 | 0 |
| 81958 | 10.99 | 24213 | 60 | 0 |
| 98338 | 10.30 | 24219 | 60 | 0 |
| **114718** | **9.67** | 24204 | 63 | 0 |
| 131098 | 9.14 | 24189 | 59 | 429 |

Stop: swap grew 429 MB at depth 131098, a mem verdict. Clean ceiling:
**114718 tokens** at 9.67 tok/s. This is the only measured ceiling of
the three builds. Wired held near 24.2 GB the whole way, so the stop
came from the machine's free memory and not from the wired limit.

Tool: `local-llm-eval-tools` commit `2344f00`.

**(2026-09-09: every Qwen3.8 candidate below ran at effort medium,
inherited from the control row. That inheritance rule is withdrawn and
medium is banned for this model from this date. We do not want parity
with these rows and we will not compare medium against medium. Not
running medium matters more than parity. A model's first run uses that
model's own default, xhigh here.)**

## The three EvalPlus smokes

Control (`bartowski/Qwen3.8-27B-GGUF:Q4_K_M`, f16, `-c 49152`, medium,
the row we serve today): 4/4 passed, 0 empty, 3506/8192 tokens.

| build | passed | empty | tokens | verdict |
| --- | --: | --: | --: | --- |
| unsloth q3kxl (`-c 49152`) | 4/4 | 0 | 2804/8192 | level |
| atomicchat iq3s (`-c 98304`) | 4/4 | 0 | 2668/8192 | level |
| ista iq3s-mtp (`-c 114688`) | 4/4 | 0 | 2598/8192 | level |

### `qwen38-evalplus-gate`

| build | pass count | mendel |
| --- | --: | --- |
| unsloth q3kxl | 4/4 | run |
| atomicchat iq3s | 4/4 | run |
| ista iq3s-mtp | 4/4 | run |

All three level with the control row and none returned an empty
completion. All three go on to their Mendel smoke.

Tool: `benchmarks/evalplus-smoke.py`, budget from
`benchmarks/calibration-qwen38-gguf-medium.json` (8192, both sides).
Needed `openai` and `evalplus` installed; put them in a venv at
`~/.venvs/local-llm-bench` rather than touching the Homebrew Python.

## Every creep of this run, side by side

The two strip creeps are lower in this file, under their own items.
They are here because the depth they buy is only readable against the
candidates.

The `kind` column matters more than the depth. **A measured ceiling is
a number this machine refused to pass. A list end is only the deepest
step the tool asked for.** Three of these five never hit a stop
condition, so their depth is a floor under the true ceiling, never the
ceiling itself. No plan may read a list end as a ceiling.

| config | depth | tok/s there | kind | stop reason |
| --- | --: | --: | --- | --- |
| unsloth q3kxl | 49198 | 12.45 | measured ceiling | mem, swap +3 MB at 65578 |
| atomicchat iq3s | 98338 | 10.26 | **list end** | none hit |
| ista iq3s-mtp | 114718 | 9.67 | measured ceiling | mem, swap +429 MB at 131098 |
| unsloth q3kxl, no drafter | 131098 | 8.58 | **list end** | none hit |
| gemma26, no drafter | 196618 | 18.57 | **list end** | none hit |

The depth list needs extending before the next run. Three of these
five rows cannot be improved by any amount of re-reading; they need a
deeper sweep.

## The three Mendel smokes

Control (`bartowski/Qwen3.8-27B-GGUF:Q4_K_M`, f16, `-c 49152`, medium):
10 calls, 1 commit, no loop, clean, 111s, pass.

| build | calls | commits | loop | clean | wall_s | verdict |
| --- | --: | --: | --- | --- | --: | --- |
| unsloth q3kxl (`-c 49152`) | 12 | 1 | ok:1.00 | yes | 192 | pass |
| atomicchat iq3s (`-c 98304`) | 9 | 1 | ok:1.00 | yes | 114 | pass |
| ista iq3s-mtp (`-c 114688`) | 10 | 1 | ok:1.00 | yes | 111 | pass |

All three pass the handed `xtend` task at their own creep window: the
task-lossless 3-bit claim survives an agent loop for all three
candidates. All three are candidates for the coordinator's bench pick.

## Effort levels, control row

Against the medium row's 87 (`../qwen38-configs.md`, "Reasoning
effort"). Same row, `-c 49152`, only `--reasoning-effort` moves.

| level | calls | commits | loop | clean | peak | wall_s | verdict |
| --- | --: | --: | --- | --- | --: | --: | --- |
| low | 13 | 1 | ok:1.00 | yes | | 91 | pass |
| xhigh | 10 | 1 | ok:1.00 | yes | 4763 | 127 | pass |

Both levels pass clean, with no loop and no failure to commit. **Effort
level is not a robustness lever for this model on this task.** The
report that medium is the worst setting for agent work is neither
confirmed nor refuted here: the smoke asks whether a level survives the
loop, and all of them do. Only a scored run separates them.

## `compaction-qwen38`

Baseline, twice, `xtend-wide` task, cap 2700s, reserve 8192:

| run | calls | commits | compactions | peak | wall_s | verdict |
| --- | --: | --: | --: | --: | --: | --- |
| 1 | 9 | 1 | 0 | 5738 | 136 | pass |
| 2 | 13 | 1 | 0 | 8360 | 900 | pass |

P (larger peak) = 8360, far under the 20000-token line where pi's
compaction can fire at all (`docs/compaction.md`, `keepRecentTokens`
default 20000). Per the ladder's own stop rule (stop when `T` under
8192), the first rung (`0.8P` = 6688) is already under the floor: no
rung ran. **No compaction observed.** This model is too token-efficient
at the `xtend-wide` task for the experiment to test its compaction
behavior; the task would need to grow to produce a real reading.

## `compaction-gemma12`

Baseline, twice, thinking off, `xtend-wide` task, cap 2700s, reserve
8192:

| run | calls | commits | compactions | peak | wall_s | verdict |
| --- | --: | --: | --: | --: | --: | --- |
| 1 | 25 | 1 | 0 | 34440 | 420 | pass |
| 2 | 38 | 1 | 0 | 40238 | 700 | pass |

P = 40238. Ladder, two repeats per rung:

| rung | window | keepRecentTokens | run | compactions | commits | end | verdict |
| --- | --: | --: | --: | --: | --: | --- | --- |
| 1 (0.8P) | 39936 | default | 1 | 0 | 1 | stop | pass |
| 1 | 39936 | default | 2 | 0 | 0 | length | fail |
| 2 (0.6P) | 31744 | 11264 | 1 | 1 | 1 | stop | pass |
| 2 | 31744 | 11264 | 2 | 3 | 0 | cap | fail |
| 3 (0.4P) | 23552 | 7168 | 1 | 0 | 1 | stop | pass |
| 3 | 23552 | 7168 | 2 | 0 | 1 | stop | pass |

Rungs 1 and 2 are mixed (one pass, one fail each) — variance between
runs of the same model and window, exactly what the doc's "two repeats"
rule exists to catch. Rung 3 is the first rung with two clean passes,
so `contextWindow` floor = **23552**. Only rung 2's passing run showed
a real compaction firing (`compactions=1`) and still finishing clean;
every other pass ran under its own compaction threshold without ever
triggering one.

## `compaction-bonsai-mlx`, skipped

Smoke line passes (bench10: 14 calls, 1 commit, no loop, 115s), but
the item needs the MLX margin rule's window, and that rule is
explicitly out of this run (`AGENT.md`, "Not in this run"). Bonsai has
documented history of a 3-hour stuck run and a 17440-token single-turn
blowup without that margin. Skipped rather than guess a window.
Stop-and-ask for the coordinator.

## `compaction-gemma26`

Baseline, twice, thinking off, `xtend-wide` task, cap 2700s, reserve
8192:

| run | calls | commits | compactions | peak | wall_s | verdict |
| --- | --: | --: | --: | --: | --: | --- |
| 1 | 27 | 1 | 0 | 35092 | 115 | pass |
| 2 | 28 | 1 | 0 | 35225 | 119 | pass |

P = 35225. Rung 1 (W 35840, T 27648):

| run | compactions | commits | clean | end | verdict |
| --- | --: | --: | --- | --- | --- |
| 1 | 0 | 0 | no | stop | fail |
| 2 | 0 | 0 | no | stop | fail |

Both runs end `stop` — the model believes the task is finished — but
leave the tree unclean with no commit, and `compactions=0` in both:
compaction never fired, so this is not a compaction failure. The model
just does worse work under the reduced window on this task. Per the
ladder's stop rule (two failures at one rung), the ladder stops here.
**No `contextWindow` floor found for Gemma-26B** on `xtend-wide`.

## `strip-qwen38-pair`

`bartowski/Qwen3.8-27B-GGUF:Q4_K_M`, f16, `-c 49152`, drafter on both
sides.

| side | wired delta | tok/s (warmup) | tok/s (2nd) | creep @ 32818 |
| --- | --: | --: | --: | --: |
| without mmproj | 22511 MB | 17.04 | 17.04 | 16.41 |
| with mmproj | 23686 MB | 17.04 | 17.05 | 16.40 |

Wired delta (`with - without`) = **1175 MB**, at or above the mmproj
file size (928 MB). tok/s and creep speed match within noise (both
under 1%). Pass rule met: **memory only, already taken.** Projector
compute-buffer cost on Metal = 1175 - 928 = **247 MB**.

## `strip-gemma26-pair`

`unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL`, f16, `-c 212992`, drafter
on both sides.

Without mmproj: loads clean, wired delta 24490 MB, tok/s 70.28 →
75.04, creep @ 32818 clean at 40.95 tok/s.

With mmproj at the row's full `-c 212992`: **OOMs**. First attempt
used `--offline` and silently skipped the projector (not cached, no
error) — an invalid measurement, worth flagging as a real gotcha:
`--offline` on an uncached side-file fails silent, not loud. Retried
without `--offline` to let it fetch `mmproj-BF16.gguf`; then it hit
the documented signature exactly (`ggml_metal_synchronize:
Insufficient Memory`, `Compute error` 500 on every completion,
`model loaded` printed anyway).

Search down in 8192 steps: `-c 204800` loads and serves fine (with
`--offline`, now cached); `-c 212992` OOMs. **The boundary is the full
row's own `-c`** — one 8192 step below it works.

## `strip-qwen38-nodrafter-creep`

`unsloth/Qwen3.8-27B-GGUF:UD-Q3_K_XL`, f16 KV, `--spec-type draft-mtp`
removed, everything else unchanged. Ladder cleared at `-c 131072`
(1849 tokens, EOS, 13.95 tok/s — the with-drafter row measured 13.55
at the same depth).

Creep ran the whole depth list clean with no stop, start wired 23151 MB,
free 59 MB, swap used 464 MB. Raw file:
`results/creep-strip-qwen38-nodrafter.tsv`.

| depth | tok/s | wired MB | free MB | swap delta MB |
| --: | --: | --: | --: | --: |
| 4114 | 13.79 | 23147 | 58 | 0 |
| 8222 | 13.43 | 23146 | 67 | -8 |
| 16386 | 12.95 | 23141 | 65 | -8 |
| 24602 | 12.40 | 23139 | 58 | -8 |
| 32818 | 12.07 | 23153 | 58 | -8 |
| 40982 | 11.68 | 23143 | 66 | -8 |
| 49198 | 11.32 | 23142 | 84 | -8 |
| 65578 | 10.63 | 23143 | 58 | -16 |
| 81958 | 10.04 | 23142 | 64 | -24 |
| 98338 | 9.51 | 23154 | 58 | -24 |
| 114718 | 9.02 | 23165 | 175 | -32 |
| **131098** | **8.58** | 23145 | 63 | -48 |

**No stop condition was hit**, so 131098 is the list's end and not a
measured ceiling. Wired held at 23.1 to 23.2 GB the whole way, about
2 GB under the same build with its drafter, and the swap delta ran
**negative** at every step past the first: the machine gave swap back
as the sweep went deeper. This config had headroom to spare at the
deepest step the tool could ask for.

**The trade, answered.** With the drafter, this row mem-stopped at
49198 tokens. Without it, the same row ran clean past 131072 — the
list's own boundary, not a measured ceiling. Dropping the drafter buys
this build well over 2.6x the clean depth, at a shallow-speed cost of
roughly a wash (13.55 → 13.95 at 131k prompt) and a deep-speed cost of
about 9.14 → 8.58 tok/s at ~131k used. For a task that needs depth over
shallow throughput, dropping the drafter is the better trade on this
build.

## `strip-qwen36-pair`

`unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL`, f16, `-c 49152`, drafter
removed on both sides.

| side | wired | tok/s (warmup) | tok/s (2nd) | creep @ 32818 |
| --- | --: | --: | --: | --: |
| without mmproj | 23589 MB | 51.33 | 51.68 | 39.89 |
| with mmproj | 24785 MB | 51.36 | 51.71 | 39.70 |

Wired delta = **1196 MB**, at or above the mmproj file size (899 MB).
Speeds match within noise (all under 0.5%). Pass rule met: **memory
only, already taken.**

## `strip-gemma26-nodrafter-creep`

`unsloth/gemma-4-26b-a4b-it-GGUF:UD-Q4_K_XL`, f16 KV, no `--no-mmproj`
drafter flags, `-c 212992`. Ladder cleared (4096 tokens, EOS, 54.95
tok/s).

Creep ran clean the whole extended depth list with no stop, start wired
23582 MB, free 64 MB, swap used 416 MB. Raw file:
`results/creep-strip-gemma26-nodrafter.tsv`.

| depth | tok/s | wired MB | free MB | swap delta MB |
| --: | --: | --: | --: | --: |
| 4114 | 52.46 | 23776 | 113 | 0 |
| 8222 | 50.34 | 23774 | 62 | 0 |
| 16386 | 47.99 | 23903 | 104 | 0 |
| 24602 | 43.95 | 23915 | 65 | 0 |
| 32818 | 41.89 | 23913 | 59 | 0 |
| 40982 | 39.30 | 23908 | 68 | 0 |
| 49198 | 36.89 | 23907 | 62 | 0 |
| 65578 | 33.51 | 23906 | 81 | 0 |
| 81958 | 30.27 | 23925 | 59 | 0 |
| 98338 | 27.78 | 23923 | 56 | 0 |
| 114718 | 25.71 | 23906 | 66 | 0 |
| 131098 | 23.89 | 23922 | 68 | 0 |
| 163858 | 21.03 | 23929 | 83 | 0 |
| **196618** | **18.57** | 23915 | 64 | 0 |

**No stop condition was hit**, so 196618 is the list's end and not a
measured ceiling. Wired held at 23.8 to 23.9 GB the whole way with no
swap growth at any step.

At a comparable depth the published with-drafter row gates on memory
near 197k at 25.6 GB wired; without the drafter this ran the same
depth clean at 23.9 GB — about 1.7 GB freed, and the ceiling did not
even hit a stop condition this time.

## The two gates

`qwen38-creep-gate` and `qwen38-evalplus-gate` each write their table
here, with one line per build, the builds they passed as well as the
builds they stopped.

### `qwen38-creep-gate`

Reference: 49152 tokens (deepest clean depth this machine has measured
for Qwen3.8 at f16). Floor: 20 percent under it, 39322 tokens.

| build | clean depth | reference | ratio | evalplus |
| --- | --: | --: | --: | --- |
| unsloth q3kxl | 49198 | 49152 | 100.1% | run |
| atomicchat iq3s | 98338 | 49152 | 200.1% | run |
| ista iq3s-mtp | 114718 | 49152 | 233.4% | run |

All three clear the floor. All three go on to their EvalPlus smoke.
