# Status lines

A benchmark run reports to the owner. It reports in chat while the run
goes, in `state.md` when a block closes, and in `results.md` and on the
site when a number becomes public. This page gives the five lines a run
sends to chat, so no runner has to invent a format again.

Everything else the run produces goes in a file. A line that is not one
of the five is not sent.

## The three sizes, and where each one goes

| Size | Shape | Where |
|---|---|---|
| **short** | one line, numbers only | chat, at the heartbeat |
| **medium** | a few lines, with the evidence | the run's `state.md`, at block close |
| **large** | the site table row, old row and new row | `results.md`, and the coordinator's publish step |

A short line goes to chat. Nothing longer goes to chat unless the owner
asks for it. The medium form goes into `state.md` when the block
closes. The large form is the comparison table: the exact published row
first, the new row under it.

Two rules decide the size, and they leave no judgment to the runner:

1. **An agent that runs a benchmark unattended sends the short form at
   every 20-minute wakeup.** Every wakeup, not only the interesting
   ones. A wakeup with nothing new still sends one short line.
2. **The medium form is the default answer when the owner asks for
   status.** The owner asking is not a request for the short line
   again, and not a request for a wall of prose. Give the medium form
   unless they name a different size.

## Every short line stands alone

A short line is often the only line the owner reads. It must repeat the
context, not only the new result. The owner said it directly:
"statusline shoudl repeat model/want/etc not only results, otherwise it
is not reasable for me, when I get back and read only one line"
(`4f614267`, 2026-09-05). And, on the same run: "Report status lines
that name run/block/model/config." (`4f614267`, 2026-09-05).

So the frame of every short line is:

`<task> <model short id> <variant> <n>/<N>: <the numbers>. <state or next check>.`

## The naming rules

### Blocks

Name a block by its mnemonic, the name its runbook gives it, and add
the count of the run: `gemma12-gguf-2slot 3/8`. Do not write `Step A`,
`Step 1`, or `Block A1b`, and do not use the number alone: a run
reorders, and a number that moved tells the reader nothing. The
mnemonic says which block it is, the count says how far the run is.

A block that repeats one test over several arms gets a subtype with its
own count: `creep 1/3`, `smoke 2/2`, `arm 1/2`.

### Model short ids

A short id must show the size and say whether the model is dense or a
mixture of experts. Keep the vendor, the version, the parameter count,
and the active-parameter suffix when the model has one.

| Short id | Reads as |
|---|---|
| `qwen-3.8-27b` | dense, 27B |
| `qwen-3.6-35b-a3b` | MoE, 35B total, 3B active |
| `gemma-4-12b` | dense, 12B |
| `gemma-26b-a4b` | MoE, 26B total, 4B active |
| `bonsai-27b` | dense, 27B |

Never drop the `a<N>b` suffix. `gemma-26b` alone reads as a dense 26B
model and is wrong.

After the model id, name only the parameters this update changes, never
the whole serving command.

### The variant

A model short id no longer says which row is running: one model runs
several builds, cache types, modes and levels in one run. So every
short line carries a variant after the model id.

The variant is the smallest set of fields that tells this row apart
from the other rows of the same model in the same run, joined by `/`
in this order. A field that does not differ is left out:

| Field | Written as | Example |
|---|---|---|
| build or quant | the publisher's short tag | `q4km`, `q3kxl`, `iq3s`, `mlx4` |
| cache type | the type | `f16`, `q8` |
| slots | `<N>slot`, only above one | `2slot` |
| drafter | `nodraft`, only when removed | `nodraft` |
| level | the thinking or effort level | `medium`, `xhigh`, `off` |

So `qwen-3.8-27b q3kxl/f16`, `qwen-3.6-35b-a3b q8/high`,
`gemma-4-12b 2slot`. The benchmark mode is not a model parameter: it
belongs to the task word, `simulator(mendel-guided)`.

When two publishers ship the same quant name for one model, the quant
name alone is not a build tag. Add the publisher's own prefix from the
file name until the tags differ: `ad-iq3s` and `gsq-iq3s`, not `iq3s`
twice. One model can carry several builds at once, so a tag that
collides names two different sets of weights and makes every number on
the line unreadable.

### The task word comes first

A short line opens with the task, not with the model, because the
reader scans for what is happening before which model it happened to.
The task words are fixed: `creep`, `evalplus`, `simulator(<suite>-<mode>)`,
`watcher`, `gate`. A smoke is not a task word: it is the prefix
`smoke:` in front of any of them.

