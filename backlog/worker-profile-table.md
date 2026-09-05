# Worker-profile table: which config is the best sub-agent

Status: draft, waits for the owner to read it (owner request,
2026-09-04: a fuller explanation before any agent starts).
Filed: 2026-09-04. Origin: the owner's observation that Gemma-12B does
not spin the fans while Qwen3.6 does, and research run 2's finding that
Gemma-12B thinking off is a clean 0.909 with every answer delivered.
Needs hardware: no for the table; it may name missing rows that become
bench items.

## Background, for a reader who has not followed the runs

The site measures each model configuration on three tests. The depth
sweep gives decode speed as the context fills and where the config
stops (memory, speed floor, or the model's window). EvalPlus is a
single-turn code test, 164 problems, scored with thinking on and with
thinking off. Mendel is a multi-turn agent task where the model edits a
real repository through the pi harness. The tables rank configs as if
one model does everything: a long thinking session at deep context.

The owner's daily setup is different. One main agent thinks and holds
the long context. Several sub-agents receive short handed tasks (edit
this file, run these tests, replace this dependency), run with thinking
off, start and stop often, and must fit in memory beside the main
agent's model. The measurement rules already say this is the target
setup (`docs/methodology/common-rules.md`, rule 8, which is why both
thinking modes are scored). The site never draws the conclusion.

The owner also noticed that Gemma-12B does not spin the fans while
Qwen3.6 does. That is a hint that the sub-agent seat wants a smaller,
cooler model, and that the main-seat ranking hides it.

## The problem in plain words

The measurement rules say the setup we aim for has two seats: a main
agent that thinks, and sub-agents that run with thinking off and do
short handed tasks (edit this file, run these tests, replace this
dependency). Every table on the site ranks configs for the first seat:
a long thinking session, deep context, full task. Nothing on the site
ranks configs for the second seat. So a reader cannot answer "which
model do I give my sub-agents", and the owner's daily-driver choice
(Qwen3.6 for the main seat) says nothing about it.

## What the table is

One table on the comparison page, one row per candidate worker config.
Columns:

| Column | Why it matters for a worker |
| --- | --- |
| decode tok/s at 4K and at 16K | a handed task is short; the deep curve does not matter |
| EvalPlus, thinking off | the quality of quick answers |
| completion rate | a worker that returns nothing 37% of the time is useless |
| memory at 16K | it must fit BESIDE the main agent's model, not alone |
| load and warm-up time | workers start and stop often |
| energy per token | if research 3 measures it; the fan noise the owner noticed |

Candidates today: Gemma-12B GGUF thinking off (llama-server), Gemma-12B
`gemma-4-12b-it-mlx` (LM Studio, thinking off by nature), Bonsai MLX
thinking off, Qwen3.8 at effort low, Qwen3.6 thinking off.

## What exists and what is missing

| Candidate | EvalPlus thinking off | decode at 4K / 16K | memory |
| --- | --- | --- | --- |
| Gemma-12B GGUF, off | 0.909 / 0.872 (shared score; own score is bench 9 B1) | 24.6 / 22.7 at f16 KV (run 2) | 10-11 GB |
| Gemma-12B LM Studio `gemma-4-12b-it-mlx` | 0.909 / 0.872, 164/164 answered | not measured on this entry (bench 9 A0) | about 8 GB |
| Bonsai MLX, off | 0.927 / 0.902 | 24.5 / ? (row is daggered) | 22.5 GB, too big beside a main agent |
| Qwen3.8 MLX, effort low | 0.976 / 0.927 | 17 / 15 | 22 GB, too big beside a main agent |
| Qwen3.6, off | **not scored** | 44 / ? at q8 (daggered) | 18-23 GB |
| Gemma-26B GGUF, off | **not scored** (bench 9 block D) | 23.5 / ? (daggered) | 15 GB |

The two missing scores are bench items. Memory decides most of it: a
worker sits beside the main agent, so a 22 GB worker on a 32 GB machine
is not a worker. On that reading Gemma-12B is the only candidate under
11 GB, which is the owner's hypothesis. The table makes that visible
instead of assumed.

## Deliverable

1. The table as a proposal, with a "pending" cell wherever a number is
   not measured on that exact config, and the bench item that fills it.
2. A one-paragraph rule for the comparison page: what a worker seat
   needs, in the order memory, completion, decode at 16K, quality.
3. The owner decides the layout and whether energy joins the columns.
