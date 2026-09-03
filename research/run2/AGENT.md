# Research run 2 — runtime improvements (Mac, in-depth)

You are a research-and-experiment agent on the Mac. Read this file,
`state.md`, `../run1/` (its diagnoses feed this run), then
`results/*.md` — three web-research reports gathered by the
coordinator (2026-09-03), with sources. Write all prose in ASD-STE100
Simplified Technical English. `AGENTS.md` ground rules apply, plus:
NO model downloads and NO destructive config changes until the owner
approves a filtered experiment list. Your first deliverable is that
list.

## Why

Run 7 showed serving-stack failures masquerading as model quality:
the Gemma-12B newline flood (three ~30 rows, zero commits), the mlx
dead-thread Metal OOM, the Qwen3.8 26624-token window, the llama.cpp
MTP drafter breaking the backend, and the dagger-sweep OOM. The goal
is what the first commits of this repo did for serving configs: make
every model complete its runs, so a real user hitting a fluke can
restart and keep working.

## How to work

1. Verify locally what the web reports claim (versions, templates,
   configs) — the reports are leads, not truth. Add your own research.
2. Merge with `../run1/results/` diagnoses (session-log evidence).
3. Propose a ranked experiment list to the owner. Iterate: agree,
   test, evaluate, record. Only then change published configs.

## Threads and starting alternatives (err wild; filter later)

### A. Model containers — get the download right

- Verify every local GGUF's embedded template (`gguf_dump.py` →
  `tokenizer.chat_template`) and every MLX repo's
  `tokenizer_config.json` against the base model's template. Wrong
  templates break tool calls and leak thinking tags.
- llama-server: test `--jinja` on/off per model; try
  `--chat-template-file` with community-fixed templates (Qwen 3.x
  think-tags; Gemma has no official tool role — see
  `results/web-quant-and-models.md`).
- Check whether our Gemma-4 MLX quants have the confirmed
  quantized-PLE defect (all HF mlx-community Gemma-4 quants reported
  broken; a fix repo exists). Compare `config.json` quantization
  blocks against a known-good reference.
- M1 Max instruction sets: `dotprod` yes, `i8mm` NO (M2+). Check
  `sysctl -a | grep hw.optional` and whether any of our GGUFs or
  build flags assume i8mm. Q4_0 online repacking targets the CPU
  path — measure whether it matters at all for our GPU-only runs.
- KV cache: never Q4 (large silent output drift); Q8 or f16 only.
  Audit our published configs for this.
- Pin exact HF revisions for every model file — quant makers replace
  files silently.

### B. Re-quantization — make better local builds

- Re-quantize one model from original weights with
  `mlx_lm.convert -q --q-bits 4 --q-group-size 32
  --quant-predicate mixed_4_6` and A/B against the mlx-community
  download (EvalPlus smoke + a short Mendel-style task).
- Wilder: `mlx_lm.dwq` (distilled quantization, biggest reported
  quality gain) on Bonsai or Qwen3.8.
- A/B K-quant vs IQ-quant decode speed on the M1 Max GPU (IQ reported
  3.5x slower on Apple GPUs).

### C. Gemma-12B newline flood (LM Studio MLX)

Upstream facts: Gemma-4 has a confirmed model-level repetition
collapse (44-60% repro on long agent prompts, present in F16 —
repeat_penalty does not help); LM Studio's bundled Gemma-4 template
crashes on tool calls (fix macro in their tracker #2012); the MLX
engine ignores `enable_thinking:false`, the set context length, and
mishandles stop sequences. Alternatives, ranked by the researcher:

1. Disable thinking in the LM Studio UI (not the API) and re-test.
2. A/B the same model as GGUF (two of the bugs are MLX-engine-only).
3. Apply the template fix macro; watch server logs for the Jinja
   error right after a failed-edit turn.
4. Harness-side hard stop on N repeated tokens (do not trust the
   engine's stop handling).
5. Trim tool-schema verbosity; sanitize failed-edit error text before
   feeding it back (its repeated structure may seed the loop).
6. Compare LM Studio's MLX wrapper against upstream `mlx_lm.server`
   to isolate the owning layer.
If nothing works, propose marking the Gemma-12B x LM Studio x agent
combination unsupported (feeds run 1 goal 2).

### D. mlx_lm.server dead thread and OOM

Upstream: confirmed open bug — /health never checks the generation
thread (issues 1505/1390/854; unmerged PRs 1513/1514/1791).
Alternatives: `--prompt-cache-bytes` cap (4-6 GB); a watchdog that
probes a REAL completion, not /health (our monitors already check
output growth — unify); cherry-pick the unmerged PRs locally; a
`threading.excepthook` → `os._exit()` wrapper so the process dies
honestly; periodic `mx.clear_cache()`; `--max-kv-size` is in the
library but not exposed by the server (could patch); check if a newer
mlx-lm fixes the Qwen3.8 26624 window pinning.

### E. llama.cpp memory fit and the MTP drafter

Upstream: `--fit` exists but UMA accounting is admittedly broken;
`-fit on` ignoring the drafter's memory was fixed by PR 23485 —
check our brew build's vintage. Our exact symptom (drafter alloc
fails, /health green, all requests 500) is NOT confirmed upstream:
run 1's minimal repro on a pinned commit is the input for filing it.
Alternatives: update the build; replace `-ngl 999` with `--fit on`
or a measured `-ngl` minus 15-20% margin; skip MTP entirely on 32 GB
(spec-decode gives ~zero gain on Apple Silicon per the video
research); harness-side relaunch-without-drafter fallback; match
drafter and main context sizes.

### F. New model candidates (verify cards first; some figures are
secondary-source)

GLM-4.7-Flash (30B-A3B MoE, MIT — same active class as Qwen3.6),
Meta Muse Glimmer 30B (dense, official GGUF+MLX), Poolside Laguna
XS 2.1 (33.4B/3B MoE — check llama.cpp support), Mistral Devstral
Small 2 (24B dense, leaves context headroom). Downloads only after
the owner approves the shortlist.

## Deliverables

- `state.md`: running log, handing-over sections.
- `results/experiments.md`: the ranked, owner-filterable experiment
  list with expected cost (GPU-hours, downloads) per item.
- After owner approval: per-experiment findings appended to
  `results/`, and config changes proposed as diffs, not applied
  silently.
