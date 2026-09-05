# Non-goals sweep: sources behind the README section

Status: evidence file for "What this project does not measure" in
`README.md`.
Filed: 2026-09-04. Rewritten: 2026-09-05 after the owner rejected the
first list.
Needs hardware: no.

The first list mixed project scope with agent rules, one-off decisions,
model verdicts, and vocabulary. The owner set the framing: a non-goal is
work that does not help one person choose a coding model for one
machine. It must stay true for a contributor on other hardware.

Sources: the owner's Claude Code session logs on both machines
(`~/.claude/projects/`), the `git log`, and the rule files. Quotes are
the owner's own words, lightly trimmed.

## Kept, with the source

| Non-goal | Date | Owner's words |
| --- | --- | --- |
| Power and energy use | 2026-09-04 | "The energy meter: no sudo, don't care. This does not improve my quality and does not improve speed." Plus the framing itself: "It is a goal for datacenters or larger LLM home builds. This is a single user on a single hardware." (2026-09-05) |
| Throughput under concurrent load | 2026-09-04 | "Pi will almost never do parallel use of context, we test sequential and round-robin." And: "sub-agents [do] not run parallel always, but do have parallel contexts... we test a single one for the context speed." Also `docs/methodology/context-creep.md`: slots are parallel contexts, not parallel use. |
| A quality score per runtime | 2026-08-29 | "We will never EvalPlus [a model] MLX versus GGUF, we assume it is the same, because narrow differences don't count, I don't have time to test all combinations. Same model, same scores." |
| Our own quantization of weights | 2026-09-04 | "Re-quantization... I would never suggest we do that. Time consuming and it is out of my league to verify." And: "no re-quantization allowed, instead research community quants." |
| A large model catalogue | 2026-09-04 | "What we are not doing: finding models for the sake of expanding the benchmark; not trying old models that score badly compared to newer." |

## Rejected candidates

One-off decisions. A single ruling, not project scope:

- No q4_0 KV cache unless the vendor calibrates it. Stays in
  `docs/methodology/common-rules.md`.
- No `--HEAD` build, one vendor fork only. Stays in
  `docs/methodology.md`.
- No GUI-only runtime; a config must serve an HTTP API. Stays in
  `docs/methodology.md` and the common rules.
- No two models on the GPU at once. Stays in the common rules.
- No `sudo` in a runbook. Stays in `benchmarks/PLANNING.md`.
- No EvalPlus inside a research run. A run-kit rule, not project scope.

Model-scoped decisions. True for one model, not for a contributor's
hardware:

- No thinking-on agent work on Gemma-4-12B over MLX or LM Studio. Stays
  in `hardware/m1-max-32gb/research/run2/results/gemma12-verdict.md`.
- The DRY sampler does not stop that model's repetition loop. Stays in
  `hardware/m1-max-32gb/research/run2/results/dry-arm.md`.

Terms. Vocabulary, not scope:

- Never "collapse" for a repetition loop.

Agent rules. Useful to an agent, not to a reader choosing a model:

- Run the exact files the runbook names; downloading is a planning decision.
- Push and publish only on owner request.
- No superseded number on a current page.
- No unit tests unless the owner asks.
- No inventory of the owner's machine in git.
- No bare `git stash`; a runner never works in a main worktree.
- Out of credits is a pause, never a teardown.
- No model name on a method page.

## What moved to AGENTS.md

The agent rules above were already standing rules, except these four,
which the sweep added or strengthened:

1. **Never offer to publish.** Added to the "Push only on owner
   request" rule.
2. **Terminology follows the community; never "collapse".** Moved out
   of `CONVENTIONS.md`, which governs markdown shape, not agent
   behaviour.
3. **Never edit a shell script while it runs.** The owner repeated it
   in every unattended run 2 prompt; no file held it.
4. **A harness stops a run; it never rescues it.** It was a coordinator
   position in `hardware/m1-max-32gb/research/run2/AGENT.md` only. It covers both the
   prompt-layer fix and the sampler trick.

## Open, for the owner

- The model entry criteria have a positive half the rule files do not
  state: a better quant of a model we know, more context at a lower
  quant, and two medium contexts at once. The README carries the
  refusal only.
- A run gated by our own configuration is our fault, not the model's
  (owner, 2026-09-03). The scoring plan covers invalid runs, not this
  framing.
