# Status lines

A benchmark run reports to the owner. It reports in chat while the run
goes, in `state.md` when a block closes, and in `results.md` and on the
site when a number becomes public. This page gives one template per
update type, in three sizes, so no runner has to invent a format again.

Every example below is a real line from a run session. The session file
and the date follow each quote.

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
context, not only the new result: the run, the block, the model short
id, and the config being changed. The owner said it directly:
"statusline shoudl repeat model/want/etc not only results, otherwise it
is not reasable for me, when I get back and read only one line"
(`4f614267`, 2026-09-05). And, on the same run: "Report status lines
that name run/block/model/config." (`4f614267`, 2026-09-05).

So the frame of every short line is:

`run <N>, block <n>/<N> <intent>: <model short id> <changed params> — <the numbers>. <next step or next check>.`

The templates below give the part after the colon. The frame in front
of it is always there.

## The naming rules

### Blocks

Name a block by its number and the count, not by a letter and not by a
step word. Write `block 3/8`. Do not write `Step A`, `Step 1`, or
`Block A1b`. All blocks are the same type of thing, so the number is
enough.

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

After the model id, name only the parameters this update changes. Write
`qwen-3.8-27b f16 -c 49152`, not the whole serving command.

### The delta rule

A progress line for a growing test prints only what is new since the
last line. The first line of a creep gives the rows it has. Every line
after it gives only the rows that landed since.

- first line: `14k @ 10 t/s, 20k @ 9.9 t/s`
- next line: `32k @ 9.8 t/s`

The same rule holds for a problem count, a task count, and a nudge
count: print the new number and the total, never the whole history
again.

The rule reverses at close. A close line prints the whole curve,
because it is the result.

## Templates

### Run start

- **short**: `run <N> start: <M> blocks, first is <what>. <machine state in one clause>.`
- **medium**: the short line, then one line per queued block: intent,
  model short id, and `queued`.
- **large**: none. A run start publishes nothing.

The owner's own words on the medium form: "I want the intention of the
model (speed, evalplus, etc), the model, the results or if it is
running or queued. One line per item, ok if line is a bit long and
wraps, but no paragraph." (`f55b29c3`, 2026-09-05).

### Block start

- **short**: `block <n>/<N> <intent>: <model short id> <changed params>. <first observation>.`
- **medium**: the short line, plus the exact serving command, the
  output file, and what "done" means for this block.
- **large**: none.

Real short line: "Gemma-26B f16 sweep started, wired 19809 MB. Next
check in 16 min." (`f55b29c3`, 2026-09-04). A block start always says
the memory the config starts at, because that number decides whether
the block can finish.

### Creep progress

- **short**: `<model short id> <kv> <-c>: <new depth> @ <tok/s>, wired <GB>. <no stop | stop reason>.`
  Only the new rows. See the delta rule.
- **medium**: every row so far as a table (depth, tok/s, wired_mb,
  swap, compress/decompress pages), then the stop state.
- **large**: none until the creep closes.

The owner asked for this shape twice, in the same words both times:
"You are not giving me relevant numbers, partial results at the status
line. For example, tok/s progression since the last run. Like 22.1
tok/s at 10k, 22.0 at 16k, etc. any other relevant numbers, mem is good
too." (`f55b29c3`, 2026-09-04). Then, after a line that gave none: "I
was expecting status such as 'Gemma-26B q8_0: 24.9 tok/s at 4K → 17.1
at 8K → 10.2 at 16K → 8.1 at 24K'" (`f55b29c3`, 2026-09-04).

The line the owner asked for, as the runner then wrote it:

> Qwen3.8 q8_0: 16.7 tok/s at 4K → 13.1 at 8K → 9.4 at 16K → 8.5 at
> 24K → 7.1 at 32K, wired ~21.6-21.7 GB throughout. Speed stop, under 8
> tok/s floor at 32818. Starting f16 arm now.

(`f55b29c3`, 2026-09-04.)

### Creep close, with the verdict

- **short**: the whole curve with arrows, then `<verdict>` and the
  ceiling row. `mem`, `speed`, or `window`, and what gated it.
- **medium**: the full table, the verdict, the published `-c` against
  the `-c` actually used, and the OOM evidence for every `-c` that
  failed.
- **large**: the site comparison rows (see below).

