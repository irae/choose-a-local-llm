# Qwen3.8-27B on RTX 5060 Ti 16 GB

Backends: llama-server · [GGUF on Hugging Face](https://huggingface.co/unsloth/Qwen3.8-27B-GGUF)

<!-- gen:model-kpis:start -->
<div class="kpis">
  <div class="kpi"><b>0.957 / 0.921</b><span>EvalPlus base / plus, UD-IQ3_S, xhigh</span><small>98% completion</small></div>
  <div class="kpi"><b>91</b><span>Mendel blind, ISTA IQ3_S-mtp, xhigh, 8/8</span></div>
  <div class="kpi"><b>85</b><span>Mendel guided, ISTA IQ3_S-mtp, xhigh, 8/8</span></div>
  <div class="kpi"><b>65k</b><span>usable context, both 3-bit builds, q8_0 KV</span></div>
</div>
<!-- gen:model-kpis:end -->

Speed, context, drafter arms and both agent tasks measured 2026-09-13 to 2026-09-15; EvalPlus scored 2026-09-15 and 2026-09-16 on both builds at effort xhigh.

## Highlights

- **The 3-bit build is the one that leaves room for a KV cache.** The
  dense 27B model at 4 bits or at NVFP4 is 16 GB and up, the card's
  whole memory; the UD-IQ3_S file is 12 GB.
- **The KV type is measured here, f16 against q8_0.** On this card
  the type decides the window, and the reference setup's pick does
  not carry over.
- **Effort xhigh, the model's published default.** Medium is never
  run on this model.
- **EvalPlus at xhigh: unsloth 0.957 / 0.921 with 3 empty, ISTA
  0.945 / 0.909 with 7 empty.** The unsloth build leads the single-turn
  test and the ISTA build the agent task; both builds are two
  providers' trade-offs of one model for the same 12 GB budget.

## All configs — this model

<!-- gen:model-table:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" page="/binaries/qwen38-ista-iq3s-mtp" top /> | **65k** | <TokCell shallow="29.43" deep="21.13" cap="mem" top-shallow top-deep /> | **14.8 GB** | <ScoreCell value="0.945/0.909" sub="96% completion" top /> | <ScoreCell value="91" pill="mendel-blind" top /> | <span title="EvalPlus 3h38 · Mendel 1h15"><b>4h53</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" page="/binaries/qwen38-unsloth-ud-iq3s" top /> | **65k** | <TokCell shallow="29.36" deep="20.92" cap="mem" top-shallow top-deep /> | **14.2 GB** | <ScoreCell value="0.957/0.921" sub="98% completion" top /> | <ScoreCell value="79" note="88%" pill="mendel-guided" top /> | <span title="EvalPlus 4h50 · Mendel 4h46"><b>9h36</b></span> |
| <ModelSpec base="Qwen3.8-27B" quant="Q3_K_M" server="llama-server" publisher="OBLITERATUS" repo="OBLITERATUS/Qwen3.8-27B-OBLITERATED" kv="q8_0" effort="medium" page="/binaries/qwen38-obliteratus-q3km" /> | **65k** | <TokCell shallow="22.67" deep="16.74" cap="mem" /> | 15.3 GB | <ScoreCell value="0.854/0.787" sub="100% completion" /> | <ScoreCell value="0" note="0%" pill="failed-smoke" /> | <span title="EvalPlus 1h29 · Mendel —">1h29†</span> |

Rows below 100 percent completeness. Completeness counts three measurements: tok/s, EvalPlus and Mendel.

| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="OBLITERATUS" repo="OBLITERATUS/Qwen3.8-27B-OBLITERATED" offload="ngl 45/64" kv="q8_0" effort="medium" top /> | **64k** | <TokCell shallow="5.13" deep="2.31" cap="speed" top-shallow top-deep /> | **13.1 GB** | <ScoreCell value="not run" /> | <ScoreCell value="not run" /> | — |
<!-- gen:model-table:end -->

## Configs

Each table row above is one config; start it with its block below.

<!-- gen:model-configs:start -->
<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" page="/binaries/qwen38-ista-iq3s-mtp" />

pi id `qwen3.8-27b-ista`. The 3-bit build the reference setup serves, at its revision `d562806`. The file sets `min_p 0.0` in its sampling defaults, where the unsloth file sets none. The drafter arms need a smaller `-c`: n-max 1 and 2 serve `-c 57344`, n-max 3 `-c 49152`; n-max 2 is the fastest arm (45.9 tok/s at 4K, 26.2 at 56K). n-max 2 served the guided task first, and the server died three times with a GPU launch timeout: the desktop shares the card, and about 440 MiB stayed free. No drafter leaves 1.2 GB free and served the guided and blind tasks with no crash. The best agent rows on this machine: guided 85 and blind 91, both 8 of 8. EvalPlus at effort xhigh, scored 2026-09-15 at budget 20500: 0.945/0.909, 7 empty answers of 164 whose cause is unproven because the run saved no finish log, in 217.6 minutes of active time. Two driver watchdog crashes on the drafter arm forced a temporary no-drafter arm; a drafter does not change an answer at temperature 0, so every problem counts once. Under a server thinking budget of 30000 tokens (the derive cap; the calibration's longest converged reasoning ran 22947 tokens; answer budget 2048, `max_tokens` 32048; the thinking-budget test, 2026-09-17), the same build and level scored 0.976/0.933 with no empty answer in 273.4 minutes: 6 problems hit the budget and were forced to answer, and 5 of the 6 passed the base tests, 4 the plus tests. The natural run at 20500 left 7 empty in 217.6 minutes. The two forced failures hit the 30000 cap without the budget too (the natural re-run, 37.2 minutes), so the budget stands. A second budgeted run at a fixed 8192 thinking budget (answer budget 2048, `max_tokens` 10240) scored the same 0.976/0.933 with no empty answer in 175.0 minutes: 11 problems were forced to answer, and 8 of the 11 passed the base tests, 5 the plus tests. Its six forced failures do not pass without the budget: two hit the 30000 cap and four converge between 10379 and 22947 reasoning tokens and fail the same tests, as they do in the 30000 run, so the 8192 budget lost no answer. The owner's word on how a budgeted score is shown is pending.

```bash
llama-server -m "$(hf download ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf)" \
  --alias qwen3.8-27b-ista --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 65536 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" page="/binaries/qwen38-unsloth-ud-iq3s" />

pi id `qwen3.8-27b-iq3s`. The 3-bit build that leaves room for a KV cache on 16 GB. The KV type was measured on this card: q8_0 serves `-c 65536`, and f16 serves only `-c 53248` (24.3 tok/s at its deep cell), because a larger f16 window loads but runs out of memory on the first real request. q8_0 is the served type. The MTP drafter was read after the agent row, at the same `-c`: n-max 1 reads 37.2 → 26.3 tok/s and n-max 2 47.1 → 30.8, both faster than no drafter at every depth; n-max 3 needs `-c 57344`. The guided task ran with no drafter: 79, 7 of 8 libraries, stopped when the output-budget nudges ran out. EvalPlus at effort xhigh, scored 2026-09-16 with no drafter at `-c 32768`, budget 19000: 0.957/0.921, 3 empty answers of 164 whose cause is unproven because the run saved no finish log, in 289.6 minutes of active time. Two of ten calibration problems never converged, so the budget sits just above the longest successful answer. No earlier score exists for this build at this level on any machine.

```bash
llama-server -m "$(hf download unsloth/Qwen3.8-27B-GGUF Qwen3.8-27B-UD-IQ3_S.gguf)" \
  --alias qwen3.8-27b-iq3s --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 65536 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

<ModelSpec base="Qwen3.8-27B" quant="Q3_K_M" server="llama-server" publisher="OBLITERATUS" repo="OBLITERATUS/Qwen3.8-27B-OBLITERATED" kv="q8_0" effort="medium" page="/binaries/qwen38-obliteratus-q3km" />

pi id `qwen3.8-27b-oblit-q3km`, revision `a58c3b5`, 12.57 GiB of weights. An abliterated repack of the dense 27B model. **This build cannot do the agent task**: its smoke ended with zero tool calls in 9 seconds, because the file's own chat template carries no `tools` and no `tool_call` handling, so `--jinja` has nothing to parse and the model writes its calls as literal text. A thinking block was present in the session log, so the level reached the server; the fault is the file, not the harness or the window. A tools-capable template supplied to the server would be a different serving config and a different row. The larger quant still keeps the window: q8_0 serves `-c 65536`, the same as the two 3-bit builds of this model here, where f16 stops at 32768. Speed 22.67 tok/s at 4K, 20.65 at 24K and 16.74 at 64512, about 23 percent under the 3-bit builds at both ends, with no depth under the 8 tok/s floor. EvalPlus at **effort medium, an owner overrule of 2026-09-17** (`AGENTS.md` bans medium for this model everywhere else), scored 2026-09-18 under a server thinking budget of 3986 (answer budget 2048, `max_tokens` 6034): 0.854/0.787 with 3 empty answers of 164 whose cause is the model, in 89 minutes. Five problems hit the budget and were forced to answer; one passed. The four that failed fail again without the budget at the 30000-token cap, as wrong answers and not as loops, so the budget lost nothing. Medium reasons far shorter than xhigh on this model, which is why the budget is 3986 against 25209 on a ternary build at xhigh. Build and level moved together in this run, so neither alone explains the quality against the 3-bit builds at xhigh. An xhigh row is pending.

```bash
llama-server -m "$(hf download OBLITERATUS/Qwen3.8-27B-OBLITERATED Qwen3.8-27B-OBLITERATED-Q3_K_M.gguf)" \
  --alias qwen3.8-27b-oblit-q3km --no-mmproj --parallel 1 \
  -ngl 999 --fit off -fa on -c 65536 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --jinja --port 8081
```

<ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="OBLITERATUS" repo="OBLITERATUS/Qwen3.8-27B-OBLITERATED" offload="ngl 45/64" kv="q8_0" effort="medium" />

pi id `qwen3.8-27b-oblit-q4km`, revision `a58c3b5`, 15.66 GiB of weights, larger than the card. The one row on this machine that keeps part of a model in host RAM by design: `-ngl 45` of 64 layers on the card, 19 in host RAM, at a fixed `-c 65536` under a VRAM cap of 13811 MiB that leaves 2.5 GB for the system (owner, 2026-09-18; the card has no reserve rule otherwise). The ladder: 43 loads at 12945 MiB, 47 and 51 go over the cap at load, 45 loads at 13397 MiB and holds 13426 MiB under a real 64K request. **The row does not reach the usability floor**: 5.13 tok/s at 4K, 3.49 at 24K, 2.67 at 49K and 2.31 at 64512, where 8 tok/s is the floor. Against the same model's Q3_K_M inside the card, that is about 4.4 times slower at both ends. Memory was never the limit: VRAM held flat at 13422 MiB against the cap through the whole sweep, so the cost is the transfer of 19 layers per token, not capacity. The run ended at the sweep on its speed gate (coordinator, 2026-09-18), so no EvalPlus row and no agent row exist for this build and none is planned here. Halving the window to 32768 frees 1088 MiB of cache, about four more layers at the ladder's own 226 MiB per layer, which still does not reach the floor.

```bash
llama-server -m "$(hf download OBLITERATUS/Qwen3.8-27B-OBLITERATED Qwen3.8-27B-OBLITERATED-Q4_K_M.gguf)" \
  --alias qwen3.8-27b-oblit-q4km --no-mmproj --parallel 1 \
  -ngl 45 --fit off -fa on -c 65536 \
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
- **EvalPlus at effort xhigh, q8_0 KV, no drafter for the score.** The
  unsloth build: 0.957/0.921, 3 empty answers of 164, budget 19000,
  289.6 minutes. The ISTA build: 0.945/0.909, 7 empty of 164, budget
  20500, 217.6 minutes, two driver watchdog crashes on the drafter arm
  inside the run. On the Mac the same two builds read 0.945 / 0.927
  (8 empty) and 0.945 / 0.921 (5 empty), so the card and the Mac agree
  within about one point on base. Every empty here is unproven because
  the run saved no finish log; on the Mac the ISTA empties were proven
  as the budget. The ISTA row is the second case of the thinking-budget
  test: forced to answer at 30000 thinking tokens it scored 0.976/0.933
  with no empty answer in 273 minutes, 6 forced answers of which 5
  pass the base tests and 4 the plus; at a fixed 8192 it scored the
  same in 175 minutes with 11 forced answers; the site shows the natural score until the owner decides how a
  budgeted row reads.

## Quality — EvalPlus HumanEval+

<!-- gen:model-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" page="/binaries/qwen38-unsloth-ud-iq3s" />](../benchmarks/qwen3.8-27b.md) | 19000 | <ScoreCell value="0.957/0.921" sub="98% completion" top /> | † unproven | <TokCell shallow="29.36" deep="20.92" /> | 4h50 |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" page="/binaries/qwen38-ista-iq3s-mtp" />](../benchmarks/qwen3.8-27b.md) | 20500 | <ScoreCell value="0.945/0.909" sub="96% completion" top /> | † unproven | <TokCell shallow="29.43" deep="21.13" /> | 3h38 |
| [<ModelSpec base="Qwen3.8-27B" quant="Q3_K_M" server="llama-server" publisher="OBLITERATUS" repo="OBLITERATUS/Qwen3.8-27B-OBLITERATED" kv="q8_0" effort="medium" page="/binaries/qwen38-obliteratus-q3km" />](../benchmarks/qwen3.8-27b.md) | 6034 | <ScoreCell value="0.854/0.787" sub="98% completion" /> | model | <TokCell shallow="22.67" deep="16.74" /> | 1h29 |
<!-- gen:model-evalplus:end -->

Every run of this model on this machine, best base score first. The empties column carries the cause word ([what the words mean](../../../benchmarks/evalplus.md#limits-on-local-hardware)).

## Agentic quality — Mendel

<!-- gen:model-mendel:start -->
Blind test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" page="/binaries/qwen38-ista-iq3s-mtp" /> | blind-v1.1 | 64k | **91** | 8/8/done | 75.1 | 6,882k | 65k | 3 | 257 | 17 |  |

Guided test:

| config | prompt | window | score | completed | minutes | tokens | peak ctx | compactions | tool calls | commits | loop |
|---|---|--:|--:|---|--:|--:|--:|--:|--:|--:|---|
| <ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="q8_0" effort="xhigh" page="/binaries/qwen38-ista-iq3s-mtp" /> | guided-v3.0 | 64k | **85** | 8/8/done | 214.8 | 10,680k | 58k | 23 | 320 | 8 |  |
| <ModelSpec base="Qwen3.8-27B" quant="UD-IQ3_S" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.8-27B-GGUF" kv="q8_0" effort="xhigh" page="/binaries/qwen38-unsloth-ud-iq3s" /> | guided-v3.0 | 64k | **79** | 7/8/partial | 285.9 | 11,327k | 58k | 35 | 332 | 7 |  |

The window cell is the harness context window of that run. Rows before the KV pick of 2026-09-04 carry the type their runbook served, or `q8_0` where no record names one.
<!-- gen:model-mendel:end -->

Full data: [the benchmarks page](../benchmarks/qwen3.8-27b.md).
