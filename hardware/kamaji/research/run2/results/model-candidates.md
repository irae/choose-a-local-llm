# T3.4 — new model candidates, re-filtered for coding

Run 2, session 1, 2026-09-04. Section H. **No model was downloaded.**
The standing rule is that only the owner downloads a model, so this is
a shortlist and nothing more.

The owner already cut Muse Glimmer for weak coding scores and asked
that every candidate be re-filtered on coding and agentic benchmarks
before it reaches a shortlist. All three below pass that filter. What
separates them is fit on this machine.

## The three, with what the vendors and reviewers claim

| Candidate | Shape | Licence | Coding claims |
| --- | --- | --- | --- |
| Mistral Devstral Small 2 | 24B dense | Apache 2.0 | SWE-bench Verified 68.0% |
| GLM-4.7-Flash | 30B, MoE (sources disagree, see below) | MIT | SWE-bench Verified 59.2%, tau2-Bench 79.5 |
| Poolside Laguna XS 2.1 | 33.4B total / 3B active MoE, 256K context | see repo | SWE-bench Verified 70.9%, SWE-bench Multilingual 63.1%, Terminal-Bench 2.1 33.4% |

Treat every number above as a vendor claim. None of them is our
benchmark: this project scores EvalPlus and Mendel, and the ranking
those produce has already disagreed with published leaderboards.

## Ranked for THIS machine

**1. Mistral Devstral Small 2 — the best fit.** 24B dense at Q4 is
about 14 GB of weights, which leaves real context headroom under the
24000 MB wired limit. Every other candidate spends 4-5 GB more before
the first token. Apache 2.0 removes any licence question. The risk is
speed: it is dense, and our dense 27B models run 14-17 tok/s, so expect
that class rather than the 40+ tok/s the MoE models give.

**2. GLM-4.7-Flash — the fast one, if the shape is what we think.**
The runbook records it as a 30B-A3B MoE, the same active class as
Qwen3.6-35B-A3B, which this machine already runs at 96K context and
62-68 tok/s. If that is right, it is the cheapest candidate to serve
and the most interesting comparison, because we would have two models
of the same shape. **But the sources contradict each other**: one
review describes it as a dense 30B. A dense 30B is a different machine
problem entirely. Settle the architecture from the model repo's own
`config.json` before anything is downloaded.

**3. Poolside Laguna XS 2.1 — the strongest claims, the least certain
support.** 33.4B total at 3B active would decode fast, and 256K context
is more than we can hold anyway. Two blockers. Its memory footprint is
the largest of the three at Q4, around 19 GB, which is close to where
this machine starts trading context for weights. And llama.cpp support
is contested in the sources: one says it is "coming soon", another
claims launch-day support with GGUF checkpoints. That has to be
resolved before it is considered, because MLX is the only alternative
path and no MLX conversion was found.

## What the owner has to decide, and what it costs

Each download is roughly 15-20 GB at Q4. Nothing else in this run is
blocked by the answer, so there is no hurry.

If only one is taken, take Devstral Small 2: best fit, permissive
licence, no open architecture question, and it is the only candidate
that leaves the context headroom this machine is short of.

Sources: [Devstral 2 announcement](https://mistral.ai/news/devstral-2-vibe-cli/),
[VentureBeat on Devstral 2](https://venturebeat.com/ai/mistral-launches-powerful-devstral-2-coding-model-including-open-source),
[GLM-4.7-Flash review](https://llm-stats.com/blog/research/glm-4.7-flash-launch),
[Laguna XS 2.1 on Hugging Face](https://huggingface.co/poolside/Laguna-XS-2.1),
[Poolside's announcement](https://poolside.ai/blog/introducing-laguna-xs-2-1).
