# pi test with sub-agents: keep the main context clean

Observed in run 11, block 9: Qwen3.6-35B-A3B (GGUF, thinking off) ran
the guided Mendel task much further than expected — 5 clean commits
in under an hour, on a tight 49152-token pi window, at the cost of 3
context compactions from running close to the window ceiling the
whole time.

Idea: a pi harness mode that runs each library/task step as a
sub-agent call, not inline in the main agent's context. Shape:

- The main agent dispatches one sub-agent per unit of work (e.g. one
  library replacement).
- The sub-agent's own context absorbs the large first request (reads,
  greps, exploration) and any cache misses that come with it; it
  returns only a short "done" report to the main agent.
- The main agent's context stays small across the whole run: it never
  holds the sub-agent's intermediate reads, greps, or dead ends, only
  the reports.
- With a single physical context/cache slot (no cache-preserving
  parallelism), a sub-agent call still evicts the main agent's cached
  prefix on entry, and the main agent's own resumption evicts the
  sub-agent's cache on return. So this trades compaction pressure for
  a larger number of full cache misses, one per hand-off, rather than
  the periodic compactions a single long-lived context takes.
- Worth testing whether a model that already handles a full inline
  run reasonably (like this one) can go further, faster, or with a
  cleaner main-context trail using this shape, and at what hand-off
  frequency the cache-miss cost outweighs the compaction-avoidance
  gain.

Needs its own harness support (pi has no such mode today) and its own
test design, separate from the current Mendel guided/blind method.

## Owner's decision

Not yet reviewed.