Real short close: "Gemma-26B f16 @ -c131072: 61.3→65.0→56.7→52.7→46.5→41.0→36.2→33.3→28.7→26.3 tok/s (4K→114K), wired flat ~23.2GB. Hit the `-c` boundary at 131072 (HTTP 400, not OOM), not a memory stop." (`f55b29c3`, 2026-09-04).

A short close may drop the "at NK" on every step and give the range
once at the end, as that line does. Use the arrow form only at close,
never for progress: progress uses the delta rule.

### KV pick

- **short**: `<model short id>: <pick> picked (<A> vs <B> tok/s at <depth>). <commit>.`
- **medium**: both arms as tables, the rule that decided, and the
  `-c` each arm loads at.
- **large**: the comparison rows, because the pick changes the
  published config.

Real short line: "Qwen3.8: f16 picked (16.4 vs 7.1 tok/s at 32K).
Committed `9c132af`. Starting Gemma-26B q8_0 arm now."
(`f55b29c3`, 2026-09-04).

### EvalPlus calibration

- **short**: `<model short id> calibration: max completion <N> tokens → budget <B> (<which rule won>).`
- **medium**: the calibration file, the observed maximum, the rule,
  and whether the calibration converged.
- **large**: none.

Real short line: "Max completion 1049 tokens → budget = max(1049×1.5,
8192 floor) = 8192. Starting memory watcher and the EvalPlus run."
(`f55b29c3`, 2026-09-04).

### EvalPlus progress

- **short**: `<model short id>: <done>/164 problems.` Nothing else.
- **medium**: the count, the last `task_id`, the empty count so far,
  and the memory watcher's last line.
- **large**: none.

Real short line: "117/164 problems done. Next check in 15 min."
(`f55b29c3`, 2026-09-04).

When a pace exists, add it: "Block 4: done 126/164, ~2h19min left.
Healthy. Next check in 20 minutes." The checklist keeps this as the
heartbeat form (`checklist.md`, step 9). Say "ETA too early" instead of
a guess when only one completion has landed.

### EvalPlus close

- **short**: `<model short id> <config>: <base>/<plus>, <empty>/164 empty, budget <B>.`
- **medium**: the score, the empty count with its cause, the budget and
  the calibration it came from, and the result directory.
- **large**: the comparison rows.

### Mendel smoke

- **short**: `<model short id> smoke <a|b>: <passed>/4 passed, <empty> empty, <tokens>/<budget>. <verdict>.`
- **medium**: every `SMOKE` line as a block, the self-check pair, and
  the verdict with its reasoning.
- **large**: none. A smoke is never published.

Real short line: "Qwen3.8 q8_0: 4/4 passed, 0 empty, 3186/8192 tokens
used. All three runs (f16-a, f16-b, q8) show 0 empties comfortably
under budget — no calibration-budget artifact possible here. Verdict:
LEVEL." (`f55b29c3`, 2026-09-05).

A verdict is one of `level`, `better`, `worse`, or `no verdict`.

### Mendel run progress

- **short**: `<model short id> <mode>: <x>/8 tasks, prompt at <N>k/<cap>, nudges <u>/<max>, ~<t> min elapsed.`
- **medium**: the short line, plus the last runner-log event and
  whether real tool work happened between nudges.
- **large**: none until the run closes.

The owner wrote the short template themselves: "Status line: 'X/8
tasks done, prompt at NK/26624, processes alive Y/N, ~Z min elapsed'."
(`f55b29c3`, 2026-09-05). The runner's line: "6/10 tooling nudges, 0/8
tasks, likely heading toward `tooling_budget_exhausted` within the
hour. Next check in 20 min." (`f55b29c3`, 2026-09-05).

The medium form is fixed. The owner wrote its four fields
(`48960eb2`, 2026-09-02): "done/total items, pending item description,
done/total sub-items for the current pending item, known events count."
The first answer added prose and parentheses, and the owner rejected
it: "You didn't get it. 100% of what I said id about the model. No
parens, no explanation. It is just progress/status for the model."
(`48960eb2`, 2026-09-02). The corrected form ran the whole night:

> **Progress**
> - Items: 8/8
> - Pending item: none unchecked
> - Sub-items: 0/0
> - Known events: 0

Known events are the failed tool calls, the nudges, and the stalls.
Count them; do not describe them here. A Mendel run has no X/Y problem
count, so the commit count and the elapsed time are the progress proxy
(`b4b8f2c7`, 2026-08-30).

