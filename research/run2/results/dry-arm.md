# T2.3b — DRY against the collapse (arm 3), interim

Run 2, session 1. Started 2026-09-04 07:59Z, 150-minute wall. Arm 2's
exact configuration plus DRY sampling. Both variables verified on the
live server before the run: `dry_multiplier 0.8`, `dry_base 1.75`,
`dry_allowed_length 2`, `dry_penalty_last_n 2048`, and the pre-fix
template rendering no generation prefix after a tool response.

The window is deliberate. `sampler-defaults.md` showed the default
`dry_penalty_last_n` of 64 tokens is shorter than one tool call, so it
could not see a repeat even in principle. 2048 spans many.

## DRY does not stop the collapse. It changes its shape.

At 40 minutes in, arm 3 emitted a single tool call containing:

- **231 consecutive lines** of the form `ls -d examples/<path>/*`,
  grown to **485** by 09:30Z and still running
- **229 of them distinct** at the first measurement, 663 distinct
  tool-call lines overall
- **231 of 231 with a corrupted path.** Not one is the real
  `examples/planout-example`.

The sequence degrades as it goes:

```
ls -d examples/planout_example/*      <- near miss
ls -d examples/planot_example/*       <- worse
ls -d examples/pl_anout-example/*     <- worse
...
ls -d examples/de-in_southple/*       <- gibberish
ls -d examples/df-in_southple/*
```

The model walks a counter through two-letter prefixes and corrupts the
directory name further at each step.

This is DRY working exactly as specified, and the model routing around
it. DRY penalises repeated token SEQUENCES. Vary one token per line and
the penalty no longer matches — so the model varies one token per line.

**The result is worse output, not better.** Arm 2 repeated a coherent
English sentence 498 times. Arm 3 emits 231 distinct broken shell
commands, every one of which would fail if run.

## It defeated every exact-match detector, including mine

| Detector | Reads arm 3 as |
| --- | --- |
| `count-events.py`, identical tool calls | healthy, longest run 1-2 |
| `measure-collapse.py`, identical lines | **clean, longest run 1** |
| `flood-check.py`, newline runs | clean |
| the live monitor built on them | reported "longest identical consecutive line run: 1" for 40 minutes |

Every one is correct and every one is blind. The collapse sits inside a
single unfinished tool call, in lines that are never identical.

`measure-neardup.py` detects it, but only after a second attempt. A
prefix comparison is not enough: at a 20-character prefix the
incrementing counter still breaks the run, and it reported 10.

What works is a SHAPE comparison — replace every letter run with `W` and
every digit run with `N`, then count identical shapes in a row.
`bk-in_southple` and `bl-in_southple` have the same shape, so a counter
cannot hide behind it. One detector then separates all three arms
cleanly:

| Arm | thinking shape-run | tool-call shape-run | verdict |
| --- | --- | --- | --- |
| 1, post-fix template | 2 | 5 | clean |
| 2, pre-fix template | **498** | 5 | collapse |
| 3, pre-fix + DRY | 7 | **485** | collapse |

Note where each collapse lands. Arm 2 collapsed in its THINKING; arm 3,
with DRY on, collapsed in a TOOL CALL instead. DRY moved the failure
from one channel to the other as well as changing its shape.

## What this means for section I

The coordinator's position was to build the loop stop as a harness STOP
rather than a sampler fix. This supports that, and sharpens the reason:

- A sampler that penalises exact sequences does not remove the failure.
  It **hides** it, by converting a detectable repetition into varied
  corruption.
- Anything measuring "identical calls in a row" gets less reliable once
  DRY is on, not more. `loop-stop.ts` would fire on arm 2 long before it
  fired on arm 3, even though arm 3 is producing worse output.
- So DRY is not a defence to ship. It is an argument for detecting
  collapse by near-duplication or by output quality, not by exact
  repetition.

## Status

Interim. The arm runs to about 10:29Z. Its final counts, and whether it
recovered, go in the closing section.

## The chain, completed at 09:39Z

The collapsed output was not many tool calls. It was **one**.

| Time | Event |
| --- | --- |
| 08:29:26Z | call 37, `ls -d examples/planout-*`, normal, executed |
| 08:29 to 09:39 | **70 minutes generating a single tool call** |
| 09:39:11Z | call 38 emitted: one `bash` command holding 1133 corrupted `ls -d` lines |
| 09:39:11Z | pi **rejects it** |
| 09:41Z | the model is thinking again |

pi's rejection, verbatim:

> Tool call "bash" was not executed: the response hit the output token
> limit, so its arguments may be truncated. Re-issue the tool call with
> complete arguments.

So the call never ran. The model spent 70 minutes producing something
the harness threw away, and was then asked to produce it again.

### How far this goes toward the tool-call loop, and where it stops

Run 1 established that both reproduced loops began with a malformed call
that pi rejected, and that the model then re-emitted the rejected call
unchanged. This arm explains where such a call can come from:

1. The pre-fix chat template gives no generation prefix after a tool
   response, and the model collapses into repetition.
2. With DRY on, the repetition moves into a tool call and varies one
   token per line, so no sampler and no exact-match detector stops it.
3. The call grows past the output token limit.
4. **pi rejects it and asks the model to re-issue it.**

Steps 1 to 4 are measured. **Step 5 did not happen.** The model did not
re-issue. Within three minutes of the rejection it made six varied,
sensible calls:

```
09:42:32  bash  ls -R examples/planout-example
09:43:29  read  examples/planout-example/app_js
09:43:59  bash  ls examples/planout-example
09:44:37  read  examples/planout-example/1app.js
09:45:16  bash  cat examples/planout-example/app.js
09:49:49  bash  ls -R test/
```

The paths are still slightly damaged — `app_js`, `1app.js` — but the
model recovered on its own and kept working.

So this arm does NOT show a rejection turning into a loop. It shows a
collapse that costs 70 minutes and one wasted call, after which the
model recovers. Whether a rejection sometimes produces the run 1 loop
instead remains open, and this run cannot answer it. An earlier draft of
this file claimed the chain reached the loop; that was wrong, and the
run's own next reading disproved it.

### Two consequences worth carrying

**`loop-stop.ts` would not fire on this.** It counts identical
consecutive tool calls, and this is a single call. A stop that only
counts calls cannot see a 70-minute one. The stop needs a second trigger:
elapsed time or output size inside ONE call.

**Proposal P1 gains a second reason.** The output token limit is what
converts a collapse into a rejected call and a re-issue request. That
limit is `maxTokens`, the same number P1 proposes to change for Qwen3.8.
Whatever value it takes, a run should treat "hit the output limit" as a
run-level alarm rather than a routine retry — not because it always
leads to a loop, which this arm shows it does not, but because it means
the model just spent its entire output budget on something discarded.
