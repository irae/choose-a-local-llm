# Container trials: better builds of models we already run

Status: draft, owner criteria of 2026-09-04. Needs hardware: yes, for
the three quick checks per candidate; the survey needs none.

## What this is for, the owner's criteria

Not doing:

- Adding models to make the benchmark bigger.
- Trying older models that already score below the current set.

Doing:

1. **Same weights, better container.** A published quant of a model
   we already benchmark, made with a method that claims more quality
   per byte on Apple Silicon (mixed-precision OptiQ, QAT builds,
   unsloth dynamic UD quants).
2. **Lower quant, larger context, most of the intelligence kept.** A
   3-bit or 2-bit build of a model we already benchmark, when it buys
   context we cannot reach at 4-bit.
3. **A smaller model that credible reports say matches a larger one
   we run** (the Bonsai case: a compressed 27B built from a model we
   already score).

## Entry criteria, written so a runner can apply them

Research runs no full EvalPlus and no scored Mendel. Those are bench
runs, and this project scores its own quantized files there. Research
tries candidates and reports whether they look better; the evidence it
uses is what the community already has (user impressions, "this is my
candidate for real coding use on a 32 GB machine" reports, a quant publisher's own proof
that their build of the same model at the same size is done better)
plus the three quick checks below.

A candidate container enters a trial only if ALL hold:

- It is a claimed improvement on something we already run, of one of
  the three shapes above. A new model in the same size class enters
  only when reports place it at or above our best in that class, and
  its llama.cpp or MLX support is merged, not announced.
- Weights at the chosen quant leave at least 32K of KV inside the
  wired limit of the machine file at the model's KV cost (run 9 for
  llama-server; the measured ceiling for MLX).
- The HF revision is pinned at download time and added to
  `run2/results/model-pins.md`.
- K-quants only on llama-server; IQ quants are reported 3.5x slower on
  Apple GPUs, so a decode check comes before any IQ trial.

The three quick checks, in this order, always against the config we
run today for that model or class:

1. **Context sweep**, one or two configs (GGUF and MLX where both
   exist), with the creep runner. The ceiling and the curve decide
   whether the container is worth the next two checks.
2. **Mendel smoke**, `benchmarks/mendel-smoke.sh`, against the same
   smoke on the config we run today.
3. **EvalPlus smoke**, `benchmarks/evalplus-smoke.py`, same budget on
   both sides, against the current config.

A trial is a KEEP when the sweep is not worse, and the two smokes are
level or better. A keep becomes a bench item (full EvalPlus, then a
scored Mendel row); research never publishes a number.

## The survey, then the trials

The survey needs no hardware, so it is planning: list candidates of
the three shapes for Qwen3.6-35B-A3B, Qwen3.8-27B and Gemma-26B-A4B,
with size, revision, the claim and its proof; compute the context each
buys from run 9's KV cost per token; shortlist at most three. Run 2's
survey covered OptiQ only and found it bigger than our 4-bit builds
(`run2/results/quant-survey.md`).

The run then executes the approved trials: download at a pinned
revision (a planning decision written into the runbook), the three
quick checks, the keep verdict with the numbers beside it. Judgment is
in reading a borderline result and in stopping a trial early when the
sweep already says no.

## Survey results, 2026-09-07

Desk work only. No hardware used. Repository listings and model cards
read from the Hugging Face Hub API and file headers; sizes are the
`Content-Length` of the actual weight file, not a card's stated figure.
Speed is not in this survey; it is a Mac measurement and stays unknown
until the trial runs.

### Shape 1 — same weights, better container