### Mendel run close, with the row

- **short**: the score and the worst defect, in one line.
- **medium**: the score, the stop reason, the tool-call and
  peak-context counts, and the session log path.
- **large**: the site Mendel row, published row first, new row under
  it:

```
| model | serving | score | worst defect |
|---|---|--:|---|
| qwen-3.6-35b-a3b | llama-server | **63/100** | critical |     <- published
| qwen-3.8-27b | mlx_lm.server | **12.5/100** (partial) | minor |  <- new
```

A partial always carries the word `(partial)` and the stop reason.

### Watcher event

- **short**: `<what died> at <when>: <the death signature>. <what the run does next>.`
- **medium**: the watcher's exit line, the server log lines that carry
  the signature, and the state of the output file at the moment of
  death.
- **large**: none.

A watcher event is the one status line the runner writes without being
asked. Real form: "A1 sweep stopped: swap grew 162MB at depth 65578 — a
**mem** verdict. Ceiling is the last clean row: depth 49198 at 27.65
tok/s." (`4f614267`, 2026-09-05).

A restart says what changed: "`-c 688128` OOMs under real decode load
at depth 4096, even though it loaded and passed a trivial warmup."
(`4f614267`, 2026-09-05). Then the new value and why.

### Gate decision, a config dropped

- **short**: `<model short id> <config> dropped: <the test it failed>, <the number>. <what runs instead>.`
- **medium**: the failing evidence quoted from the log, the rule that
  the drop follows, and what the run keeps.
- **large**: none. A dropped config never reaches the site; if it was
  published before, the large form is the row moving to `historical.md`.

Real short line: "Qwen3.6-35B-A3B GGUF: q8_0 arm reached a memory stop
at depth 32818 (19.63 tok/s, wired ~25.0GB). f16 arm OOM'd at model
load — every completion returned 500 'Compute error' with 'Insufficient
Memory' in the log before any request, so it can't serve at `-c 40960`
at all. Pick: q8_0 (rule 6 — f16 doesn't fit)." (`f55b29c3`,
2026-09-04).

### Block close

- **short**: `block <n>/<N> closed: <the one-clause result>. <commit>. Starting block <n+1>/<N>, <what>.`
- **medium**: goes to `state.md`. The block's result table, the
  deviations as they happened, and the files written.
- **large**: only if the block produced a publishable number.

Real short line: "Block A1 closed: Qwen3.6=q8_0, Qwen3.8=f16,
Gemma-26B=f16. Committed `c5cd928`. Starting block A1b — full creep on
Qwen3.6 (q8_0) first." (`f55b29c3`, 2026-09-04). Written to today's
rule it would open `block 1/8 closed:`.

### Run close, and the handing-over pointer

- **short**: `run <N> closed: <M> blocks done, <K> deferred to run <N+1>. Merged to master at <commit>. Handing over: benchmarks/bench<N>/state.md.`
- **medium**: one line per block in the owner's summary form: intent,
  model short id, and the result or `running` or `queued`. No block
  letters, no paragraphs. Group the lines under `Done`, `In progress`
  and `Pending`; the owner accepted that grouping unchanged
  (`1fe3727e`, 2026-09-02). Group scores by test mode, blind and
  guided kept apart (`1fe3727e`, 2026-09-02).
- **large**: the full comparison, every changed row.

The owner's rule for the medium form, in their words: "I don't want the
refernces (A, B, B1, etc). I want the intention of the model (speed,
evalplus, etc), the model, the results or if it is running or queued.
One line per item, ok if line is a bit long and wraps, but no
paragraph." (`f55b29c3`, 2026-09-05). The runner's answer to it:

> - Qwen3.8-27B GGUF, KV-cache type pick (speed/memory): f16 chosen —
>   beats q8_0 more than 2x at depth; real hardware ceiling found at
>   49152 context (larger `-c` values all OOM), 14.98 tok/s there

## The site comparison, in full

The large form is three parts, always in this order:

1. **One comparison table** with every model the run changed.
2. **One Mendel table**, in the shape the site uses.
3. **Items or short prose** for the events and the details.

Two tables, then the words. Not a table for each model, and not a table
for each change.

### The comparison table

One table for the whole run. Each published row comes first, and its
new row follows it at once. The header is the published one, copied
without change from `docs/setups/<setup>/comparison.md`.

