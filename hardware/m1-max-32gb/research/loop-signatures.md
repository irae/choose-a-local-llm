# Loop signatures: every loop the Mendel runner has seen

Research for a live loop stop in `run-pi-rpc.mjs`. The owner wants a loop
caught about two minutes after it starts, and knows some loops are wider
than that. This file lists every loop occurrence found in the Mendel
session logs, result rows, benchmark run records, and the site archive,
with its shape and its timing, then answers the design questions.

## Every loop occurrence found

| # | Date | Model / config | Test | Loop kind | Repeated unit (quoted) | Repeats | Duration before stop | What stopped it | Real work between repeats | Detector / when |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 2026-09-06 | Bonsai 2bit, thinking off | guided v3, retry 2 | identical tool call | `ls -la .../.taprc 2>/dev/null; cat .../.taprc 2>/dev/null` | 85 | 169 of 187 min wall | operator kill (no runner end condition) | none | `loop-check.py`, run by hand after the kill, never at run close |
| 2 | 2026-09-06 | Bonsai 2bit, thinking off | guided v3, attempt 1 | identical tool call | interactive `gh auth login` device-code prompt | 8 | 83.5 min (each retry cost a 10-min stall wait) | tooling-nudge budget exhausted | none | `loop-check.py` said "ok" (ratio 1.00) — only 10 tool calls total, below the 60-line window |
| 3 | 2026-09-02 | Bonsai 2bit, thinking high (mislabeled "low" branch) | blind v1.1 | thinking loop | "Let me check if there's a way to allow built-in modules..." (eslint-plugin reasoning, cycling 3 near-duplicate lines) | window ratio 0.07 over 616 thinking lines | ran inside a 300-min partial run | wall clock (300 min) | yes — 4 commits landed, incl. a self-fix of a JSON syntax break (~40 min) | `loop-check.py` at report time, LOOP |
| 4 | 2026-09-02 | deepseek-v4-flash-0731 | blind v1.1 | text loop (catchphrase) | "Let me check `enableColor` usage across the codebase:" | window ratio 0.02 over 61,818 text lines | early in a 100.6-min run | run completed normally | yes — 14 commits, task finished, score 84.5 | `loop-check.py` at report time, LOOP (run was healthy) |
| 5 | 2026-09-02 | deepseek-v4-flash-0731 | guided v3.0 | text loop (same catchphrase habit) | same pattern as #4 | window ratio 0.02 over a 249-min run | throughout a run that finished | run completed normally | yes — 16 commits, score 97 | `loop-check.py` at report time, LOOP (run was healthy) |
| 6 | 2026-09-02 | deepseek-v4-pro-0813 | blind v1.1 | thinking loop (tool-call syntax leaking into reasoning) | `</\|DSML\|invoke>` / `</\|DSML\|tool_calls> <parameter name="command">ls -la ...` | window ratio 0.03 over 13,763 thinking lines | inside a 92.5-min run | run completed normally | yes — 18 commits, score 79 | `loop-check.py` at report time, LOOP (run was healthy) |
| 7 | 2026-08 to 2026-09 | google/gemma-4-12b, LM Studio (retired entry), thinking on | 3 invalid rows: blind high, guided high, guided low | thinking loop → degenerate output | pure-newline flood ending on a bare `<\|channel>` token (no words at all) | 40,000+ chars per flooded turn, 3 floods across the block | 46-99 min per run, all `model_budget_exhausted` | two at-budget `length` stops in a row (`output_limit`), not a loop rule | none — 0 commits in all 3 rows | `loop-check.py` missed it: ratio stayed 0.93 / 0.20 ("ok") because a pure-newline flood strips to almost no non-blank lines |
| 8 | 2026-09-05 | Gemma-4-12B, llama.cpp, thinking off | guided v3.0 | short-cycle text loop (thinking off, so the loop sits in the visible answer) | "Wait, I will do glob first / Actually, I will do rimraf in legacy-packages" (~300 reps/turn); later "Wait, I will do that now / Actually, I will just do that" (~815 reps) | 3 capped turns, hundreds of reps each | 97.6-min partial run | two at-budget `length` stops (`output_limit`) | partial — some edits landed before the collapse, left uncommitted | `loop-check.py` at report time, LOOP, kind text |
| 9 | 2026-09-04/05 | Gemma-4-12B, LM Studio (retired entry), thinking low | guided v3.0 | identical tool call | `ls -F_r` then `ls -R_r` (invalid option, rejected every time) | 100 in a row | ~12 of 99 min | model itself moved on after a malformed-token turn, not a rule | none | not caught live; found reading the session by hand |
| 10 | 2026-09-03 (bench7) | google/gemma-4-12b, LM Studio, thinking high | original discovery, pre-dates the Mendel rows above | identical tool call | `ls -F_r` (malformed flag) | 72 in a row | most of a run at context 158464 | ran to its own end, not a rule | none | none; this run is what prompted the `loop-stop.ts` research extension |
| 11 | 2026-09-04 (research run 2) | same model, llama-server replay, DRY sampling on | replay probe, not scored | identical tool call, hidden by DRY | `bash {"command": 4}` | 37 in a row | replay probe | replay ended by script | none | exact-match / DRY-aware detectors read this as clean; only the shape-ratio test (`loop-check.py`) later caught the sibling case at 1,133 shape-identical lines inside one tool call |
| 12 | 2026-08-31 (bench7, run7) | Bonsai 2bit, thinking low | guided v3, block 2 run 2 | identical tool call, self-authored path typo | `ls` of `.../Ternary-Bonsai-2bit-low/...` (missing `27B-mlx-` segment) | "many times in a row," not counted exactly | most of a 300-min run | wall clock (300 min) | one commit landed (uuid only, 1/8 libraries) | not caught live; noted by the operator watching the run |
| 13 | 2026-08-26 | gemma-4-26b-a4b | blind v1.0 | not a loop (checked, included as a caveat) | n/a | window ratio 0.45, "ok" | end_reason `stuck` | — | — | `loop-check.py` correctly says "ok" — a `stuck` end reason is not proof of a repetition loop |