| Model | Publisher / repository | Claim | File size | Revision to pin | Proof offered |
| --- | --- | --- | --- | --- | --- |
| Qwen3.6-35B-A3B | `mlx-community/Qwen3.6-35B-A3B-OptiQ-4bit` | OptiQ mixed-precision 4-bit, sensitive layers at 8-bit | 22.14 GB | `70a3aa32c7feef511182bf16aa332f37e8d82014` | None published for this model specifically; the OptiQ card family reports a capability score against its own sensitivity reference, not against uniform 4-bit (`run2/results/quant-survey.md`) |
| Qwen3.6-35B-A3B | GGUF: no QAT or OptiQ-style build found | — | — | — | None. The only GGUF for this model is unsloth's dynamic UD line, already our pinned baseline |
| Qwen3.8-27B | `mlx-community/Qwen3.8-27B-OptiQ-4bit` | Same OptiQ method | 19.43 GB | (see `run2/results/quant-survey.md`, already surveyed) | Capability score 87.98%, no uniform-4-bit number beside it |
| Qwen3.8-27B | `unsloth/Qwen3.8-27B-GGUF:UD-Q4_K_XL` | Unsloth "Dynamic 2.0": selective higher precision on sensitive tensors, same nominal bit width as our current `Q4_K_M` pin | 17.56 GB | `4ca720788d1e01f1bff70c033e0d0028fd02e502` | Publisher blog claims across the UD line generally; no model-specific score card on this repo |
| Qwen3.8-27B | `ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF` | GSQ-RCO quantization method | IQ2_S 9-10 GB class, IQ3_S 12-13 GB class (not measured, IQ only) | `d562806dbafae37109975e970aae91b43e73b440` | None on the card beyond the method name; also IQ-only, so it fails the K-quants-only rule before proof matters |
| Gemma-4-26B-A4B | `google/gemma-4-26B-A4B-it-qat-q4_0-gguf` | Official Google QAT (quantization-aware trained) int4, from the model's own publisher | 14.44 GB | `d1c082be9cf3c8a514acf63b8761f4b41935842e` | Google's QAT method write-ups for the Gemma family report smaller quality loss than post-training quant at the same width; no HumanEval+/EvalPlus number on this card itself |
| Gemma-4-26B-A4B | `unsloth/gemma-4-26B-A4B-it-qat-GGUF:UD-Q4_K_XL` | Google's QAT weights repackaged through unsloth's dynamic K-quant | 14.25 GB | `7b92b5b28818151e8669af2e45e88d6086f490dd` | Same as above, plus the unquantified UD claim; no independent score |
| Gemma-4-26B-A4B | `mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit` | Same OptiQ method | 17.63 GB | `e0061bda54f72709cf6fa51229530c3b14cd9d7d` | Same capability-score-only proof pattern as the other OptiQ repos |

### Shape 2 — lower quant, larger context

K-quants only, per the entry criteria; IQ files are listed in the
shape-1 table above only to record that they exist, not as shape-2
candidates.

| Model | Publisher / repository (K-quant) | File size | Revision to pin | Proof offered |
| --- | --- | --- | --- | --- |
| Qwen3.6-35B-A3B | `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q3_K_XL` | 17.23 GB | `5bc3e238d916f48a861bac2f8a1990a0e9b7e98d` | None model-specific; the UD line's general claim only |
| Qwen3.6-35B-A3B | `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q2_K_XL` | 12.57 GB | `5bc3e238d916f48a861bac2f8a1990a0e9b7e98d` | None model-specific |
| Qwen3.8-27B | `unsloth/Qwen3.8-27B-GGUF:UD-Q3_K_XL` | 13.15 GB | `4ca720788d1e01f1bff70c033e0d0028fd02e502` | None model-specific |
| Qwen3.8-27B | `unsloth/Qwen3.8-27B-GGUF:UD-Q2_K_XL` | 9.83 GB | `4ca720788d1e01f1bff70c033e0d0028fd02e502` | None model-specific |
| Gemma-4-26B-A4B | `unsloth/gemma-4-26B-A4B-it-GGUF:UD-Q3_K_XL` | 12.91 GB | `c099eb48e663fd284577b04978a94ffccb261841` | None model-specific |
| Gemma-4-26B-A4B | `unsloth/gemma-4-26B-A4B-it-GGUF:UD-Q2_K_XL` | 10.55 GB | `c099eb48e663fd284577b04978a94ffccb261841` | None model-specific |

No MLX 2-bit or 3-bit build of any of the three models was found on
`mlx-community`; `mlx-community` stops at 4-bit going down (5, 6, 8-bit
and `bf16` go up). Shape 2 is a GGUF-only shape for this set of models.

### Shape 3 — a smaller model reported to match a larger one

Applies to the two MoE models only. Qwen3.8-27B is dense, and REAP
(the pruning method behind every candidate here) removes MoE experts,
so it has no shape-3 candidate; that gap is architectural, not a gap
in the search.

