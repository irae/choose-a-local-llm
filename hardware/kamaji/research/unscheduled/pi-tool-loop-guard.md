# A tool-loop guard for daily pi use

Status: unscheduled, filed 2026-09-16. Origin: the owner's discussion
of 2026-09-16 on non-convergence (`../../../arrietty/research/thinking-budget.md`).
Needs hardware: yes, a local model under pi for the trial. Desk work
first: read the candidates.

## Why this exists

A thinking budget on the server (`docs/methodology/evalplus.md`,
"Unproven yet") bounds the thinking inside one turn. Most of the loops
the agent benchmark has seen are across turns: the same tool call
again and again, each turn ending clean (`../loop-signatures.md`, rows
1, 2, 9, 10, 12). A thinking budget never sees those. `loop-check.py`
sees them after the run, as a measurement; it stops nothing. The
benchmark runner's live loop stop ends the run, which is right for a
benchmark and wrong for daily use, where a nudge should come first.

The owner wants daily use covered: a fair use of the server's thinking
budget plus a guard in the harness for repeated tool calls, with a
nudge before a halt. If a guard proves itself, the simulator runs pi
with it, so the benchmark measures what the user runs.

## Candidates looked at (2026-09-16)

- `pi-anti-doom-loop` (community, irfndi). Blocks an identical repeated
  tool call at the source, nudges on near-identical assistant texts (a
  token-similarity threshold), aborts after a threshold with one
  fresh-resume directive. The nudge-then-halt shape the owner asked for.
  Small enough to read in full.
- `pi-loops` (community, Asm3r96). A larger supervised-loop framework
  with gates, approvals and model routing. More than this needs.

Neither is proven at scale; both are community work. The owner's bar
is a proven solution that lifts small hardware toward production
quality, or a build of our own from the same measurements. The
decision: discussion and a trial first, then build our own if the
trial says the shape is right.

## The trial

1. Read `pi-anti-doom-loop` in full. Note its detection rule, its nudge
   text, its abort threshold, and what it logs.
2. Compare its rule with `loop-check.py`'s three shapes: identical
   lines, counters, short cycles. A guard that sees only identical
   calls misses the counter and the cycle.
3. One guided agent row of a model that loops on tool calls (the
   ternary 27B fork, `loop-signatures.md` rows 1 and 12), with the
   guard on and the server's thinking budget on, paired with the same
   config with both off. Score, wall, end reason, and `loop-check.py`'s
   verdict on both. Under the benchmark law a harness nudge is never
   scored, so whether a guard row scores as the model or as the harness
   is the owner's rule to write before the pair runs.
4. Report the shapes the guard caught and missed against the table in
   `loop-signatures.md`.

Outcome wanted: the rule for a guard of our own, or the adoption of
the candidate with its version pinned, and a decision on whether the
simulator runs with it.