### `ctx` is the largest context that matters right now

A creep is looking for that number, so its `ctx` is the bound under
test: the configured one while the sweep runs, the measured ceiling at
close. A simulator line already knows the bound, so `ctx 62k/82k` is
how much of it the run has used. Never write `-c` in a status line:
that is how a server was loaded, not the number the reader wants.

### Numbers are human readable

Every context, depth and token count in a status line is the rounded
`k` form: `128k`, not `131072`; `49k`, not `49152`; `3k/8k`, not
`3186/8192`. The reader compares sizes at a glance and seven digits do
not compare at a glance. Below 1000, print the raw number (`820
tokens`), because `0k` says nothing.

Exact token counts still belong in `results.md`, in `state.md` and in
a config note. A ceiling is exact and `-c 49152` is a command. A short
line reports; those files record.

### The delta rule

A progress line for a growing test prints only what is new since the
last line. The first line of a creep gives the rows it has. Every line
after it gives only the rows that landed since.

- first line: `14k @ 10 t/s, 20k @ 9.9 t/s`
- next line: `32k @ 9.8 t/s`

The same rule holds for a problem count, a task count, and a nudge
count: print the new number and the total, never the whole history
again.

A creep progress line shows **at most four steps**. The first and the
last are mandatory; `...` stands for everything suppressed between
them.

The rule reverses at close. A close line prints every step, because it
is the result.

## The lines

Five lines, and nothing else goes to chat. Three are the tick, sent at
every wakeup; two are sent unasked when they happen. A run start, a
block start and a block close are not status: the runbook already says
what runs next, and `state.md` carries the rest.

### creep

```
creep qwen-3.8-27b q3kxl/f16 ctx 128k: 4k @ 14.4 → ... → 32k @ 12.1 → 41k @ 10.9 → 49k @ 12.5 tok/s, wired 24.5GB. still running.
creep gemma-4-12b 2slot ctx 256k: 4k @ 48.2 → ... → 98k @ 31.7 → 114k @ 29.4 tok/s, wired 21.8GB. still running.
creep gemma-4-12b 2slot ctx 256k: A@49k@18.63 → B@49k@18.63 → A@66k@17.02 tok/s, wired 21.8GB. still running.
```

At most four steps, first and last mandatory, `...` for the rest. The
last field is the state: `still running`, or the stop reason.

A round-robin creep sweeps two or more slots, so it reaches the same
depth once per slot. Prefix every step with its slot letter, the letter
the creep tool prints in its `context` column: `A@49k@18.63 →
B@49k@18.63`. Without the letter, two steps at one depth read as a
repeat or as a mistake.

The close prints every step, the verdict and the ceiling:

```
creep gemma-26b-a4b f16 ctx 128k close: 61.3 → 65.0 → 56.7 → 52.7 → 46.5 → 41.0 → 36.2 → 33.3 → 28.7 → 26.3 tok/s (4k→114k), wired flat 23.2GB. window: hit the ctx boundary at 128k (HTTP 400, not OOM). Ceiling 114k @ 26.3 tok/s.
```

A verdict is `mem`, `speed` or `window`.

### evalplus

```
evalplus qwen-3.8-27b q3kxl/f16: 42/164 problems, 0 empty. still running.
evalplus qwen-3.8-27b q3kxl/f16: 126/164 problems, 2 empty, ~2h19min left.
evalplus qwen-3.8-27b q3kxl/f16: 164/164 problems, 2 empty. scoring.
evalplus qwen-3.8-27b q3kxl/f16 close: 0.976/0.927/100%, 2/164 empty, budget 8k.
evalplus gemma-26b-a4b f16 close: 0.939/0.884/98.8%, 2/164 empty, budget 8k.
```

Say "ETA too early" instead of a guess when only one completion has
landed.

### simulator

```
simulator(mendel-guided) qwen-3.6-35b-a3b q8/high: 1/8 tasks, ctx 24k/82k, nudges 0/10, ~20 min. still running.
simulator(mendel-guided) qwen-3.6-35b-a3b q8/high: 6/8 tasks, ctx 78k/82k, nudges 2/10, ~210 min. 2 compactions.
simulator(mendel-guided) qwen-3.6-35b-a3b q8/high close: 62.5/100, 8/8 tasks. Worst defect: minor.
simulator(mendel-blind) qwen-3.8-27b q4km/f16/medium close: 31.5/100, partial 3/8 tasks, stopped on wall_clock. Worst defect: critical.
```