Full session logs exist for rows 1, 2 (as an events stream), 3, 4, 5, 6, 7
(partial), 13; rows 8-12 are reconstructed from `bench7`/`bench10`
`state.md`, `report.md`, the site's Gemma-12B retired-entry section, and
`loop-stop.ts`'s own commit note, because their raw logs are gone or were
never archived.

### Timing detail: what a two-minute window would have caught

- **Row 1 (`.taprc`)**: first repeat at 11:27:40 UTC, gap ~75 s early,
  growing to ~165 s late. A rule needing N=3 identical calls fires
  ~2.5 min after the first repeat; N=5 fires ~5 min in. Both are inside
  the loop's 169-minute run, so either would have saved well over two
  hours. A strict "N=3 inside 2 minutes" bar is missed by a few tens of
  seconds at this call rate; N=3 with no fixed window (just "3 in a row")
  still ends the run in single-digit minutes.
- **Row 2 (`gh auth login`)**: each retry is gated by the 10-minute stall
  timer before the harness even resends the nudge, so no identical-call
  count can beat 2 minutes here — the floor is the stall timer, not the
  loop rule. N=3 fires at ~30 min, still far short of the 83.5-min
  actual run.
- **Row 9 (`ls -F_r`/`-R_r`)**: calls are seconds apart. N=5 fires within
  under a minute of the loop starting.
- **Rows 4-6 (catchphrase / syntax-leak text and thinking "loops")**: these
  are not consecutive-call repeats; the repeated line recurs every few
  turns across a long healthy run. A per-turn "N identical tool calls in a
  row" rule never sees them, correctly, because real tool calls with real
  arguments happen in between every recurrence.
- **Row 7 (newline flood)**: the flood fills a single turn up to the
  output cap; there is no "start" to count from inside a 2-minute window
  scheme built around consecutive tool calls, because the flood contains
  no tool calls at all. Detection has to happen inside the turn, on the
  text/thinking stream itself, not between turns.

## Question 1: what does the runner see live, per event, today?

`run-pi-rpc.mjs` logs every raw `pi --mode rpc` event to `<slug>-events.jsonl`
as it arrives, unfiltered except for the `response` type used for its own
request/response bookkeeping (`logEvent` runs on every other event,
`run-pi-rpc.mjs:191`). That stream already contains `thinking_delta`,
`text_delta`, and `toolcall_delta` character-level pieces — the same event
shapes `loop-check.py` reads from either an events log or a session log.
So the runner can see thinking content live, not only tool calls.

