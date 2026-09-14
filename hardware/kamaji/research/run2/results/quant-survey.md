# Section C — published quants worth trying

Run 2, 2026-09-04, after the owner's ruling in master `8314735`: no
weight transformation of our own; survey published builds, shortlist
them, download only after approval.

## The finding: OptiQ covers four of our five MLX models

`mlx-community` publishes an **OptiQ** line — mixed-precision 4-bit where
per-layer bit widths come from a KL-divergence sensitivity pass over a
six-domain calibration mix (prose, reasoning, code, agent, tool-call,
constraint-following). Sensitive layers go to 8-bit, robust ones stay at
4-bit. The stated aim is to beat uniform 4-bit at the same disk size.

Direct counterparts exist for almost everything we run:

| Our current MLX quant | OptiQ counterpart | Note |
| --- | --- | --- |
| `mlx-community/gemma-4-12B-it-4bit` | **`mlx-community/gemma-4-12B-it-qat-OptiQ-4bit`** | QAT base *and* OptiQ. Its `config.json` is already in our cache. |
| `mlx-community/Qwen3.8-27B-4bit` | **`mlx-community/Qwen3.8-27B-OptiQ-4bit`** | 261 layers at 8-bit, 237 at 4-bit, group 64 |
| `mlx-community/Qwen3.6-35B-A3B-4bit` | **`mlx-community/Qwen3.6-35B-A3B-OptiQ-4bit`** | |
| `mlx-community/gemma-4-26b-a4b-it-4bit` | **`mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit`** | |
| `prism-ml/Ternary-Bonsai-27B-mlx-2bit` | none | ternary is its own scheme |

This is not a guess about what OptiQ does. Our own container audit
(`container-audit.md`, finding 2) already measured the difference on the
one OptiQ config we hold: the plain 4-bit Gemma-12B quant has **no
per-module overrides** and keeps its 262144-entry `embed_tokens` at 4
bits, while the QAT OptiQ build carries **330 overrides** and protects
`embed_tokens` at 8 bits. So the two builds differ exactly where the
method claims to.

## The catch, and it is a real one for this machine

**OptiQ is bigger.** `Qwen3.8-27B-OptiQ-4bit` is 18.9 GB on disk against
our current 16.1 GB — about **+2.8 GB of weights**.

Last night's ceiling probe measured the Qwen3.8 context ceiling at
`iogpu.wired_limit_mb=24000` as **between 26708 and 28672 tokens**, with
the declared `contextWindow` of 26624 sitting ~84 tokens under the last
success (`qwen38-ceiling.md`). Weights and KV cache share the same wired
budget. Adding 2.8 GB of weights takes it straight out of the KV
allowance.

So on Qwen3.8 the trade is explicit: **better quality per byte, at the
cost of context we do not have to spare.** The declared window would
likely have to drop. That is measurable — re-run `qwen38-ceiling.sh`
against the OptiQ build — but it should be expected, not discovered.

Gemma-12B has far more headroom (10 GB of weights against a 13.6 GB
total at 262K context on llama-server), so the same trade is cheap
there.

## Shortlist, ranked

**1. `mlx-community/gemma-4-12B-it-qat-OptiQ-4bit`** — about 7 GB.
The best first trial. It is the model whose failures this whole run is
about, it has the most memory headroom, its config is already partly
downloaded, and it is the only candidate that is BOTH quantization-aware
trained and OptiQ. Worth pairing with the template fix so the two
changes are measured separately, not together.

**2. `mlx-community/Qwen3.8-27B-OptiQ-4bit`** — 18.9 GB.
Our most-used local model and the one with a published EvalPlus row to
compare against, so an A/B is meaningful. But it costs context, see
above. Only worth it if a lower `contextWindow` is acceptable.

**3. `mlx-community/gemma-4-26B-A4B-it-OptiQ-4bit`** and
**`mlx-community/Qwen3.6-35B-A3B-OptiQ-4bit`** — both MoE, both already
near the memory limit. Lower priority for the same reason as 2, more so.

**Not recommended: the REAP variants.** Several OptiQ repos carry a
`-REAP-<N>B` suffix (for example `gemma-4-26B-A4B-it-OptiQ-4bit-REAP-14B`).
REAP is expert pruning — it removes parameters, which changes the model,
not just its encoding. That is a different experiment from a quant A/B
and should not be mixed into one.

## What is NOT yet known, and I did not assume it

- **No published head-to-head against uniform 4-bit.** The Qwen3.8 OptiQ
  card reports a "Capability Score" of 87.98% over MMLU, GSM8K, IFEval,
  BFCL-V3, HumanEval and HashHop, but does **not** publish the uniform
  4-bit score beside it. The uniform build is described only as the
  sensitivity reference. So the claim "beats uniform 4-bit" is the
  method's aim, not a number I can quote.
  **That is exactly what an A/B here would produce**, and it would be
  the first such comparison on this hardware.
- Revisions are not pinned in this table. Pin them at download time and
  add them to `model-pins.md`, per section A.
- GGUF alternatives (unsloth, bartowski) were not surveyed here; this
  pass covered the MLX path, which is where the failures are.

## Cost if approved

| Item | Download | GPU |
| --- | --- | --- |
| Gemma-12B QAT OptiQ | ~7 GB | EvalPlus smoke ~1 h, plus a short agent task |
| Qwen3.8 OptiQ | ~19 GB | ceiling re-probe ~30 min, then EvalPlus ~1.5 h |
| The other two | ~16-21 GB each | similar |

Sources: the OptiQ repo listing on Hugging Face and the
`Qwen3.8-27B-OptiQ-4bit` model card.