The suite and the mode live in the task word, so a second suite lands
as `simulator(swebench-guided)` and nothing else changes. A close
always carries the tasks done, and a partial always carries the word
`partial` and the stop reason. Count the known events — failed tool
calls, nudges, stalls — never describe them.

### smoke: any of the three

A smoke is not its own line. It is the prefix `smoke:` in front of the
line the same task would send, and it marks the line as never
publishable. Two fields change: the denominators are the smoke's own,
and the score slot carries a verdict, because a smoke has no score.

```
smoke: evalplus qwen-3.8-27b q3kxl/f16: 4/4 problems, 0 empty, 3k/8k tokens. level.
smoke: evalplus qwen-3.8-27b iq3s/f16: 2/4 problems, 2 empty, 8k/8k tokens. worse.
smoke: simulator(mendel-guided) qwen-3.8-27b q3kxl/f16: 8 calls, 1 commit, clean, 62s. pass.
smoke: simulator(mendel-guided) qwen-3.8-27b iq3s/f16: 0 commits, 5 identical calls, cap hit. fail: repetition_loop.
```

An EvalPlus smoke's verdict is `level`, `better`, `worse` or `no
verdict`, against the row we serve today. A simulator smoke's verdict
is `pass` or `fail: <reason>`.

### watcher, sent unasked

```
watcher qwen-3.6-35b-a3b q8/f16: sweep stopped at depth 65k, swap grew 162MB. mem verdict. Ceiling is the last clean row, 49k @ 27.7 tok/s.
```

A restart says what changed, then the new value and why.

### gate, sent unasked

```
gate qwen-3.8-27b iq3s/f16 dropped: creep clean depth 31k, under the 39k floor. Its EvalPlus and simulator smokes are skipped.
```

A dropped config never reaches the site. If it was published before,
its row moves to `historical.md`.

## The medium form, in `state.md`

The evidence behind a chat line goes to `state.md`, never to chat. The
runner never pastes a table or a log excerpt into chat; it names the
file.

Every medium entry has the same four parts:

1. **The heading**: the task, the model short id, the variant, and the
   `ctx`. While the thing still runs, the heading ends with
   `— running`.
2. **One identity line**: what a reader needs to reproduce the run.
   The file and its revision, the flags that differ, the KV type, the
   wired limit, the tool or harness values, and the times.
3. **One table.** A value that is not known yet is `-`, never blank
   and never a guess.
4. **The close**: the verdict or state, the files, and the deviations.
   Write `Deviation: none` rather than leaving it out.

A count that grows is written as it happens, not at the end. Count the
known events — failed tool calls, nudges, stalls — and never describe
them here.

### creep

A creep table carries the measured rows, then one `...` row, then the
target depth with `-` cells. The target is the largest depth the creep
is configured to reach. When the target is the next step, the `...`
row is left out.

### creep qwen-3.8-27b q3kxl/f16 ctx 128k — running

`unsloth/Qwen3.8-27B-GGUF:UD-Q3_K_XL` rev `4ca7207`, MTP n-max 3, one slot, f16 KV, wired 25000. Tool `2344f00`. Ladder: 131072 served, 139264 failed. Started 21:14, last row 22:02.

| depth | tok/s | wired MB | swap Δ | compress | decompress |
|--:|--:|--:|--:|--:|--:|
| 4k | 14.4 | 24831 | 0 | 12 | 0 |
| 8k | 14.1 | 24847 | 0 | 8 | 0 |
| 16k | 12.2 | 24902 | 0 | 41 | 0 |
| 24k | 13.0 | 24955 | 0 | 18 | 0 |
| 32k | 12.1 | 25010 | 0 | 96 | 0 |
| ... | | | | | |
| 128k | - | - | - | - | - |

still running, next depth 41k. No stop condition met.
Files: `results/creep-qwen38-unsloth-q3kxl-f16.tsv`, `results/server-qwen38-unsloth-q3kxl-f16.log`.
Deviation: none.

At close the table holds every measured row, with no `...` row and no
target row:

### creep qwen-3.8-27b q3kxl/f16 ctx 128k

`unsloth/Qwen3.8-27B-GGUF:UD-Q3_K_XL` rev `4ca7207`, MTP n-max 3, one slot, f16 KV, wired 25000. Tool `2344f00`. Ladder: 131072 served, 139264 failed.

| depth | tok/s | wired MB | swap Δ | compress | decompress |
|--:|--:|--:|--:|--:|--:|
| 4k | 14.4 | 24831 | 0 | 12 | 0 |
| 8k | 14.1 | 24847 | 0 | 8 | 0 |
| 16k | 12.2 | 24902 | 0 | 41 | 0 |
| 24k | 13.0 | 24955 | 0 | 18 | 0 |
| 32k | 12.1 | 25010 | 0 | 96 | 0 |
| 41k | 10.9 | 25088 | 0 | 210 | 0 |
| 49k | 12.5 | 25140 | 0 | 154 | 0 |

**speed**, ceiling 49k @ 12.5 tok/s. Floor reached at 57k (7.4 tok/s).
Files: `results/creep-qwen38-unsloth-q3kxl-f16.tsv`, `results/server-qwen38-unsloth-q3kxl-f16.log`.
Deviation: none.

The compress and decompress columns stay even when they read near
zero. Their being near zero is the evidence that a stop was speed and
not memory.

### evalplus

### evalplus qwen-3.8-27b q3kxl/f16 — running

`unsloth/Qwen3.8-27B-GGUF:UD-Q3_K_XL` rev `4ca7207`, MTP n-max 3, one slot, f16 KV, ctx 49k, wired 25000. Budget 8k from `calibration-qwen38-gguf-medium.json`. Started 22:40, last problem 23:55.

| metric | value |
|---|--:|
| problems | 126/164 |
| empty so far | 2 |
| HumanEval base | - |
| HumanEval plus | - |
| completion rate | - |

still running, ~2h19min left. Last `task_id` `HumanEval/131`.
Files: `results/evalplus-qwen38-unsloth-q3kxl-f16/`, `results/server-qwen38-unsloth-q3kxl-f16.log`.
Deviation: none.

The scores stay `-` until the evaluator runs, because EvalPlus scores
the whole set at the end. A running average is a number a reader can
mistake for a result. At close:

### evalplus qwen-3.8-27b q3kxl/f16

`unsloth/Qwen3.8-27B-GGUF:UD-Q3_K_XL` rev `4ca7207`, MTP n-max 3, one slot, f16 KV, ctx 49k, wired 25000. Budget 8k from `calibration-qwen38-gguf-medium.json` (max completion 1049 → max(1049×1.5, 8192)).

| metric | value |
|---|--:|
| HumanEval base | 0.976 |
| HumanEval plus | 0.927 |
| completion rate | 100% |
| empty | 2/164 |

Empty: `HumanEval/129`, `HumanEval/132`. Both hit the budget at 8192 tokens, so the cause is length, not refusal.
Files: `results/evalplus-qwen38-unsloth-q3kxl-f16/`, `results/server-qwen38-unsloth-q3kxl-f16.log`.
Deviation: none.

An empty completion is always listed by `task_id` with its cause.

### simulator

### simulator(mendel-guided) qwen-3.6-35b-a3b q8/high — running

`unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` rev `5bc3e23`, MTP n-max 3, one slot, q8_0 KV, ctx 98k served, wired 25000. Harness: window 82k, reserve 8192, keep-recent 20000. Branch `qwen3.6-35b-a3b-high-guided-v3-issue-13`. Started 19:20, last event 22:50.

| field | value |
|---|--:|
| score | - |
| tasks | 6/8 |
| worst defect | - |
| stop reason | - |
| tool calls | 168 |
| peak ctx | 78k/82k |
| known events | 4 |
| elapsed | 210 min |

still running, task 7 of 8. Known events: 2 nudges, 2 compactions.
Files: `results/mendel-qwen36-q8-guided-high.jsonl`, session log `results/session-qwen36-q8-guided-high.log`.
Deviation: none.

Score and worst defect stay `-` until scoring runs, which happens
after the run ends. `peak ctx` carries a value from the first task
onward. At close:

### simulator(mendel-guided) qwen-3.6-35b-a3b q8/high

`unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL` rev `5bc3e23`, MTP n-max 3, one slot, q8_0 KV, ctx 98k served, wired 25000. Harness: window 82k, reserve 8192, keep-recent 20000. Branch `qwen3.6-35b-a3b-high-guided-v3-issue-13`.

| field | value |
|---|--:|
| score | 62.5/100 |
| tasks | 8/8 |
| worst defect | minor |
| stop reason | completed |
| tool calls | 214 |
| peak ctx | 78k/82k |
| known events | 4 |
| elapsed | 254 min |

Known events: 2 nudges, 2 compactions. Compactions at task 5 and task 7, each freeing 1 to 8 points of the window.
Files: `results/mendel-qwen36-q8-guided-high.jsonl`, session log `results/session-qwen36-q8-guided-high.log`.
Deviation: none.

## The site comparison, in full

The large form compares **runs**, not table cells. The site table is
only the format: its header and its columns. The data in an old row is
the measurement this run replaces, on the same model and the same
configuration, or the nearest one. A cell the site carried by a rule
(a score copied from another build, a curve copied from a sibling
row) is not a measurement: it is shown, marked as a copy, and the pair
is the run that measured it.

One table per task, then the words:

1. **Quality table**: every EvalPlus change, in the site's comparison
   columns.
2. **Speed and context table**: every depth curve, ceiling, or memory
   change, same columns.
3. **Mendel table**: every agent row, in the site's Mendel columns.
4. **Gates table**: every smoke and every gate decision, one line each.
5. **Items** for the events and the details.

A table with no rows is left out. Not a table per model, and not a
table per change.

### The rows and the pairs

- Every table has an `old/new` column first. `old` is the run that
  measured the value being replaced; `new` is this run. The old row
  keeps the site's `#` where it has one. The new row carries `—`,
  because the number belongs to `models.json` and the coordinator
  writes it there.
