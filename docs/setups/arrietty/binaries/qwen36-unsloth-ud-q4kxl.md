# Qwen3.6-35B-A3B UD-Q4_K_XL (unsloth) on RTX 5060 Ti 16 GB

File: [`unsloth/Qwen3.6-35B-A3B-MTP-GGUF`](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-MTP-GGUF),
`Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf`, revision `5bc3e23`, about 23 GB,
with the MTP drafter embedded in the file. Server: llama-server on
CUDA, q8_0 KV, `--n-cpu-moe` for the experts that do not fit on the
card. Every run of this file on this machine is on this page, retired
and superseded rows included; a run a harness or serving defect voided
is not.

- **Why it is here.** The card's file is larger than the card, so a
  measured count of expert layers stays in host RAM. A community
  NVFP4 repack of the same model failed a tensor-count check at load,
  so the owner picked this mainstream unsloth build over a niche one
  (owner, 2026-09-14).
- **What it settled.** The MTP drafter pays at every depth on this
  card: n-max 2, with 21 expert layers in host RAM, is the served arm,
  fastest at 4K and 65K and within the spread of n-max 3 at 97K. The
  guided agent task scored 48.5, 6 of 8 libraries, and ended on a
  repetition loop at the seventh.
- **Where it stands.** EvalPlus at thinking on reads 0.945/0.902, 6 of
  164 answers empty, against the Mac's 0.957/0.939 with 2 empty on the
  same file.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" page="/setups/arrietty/binaries/qwen36-unsloth-ud-q4kxl" top /> | **97k** | mem | <TokCell shallow="61.16" deep="45.42" top-shallow top-deep /> | **14.7 GB** | <ScoreCell value="0.945/0.902" sub="96% completion" top /> | <ScoreCell value="48.5" note="75%" pill="mendel-guided" top /> | <span title="EvalPlus 3h12 · Mendel 0h27">3h39</span> |
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" page="/setups/arrietty/binaries/qwen36-unsloth-ud-q4kxl" />](../benchmarks/qwen3.6-35b-a3b.md) | 24154 | <ScoreCell value="0.945/0.902" sub="96% completion" top /> | † unproven | <TokCell shallow="61.16" deep="45.42" /> | 3h12 |
<!-- gen:binary-evalplus:end -->

The 6 empty answers are unproven because the run saved no finish log.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/2" kv="q8_0" effort="on" page="/setups/arrietty/binaries/qwen36-unsloth-ud-q4kxl" /> | guided-v3.0 | 96k | **48.5** | 6/8/partial | 27.2 | 10,958k | 86k | 1 | 266 | 6 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:binary-mendel:end -->

The row ended with 6 of 8 libraries done and a live loop stop: five
identical edit calls in a row on the seventh library, declared after
27.2 minutes. Three of the six commits moved `.husky/pre-commit` aside
and back around `git commit`, a functional bypass the literal
`--no-verify` check in `score.mjs` does not see.

## Speed and context

<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="q8_0" hide="drafter,effort" />

| measurement | date | config | result |
|---|---|---|---|
| `--n-cpu-moe` ladder and no-drafter arm | 2026-09-13 | `-c 98304`, `--n-cpu-moe 17` | 55.81 tok/s at 4K, 37.80 at 97280; swap flat around 4.5-4.7 GB |
| drafter climb, n-max 1 | 2026-09-13 | `--n-cpu-moe 19` | 60.60 tok/s at 4K, 37.92 at 97280, faster than no drafter at every depth; acceptance 0.78-0.84 |
| drafter climb, n-max 2 (served) | 2026-09-13 | `--n-cpu-moe 21` | 61.16 tok/s at 4K, 50.04 at 65536, 45.42 at 97280; acceptance 0.63-0.92 |
| drafter climb, n-max 3 | 2026-09-13 | `--n-cpu-moe 21` | 57.85 tok/s at 4K, 47.25 at 65536, 46.76 at 97280; acceptance 0.54-0.77, the last arm in the climb |

The full curves are on [the benchmarks page](../benchmarks/qwen3.6-35b-a3b.md).
The Mac's q8_0 KV row of the same file at n-max 3 reads 43.7 tok/s at
4K and 13.0 at 82K, on the served arm chosen there.

## Log

- 2026-09-13 — A community NVFP4+MTP repack of this model
  (`michaelw9999/Qwen3.6-35B-A3B-NVFP4-MTP-GGUF`) fails to load at any
  `--n-cpu-moe` or `-c`: a tensor-count mismatch, 1079 tensors against
  an expected 1101. Not a memory condition, so the coordinator stops
  and asks. `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-14 — Owner picks this unsloth UD-Q4_K_XL file over the
  failed NVFP4 repack, a popular stable release over a niche build.
  `--n-cpu-moe` ladder and drafter climb run: no drafter at 17 (55.81
  tok/s at 4K, 37.80 at 97280), n-max 1 at 19 (60.60, 37.92), n-max 2
  and n-max 3 at 21 (61.16 and 45.42 for n-max 2; 57.85 and 46.76 for
  n-max 3). n-max 2 is named the served arm: fastest at 4K and 65K,
  within the spread of n-max 3 at 97K, and needs less VRAM headroom
  for its smaller draft window. `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-14 to 2026-09-15 — Mendel smoke on the served arm (window
  94208, level high) passes clean, 7 calls, 1 commit, no loop.
  Guided agent task scores 48.5 raw, 6 of 8 libraries done, on a
  27.2-minute run: trap A shipped (an `fs.promises.glob().then()`
  call), a second `fs`-not-imported bug shipped in the same commit,
  and three of six commits moved the pre-commit hook aside and back
  around `git commit`, a bypass the automatic `--no-verify` check
  misses. The run ends on a five-times repetition loop at the seventh
  library. `hardware/arrietty/benchmarks/bench17/`.
- 2026-09-15 to 2026-09-16 — EvalPlus at thinking on, served arm,
  `-c 32768`: calibration converges cleanly on 10 of 10 rows (unlike
  both Qwen3.8 builds on this card), budget 24154 from the standard
  formula. The host runs under memory pressure through the block,
  0.4.0-dev with 21 expert layers in host RAM, about 1.1 to 1.5 GB
  free and 10 to 11 GB of swap in use, stable and not growing. Scores
  0.945/0.902, 100% completion, in 192.0 minutes. The run's own
  `results.md` reports 0 empty answers; the coordinator re-derived the
  count from the samples on 2026-09-16 and found 6 of 164 empty, cause
  unproven because the run saved no finish log.
  `hardware/arrietty/benchmarks/bench19/`.