- The published row keeps its `#`. The new row carries `—`, because the
  number belongs to `models.json` and the coordinator writes it there.
- Bold only the cells that moved.
- A new row with no exact published match pairs with the closest
  published row. The note under the table says which row it picked and
  why. A new thinking-off row pairs with the model's thinking-on row. A
  new backend pairs with the same model on the other backend.
- A result the run has not finished still gets its row, with `—` in the
  cells it does not have and its state in the note.

### The Mendel table

One table, in the shape of the site block the change belongs to
(`docs/setups/<setup>/benchmarks/mendel.md`). The local blind block is
`model | serving | score | worst defect`. The guided block is
`model | harness | score`. Pair the rows the same way: the published
row, then its new row. When one run changed both a blind and a guided
row, add a `test` column and keep one table.

A model the site has never scored pairs with the row it replaces, or
with the nearest published local row. The note says which.

### The worked example

Run 10, as of 2026-09-06. Three EvalPlus scores and three Mendel rows
changed.

```
| # | Config | Max ctx | Gated by | tok/s<br>(shallow → deep) | Memory<br>(at max ctx) | EvalPlus |
|--:|---|--:|:--:|--:|--:|--:|
| 14 | Gemma-4-26B-A4B, GGUF, MTP f16 | 197k | mem | 60.3 → 17.3 | 25.6 GB | 0.713/0.701 |
| —  | Gemma-4-26B-A4B, GGUF, MTP f16, thinking on | 197k | mem | 60.3 → 17.3 | 25.6 GB | **0.884/0.860** |
| 14 | Gemma-4-26B-A4B, GGUF, MTP f16 | 197k | mem | 60.3 → 17.3 | 25.6 GB | 0.713/0.701 |
| —  | Gemma-4-26B-A4B, GGUF, MTP f16, thinking off | 197k | mem | 60.3 → 17.3 | 25.6 GB | **0.976/0.945** |
| 8  | Qwen3.6-35B-A3B, GGUF, MTP q8, thinking on | 8k | mem | 36.4 → 43.8 | 25.0 GB | 0.939/0.921 |
| —  | Qwen3.6-35B-A3B, GGUF, MTP q8, thinking off | 8k | mem | 36.4 → 43.8 | 25.0 GB | **0.951/0.915** |
```

```
| test | model | serving | score | worst defect |
|---|---|---|--:|---|
| blind | Qwen3.8-27B (mlx, low) | mlx_lm.server | **12.5/100** (partial) | minor |
| blind | qwen3.8-27b | llama-server | **87/100** | minor |
| blind | qwen3.6-35b-a3b | llama-server | **63/100** | critical |
| blind | gemma-4-26b-a4b | llama-server | **47.5/100** | critical |
| guided | Ternary-Bonsai-27B-mlx-2bit | pi | **12.5/100** (partial) | — |
| guided | Ternary-Bonsai-27B-mlx-2bit | pi | — | — |
```

- **Gemma-26B, thinking on**: an exact pair. Row 14 carried
  0.713/0.701, copied from the MLX row. This run scored the GGUF quant
  itself for the first time, and the score rises to 0.884/0.860.
- **Gemma-26B, thinking off**: the site has no thinking-off row for
  this model, so the pair is row 14, its thinking-on row. Thinking off
  scores higher, 0.976/0.945.
- **Qwen3.6, thinking off**: the same case. The pair is row 8, the
  published thinking-on row. 0.951/0.915: up on base, down on plus.
- **Qwen3.8 blind Mendel**: the site has no llama-server row for this
  model, so the pair is the published MLX low row, the only Qwen3.8
  Mendel row there is. 87/100 against 12.5/100 partial. The MLX row
  stopped on a server failure, not on the rubric, so the pair shows the
  backend, not a gain in model quality.
- **Gemma-26B blind Mendel**: the first Mendel row for this model. The
  pair is qwen3.6-35b-a3b on llama-server, the nearest published local
  row. 47.5/100, worst defect critical: trap A, `glob(...).then is not
  a function`.
- **Bonsai guided**: the published 12.5/100 partial stands. The run 10
  retry is still running, so its row carries `—`. Do not publish an
  invalid row, and do not delete the old one. The new row lands when
  the retry closes.

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

1. **The wakeup cadence stays at 20 minutes.** Do not shorten it to
   watch a step land. A shorter cadence buys nothing and costs one
   turn every time ([checklist](./checklist.md), step 7).
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