At `message_end` for an assistant message, the runner also has the full
parsed `content` array, including `toolCall` blocks with tool name and
already-parsed arguments (used today only for output-limit accounting
and stop classification, `run-pi-rpc.mjs:252` and `:400`).

What it does NOT do today: track tool-call identity turn to turn, or
inspect the thinking/text delta text for repetition. The repetition
check runs once, after the fact, in `loop-check.py`, called by
`run-worker.sh` only when a run reaches a normal end condition.

## Question 2: which loops would a live "N identical tool calls, no edit or commit between" rule catch?

Directly, by exact match of tool name + arguments:

| Row | N to catch | Minutes to catch |
|---|---|---|
| 1 (`.taprc`) | 3-5 | ~2.5-5 min |
| 2 (`gh auth login`) | 3 | ~30 min (bounded by the stall timer, not N) |
| 9 (`ls -F_r`/`-R_r`) | 5 | under 1 min |
| 12 (path typo) | 3-5 | minutes, well inside its 300-min run |

Needing `loop-check.py`'s window-ratio shape instead, because the loop is
not consecutive-identical:

- Row 11's sibling case (1,133 shape-identical lines with a changing
  counter inside one tool call) — the shape function (letters→`W`,
  digits→`N`) is required; exact match sees every line as different.
- Any A/B/A/B short cycle — none of these appeared as tool calls in the
  corpus, but row 8 shows the same shape in text.

Needing a thinking- or text-channel rule, because there is no tool call
to compare at all:

- Row 7 (newline flood) and row 8 (short A/B text cycle) both live
  entirely inside the assistant's thinking or answer text. A tool-call
  counter cannot see either one.

## Question 3: what does `loop-check.py` catch at report time that no runtime rule catches today?

Every shape-based case in the table: the short A/B cycle (row 8), the
counter-hidden loop (row 11's sibling), and the two catchphrase/text
loops that turned out to be healthy habits, not failures (rows 4-6) —
`loop-check.py` flags all of these; nothing live does, because nothing
live runs a window-ratio scan at all today. It also catches row 1 and
row 3 correctly, but only once a session log exists — row 1 never
reached that point on its own, and had to be checked by hand.

## Question 4: which loop would a two-minute rule call wrongly?

Rows 4, 5, and 6 are the clearest case: a model that repeats one
sentence or reasoning fragment every so often across a long, otherwise
healthy run, with commits landing throughout. A rule keyed on
consecutive identical tool calls, gated by "no edit or commit since the
last repeat," correctly ignores these, because real tool calls and real
commits sit between every recurrence. A rule keyed only on the text or
thinking shape-ratio, without that same gate, would flag all three and
end a run that was about to finish at 97/100.

The corpus also has legitimate, deliberate repeats of the *same* command:
row 3's model reran `npx tap test/app-test.js` four times while fixing a
self-inflicted JSON syntax error, and deepseek's rows reran the same
per-package `tap` command dozens of times across their long runs. Both
are protected by the same gate — a file edit sits between each rerun —
so "no edit or commit between repeats" is not a cosmetic clause, it is
what separates rows 3-6 (healthy, must not stop) from rows 1, 2, 9, and
12 (must stop).

## Recommendation

Add a live rule to `run-pi-rpc.mjs`: **5 consecutive tool calls with the
same name and the same arguments (stable-key match, as in
`loop-stop.ts`), with no file edit and no commit since the streak
started, ends the run with `end_reason: repetition_loop`.** N=5 catches
every identical-call loop in the table inside single-digit minutes
except the `gh auth login` case, whose floor is the 10-minute stall
timer, not N — no identical-call count reaches that one in two minutes,
because the model is not given the chance to repeat any faster. Keep
`loop-check.py`'s window-ratio rule (window 60, threshold 0.10) as a
second live check run on the thinking and text delta streams at every
`message_end`, unchanged from its tuned values, because it is the only
rule that catches a short A/B cycle or a counter-hidden loop; do not
lower its threshold or window to chase a faster catch, since the clean
control arm already sits close to today's threshold. Add a third,
narrow rule for the newline-flood shape the window-ratio rule cannot
see at all: if a single assistant turn streams more than about 500
characters where over 90% are one repeated character or whitespace,
end the run immediately as `end_reason: degenerate_output` without
waiting for the output-token cap. None of the three rules should fire
on their own inside a turn that is also producing file edits or commits
— that gate is what keeps deepseek's and Bonsai's healthy, repeat-heavy
runs alive.
