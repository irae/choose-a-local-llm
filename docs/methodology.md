# Methodology

This are stablished constraints for every test cycle. Do not skip steps. The rules are
split by task — read the page for the task you are about to do:

| Before you… | Read |
|---|---|
| Start ANY benchmark or sweep | [The bench run checklist](./methodology/checklist.md) |
| Write or run any measurement script | [Common rules](./methodology/common-rules.md) |
| Measure a new model at all | [KV cache pick](./methodology/kv-cache-pick.md) |
| Run a depth / context-creep sweep | [Context creep](./methodology/context-creep.md) |
| Probe a memory ceiling | [Memory ceiling](./methodology/memory-ceiling.md) |
| Run an EvalPlus scoring pass | [EvalPlus](./methodology/evalplus.md) |
| Run the Mendel agentic benchmark | [Mendel](./methodology/mendel.md) |
| Run the Aider polyglot benchmark | [Polyglot](./methodology/polyglot.md) |
| Touch a server, or debug a stall/crash | [Server lore](./methodology/server-lore.md) |

## Goals

One question for one computer: which local model, runtime, and
configuration should I code with? Speed alone does not pick a winner. A
config must hold a usable decode speed at real agent depths (our floor:
8 tok/s), fit in memory beside a harness, and pass the quality gates.
EvalPlus gates every config; Mendel and Aider polyglot rank the
survivors.

## How we pick models (reasoning to reuse)

- **Prefer MoE on bandwidth-limited hardware.** Decode scales with *active*
  parameters.
- **Prefer models with MTP support** — output-lossless free speed on llama.
  Note: speculative decoding (MTP or draft-model) costs depth — the floor
  arrives shallower with a drafter; measure both.
- **Take the newest strong models even if slow**; let the quality gate decide.
- **One compressed-frontier experiment at a time**, and read the
  vendor's serving docs before concluding anything.
- **Use the most popular mainstream quant repos** (HF download counts);
  verify exact file lists first.
- **Score the quant, once per model.** Published full-precision scores do
  not count: what you run is a quant. But narrow differences between
  runtimes' standard quants do not count either — score each model once
  per thinking mode and share that score across runtimes. Aggressive or
  calibrated quants (for example a vendor-calibrated q4 KV) are not narrow;
  each passes the gate separately.

## The flow, per model, with gates

A run usually starts with several candidate models and ends with one.
The cheap tests come first, and after each group of them the list is
cut: a model that already lost is dropped, or parked with its numbers
so far. The expensive tests run on the survivors only. Each step has
its page above.

1. **Name the models and their exact files.** Planning decides this,
   and whether the run may download anything.
2. **Cold start.** The checklist, with the machine file's values.
3. **KV cache pick**, every model: research, short creep of both
   types to 32K, fit prediction, candidate pick.
4. **EvalPlus smoke on the candidate pick.** LEVEL or BETTER confirms
   it. This is minutes per side and it kills a broken config before
   an hour is spent on it.
5. **Gate.** Every model has a cache type, a 32K speed reading, and a
   smoke line. Drop what already lost on speed or fit. Tell the owner
   if reachable; proceed on the survivors if not.
6. **Memory ceiling** at the picked type.
7. **Full context creep** at the picked type, to a real stop
   condition: the floor, an OOM, memory onset, or the trained window.
   Every config gets a "gated by" verdict, speed or mem.
8. **Gate.** Same as before, now with the depth curve. Most of the cut
   happens here: a model under the floor at the depth the owner works
   at is out.
9. **EvalPlus**, the quality gate: calibrate the budget, then the full
   run. Planning says which thinking modes and reasoning levels,
   from the vendor's documentation and the owner.
10. **Output probe and the harness entry.** Three single calls give
    the first `maxTokens`; the creep gave the window. Only now does a
    model get a pi entry ([Mendel](./methodology/mendel.md) holds
    the rule).
11. **Mendel smoke**, one handed task, 25 minutes, unscored. A config
    that cannot commit a two-file dependency swap does not get a
    five-hour run. This is a gate too: smoke every candidate, run the
    passes.
12. **Mendel**, the agentic benchmark, blind and guided per its plan.
    The plan sends very weak models to guided only and very strong
    ones to blind only.
13. **Aider polyglot** for the survivors, hours per model.
14. **Record every surface, commit, publish.**

Steps 3 to 9 are HTTP against the server and need no harness. Steps 10
to 13 go through pi. A runner drops a model at a gate on its own and
writes why in the run's state; it does not wait for the owner.

## Runtimes

- **llama-server** (llama.cpp). The concurrency backbone: slots
  share one weight copy; MTP speculative decoding.
- **mlx_lm.server** (mlx-lm). Often faster decode and flatter depth
  curves, but no slots, f16 KV only, and hard memory ceilings.
- **A GUI-bundled runtime driven only through its CLI** is an approved
  exception to the no-GUI rule, when every step runs CLI-only (get, load,
  serve) and the model store stays shared with the app. Such an engine can
  support MLX architectures that mlx-lm lacks and implement their attention
  properly. Read [the server lore](./methodology/server-lore.md) before
  touching it.
- **One vendor fork is allowed** when it is the only backend for a model
  family — a ternary quant, a calibrated q4 KV, a matching drafter — and
  the vendor maintains it. Install it side by side, keep one build at a
  time, and label every result with the fork build.
- Default remains: no other forks, no `--HEAD` builds.

The reference setup names the runtimes it runs, with install paths and
aliases: [runtimes on this machine](./setups/m1-max-32gb/index.md#runtimes-on-this-machine).

## Where runs live

Run kits are in `hardware/m1-max-32gb/benchmarks/bench<N>/` (runbook `AGENT.md`, log
`state.md`, results). Shared tools and calibrations sit in
`benchmarks/`. The findings index is `hardware/m1-max-32gb/benchmarks/INDEX.md`. Nothing
outside `docs/` reaches the published site.
