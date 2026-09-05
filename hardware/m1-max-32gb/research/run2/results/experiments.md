# Research run 2 — ranked experiment list

Written 2026-09-04 by the run 2 agent, first session. The owner filters
this list. Nothing runs before that, except the free audits in tier 0,
which only read files.

Ranking rule: what unblocks the most other work comes first, then cost.
"Cost" is GPU time on this Mac. "Download" says whether the experiment
needs a file the machine does not already hold.

Machine at the time of writing: rebooted 58 minutes ago, zero swap,
1.65 GB wired, 12.9 GB free pages, no server, no LM Studio process, no
panic log. `iogpu.wired_limit_mb` is 0 (the boot default), because the
reboot cleared run 1's 24000.

---

## Tier 0 — free. No GPU, no downloads, no config change

These read files and report. They can run beside any GPU experiment, so
they do not compete for the machine.

### T0.1 Container audit (section A)

Dump `tokenizer.chat_template` from every local GGUF and every MLX
`tokenizer_config.json`. Compare each against its base model's template
and against the two upstream dates: the Google chat-template fix of
2026-07-15 and llama.cpp PR 21343 of 2026-04-03. Record the conversion
date of every local Gemma-4 container.

Cost: 0 GPU, about 45 minutes. Download: none.
Unblocks: section D item 2, and says whether the loop can be a stale
template before any GPU time is spent on it.

### T0.2 Quantized-PLE check on the Gemma-4 MLX quants (section A)

Compare the `config.json` quantization block of the local Gemma-4 MLX
repos against a known-good reference. The report claims all HF
mlx-community Gemma-4 quants carry the defect.

Cost: 0 GPU, about 20 minutes. Download: none (comparison is against a
published config file, not a model).

### T0.3 KV type and instruction-set audit (section A)

Grep every published config for `q4` KV cache types. Read
`sysctl -a | grep hw.optional` and record `dotprod` and `i8mm`. Check
whether any local GGUF or build flag assumes `i8mm`.

Cost: 0 GPU, about 20 minutes. Download: none.

### T0.4 Prompt-cache telemetry (section G)

Find what each local backend exposes: llama-server slots and metrics,
`cached_tokens` in mlx_lm.server responses, the LM Studio field the
sweep already reads. Write the reader and the alert threshold proposal.

Cost: 0 GPU for the code; the verification rides on any tier 1-2 server.
Download: none.

---

## Tier 1 — the blocking question

### T1.1 Replay the Gemma-12B loop on llama-server (section D item 1)

Run the same failing Mendel task, from the same base commit, against
`unsloth/gemma-4-12b-it-GGUF:Q4_K_XL` on llama-server instead of the LM
Studio MLX path. The LM Studio arm is already measured twice: 130 calls
/ 30 distinct / 72 in a row, and the replay's 71 / 30 / 37. One
llama-server arm separates the model from the MLX path.

Everything else in section D waits on this answer. If the GGUF path
loops too, the model is the cause and the LM Studio bug list is a side
issue. If it does not, the MLX path is the cause and the combination can
be marked unsupported.

Cost: up to 3.5 GPU-hours for a full-length arm; a 90-minute cap already
passes the point where both measured arms were repeating (call 11-40).
Download: none. The GGUF is in the llama.cpp cache from run 1.
Risk: none to machine state. It is one server, one context, one load.

---

## Tier 2 — measurements that fill the queue and settle open items

### T2.1 llama.cpp context ramp with the MTP drafter (section F)

Contexts 8K, 32K, 64K, 128K, 262K with the drafter enabled. Record at
each step: does the drafter allocate, wired memory before and after, and
draft acceptance. Then the same ramp with `-ngl 999` replaced by
`--fit on`. Sample `vmmap --summary` IOAccelerator once on llama-server,
which also answers whether that meter is useless in general or only for
MLX.

Cost: about 1.5 GPU-hours, ramped. Download: none.
Answer: the exact context where the vetted 262144 config breaks.

### T2.2 Qwen3.8 window arithmetic and ceiling re-probe (section E)

Two parts. Re-probe the context ceiling at the wired limit this session
runs at; the ~29K figure was measured at 25000. Then propose a
`maxTokens` and `contextWindow` pair that can fit, because 16384 plus
26624 cannot once a prompt passes 10K. The fix is a diff for the owner,
not an applied change: it alters a published measurement.

Cost: about 1 GPU-hour. Download: none.

### T2.3 Sampler probe against the loop (section I)

Two questions, one kit. First, do the servers honour the parameters, or
drop them silently: `frequency_penalty` and `presence_penalty` on both,
DRY and XTC on llama-server, `repetition_penalty` with a
`repetition_context_size` sized to several tool calls on mlx_lm.server.
Second, does any of them stop the replay loop. `repeat_penalty` is
already a known negative against Gemma-4, so DRY is the interesting arm.

Cost: about 1 GPU-hour, and it re-uses the T1.1 server. Download: none.

### T2.4 Loop stop as a harness extension (section I)

Build the "N identical consecutive tool calls" rule as a pi extension
that ENDS the run with its own `end_reason`. Measure it unscored on the
replay kit. It is a stop, not a rescue: a rescue changes what the
benchmark measures.

Cost: 0 GPU for the code, about 30 minutes of GPU to fire it once on the
replay. Download: none.

---

## Tier 3 — needs a decision, a download, or a scored run

### T3.1 Bonsai thinking OFF and q8_0 KV (section B)

The owner already decided the direction on 2026-09-03. The cheap part is
the config fix on both the MLX serving config and the prism fork. The
expensive part is proving it, because the evaluation is a Mendel run.

Cost: config work is minutes; a Mendel arm is 3-5 GPU-hours.
Download: none.
Recommend: land the config change in this run, schedule the Mendel arm
for a benchmark run, not a research run.

### T3.2 LM Studio trial for Qwen3.8-27B (section H)

Motivated by the 26624 window. But section E shows 26624 is our own
harness number, so this trial buys nothing until T2.2 lands. Also check
whether 0.4.23 exposes the MLX context AutoFit toggle, because an
auto-fit window the harness does not know about is worth nothing.

Cost: about 2 GPU-hours. Download: none if the model is cached in LM
Studio; otherwise it needs one.
Recommend: after T2.2, and only if T2.2 leaves a real ceiling problem.

### T3.3 Re-quantization A/B (section C)

`mlx_lm.convert` from original weights, A/B against the mlx-community
download. This needs the ORIGINAL weights, which the machine holds only
as quants. It is a download of tens of gigabytes.

Cost: 2-3 GPU-hours plus a large download. Download: YES, large.
Recommend: park unless the owner wants it.

### T3.4 New model candidates (section H)

GLM-4.7-Flash, Poolside Laguna XS 2.1, Mistral Devstral Small 2. Each
needs a coding and agentic benchmark re-filter before it is shortlisted,
then a download.

Cost: filtering is free; each download is 15-25 GB.
Recommend: filter now, download only on owner approval.

---

## Proposed order for this session

1. T0.1 to T0.3 while the machine warms.
2. T1.1, the llama-server replay. This is the long GPU item.
3. T2.1, the context ramp, next, because it is a clean ramp.
4. T2.3 rides on the T1.1 server if it is still up.
5. T0.4 and T2.4 code work between GPU items.

## Two questions for the owner

1. **Wired limit.** The reboot cleared run 1's `iogpu.wired_limit_mb=24000`
   and it now reads the boot default. Run 1 measured under 24000, and the
   published Qwen3.8 ceiling was measured at 25000. Should this session
   set 24000 again for comparability, or measure at the default?
2. **Scope.** Which tiers may run unattended tonight?
