# pi's compaction may be too shallow to be useful under a small window

Observed in run 11, block 9: Qwen3.6-35B-A3B (GGUF, thinking off),
pi's 49152-token contextWindow entry, guided Mendel task.

## Evidence

Compaction timestamps and the context usage right before and right
after each one, read from the run's event log
(`qwen3.6-35b-a3b-off-guided-events.jsonl`):

| compaction ends at | usage before | usage after | freed |
| --- | --- | --- | --- |
| 19:23:16Z | 92.5% | 58.0% | 34.5 pt |
| 19:33:33Z | 104.9% | 64.8% | 40.1 pt |
| 19:50:39Z | 92.0% | 70.6% | 21.4 pt |
| 19:54:56Z | 91.8% | 65.2% | 26.6 pt |
| 19:57:37Z | 100.1% | 92.8% | 7.3 pt |
| 20:01:04Z | 95.0% | 93.6% | 1.4 pt |
| 20:04:19Z | 96.2% | 93.6% | 2.6 pt |
| 20:07:30Z | 93.8% | 91.5% | 2.3 pt |
| 20:09:39Z | 92.1% | 91.0% | 1.1 pt |
| 20:12:07Z | 93.0% | 84.4% | 8.6 pt |
| 20:17:23Z | 90.1% | 56.9% | 33.2 pt |
| 20:25:39Z | 92.2% | 59.5% | 32.7 pt |

Compaction frequency rose from about one per 9 minutes early in the
run to one per 2-3 minutes by the middle of the run. Several
compactions in the middle stretch freed only 1-8 points of headroom
before the next one triggered — barely enough to take one more tool
call before hitting the ceiling again.

## Why this is worth a look

The owner's experience with Claude Code's compaction, at a much
larger window (roughly 1M tokens), is a drop from about 90% down to
roughly 3% — a compaction that buys a long stretch of new work before
the next one is needed, and does not visibly cost the model its
thread on the task. pi's compactions here, on a 49152-token window,
sometimes drop to a similarly proportioned low point (56-70%) but
other times barely move the needle (1-8 points), which is why the
frequency climbs.

Whether this is a pi issue, a small-window issue, or specific to how
this model's own context gets used is unclear from one run.
Separately, in this same run the model did not visibly lose track of
its task across compactions — after most of them it re-read `TASKS.md`
and re-checked `git status` before acting, which is the right recovery
behavior. So the concern here is compaction depth/frequency (a
possible efficiency or cost problem), not thread loss (not observed
in this run, but only one run's worth of evidence).

## Ask

Have the coordinator look into pi's compaction options soon:

- Does pi have a tunable compaction depth/target (compact to X% rather
  than a fixed strategy), the way Claude Code's compaction seems to
  aim for a much lower floor?
- Is the shallow compaction specific to a small `contextWindow` entry
  (49152 here), or does it happen at any window size?
- Would a deeper compaction target trade cost (more to re-derive) for
  fewer compaction cycles, and is that trade favorable at this scale?

Session for reference: this conversation, run 11, block 9,
2026-09-06, around 19:20Z-20:30Z.

## Findings (coordinator, 2026-09-06, from pi 0.84.4 docs and source)

pi has no compaction target. The floor after a compaction is a sum:

    system prompt + tool definitions + summary + kept recent messages

- The trigger is `contextTokens > contextWindow - reserveTokens`.
- The kept part is `compaction.keepRecentTokens`, default 20000,
  estimated at chars/4. The cut walks back from the newest message
  until 20000 estimated tokens, then cuts at the nearest user or
  assistant message. It never cuts between a tool call and its
  result, so one large tool result inside the kept span stays whole.
  Code tokenizes denser than chars/4, so 20000 estimated is more than
  20000 real on a Qwen tokenizer.
- The summary is written by the run's own model, capped at
  `0.8 * reserveTokens` output tokens (6553 at reserve 8192).
- The same model generates the summary, so each compaction costs one
  prefill of the whole summarized span plus up to 6553 output tokens.
  On a local model that is minutes, not seconds.

At contextWindow 49152 the kept span alone is 41 percent of the
window. That is why the deep compactions land at 57 to 70 percent:
about 5K system, 3 to 6K summary, 20K plus kept. Claude Code's 90
percent to 3 percent drop is the same design at a 1M window, where a
kept span of a few tens of thousands of tokens is 3 percent. The
shallow 1 to 8 point compactions fit one cause: a large tool result
(a file read, a test run) sits inside the kept span, so every
compaction keeps it whole until 20K newer tokens push it past the
cut. The 20:17Z drop to 57 percent is that moment.

So: the shallowness is the small window, not a pi defect, and it is
tunable.

- `compaction.keepRecentTokens` is the depth knob. At 8000 on a 49152
  window the floor is near 35 to 40 percent. Nothing else changes.
- The cost of deeper compaction is re-reading. The run already showed
  the model re-reads `TASKS.md` and `git status` after a compaction,
  so the re-derive cost is one or two tool calls.
- The trade is favorable at this scale: fewer summaries (each one a
  full prefill plus thousands of output tokens on the local model)
  against one or two re-reads. Above about 100K windows the default
  is fine.
- An extension on `session_before_compact` can implement a Claude
  Code style compaction (summary only, keep nothing), but it is a
  new results epoch and needs its own row category.
- The other lever is the window itself: block 1 found 82K clean depth
  for this model at q8_0 KV (`qwen36-entry-window.md`).

Why block 9 ran at 49152 and not at the 82K block 1 found: by
instruction. The runbook (Server F section) says the pi entry's
`contextWindow` is 49152 and "the entry stays as it is (the runner
never edits it)"; the server ran at `-c 98304` and pi capped itself
at 49152. The 49152 value is the coordinator's daily-driver setting
of 2026-09-05 (`qwen36-entry-window.md`, owner decision pending). Not
macOS memory: the server log and the creep show no pressure at that
depth.

Note for the future (owner, 2026-09-06): the guided prompt hands the
model `TASKS.md` so it can find its place again after a compaction,
and the block 9 log shows it re-reading that file after most
compactions. Whether that file is what kept the thread across twelve
compactions is untested. A run with the same prompt minus the task
file, or a blind row with many compactions, would show it. Other
harnesses keep the original prompt plus the recent span and compact
the rest differently; pi keeps the summary plus the recent span and
drops the original prompt into the summary.

Proposed rule for run 12, owner decides: for entries with
`contextWindow` under 65536, set `compaction.keepRecentTokens` to
8192 in the run's pinned pi config, beside `reserveTokens` 8192, and
record it in every config note. Rows before that keep the default
20000 in their notes.
