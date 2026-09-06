# The Qwen3.6 GGUF pi entry at contextWindow 49152

Status: pending owner decision. Filed 2026-09-05.
Needs hardware: no for the decision.

On 2026-09-05 the coordinator set the daily driver's pi entry
`qwen3.6-35b-a3b` to `contextWindow` 49152, after run 9 found the
published `-c 98304` and 65536 fail at load with a Metal OOM under
the 24000 wired limit, and 49152 loads. The Mendel rows of late August
ran at 98304 and peaked at 94K used tokens, so the entry is now half
the window those rows used.

Why 98304 loaded in August and not in September is not established
(wired limit, memory state, or build). It is a question in the
research item `hardware/m1-max-32gb/research/no-oom-at-mendel.md`.

Options: keep 49152 on the daily driver until that answer, or raise
it back to 98304 and accept a load failure risk on the owner's own
sessions.
