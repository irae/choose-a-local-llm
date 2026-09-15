# Qwen3.8-27B on RTX 5060 Ti 16 GB

Backends: llama-server · [GGUF on Hugging Face](https://huggingface.co/unsloth/Qwen3.8-27B-GGUF)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>65k</b><span>usable context, both 3-bit builds, q8_0 KV</span></div>
  <div class="kpi"><b>85</b><span>Mendel guided, ISTA IQ3_S-mtp, xhigh, 8/8</span></div>
  <div class="kpi"><b>91</b><span>Mendel blind, ISTA IQ3_S-mtp, xhigh, 8/8</span></div>
</div>
<!-- gen:model-kpis:end -->

First run 2026-09-13 to 2026-09-15: speed, context, drafter arms and both agent tasks. No EvalPlus on this machine yet.

## Highlights

- **The 3-bit build is the one that leaves room for a KV cache.** The
  dense 27B model at 4 bits or at NVFP4 is 16 GB and up, the card's
  whole memory; the UD-IQ3_S file is 12 GB.
- **The KV type is measured here, f16 against q8_0.** On this card
  the type decides the window, and the reference setup's pick does
  not carry over.
- **Effort xhigh, the model's published default.** Medium is never
  run on this model.

## All configs — this model

<!-- gen:model-table:start -->
| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" top /> | **65k** | mem | <TokCell shallow="29.43" deep="21.13" top-shallow top-deep /> | **14.8 GB** | <ScoreCell value="0.945/0.909" sub="100% completion" top /> | <ScoreCell value="91" pill="mendel-blind" top /> | <span title="EvalPlus 3h38 · Mendel 1h15">4h53</span> |

Rows below 100 percent completeness. Completeness counts three measurements: tok/s, EvalPlus and Mendel.

| Model / Config | Ctx | Cap | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|:--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" top /> | **65k** | mem | <TokCell shallow="29.36" deep="20.92" top-shallow top-deep /> | **14.2 GB** | <ScoreCell value="pending" /> | <ScoreCell value="79" note="88%" pill="mendel-guided" top /> | <span title="EvalPlus — · Mendel 4h46">4h46†</span> |
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" />

pi id `qwen3.8-27b-ista`. The 3-bit build the reference setup serves, at its revision `d562806`. The file sets `min_p 0.0` in its sampling defaults, where the unsloth file sets none. The drafter arms need a smaller `-c`: n-max 1 and 2 serve `-c 57344`, n-max 3 `-c 49152`; n-max 2 is the fastest arm (45.9 tok/s at 4K, 26.2 at 56K). n-max 2 served the guided task first, and the server died three times with a GPU launch timeout: the desktop shares the card, and about 440 MiB stayed free. No drafter leaves 1.2 GB free and served the guided and blind tasks with no crash. The best agent rows on this machine: guided 85 and blind 91, both 8 of 8.

```bash
llama-server -m "$(hf download ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf)" \
  --alias qwen3.8-27b-ista --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 65536 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" />

pi id `qwen3.8-27b-iq3s`. The 3-bit build that leaves room for a KV cache on 16 GB. The KV type was measured on this card: q8_0 serves `-c 65536`, and f16 serves only `-c 53248` (24.3 tok/s at its deep cell), because a larger f16 window loads but runs out of memory on the first real request. q8_0 is the served type. The MTP drafter was read after the agent row, at the same `-c`: n-max 1 reads 37.2 → 26.3 tok/s and n-max 2 47.1 → 30.8, both faster than no drafter at every depth; n-max 3 needs `-c 57344`. The guided task ran with no drafter: 79, 7 of 8 libraries, stopped when the output-budget nudges ran out.

```bash
llama-server -m "$(hf download unsloth/Qwen3.8-27B-GGUF Qwen3.8-27B-UD-IQ3_S.gguf)" \
  --alias qwen3.8-27b-iq3s --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 65536 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```
<!-- gen:model-configs:end -->

## Model details and findings

- **The ISTA build is the pick on this card**: 85 guided and 91 blind,
  both 8 of 8, at a 61440 window. The unsloth build reads at the same
  speed and stopped at 7 of 8 guided (79).
- **q8_0 KV decides the window.** Both 3-bit builds serve `-c 65536`
  at q8_0; f16 serves only 53K. The speed is about twice the Mac's,
  on less than half its window.
- **The drafter pays and costs memory.** On both files every drafter
  arm reads faster than no drafter, and n-max 2 is the fastest (about
  46 tok/s at 4K). On the ISTA file every drafter arm needs a smaller
  `-c`, and n-max 2 left about 440 MiB free: its server died three
  times in the guided task with a GPU launch timeout. The agent rows
  serve with no drafter.
- **Defects of the best rows**: the guided row shipped the `fs.glob`
  trap and dismissed the `mendel-requirify` rimraf references as out
  of scope; the blind row avoided both glob traps and never looked at
  the rimraf references its own grep printed.

## Agentic quality — Mendel

<!-- gen:model-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" /> | blind-v1.1 | 64k | **91** | 8/8/done | 75.1 | 6,882k | 65k | 3 | 257 | 17 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" /> | guided-v3.0 | 64k | **85** | 8/8/done | 214.8 | 10,680k | 58k | 23 | 320 | 8 |  |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" /> | guided-v3.0 | 64k | **79** | 7/8/partial | 285.9 | 11,327k | 58k | 35 | 332 | 7 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:model-mendel:end -->

Full data: [the benchmarks page](../benchmarks/qwen3.8-27b.md).
