# EvalPlus rows are not affected by the template bug

Run 2, 2026-09-04. No GPU used. This answers a planning question the
owner raised: which published rows are stale.

## The test

The two Gemma-4 templates differ in exactly one place — what they append
**after a tool response**. An EvalPlus request has no tool response: it
is one user turn, no tools, no assistant history.

So rather than spend three GPU hours running EvalPlus twice, render the
prompt both ways and compare.

## The result

| `enable_thinking` | pre-fix `657684f` | post-fix `main` | identical |
| --- | --- | --- | --- |
| false | 112 chars, `446002235cc2` | 112 chars, `446002235cc2` | **yes** |
| true | 116 chars, `6d03a19e0ecd` | 116 chars, `6d03a19e0ecd` | **yes** |

**Byte-identical, both ways.** The model cannot tell the two templates
apart on an EvalPlus prompt, because the branch they differ in never
fires.

## What this settles

**Every EvalPlus score is a keeper on template grounds**, on either
backend, whichever template the container carried. The 0.909 / 0.872
Gemma-12B row included.

It also bounds the whole finding: the template bug is **specific to
multi-turn tool use**. It cannot affect a single-turn benchmark, and it
should not be offered as an explanation for any single-turn number.

## What it does NOT settle

The agent runs. Mendel rows are multi-turn with tool responses on every
turn, so the branch fires constantly there. Those are the rows the
template question is about, and rendering cannot answer them — only the
arms in `replay-llama.md` can.

Reproduce with `/tmp/run2/evalplus_render.py`; the two template files are
archived in
`~/.local/share/choose-a-local-llm/evidence/run2-context-ramp/`.
