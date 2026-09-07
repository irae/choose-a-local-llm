# LM Studio, retired on this machine

Retired 2026-09-07. LM Studio is no longer a candidate runtime here. Its
measurements stay on the model pages, in italics and marked 💀, because
they are real and they explain the decision. They are gone from the
[comparison page](./comparison.md) and from the home table, which answer
"what should I run", and LM Studio is not a candidate for that answer.

## What this project asks, and why the answer matters

This project picks a model, a runtime and a configuration to write code
with on one computer, an M1 Max with 32 GB of memory. A candidate has to
do agent work: read a repository, run commands, edit files, and commit.
Speed alone does not qualify a runtime, and a number nobody can reproduce
does not qualify a configuration.

LM Studio is a desktop application that also serves models over HTTP. On
this machine it ran Gemma-4-12B through its MLX engine. It was the only
way to serve that model as MLX weights with more than one slot, which is
why it entered the comparison at all.

## Finding 1: every agent run failed, and none of them committed

The agent benchmark is [Mendel](../../methodology/mendel.md): one real
repository task, scored on a 100-point rubric. LM Studio ran it three
times, on both prompt variants and at two thinking levels:

| test, level | libraries done | commits | tool calls | end |
|---|--:|--:|--:|---|
| blind, high | 0 of 8 | 0 | 15 | invalid |
| guided, high | 0 of 8 | 0 | 21 | invalid |
| guided, low | 0 of 8 | 0 | 130 | invalid, tool-call loop |

No LM Studio run has produced a single commit on this machine. The last
one repeated the same tool call until its budget ran out. A second LM
Studio entry, `google/gemma-4-12b`, was retired earlier for a
repetition loop on its thinking channel, and it produced every failed
Gemma-12B agent run before these.

## Finding 2: lower quality on the same model

[EvalPlus](../../methodology/evalplus.md) scores the same Gemma-4-12B
weights family on both runtimes, thinking off:

| runtime | pass@1 base | pass@1 plus | answered |
|---|--:|--:|--:|
| llama-server, GGUF Q4_K_XL | 0.976 | 0.939 | 100% |
| LM Studio, MLX 4-bit | 0.909 | 0.872 | 100% |

Same model, 0.067 apart. Nothing about the runtime made up for it.

## Finding 3: the configuration cannot be pinned

A measurement is only useful when the next person can reproduce it. On
this model the context window could not be set at all. Every documented
path was tested on LM Studio 0.4.23 with mlx-engine 1.10.1, and the
engine's automatic fit won each time:

| what was tried | result |
|---|---|
| `lms load -c 100000` | ignored, loaded at 158,464 |
| `lms load --context-length 100000` | ignored |
| `lms load -c 4096` | ignored |
| REST load call with `context_length` | accepted, then ignored |
| REST load call with `contextLength` or `config` | rejected as unknown keys |
| per-model configuration file | ignored |
| the application's default context length | ignored |

Thinking is off on this entry and the API cannot turn it on. The
built-in fit estimate reported 8.83 GB for a request the engine's own
arithmetic priced at about 29 GB, so it cannot be used as a check
either.

## Finding 4: the runtime moves under the run

- **Just-in-time loading.** A request that names an unloaded model loads
  it silently with a fresh automatic fit, and an idle model unloads
  itself after twenty minutes. A run can change window in the middle
  without saying so.
- **The disk prompt cache** sits at its size cap and evicts gigabytes
  per minute. At depth it forced full recomputes with no cache hit,
  which looks like a model slowdown and is not one.
- **The application cannot be avoided.** The server needs the desktop
  application, any command line call wakes the whole application, and
  it keeps an MLX runtime alive on the graphics processor. Every other
  run on this machine has to quit it first, or an unrelated process
  holds memory during the measurement.
- **A broken endpoint.** On this build the plain completions endpoint
  does not work; only the chat endpoint answers.

## What LM Studio did give

Two real advantages, kept here for the record:

- **The fastest Gemma-4-12B curve on this machine**: 34.19 tokens per
  second shallow, 23.23 deep, in 17.2 GB, against 24.64 down to 8.86 for
  the GGUF configuration. That is 1.4 times at 4K of context and 1.8
  times deep.
- **Parallel slots on MLX weights**, which the plain MLX server does not
  support.

Both matter for single-turn work, which is not the seat this project
chooses.

## The verdict

Gemma-4-12B on llama-server is better where it counts: 0.067 higher on
quality, a window that can be set and repeated, 245K of context against
131K, and a runtime that stays where it was put. LM Studio keeps a speed
advantage that no agent run ever converted into finished work.

So LM Studio is retired as a candidate. Its rows stay on the model page
in italics with 💀, its evidence stays here, and its superseded numbers
live on [the historical page](./historical.md). The full forensic
session that established the pinning failures is
`hardware/m1-max-32gb/benchmarks/bench4/lmstudio-forensics.md` in the
repository, and the runtime quirks that outlived it are in
[server lore](../../methodology/server-lore.md).
