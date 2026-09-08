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
Creep ran at `-c 131072`, see `results/creep-qwen38-unsloth-q3kxl.tsv`:

4k @ 14.4 → 8k @ 14.1 → 16k @ 12.2 → 24k @ 13.0 → 32k @ 12.1 → 41k @
10.9 → 49k @ 12.5 → 65k @ 11.6 tok/s. Stop: swap grew 3 MB at depth
65578 (mem verdict, not a model limit). Clean ceiling: **49198
tokens**, 12.45 tok/s, wired ~24.5-25.2 GB throughout.

Tool: `local-llm-eval-tools` commit `2344f00`.

## `qwen38-atomicchat-iq3s-creep`

Ladder: `AtomicChat/Qwen3.8-27B-GGUF:AD-IQ3_S`, f16 KV, MTP drafter on.
`-c 106496` served a real 4096-token completion (1411 tokens, EOS,
13.45 tok/s), so the ladder cleared at the starting value.

Creep ran at `-c 106496` against the depth list capped at 98304, see
`results/creep-qwen38-atomicchat-iq3s.tsv`:

4k @ 15.8 → 8k @ 15.4 → 16k @ 14.8 → 25k @ 14.2 → 33k @ 13.7 → 41k @
13.1 → 49k @ 12.7 → 66k @ 11.7 → 82k @ 11.0 → 98k @ 10.3 tok/s. No stop
condition hit (no OOM, no swap growth) — the sweep ran out of depth
list before it ran out of headroom. Ceiling: **98338 tokens**, 10.26
tok/s, wired ~24.0-24.1 GB throughout, clean the whole way.

Tool: `local-llm-eval-tools` commit `2344f00`.

## `qwen38-ista-iq3s-mtp-creep`

Ladder: `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF:IQ3_S-mtp`, f16 KV,
built-in MTP head. `-c 131072` served a real 4096-token completion
(1708 tokens, EOS, 13.52 tok/s), ladder cleared at the starting value.

Creep ran at `-c 131072`, see
`results/creep-qwen38-ista-iq3s-mtp.tsv`:

4k @ 15.1 → 8k @ 13.5 → 16k @ 14.7 → 24k @ 14.2 → 33k @ 13.7 → 41k @
13.2 → 49k @ 12.7 → 66k @ 11.8 → 82k @ 11.0 → 98k @ 10.3 → 115k @ 9.7
→ 131k @ 9.1 tok/s. Stop: swap grew 429 MB at depth 131098 (mem
verdict). Clean ceiling: **114718 tokens**, 9.67 tok/s, wired ~24.2 GB
throughout.

Tool: `local-llm-eval-tools` commit `2344f00`.

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

## The three creeps, side by side

| build | ceiling | tok/s at ceiling | stop reason |
| --- | --: | --: | --- |
| unsloth q3kxl | 49198 | 12.45 | mem, swap +3 MB at 65578 |
| atomicchat iq3s | 98338 | 10.26 | none, ran off end of depth list |
| ista iq3s-mtp | 114718 | 9.67 | mem, swap +429 MB at 131098 |

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

| level | calls | commits | loop | clean | wall_s | verdict |
| --- | --: | --: | --- | --- | --: | --- |
| low | 13 | 1 | ok:1.00 | yes | 91 | pass |

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

Creep ran the whole depth list clean, no stop, see
`results/creep-strip-qwen38-nodrafter.tsv`:

4k @ 13.8 → 8k @ 13.4 → 16k @ 13.0 → 25k @ 12.4 → 33k @ 12.1 → 41k @
11.7 → 49k @ 11.3 → 66k @ 10.6 → 82k @ 10.0 → 98k @ 9.5 → 115k @ 9.0 →
131k @ 8.6 tok/s. Wired ~23.1-23.2 GB throughout, no swap growth.

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

Creep ran clean the whole extended depth list, no stop, see
`results/creep-strip-gemma26-nodrafter.tsv`:

4k @ 52.5 → 8k @ 50.3 → 16k @ 48.0 → 25k @ 44.0 → 33k @ 41.9 → 41k @
39.3 → 49k @ 36.9 → 66k @ 33.5 → 82k @ 30.3 → 98k @ 27.8 → 115k @ 25.7
→ 131k @ 23.9 → 164k @ 21.0 → 197k @ 18.6 tok/s. Wired ~23.8-23.9 GB
throughout, no swap growth.

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
