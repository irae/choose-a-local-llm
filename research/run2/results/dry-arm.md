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
