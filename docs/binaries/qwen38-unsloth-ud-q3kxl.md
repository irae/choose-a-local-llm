# Qwen3.8-27B UD-Q3_K_XL (unsloth)

File: [`unsloth/Qwen3.8-27B-GGUF`](https://huggingface.co/unsloth/Qwen3.8-27B-GGUF),
`Qwen3.8-27B-UD-Q3_K_XL.gguf`, revision `4ca7207`, about 13.44 GB,
Dynamic v3.0. Server: llama-server, f16 KV on the M1 Max 32 GB, the
only machine that served it. This file has no configuration row.
Every run of it on every machine is on this page, retired and
abandoned blocks included; a run a harness or serving defect voided
is not.

- **Why it is here.** One of three 3-bit candidates for the 12 GB
  budget, picked 2026-09-07 as the only K-quant of the three, so its
  speed does not depend on the i-quant Metal path
  (`hardware/kamaji/research/qwen38-configs.md`).
- **What it settled.** The drafter is a trade against depth on this
  build: with the MTP drafter on, the creep mem-stops at 49198 tokens;
  with it off, the creep runs clean past 131072, the depth list's own
  end. The build was dropped as a candidate by the owner on 2026-09-08.
- **Where it stands.** No configuration row and no scoring run. The
  creep stands as a measurement.

## Configurations

<!-- gen:binary-rows:start -->
No configuration row.
<!-- gen:binary-rows:end -->

No configuration row. The build was dropped as a candidate before any
scoring block ran.

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
No EvalPlus run yet.
<!-- gen:binary-evalplus:end -->

No scored EvalPlus run. The build passed its EvalPlus smoke in the
research run (4 of 4, 0 empty, 2804 of 8192 tokens, at `-c 49152`,
2026-09-08). A full run without the drafter started at budget 8192
in the next run and stopped at 39 of 164 problems, 0 empty, when the
coordinator's plan update dropped the build; that partial data stays
committed as an abandoned partial, not scored
(`hardware/kamaji/benchmarks/bench12/state.md`).

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
No Mendel run yet.
<!-- gen:binary-mendel:end -->

No Mendel run. The build passed its Mendel smoke in the research run
on 2026-09-08 (12 tool calls, 1 commit, no loop, clean, 192 s, at
`-c 49152`), but the owner dropped it before any scored block started.

## Speed and context

Measured on the M1 Max 32 GB, the only machine that served this file.

<ModelSpec base="Qwen3.8-27B" quant="UD-Q3_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="f16" hide="drafter,effort" />

| measurement | date | config | result |
|---|---|---|---|
| ladder and creep, with the MTP drafter | 2026-09-07 to 2026-09-08 | f16 KV, MTP n-max 3, wired 25000, `-c 131072` | clean ceiling 49198 tokens at 12.45 tok/s; swap grew 3 MB at 65578, a memory stop |
| ladder and creep, drafter dropped | 2026-09-08 | f16 KV, wired 25000, `-c 131072`, `--spec-type draft-mtp` removed | ran the whole depth list clean with no stop; 131098 tokens at 8.58 tok/s, swap delta negative from the second step on |

The full curves are on [the benchmarks page](../setups/kamaji/benchmarks/qwen3.8-27b.md).

## Log

- 2026-09-07 — Picked as one of three 3-bit candidates in a research
  run on the M1 Max 32 GB, with the AtomicChat and ISTA-DASLab files; the
  owner approved the three downloads the same evening.
  `hardware/kamaji/research/qwen38-configs.md`.
- 2026-09-07 to 2026-09-08 — Research run: ladder and creep with the
  MTP drafter on, at wired 25000, f16 KV. Clean ceiling 49198 tokens
  at 12.45 tok/s; a stray downloader process starved the first attempt
  of memory, caught and re-run clean. `hardware/kamaji/research/run3/`.
- 2026-09-08 — Research run: ladder and creep with the drafter
  removed, everything else unchanged. Ran the whole depth list clean
  past 131072, the list's own end, at 8.58 tok/s and with the swap
  delta negative from the second step on — well over 2.6 times the
  with-drafter depth. The drafter cost is small: one 1849-token
  completion on a 131k prompt reads 13.55 tok/s with the drafter
  against 13.95 without it, and the creep reads 9.14 against 8.58
  tok/s near 131k depth. `hardware/kamaji/research/run3/`.
- 2026-09-08 — Research run: both smokes passed at `-c 49152`, level
  with the 4-bit control — EvalPlus 4 of 4 with no empty, and the
  Mendel smoke with 12 tool calls, 1 commit and no loop.
  `hardware/kamaji/research/run3/`.
- 2026-09-08 — Named a candidate for the next run, second seat behind
  the ISTA-DASLab build, ahead of the AtomicChat file.
  `hardware/kamaji/benchmarks/bench12/AGENT.md`.
- 2026-09-08 — `qwen38-nodrafter-evalplus` (the no-drafter config)
  started there: calibration converged at budget 8192, full
  EvalPlus launched. Stopped mid-run at 39 of 164 problems, 0 empty,
  when a coordinator plan update landed: the owner dropped the build
  as a candidate, because its creep came from a strip item meant for
  the served 4-bit row, not from a real 3-bit trial. The AtomicChat
  build took the vacated seat. The partial EvalPlus data and the
  server and memory logs stay committed as an abandoned partial, not
  scored; the creep itself still stands as a measurement.
  `hardware/kamaji/benchmarks/bench12/state.md` (commit `de79d22`,
  merged as `1ced11e`).
