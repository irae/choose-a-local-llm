# Terminology — and a note for the coordinator

Owner instruction, 2026-09-04: use the terms the community uses, so that
searching, reading essays and watching talks all land on the right
material.

## What to say

| Use | Instead of | Why |
| --- | --- | --- |
| **repetition loop**, or just looping | "collapse" | What practitioners call it. |
| **degeneration** (neural text degeneration) | — | The term in the sampling literature. It is where `repeat_penalty`, DRY and XTC come from, so it is the word that finds the relevant papers. |
| **tool-call loop** | — | The loop when it shows up as repeated tool calls. |

Name the scope when it matters: a repetition loop **in the thinking
channel**, or **in the tool call**.

## Why "collapse" was dropped

**Model collapse already means something else**: a model degrading
because it was trained on AI-generated data. Using it for repetition
sends a reader to entirely the wrong material. This run coined it by
accident and it is now removed from every file this run owns.

## Left for the coordinator

Four files still carry the old word. They were left alone deliberately —
`AGENT.md` is the runbook and the other three are web research reports
that quote their sources, so rewriting them here would fight `master`
and would misquote the sources.

| File | Occurrences |
| --- | --- |
| `research/run2/AGENT.md` | 4 |
| `research/run2/results/video-research.md` | 1 |
| `research/run2/results/web-serving-failures.md` | 1 |
| `research/run2/results/web-upstream-status.md` | 1 |

Note that some of those are quotations — the upstream reports describe a
"model-level repetition collapse" in Gemma-4. Where the phrase is a
quote it should stay a quote; where it is the runbook's own prose it can
become "repetition loop".