| Model | Publisher / repository | Claim | File size | Revision to pin | Proof offered |
| --- | --- | --- | --- | --- | --- |
| Qwen3.6-35B-A3B | `crucible-labs/Qwen3.6-35B-A3B-REAP-48-v2-GGUF` | 48% of experts pruned (REAP), one mixed-quant GGUF | 9.43 GB | `b960e1f922fb4eb62113831d9629afa7b320930f` | Publisher's own `model-index`: EvalPlus HumanEval+ pass@1 0.909, MBPP+ 0.757, BFCL(simple) 0.932 — self-reported, not verified by our gate |
| Qwen3.6-35B-A3B | `mlx-community/Qwen3.6-35B-A3B-OptiQ-4bit-REAP-19B` | OptiQ quant stacked on REAP pruning (pruned to a ~19B-equivalent footprint) | 12.33 GB | `95193a560399d81cd6272c393db8e96d59f54f50` | None. Two unverified changes (OptiQ, REAP) in one file, with no combined score |
| Qwen3.6-35B-A3B | `DJLougen/Qwen3.6-35B-A3B-REAP-90pct-GGUF` | 90% of experts pruned | 3.57 GB (`Q4_K_M`) | `e0ce5c81f9b9c261cab37096bc33cb99f6c1a118` | None. No model card benchmarks at all |
| Gemma-4-26B-A4B | `crucible-labs/Gemma4-26B-A4B-REAP-25-GGUF` | 25% of experts pruned (REAP), two mixed-quant GGUFs | 9.15 GB (`Q2_K-mixed`) / 10.31 GB (`Q3_K-mixed`) | `1981a7054d03e02e1ca66781ee933321318adc10` | Publisher's own `model-index`: HumanEval pass@1 0.927, MBPP 0.704, IFEval 0.804/0.866 (`Q3_K-mixed`) — self-reported, and note these are the plain HumanEval/MBPP sets, not the "+" sets our own gate uses, so they are not the same metric as our baseline score |
| Gemma-4-26B-A4B | `mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit-REAP-14B` | OptiQ stacked on REAP, pruned to a ~14B-equivalent footprint | 10.06 GB | `6445e4283800c6a54c8b50b77d3972a30de08213` | None. Same two-unverified-changes problem as the Qwen3.6 REAP+OptiQ repo |

### The context each candidate buys

