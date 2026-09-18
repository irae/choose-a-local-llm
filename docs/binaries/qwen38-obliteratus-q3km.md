# Qwen3.8-27B Q3_K_M (OBLITERATUS)

File: [`OBLITERATUS/Qwen3.8-27B-OBLITERATED`](https://huggingface.co/OBLITERATUS/Qwen3.8-27B-OBLITERATED),
`Qwen3.8-27B-OBLITERATED-Q3_K_M.gguf`, revision `a58c3b5`,
13,500,728,352 bytes (12.57 GiB), an abliterated repack of the dense
27B model. Server: llama-server, CUDA, the prebuilt build named in the
setup overview. Every run of this file on every machine is on this
page, retired and superseded rows included; a run a harness or serving
defect voided is not.

- **Why it is here.** The owner asked for a third provider's build of
  this model on this card, beside the two 3-bit builds, in a larger
  quantization. The run that adopted it carried a gate that would have
  dropped the file if it could not hold a 32768-token window.
- **What it settled.** The larger quant keeps the window. q8_0 serves
  `-c 65536`, the same window the 3-bit builds get here, although this
  file is about 0.6 GiB larger; f16 stops at 32768. Speed is about 23
  percent under the 3-bit builds at both ends of the curve, evenly, not
  as a fall at depth.
- **Where it stands.** **The file cannot do the agent task.** Its own
  chat template carries no `tools` and no `tool_call` handling, so
  `--jinja` has nothing to parse and the model writes its tool calls as
  literal text; the smoke ended with zero tool calls in 9 seconds. The
  quality gate is the weakest this card has recorded on this model,
  0.854 / 0.787, measured at effort medium by an owner overrule.

## Configurations

<!-- gen:binary-rows:start -->
| Model / Config | Ctx | tok/s | Memory<br>(at max ctx) | HumanEval+ | Coding | Wall |
|---|--:|--:|--:|--:|--:|--:|
| <ModelSpec base="Qwen3.8-27B" quant="Q3_K_M" server="llama-server" publisher="OBLITERATUS" repo="OBLITERATUS/Qwen3.8-27B-OBLITERATED" kv="q8_0" effort="medium" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-obliteratus-q3km" /> | **65k** | <TokCell shallow="22.67" deep="16.74" cap="mem" top-shallow top-deep /> | **15.3 GB** | <ScoreCell value="0.854/0.787" sub="100% completion" top /> | <ScoreCell value="0" note="0%" pill="failed-smoke" /> | <span title="EvalPlus 1h29 · Mendel —">1h29†</span> |
<!-- gen:binary-rows:end -->

## Quality — EvalPlus HumanEval+

<!-- gen:binary-evalplus:start -->
| config | budget | Scores | empties | tok/s | wall |
|---|--:|--:|--:|--:|--:|
| [<ModelSpec base="Qwen3.8-27B" quant="Q3_K_M" server="llama-server" publisher="OBLITERATUS" repo="OBLITERATUS/Qwen3.8-27B-OBLITERATED" kv="q8_0" effort="medium" hardware="rtx-5060ti-16gb" page="/binaries/qwen38-obliteratus-q3km" />](../setups/arrietty/benchmarks/qwen3.8-27b.md) | 6034 | <ScoreCell value="0.854/0.787" sub="98% completion" top /> | model | <TokCell shallow="22.67" deep="16.74" /> | 1h29 |
<!-- gen:binary-evalplus:end -->

The three empty answers carry the cause word `model`: none of them hit
the thinking budget. Five problems did hit it and were forced to
answer; one passed. The four that failed fail again without the budget
at the 30000-token cap, as wrong answers and not as loops, so the
budget of 3986 lost nothing and needed no correction. Medium reasons
far shorter than xhigh on this model, which is why that budget is 3986
where a build at xhigh derived 25209.

## Agent task — Mendel, every prompt version

<!-- gen:binary-mendel:start -->
No Mendel run yet.
<!-- gen:binary-mendel:end -->

No agent row exists and none can be measured on this serving config.
The smoke failed at the first turn with zero tool calls, a clean tree
and no commit, because the file ships a chat template with no tool
support. A thinking block was present in the session log, so the effort
level reached the server; the fault is the file. A tools-capable
template supplied to the server would be a different serving config and
a different row.

## Speed and context

Measured on the RTX 5060 Ti 16 GB, the only machine that served this
file.

<ModelSpec base="Qwen3.8-27B" quant="Q3_K_M" server="llama-server" publisher="OBLITERATUS" repo="OBLITERATUS/Qwen3.8-27B-OBLITERATED" hide="drafter,kv,effort" />

| measurement | date | config | result |
|---|---|---|---|
| KV pick | 2026-09-17 | q8_0 against f16 | q8_0 serves `-c 65536` (73728 fails), f16 `-c 32768` (40960 fails) |
| Sweep | 2026-09-17 | q8_0, `-c 65536`, no drafter, depths 4096 / 24576 / 64512 | 22.67 / 20.65 / 16.74 tok/s, no depth under the floor |
| Smoke | 2026-09-18 | window 61440, effort medium | fail: 0 tool calls, 0 commits, 9 s, tool calls written as literal text |

The full curves stay in the run kit,
`hardware/arrietty/benchmarks/bench23/results/`.

## Log

- **2026-09-17** — adopted on the card: both KV types laddered against
  a 32768-token gate, then swept. The gate did not fire. Run kit:
  `hardware/arrietty/benchmarks/bench23/`.
- **2026-09-18** — calibration and EvalPlus at effort medium under the
  derived thinking budget, the natural re-run of the forced failures,
  and the smoke, which failed. The run was paused overnight so a model
  released that day could take the card, and resumed at 132 of 164
  problems. Run kit: `hardware/arrietty/benchmarks/bench23/`.
- **Pending** — an xhigh row, to separate the build from the level; a
  serving config with a tools-capable chat template, which is the only
  way this file reaches the agent task.
