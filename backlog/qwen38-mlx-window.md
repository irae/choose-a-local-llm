# The Qwen3.8 MLX window before any Mendel retry

Status: pending owner decision. Filed 2026-09-05.
Needs hardware: yes for the retry, no for the decision.

Run 9 block E ended invalid after three attempts: with `maxTokens` at
8192 the one-token stubs stopped, but the context still grew past the
declared 26624 window in agentic use and the mlx_lm.server generation
thread died on a Metal OOM twice, at prompts of 22892 and 27969 tokens.
The MLX ceiling for this model is 26708 to 28672 at the 24000 limit.

Options: a smaller `contextWindow` with `reserveTokens` sized for the
in-turn growth, an earlier compaction trigger, or waiting for the
measured margin from the research item
`hardware/m1-max-32gb/research/no-oom-at-mendel.md`. The blind low
retry waits on the same decision.