Method: `context = (wired_limit − weights − fixed_overhead) × 1024 ÷
KV_per_token_KiB`, capped at the model's trained window. `wired_limit`
is 24000 MB, the machine's `iogpu.wired_limit_mb`. `fixed_overhead` is
solved from one real measured row per model and runtime in
`docs/setups/m1-max-32gb/comparison.md` (weights, KV at the measured
context, and wired all known, overhead is the remainder) — it is a
calibration, not a second measurement, and it can be wrong for a
candidate whose compute-buffer needs differ from the row it was solved
from. Weights are the file size above, taken as listed (GB treated as
1000 MB, the convention already used in `run3/unscheduled/`
small-agent-models.md`). All numbers below are computed, unverified
against hardware.

**KV cost per token, f16**, verified from each model's `config.json`
(Qwen3.6:
[Hub](https://huggingface.co/Qwen/Qwen3.6-35B-A3B/raw/main/config.json),
Gemma-26B:
[Hub](https://huggingface.co/google/gemma-4-26B-A4B-it/raw/main/config.json)),
same method as `kv-quant-on-m1.md`'s Qwen3.8 section:

| Model | Layers that own a cache | KV heads × head_dim | KV per token, f16 |
| --- | --- | --- | --- |
| Qwen3.6-35B-A3B | 10 of 40 (`full_attention`, one in every four) | 2 × 256 | 10 × 2 × 2 × 256 × 2 bytes = 20 KiB |
| Qwen3.8-27B | 16 of 64 (`full_attention`) | 4 × 256 | 64 KiB (from `kv-quant-on-m1.md`) |
| Gemma-4-26B-A4B | 5 of 30 (`full_attention`, the global layers; `num_global_key_value_heads`/`global_head_dim`) | 2 × 512 | 5 × 2 × 2 × 512 × 2 bytes = 20 KiB, past the 1024-token sliding window that the other 25 layers cap at |

**Overhead calibration**, from the real f16 rows in
`docs/setups/m1-max-32gb/comparison.md`:

| Model, runtime | Calibration row | Weights | KV at that ctx | Wired measured | Overhead solved |
| --- | --- | --- | --- | --- | --- |
| Qwen3.6-35B-A3B, GGUF f16 | `-c 33792`, 24.9 GB wired | 23,000 MB | 660 MB | 24,900 MB | 1,240 MB |
| Qwen3.8-27B, GGUF f16 | `-c 49152`, 23.5 GB wired | 18,700 MB | 3,072 MB | 23,500 MB | 1,728 MB |
| Gemma-4-26B-A4B, GGUF f16 | `-c 212992`, 25.6 GB wired | 17,500 MB | 4,160 MB | 25,600 MB | 3,940 MB |
| Qwen3.6-35B-A3B, MLX | ~37K, 18.7 GB wired | 20,400 MB | 723 MB | 18,700 MB | negative (−2,423 MB); clamped to 0. The cached weight file appears larger than what the runtime actually holds resident; unexplained, flag for the trial |
| Qwen3.8-27B, MLX | ~28K, 22.0 GB wired | 16,100 MB | 1,750 MB | 22,000 MB | 4,150 MB |
| Gemma-4-26B-A4B, MLX | 70K, 20.0 GB wired | 15,400 MB | 1,367 MB | 20,000 MB | 3,233 MB |

Note on the Qwen3.6 GGUF row: solving overhead from this row leaves
zero KV budget by construction, and the measured wired (24,900 MB)
already sits above the 24000 MB `wired_limit_mb` setting — this machine
does not hard-cap exactly at that number for this model, a fact the
context prediction below inherits without explaining it further.

**Predicted context, shape 1 candidates:**

| Model | Candidate | Predicted context |
| --- | --- | --- |
| Qwen3.6-35B-A3B, MLX | OptiQ-4bit, 22.14 GB | 95,232 tokens (overhead clamped to 0, see caveat above) |
| Qwen3.8-27B, GGUF | unsloth UD-Q4_K_XL, 17.56 GB | 75,392 tokens, against the current pin's real measured 49,152 |
| Qwen3.8-27B, MLX | OptiQ-4bit, 19.43 GB | 6,720 tokens — the OptiQ tax is severe here, confirms `run2/results/quant-survey.md`'s qualitative warning with a number |
| Gemma-4-26B-A4B, GGUF | Google QAT `q4_0`, 14.44 GB | 262,144 (trained-window capped), room to spare |
| Gemma-4-26B-A4B, GGUF | unsloth QAT UD-Q4_K_XL, 14.25 GB | 262,144 (trained-window capped) |
| Gemma-4-26B-A4B, MLX | OptiQ-4bit, 17.63 GB | 160,614 tokens |

**Predicted context, shape 2 candidates:**

| Model | Candidate | Predicted context |
| --- | --- | --- |
| Qwen3.6-35B-A3B | UD-Q3_K_XL, 17.23 GB | 262,144 (trained-window capped), against the current pin's real measured 33,792 |
| Qwen3.6-35B-A3B | UD-Q2_K_XL, 12.57 GB | 262,144 (trained-window capped) |
| Qwen3.8-27B | UD-Q3_K_XL, 13.15 GB | 145,952 tokens, against the current pin's real measured 49,152 |
| Qwen3.8-27B | UD-Q2_K_XL, 9.83 GB | 199,072 tokens |
| Gemma-4-26B-A4B | UD-Q3_K_XL, 12.91 GB | 262,144 (trained-window capped); the current f16 pin already reaches this window, so the gain is disk only |
| Gemma-4-26B-A4B | UD-Q2_K_XL, 10.55 GB | 262,144 (trained-window capped), same note |

**Predicted context, shape 3 candidates:**

| Model | Candidate | Predicted context |
| --- | --- | --- |
| Qwen3.6-35B-A3B | REAP-48-v2 GGUF, 9.43 GB | 262,144 (trained-window capped) |
| Qwen3.6-35B-A3B | OptiQ-4bit-REAP-19B MLX, 12.33 GB | 262,144 (trained-window capped, overhead clamped to 0) |
| Gemma-4-26B-A4B | REAP-25 GGUF, 9.15-10.31 GB | 262,144 (trained-window capped) |
| Gemma-4-26B-A4B | OptiQ-4bit-REAP-14B MLX, 10.06 GB | 262,144 (trained-window capped) |

### Shortlist, ranked

1. **`google/gemma-4-26B-A4B-it-qat-q4_0-gguf`** (14.44 GB, shape 1).
   Proves whether Google's own QAT build beats our current dynamic
   `UD-Q4_K_XL` on quality, at 3 GB less disk and no context cost —
   the trained window stays fully reachable either way. Meets the
   entry criteria: it is a claimed improvement on a model we run,
   K-quant-compatible (`q4_0` is a legacy, non-IQ format), and leaves
   far more than 32K of KV.

2. **`unsloth/Qwen3.8-27B-GGUF:UD-Q3_K_XL`** (13.15 GB, shape 2).
   Qwen3.8 is the model whose context most limits it today — the real
   measured ceiling is 49,152 tokens, and the Mendel agent task needs
   about 46K of that, leaving almost no margin
   (`docs/setups/m1-max-32gb/comparison.md`, "the window decides the
   agent task on dense Qwen3.8"). This candidate predicts 145,952
   tokens, nearly 3x the room, for one quant step down. Meets the
   entry criteria on context; whether quality holds is exactly what
   the three quick checks are for.

3. **`unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q3_K_XL`** (17.23 GB, shape 2).
   Qwen3.6's current GGUF pin sits at the wired ceiling with zero
   spare KV budget by this survey's own arithmetic, and its real
   measured window (33,792) is the smallest of the three models
   despite Qwen3.6 being the fastest decoder in the fleet. This
   candidate predicts the full trained window. Meets the entry
   criteria; it is the model most likely to show a visible ceiling
   jump from the sweep alone.

### Downloads to authorize, if all three are approved

| Candidate | Download |
| --- | --- |
| `google/gemma-4-26B-A4B-it-qat-q4_0-gguf` | 14.44 GB (`gemma-4-26B_q4_0-it.gguf`) |
| `unsloth/Qwen3.8-27B-GGUF:UD-Q3_K_XL` | 13.15 GB |
| `unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q3_K_XL` | 17.23 GB |
| **Total** | **44.8 GB** |

### Ruled out

- **Every OptiQ MLX build (all three models).** Carries forward
  `run2/results/quant-survey.md`'s finding and extends it: OptiQ is
  bigger than the current 4-bit MLX build on every model surveyed here
  too (Qwen3.6 +1.7 GB, Gemma-26B +2.2 GB, on top of the already-known
  Qwen3.8 +2.8 GB), and no repo publishes a same-size head-to-head
  against uniform 4-bit.
- **`ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF`.** Every quant level is IQ
  (`IQ2_S`, `IQ2_XS`, `IQ3_S`, `IQ3_XXS`); fails the K-quants-only rule
  before its proof (there is none on the card) even matters.
- **`ISTA-DASLab/Qwen3.6-35B-A3B-2Bit-GSQ` and
  `ISTA-DASLab/Qwen3.8-27B-3Bit-GSQ`.** Despite the names, both repos
  hold only unquantized `safetensors` shards, not a GGUF or MLX file
  llama-server or mlx_lm.server can load.
- **`DJLougen/Qwen3.6-35B-A3B-REAP-90pct-GGUF`.** No proof offered at
  all, and 90% expert pruning is far past "credible reports say it
  matches" with zero evidence behind it.
- **Qwen3.8-27B, shape 3.** No candidate exists. REAP prunes MoE
  experts; Qwen3.8-27B is dense. The shape does not apply to this
  model.
- **`unsloth/gemma-4-26B-A4B-it-qat-GGUF`.** Near-duplicate of the
  shortlisted Google QAT build (same source weights, unsloth's UD
  quant on top instead of `q4_0`). Kept as a fallback if the Google
  build underperforms, not worth a second download up front.
- **The 2-bit candidates (`UD-Q2_K_XL`, all three models).** The 3-bit
  step already shortlisted buys more context than the entry criteria
  need; a 2-bit build is a deeper cut to try only if the 3-bit trial's
  sweep says there is still room to spend and the smoke checks hold.
- **`crucible-labs/Qwen3.6-35B-A3B-REAP-48-v2-GGUF`.** The publisher's
  own EvalPlus pass@1 (0.909) sits below our current baseline's
  measured 0.951, so its own numbers do not support the shape-3 claim
  ("matches a larger one"). Kept as a reserve.
- **`crucible-labs/Gemma4-26B-A4B-REAP-25-GGUF`.** Self-reported scores
  are on plain HumanEval/MBPP/IFEval, not the "+" sets our gate scores
  on, so they cannot be read against our baseline row at all. Kept as
  a reserve behind the two Gemma-26B candidates already ranked above
  it in the shape-1 and shape-2 tables.
- **The REAP+OptiQ MLX stacks (`Qwen3.6-35B-A3B-OptiQ-4bit-REAP-19B`,
  `gemma-4-26B-A4B-it-OptiQ-4bit-REAP-14B`).** Two unverified changes
  in one file (an unproven quant method on top of an unproven pruning
  method), with no combined score published. Lowest confidence of
  every shape-3 candidate found.

### Sources

- [Qwen3.6-35B-A3B config.json](https://huggingface.co/Qwen/Qwen3.6-35B-A3B/raw/main/config.json)
- [Gemma-4-26B-A4B-it config.json](https://huggingface.co/google/gemma-4-26b-a4b-it/raw/main/config.json)
- [mlx-community/Qwen3.6-35B-A3B-OptiQ-4bit](https://huggingface.co/mlx-community/Qwen3.6-35B-A3B-OptiQ-4bit)
- [mlx-community/Qwen3.8-27B-OptiQ-4bit](https://huggingface.co/mlx-community/Qwen3.8-27B-OptiQ-4bit)
- [mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit](https://huggingface.co/mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit)
- [mlx-community/Qwen3.6-35B-A3B-OptiQ-4bit-REAP-19B](https://huggingface.co/mlx-community/Qwen3.6-35B-A3B-OptiQ-4bit-REAP-19B)
- [mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit-REAP-14B](https://huggingface.co/mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit-REAP-14B)
- [unsloth/Qwen3.6-35B-A3B-MTP-GGUF](https://huggingface.co/unsloth/Qwen3.6-35B-A3B-MTP-GGUF)
- [unsloth/Qwen3.8-27B-GGUF](https://huggingface.co/unsloth/Qwen3.8-27B-GGUF)
- [bartowski/Qwen3.8-27B-GGUF](https://huggingface.co/bartowski/Qwen3.8-27B-GGUF)
- [bartowski/Qwen_Qwen3.6-35B-A3B-GGUF](https://huggingface.co/bartowski/Qwen_Qwen3.6-35B-A3B-GGUF)
- [unsloth/gemma-4-26B-A4B-it-GGUF](https://huggingface.co/unsloth/gemma-4-26B-A4B-it-GGUF)
- [unsloth/gemma-4-26B-A4B-it-qat-GGUF](https://huggingface.co/unsloth/gemma-4-26B-A4B-it-qat-GGUF)
- [bartowski/google_gemma-4-26B-A4B-it-GGUF](https://huggingface.co/bartowski/google_gemma-4-26B-A4B-it-GGUF)
- [google/gemma-4-26B-A4B-it-qat-q4_0-gguf](https://huggingface.co/google/gemma-4-26B-A4B-it-qat-q4_0-gguf)
- [ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF](https://huggingface.co/ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF)
- [ISTA-DASLab/Qwen3.6-35B-A3B-2Bit-GSQ](https://huggingface.co/ISTA-DASLab/Qwen3.6-35B-A3B-2Bit-GSQ)
- [ISTA-DASLab/Qwen3.8-27B-3Bit-GSQ](https://huggingface.co/ISTA-DASLab/Qwen3.8-27B-3Bit-GSQ)
- [crucible-labs/Qwen3.6-35B-A3B-REAP-48-v2-GGUF](https://huggingface.co/crucible-labs/Qwen3.6-35B-A3B-REAP-48-v2-GGUF)
- [crucible-labs/Gemma4-26B-A4B-REAP-25-GGUF](https://huggingface.co/crucible-labs/Gemma4-26B-A4B-REAP-25-GGUF)
- [DJLougen/Qwen3.6-35B-A3B-REAP-90pct-GGUF](https://huggingface.co/DJLougen/Qwen3.6-35B-A3B-REAP-90pct-GGUF)
- Hugging Face Hub search and tree APIs (`/api/models`, `/api/models/{id}/tree/main`), queried 2026-09-07, for file listings and sizes
- [`run2/results/quant-survey.md`](run2/results/quant-survey.md), [`run2/results/model-pins.md`](run2/results/model-pins.md), [`kv-quant-on-m1.md`](kv-quant-on-m1.md), [`unscheduled/small-agent-models.md`](unscheduled/small-agent-models.md), [`docs/setups/m1-max-32gb/comparison.md`](../../../docs/setups/m1-max-32gb/comparison.md) — this project's own prior research and measurements

## Waits on

- `backlog/devstral-download.md`: the first coding-model candidate.
- Not in scope, owner rulings: LM Studio engine template probes,
  Gemma-4 MLX container patches, more sampler arms, OptiQ Gemma-12B,
  re-quantization of any kind, Laguna XS until llama.cpp support is
  merged, parallel contexts, an energy meter.
