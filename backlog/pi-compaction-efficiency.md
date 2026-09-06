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