- Bold only the cells that moved.
- **The pair is the same model, the same configuration or the nearest
  one, on the same task.** A new EvalPlus score pairs with the run that
  measured the score it replaces, not with the row that displayed it.
  A new thinking-off score pairs with the thinking-on run of the same
  build. A new backend pairs with the run on the other backend of the
  same model. A new curve pairs with the previous creep of the same
  config.
- **A carried cell is marked.** When the old value was a copy, write
  `(<source> copy)` after it, for example `0.713/0.701/72% (MLX copy)`,
  and pair with the run that measured it. The note says so once.
- A result the run has not finished still gets its row, with `—` in
  the cells it does not have and its state in the note.
- **No code fences around a table.** Claude Code renders a bare
  markdown table; a fenced one shows raw pipes. The same bare table
  goes into `results.md` and `state.md`. Fences are for commands and
  log excerpts only.

### The Mendel table

The site's local blind block is `model | serving | score | worst
defect`; the guided block is `model | harness | score`. One table,
`old/new` first and a `test` column when the run changed both blind
and guided rows. The old row is the run's previous scored row on the
same model, the same test and the nearest configuration. An invalid
row is never an old row and never a new row. A model with no scored
row of its own pairs with the row it replaces, or with the nearest
scored local row, and the note says which.

### The gates table

`old/new | gate | model | config | result | verdict`. One line per
smoke (EvalPlus smoke, Mendel smoke) and per gate decision (a config
dropped, a threshold passed). The old row is the same smoke on the
config the run compares against, when there is one. A smoke never
reaches the site, so this table lives in `results.md` and in chat
only.

### The worked example

Run 10, as of 2026-09-06, the blocks that changed a published number.

Quality:

| old/new | # | Config | Max ctx | Gated by | tok/s (shallow → deep) | Memory | EvalPlus |
|---|--:|---|--:|:--:|--:|--:|--:|
| old | 16 | Gemma-4-26B-A4B, MLX, thinking on | 70k | mem | 51 → 12.8 | 20.0 GB | 0.713/0.701/72% |
| new | — | Gemma-4-26B-A4B, GGUF, MTP f16, thinking on | 197k | mem | 60.3 → 17.3 | 25.6 GB | **0.884/0.860/89%** |
| old | — | Gemma-4-26B-A4B, GGUF, MTP f16, thinking on (this run) | 197k | mem | 60.3 → 17.3 | 25.6 GB | 0.884/0.860/89% |
| new | — | Gemma-4-26B-A4B, GGUF, MTP f16, thinking off | 197k | mem | 60.3 → 17.3 | 25.6 GB | **0.976/0.945/100%** |
| old | 8 | Qwen3.6-35B-A3B, GGUF, MTP q8, thinking on | 8k | mem | 36.4 → 43.8 | 25.0 GB | 0.939/0.921/97% |
| new | — | Qwen3.6-35B-A3B, GGUF, MTP q8, thinking off | 8k | mem | 36.4 → 43.8 | 25.0 GB | **0.951/0.915/100%** |

Speed and context (run 9, shown for the shape):

| old/new | # | Config | Max ctx | Gated by | tok/s (shallow → deep) | Memory | EvalPlus |
|---|--:|---|--:|:--:|--:|--:|--:|
| old | 13 | Gemma-4-26B-A4B, GGUF, MTP q8 | 24k | speed | 23.5 → 8 | 15.4 GB | 0.713/0.701/72% (MLX copy) |
| new | — | Gemma-4-26B-A4B, GGUF, MTP f16 | **197k** | **mem** | **60.3 → 17.3** | **25.6 GB** | 0.713/0.701/72% (MLX copy) |

Mendel:

| old/new | test | model | serving | score | worst defect |
|---|---|---|---|--:|---|
| old | blind | Qwen3.8-27B (mlx, medium) | mlx_lm.server | 80/100 (partial 3/8) | medium |
| new | blind | qwen3.8-27b, GGUF f16 -c 49152, medium | llama-server | **87/100** 8/8 | minor |
| old | blind | gemma-4-26b-a4b, GGUF q8_0 (prompt v1.0) | llama-server | 38/100 (partial) | critical |
| new | blind | gemma-4-26b-a4b, GGUF f16 -c 212992, high | llama-server | **47.5/100** 8/8 | critical |
| old | guided | Ternary-Bonsai-27B-mlx-2bit, low | mlx_lm.server | 59/100 (partial 1/8) | minor |
| new | guided | Ternary-Bonsai-27B-mlx-2bit, off | mlx_lm.server | — | — |

Gates:

| old/new | gate | model | config | result | verdict |
|---|---|---|---|---|---|
| new | mendel smoke | qwen3.8-27b | GGUF f16, medium | 8 calls, 1 commit, no loop, 62 s | pass |
| new | evalplus threshold | gemma-4-26b-a4b | GGUF f16, thinking on | base 0.884 against 0.800 | pass, on to Mendel |
| new | mendel smoke | gemma-4-26b-a4b | GGUF f16, high | 11 calls, 1 commit, no loop, 31 s | pass |
| new | mendel smoke | bonsai-27b | MLX, off | 14 calls, 1 commit, no loop, 115 s | pass |

- **Gemma-26B, thinking on.** The old score was measured on the MLX
  build (2026-08-29) and carried to the GGUF rows by the shared-score
  rule; this run scored the GGUF quant itself. The two builds no longer
  share a score.
- **Gemma-26B, thinking off.** No earlier thinking-off run exists, so
  the pair is this run's own thinking-on score of the same build.
- **Qwen3.6, thinking off.** The pair is the thinking-on run of the
  same build (2026-08-29). Base up, plus down, the five empties gone.
- **Qwen3.8 blind.** The pair is the same model's last blind run at the
  same effort, on the MLX build (run 7, partial on a server failure).
  **87/100** 8/8, no bug defect.
- **Gemma-26B blind.** The pair is the same model's earlier blind run
  at q8_0 on the previous prompt version. **47.5/100** 8/8, one critical
  trap hit.
- **Bonsai guided.** The thinking-off attempt went invalid on a harness
  fault (a dead `gh` token, a login loop). Invalid rows are neither old
  nor new; the retry runs and its row lands when it closes.

The runner drafts all of this. It never edits `models.json`; that is
the coordinator's publish step (`EDITOR.md` at the repo root, the
generated-block rules).

The owner asks for this form by name: "draw me the new line, similar to
the one on the website, updated for Qwen3.8 new numbers on llama,
please. Also include other models you found the definitive ceiling so
far." (`f55b29c3`, 2026-09-05). And: "Please compare Gemma-4-26B-A4B
new numbers/decisions with what is published (comparison table)"
(`f55b29c3`, 2026-09-05). When the details get dense, they become their
own table: "Hard to read in prose, please make it a full table
before/after/comments columns." (`3f1b158c`, 2026-08-31).

## Context budget

A run consumes the runner's context. These four rules keep it small.

1. **The wakeup cadence is 20 minutes or more, never less.** Do not
   shorten it to watch a step land. A shorter cadence buys nothing and
   costs the owner one turn and its tokens every time
   ([checklist](./checklist.md), step 7). When a block is long and
   quiet, a longer gap is better, not worse.
2. **A background monitor reports on an event, never on a timer.** It
   exits 42 with the reason on stdout when the thing it watches dies or
   finishes. It prints one event line. It does not poll the agent, and
   the agent does not poll it.
3. **A heartbeat is one short line.** One line, numbers, and the next
   check time. No narration of routine steps.
4. **The runner never pastes a table or a log excerpt into chat.** It
   names the file. The owner reads the file, or asks for the table.
   The one exception is a table the owner asks for by name.

The owner set rules 3 and 4 in one message: "Lets save on your own
context. Be more quiet. I don't want to have to compact your context,
and we have more items still. one liners moving forward." (`a9ea8cc1`,
2026-09-04).
