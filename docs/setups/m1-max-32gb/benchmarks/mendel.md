# Mendel — M1 Max 32 GB

The agentic tier of the quality flow, after EvalPlus: one real repo
task with known traps, scored on a 100-point
rubric — from the open-source
[Mendel](https://github.com/irae/mendel/tree/benchmark) project, where
the task, the rubric, and the raw results live. Method and house rules:
[Mendel in the methodology](../../../methodology/mendel).

Mendel is two tests on the same task. The **blind** test gives a terse
prompt and asks whether the model finds the traps by itself. The
**guided** test hands every model the same structured plan with the
traps disclosed, and measures instruction-following. Strong API models
run blind only; local and weak models run both, so each pair shows the
lift. Scores never compare across the two tests.

The full reports are hosted here, generated from the Mendel data:

- <a href="../../../mendel/report.html" target="_blank" rel="noreferrer">Blind report</a> — scoreboard, criteria
  matrix, cost tables, defect ledger.
- <a href="../../../mendel/report-guided.html" target="_blank" rel="noreferrer">Guided report</a> — same format,
  guided runs only.

The tables below are drawn from the mirrored result files in
`benchmarks/mendel/` (`npm run docs:tables`). The two main tables
show only the current prompt version of each test (blind v1.1, guided
v3.0); valid rows from older prompt versions sit in the stale table at
the end of the page, and the hosted reports keep one scoreboard per
version. The legend under the blind table explains every column.

One Qwen3.6-35B-A3B score below, the guided 83 at thinking high, is
pending a re-run at low priority: it ran on a 120K harness window, and
at wired limit 25000 the model serves `-c 98304`. The score stays as a
record of what the model did; the other Qwen3.6 rows ran on windows
the machine serves today.

## Local models — blind test

<!-- gen:mendel-local:start -->
| Model / Config | Score | Wall | Ctx / speed | Tokens | Ctx use | Bugs | Stats |
|---|--:|--:|--:|--:|--:|---|---|
| [<ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="xhigh" />](../reports/qwen3.8-27b.md) | <ScoreCell value="93" top /> | 213 min | <span class="ctxuse">64k<br><TokCell shallow="11.8" deep="8.6" /></span> | 102k | <span class="ctxuse">394%<br><span class="ms-pill cs-pill cs-pill-yellow">3 compactions</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 272/23</span> <span class="ms-pill cs-pill cs-pill-gray">commits 17</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">turns 242</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 2t</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 56%</span></span> |
| [<ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" />](../reports/qwen3.8-27b.md) | <ScoreCell value="87" top /> | 129 min | <span class="ctxuse">48k†<br><TokCell shallow="11.8" deep="8.6" /></span> | 64k | <span class="ctxuse">493%<br><span class="ms-pill cs-pill cs-pill-yellow">4 compactions</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">1 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 210/17</span> <span class="ms-pill cs-pill cs-pill-gray">commits 10</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 2</span> <span class="ms-pill cs-pill cs-pill-gray">turns 186</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 1t</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 75%</span></span> |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="xhigh" />](../reports/qwen3.8-27b.md) | <ScoreCell value="80.5" top /> | 109 min | <span class="ctxuse">**144k**<br><TokCell shallow="14.1" deep="8.1" /></span> | 53k | **80%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span> <span class="ms-pill cs-pill cs-pill-gray">1 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 193/15</span> <span class="ms-pill cs-pill cs-pill-gray">commits 17</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 2</span> <span class="ms-pill cs-pill cs-pill-gray">turns 156</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 68%</span></span> |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" drafter="mtp/3" kv="f16" effort="medium" />](../reports/qwen3.8-27b.md) | <ScoreCell value="76.5" top /> | 135 min | <span class="ctxuse">112k<br><TokCell shallow="15.1" deep="9.7" /></span> | 46k | **78%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span> <span class="ms-pill cs-pill cs-pill-gray">3 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 195/12</span> <span class="ms-pill cs-pill cs-pill-gray">commits 17</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 1</span> <span class="ms-pill cs-pill cs-pill-gray">turns 172</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 81%</span></span> |
| [<ModelSpec base="Qwen3.8-27B" quant="Q4_K_M" server="llama-server" publisher="bartowski" repo="bartowski/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" />](../reports/qwen3.8-27b.md) | <ScoreCell value="76" top /> | 98 min | <span class="ctxuse">64k<br><TokCell shallow="11.8" deep="8.6" /></span> | 40k | <span class="ctxuse">192%<br><span class="ms-pill cs-pill cs-pill-yellow">1 compaction</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span> <span class="ms-pill cs-pill cs-pill-gray">1 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 173/14</span> <span class="ms-pill cs-pill cs-pill-gray">commits 12</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 1</span> <span class="ms-pill cs-pill cs-pill-gray">turns 145</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 2t</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 63%</span></span> |
| [<ModelSpec base="Qwen3.8-27B" quant="IQ3_S-mtp" server="llama-server" publisher="ISTA-DASLab" repo="ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF" kv="f16" effort="low" />](../reports/qwen3.8-27b.md) | <ScoreCell value="66" note="88%" /> | 163 min | <span class="ctxuse">**144k**<br><TokCell shallow="14.1" deep="8.1" /></span> | 66k | **88%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span> <span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 214/10</span> <span class="ms-pill cs-pill cs-pill-gray">commits 15</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 1</span> <span class="ms-pill cs-pill cs-pill-gray">turns 174</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 1t</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 61%</span></span> |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" />](../reports/qwen3.6-35b-a3b.md) | <ScoreCell value="63" /> | 79 min | <span class="ctxuse">96k<br><TokCell shallow="43.7" deep="13.0" /></span> | 40k | **96%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">3 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 203/13</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">commits 13</span> <span class="ms-pill cs-pill cs-pill-gray">turns 155</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 60%</span></span> |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" />](../reports/qwen3.6-35b-a3b.md) | <ScoreCell value="50.5" /> | **40 min** | <span class="ctxuse">80k<br><TokCell shallow="43.7" deep="13.0" /></span> | 35k | <span class="ctxuse">319%<br><span class="ms-pill cs-pill cs-pill-yellow">2 compactions</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">2 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">3 medium</span> <span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 190/26</span> <span class="ms-pill cs-pill cs-pill-gray">commits 10</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 1</span> <span class="ms-pill cs-pill cs-pill-gray">turns 162</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 34%</span></span> |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" kv="f16" effort="on" />](../reports/qwen3.6-35b-a3b.md) | <ScoreCell value="50" /> | **33 min** | <span class="ctxuse">64k<br><TokCell shallow="50.5" deep="33.6" /></span> | 42k | <span class="ctxuse">294%<br><span class="ms-pill cs-pill cs-pill-yellow">2 compactions</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">2 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span> <span class="ms-pill cs-pill cs-pill-gray">3 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 211/29</span> <span class="ms-pill cs-pill cs-pill-gray">commits 13</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 2</span> <span class="ms-pill cs-pill cs-pill-gray">turns 188</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 71%</span></span> |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" />](../reports/gemma-4-26b-a4b.md) | <ScoreCell value="47.5" /> | 81 min | <span class="ctxuse">**208k**<br><TokCell shallow="60.1" deep="19.1" /></span> | 63k | <span class="ctxuse">198%<br><span class="ms-pill cs-pill cs-pill-yellow">1 compaction</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 246/40</span> <span class="ms-pill cs-pill cs-pill-gray">commits 21</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 6</span> <span class="ms-pill cs-pill cs-pill-gray">turns 250</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 2m</span></span> |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" />](../reports/bonsai-27b.md) | <ScoreCell value="37.5" note="38%" /> | 300 min | <span class="ctxuse">56k<br><TokCell shallow="24.5" deep="17.3" /></span> | 35k | **87%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 135/25</span> <span class="ms-pill cs-pill cs-pill-gray">commits 4</span> <span class="ms-pill cs-pill cs-pill-red">failed commits 3</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">turns 149</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 3t 1m</span> <span class="ms-pill cs-pill cs-pill-red">loop thinking</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 13%</span></span> |
| [<ModelSpec base="Qwen3.8-27B" quant="AD-IQ3_S" server="llama-server" publisher="AtomicChat" repo="AtomicChat/Qwen3.8-27B-GGUF" drafter="mtp/3" kv="f16" effort="medium" />](../reports/qwen3.8-27b.md) | <ScoreCell value="37.5" note="38%" /> | **60 min** | <span class="ctxuse">96k<br><TokCell shallow="14.3" deep="9.6" /></span> | 28k | **71%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">3 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 189/9</span> <span class="ms-pill cs-pill cs-pill-gray">commits 7</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">turns 179</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 75%</span></span> |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.6-35B-A3B-4bit" kv="f16" effort="on" />](../reports/qwen3.6-35b-a3b.md) | <ScoreCell value="37.5" note="38%" /> | **19 min** | <span class="ctxuse">36k<br><TokCell shallow="54.5" deep="37.4" /></span> | 17k | <span class="ctxuse">184%<br><span class="ms-pill cs-pill cs-pill-yellow">1 compaction</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 63/9</span> <span class="ms-pill cs-pill cs-pill-gray">commits 3</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 2</span> <span class="ms-pill cs-pill cs-pill-gray">turns 67</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 3m</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 58%</span></span> |
| [<ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" />](../reports/qwen3.8-27b.md) | <ScoreCell value="12.5" note="13%" /> | 85 min | <span class="ctxuse">26k<br><TokCell shallow="17.3" deep="14.8" /></span> | 7k | **88%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">1 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 29/2</span> <span class="ms-pill cs-pill cs-pill-gray">commits 1</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">turns 35</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 10t</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 57%</span></span> |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" />](../reports/bonsai-27b.md) | <ScoreCell value="12.5" note="13%" /> | **43 min** | <span class="ctxuse">64k<br><TokCell shallow="14.8" deep="7.9" /></span> | 16k | **77%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span> <span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 76/22</span> <span class="ms-pill cs-pill cs-pill-gray">commits 2</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 4</span> <span class="ms-pill cs-pill cs-pill-gray">turns 79</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 69%</span></span> |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" />](../reports/gemma-4-26b-a4b.md) | <ScoreCell value="12.5" note="13%" /> | **28 min** | **208k** | 29k | **64%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">2 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">4 medium</span> <span class="ms-pill cs-pill cs-pill-gray">3 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 120/21</span> <span class="ms-pill cs-pill cs-pill-gray">commits 7</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 1</span> <span class="ms-pill cs-pill cs-pill-gray">turns 121</span> <span class="ms-pill cs-pill cs-pill-red">loop tool call</span></span> |
<!-- gen:mendel-local:end -->

#### Legend

Bold marks the best two of a column and any further row within 15
percent of the column's span of the second best, the same rule as
the homepage: higher is better for Score and the window, lower for
Wall and Ctx use.

- **Score**: the run's score out of 100, capped at the share of
  libraries done. A muted percentage before the score is that share,
  as on the homepage; no percentage means all eight libraries done.
- **Wall**: minutes from the first prompt to the end of the run; the
  cap is 300.
- **Ctx / speed**: the harness window the run had, in tokens, over
  the config's real-text decode speed, shallow then deep, as the
  homepage shows it. The window carries a dagger when the config now
  serves a larger one. The speed is not measured during the run; it
  is the best reading the site has for that config.
- **Tokens**: tokens the model generated over the run.
- **Ctx use**: the peak context as a share of the window. With
  compactions, the number adds one full window per compaction to the
  peak after the last one, so 238 percent means two compactions and a
  peak of 38 percent, and the pill under it gives the count. A
  compaction fires near the window and keeps 8192 tokens, so that
  reading is a floor, not a measure.
- **Bugs**: the defects the scorer found, by severity; `0 bugs` when
  it found none.
- **Stats**: `calls` is tool calls with the failed ones after the
  slash; `commits` the commits on the branch; `turns` the assistant
  messages; `nudges` the pushes the harness gave a stalled agent,
  `t` for a tooling cause that costs nothing and `m` for a model
  cause that costs points; `loop` a repetition the runner stopped;
  `trimmed` the share of noisy shell commands the model piped through
  `head` or `tail` or sent to a file instead of reading raw. High is
  good. Every pill except `commits` hides at zero.

Run notes for the two partials are in the
[comparison page's Mendel section](../comparison#mendel-agentic-quality-issue-13-bake-off):
both closed early on `mlx_lm.server` failures or the time budget, not
on the rubric.

Three Gemma-4-12B runs are marked invalid and are not listed above.
They ran the retired LM Studio entry `google/gemma-4-12b` with thinking
on and its pre-fix chat template, fell into a repetition loop, and
committed nothing. They measure that serving combination, not the
model — the evidence is on
[the Gemma-12B data page](./gemma-4-12b-it.md#the-retired-entry).

Two Ternary-Bonsai-27B guided runs with thinking off (2026-09-06) are
invalid and are not listed above. The first hit a dead
`gh` token and looped on login. The second ran 85 identical shell calls
in a row against a missing file and committed nothing in three hours,
and the operator stopped it. Both rows are in the guided CSV with their
stop reasons. A third attempt is scheduled, with the runner's live
loop stop in place.

Three scored rows above are scheduled for a re-run: Qwen3.8-27B GGUF
blind (87), Gemma-4-26B-A4B GGUF blind (47.5) and Qwen3.6-35B-A3B
guided (83). They compacted under the harness's old reserve of 16384
tokens; since 2026-09-06 the harness reserves 8192, the answer budget.
Each keeps its row until the fresh one lands. The 87 ran at effort
medium, which Qwen3.8 is no longer run at; its fresh row is the 4-bit
build at effort xhigh, 93 above, complete on a 65536 window at the
8192 reserve. The rows at xhigh (80.5) and low (66) above are the
ISTA 3-bit build at the 8192 reserve, on a 147456 window. Every row
from 2026-09-09 on records its sampling: temperature 1.0, top_p 0.95,
the server's default.

## Cloud reference — blind test

<!-- gen:mendel-cloud:start -->
| model | harness | score |
|---|---|--:|
| kimi-k3 | pi | **93.5/100** |
| grok-4.6 | pi | **92.5/100** |
| gpt-5.6-sol | pi | **92/100** |
| claude-opus-5 | pi | **90.5/100** |
| deepseek-v4-flash-0731 | pi | **84.5/100** |
| gpt-5.6-luna | pi | **83.5/100** |
| deepseek-v4-pro-0813 | pi | **79/100** |
| glm-5p3-flash | pi | **75/100** |
| Claude Sonnet 4.5 | pi | **43.5/100** |
| claude-haiku-4.5 | pi | **34/100** |
<!-- gen:mendel-cloud:end -->

## Guided test

Local rows on the current guided prompt, the same columns as the
blind table; the cloud anchors on the same prompt follow. A
blind-guided pair can land at different times.

<!-- gen:mendel-guided:start -->
| Model / Config | Score | Wall | Ctx / speed | Tokens | Ctx use | Bugs | Stats |
|---|--:|--:|--:|--:|--:|---|---|
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" />](../reports/qwen3.6-35b-a3b.md) | <ScoreCell value="83" top /> | **92 min** | <span class="ctxuse">120k<br><TokCell shallow="43.7" deep="13.0" /></span> | 43k | <span class="ctxuse">**179%**<br><span class="ms-pill cs-pill cs-pill-yellow">1 compaction</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 285/25</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">commits 16</span> <span class="ms-pill cs-pill cs-pill-gray">turns 230</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 65%</span></span> |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" />](../reports/qwen3.6-35b-a3b.md) | <ScoreCell value="62.5" top /> | **89 min** | <span class="ctxuse">80k<br><TokCell shallow="43.7" deep="13.0" /></span> | 35k | <span class="ctxuse">**195%**<br><span class="ms-pill cs-pill cs-pill-yellow">1 compaction</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span> <span class="ms-pill cs-pill cs-pill-gray">3 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 264/24</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">commits 16</span> <span class="ms-pill cs-pill cs-pill-gray">turns 267</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 63%</span></span> |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="on" />](../reports/gemma-4-26b-a4b.md) | <ScoreCell value="57" note="88%" top /> | **115 min** | <span class="ctxuse">**208k**<br><TokCell shallow="60.1" deep="19.1" /></span> | 61k | <span class="ctxuse">298%<br><span class="ms-pill cs-pill cs-pill-yellow">2 compactions</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">4 medium</span> <span class="ms-pill cs-pill cs-pill-gray">5 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 269/42</span> <span class="ms-pill cs-pill cs-pill-gray">commits 13</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 2</span> <span class="ms-pill cs-pill cs-pill-gray">turns 273</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 1m</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 27%</span></span> |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="off" />](../reports/qwen3.6-35b-a3b.md) | <ScoreCell value="46.5" /> | **96 min** | <span class="ctxuse">48k<br><TokCell shallow="43.7" deep="13.0" /></span> | 50k | <span class="ctxuse">1305%<br><span class="ms-pill cs-pill cs-pill-yellow">12 compactions</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">4 medium</span> <span class="ms-pill cs-pill cs-pill-gray">5 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 299/37</span> <span class="ms-pill cs-pill cs-pill-gray">commits 7</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">turns 275</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 2m</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 58%</span></span> |
| [<ModelSpec base="Gemma-4-12B" quant="Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-12b-it-GGUF" kv="f16" effort="off" />](../reports/gemma-4-12b-it.md) | <ScoreCell value="37.5" note="38%" /> | **98 min** | <span class="ctxuse">**256k**<br><TokCell shallow="25.0" deep="9.2" /></span> | 79k | **48%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">3 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 132/42</span> <span class="ms-pill cs-pill cs-pill-gray">commits 3</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 1</span> <span class="ms-pill cs-pill cs-pill-gray">turns 136</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 3m</span> <span class="ms-pill cs-pill cs-pill-red">loop text</span></span> |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="q4_0+bias" effort="on" />](../reports/bonsai-27b.md) | <ScoreCell value="31.5" note="38%" /> | 300 min | <span class="ctxuse">64k<br><TokCell shallow="14.8" deep="7.9" /></span> | 0k | <span class="ctxuse">1096%<br><span class="ms-pill cs-pill cs-pill-yellow">10 compactions</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">2 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">4 medium</span> <span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 343/96</span> <span class="ms-pill cs-pill cs-pill-gray">commits 3</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 1</span> <span class="ms-pill cs-pill cs-pill-gray">turns 352</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 35%</span></span> |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="f16" effort="off" />](../reports/gemma-4-26b-a4b.md) | <ScoreCell value="25" note="25%" /> | **20 min** | **208k** | 16k | **34%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">2 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span> <span class="ms-pill cs-pill cs-pill-gray">3 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 91/28</span> <span class="ms-pill cs-pill cs-pill-gray">commits 3</span> <span class="ms-pill cs-pill cs-pill-gray">turns 93</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">nudges 1t</span> <span class="ms-pill cs-pill cs-pill-red">loop tool call</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 4%</span></span> |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" />](../reports/bonsai-27b.md) | <ScoreCell value="12.5" note="13%" /> | 300 min | <span class="ctxuse">56k<br><TokCell shallow="24.5" deep="17.3" /></span> | 18k | **80%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">1 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 122/0</span> <span class="ms-pill cs-pill cs-pill-gray">commits 1</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">turns 128</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 2t</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 61%</span></span> |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="Q2_g64" server="prism-llama" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-gguf" kv="f16" effort="on" />](../reports/bonsai-27b.md) | <ScoreCell value="12.5" note="13%" /> | 195 min | <span class="ctxuse">128k<br><TokCell shallow="15.0" deep="9.7" /></span> | 65k | <span class="ctxuse">**197%**<br><span class="ms-pill cs-pill cs-pill-yellow">1 compaction</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">2 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span> <span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 376/74</span> <span class="ms-pill cs-pill cs-pill-gray">commits 2</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 1</span> <span class="ms-pill cs-pill cs-pill-gray">turns 307</span> <span class="ms-pill cs-pill cs-pill-yellow">nudges 1m</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 53%</span></span> |
<!-- gen:mendel-guided:end -->

Cloud anchors on the same guided prompt:

<!-- gen:mendel-guided-cloud:start -->
| model | harness | score |
|---|---|--:|
| glm-5p3-flash | pi | **98/100** |
| deepseek-v4-flash-0731 | pi | **97/100** |
| gpt-5.6-luna | pi | **88.5/100** |
| claude-sonnet-4.5 | pi | **88/100** |
| Claude Haiku 4.5 | pi | **76/100** |
<!-- gen:mendel-guided-cloud:end -->

## Stale rows

Valid local rows on an older prompt version of either test. They stay
as a record of what the model did on that prompt; the hosted reports
keep one scoreboard per version.

<!-- gen:mendel-stale:start -->
| Model / Config | Test | Score | Wall | Ctx / speed | Tokens | Ctx use | Bugs | Stats |
|---|---|--:|--:|--:|--:|--:|---|---|
| [<ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="low" />](../reports/qwen3.8-27b.md) | <span class="ms-pill cs-pill cs-pill-green">mendel-guided</span> | <ScoreCell value="75" note="75%" top /> | 154 min | <span class="ctxuse">26k<br><TokCell shallow="17.3" deep="14.8" /></span> | 17k | 85% | <span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 95/9</span> <span class="ms-pill cs-pill cs-pill-gray">commits 6</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">turns 73</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 53%</span></span> |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" />](../reports/qwen3.6-35b-a3b.md) | <span class="ms-pill cs-pill cs-pill-green">mendel-guided</span> | <ScoreCell value="65.5" top /> | **76 min** | <span class="ctxuse">**96k**<br><TokCell shallow="43.7" deep="13.0" /></span> | 40k | 96% | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span> <span class="ms-pill cs-pill cs-pill-gray">3 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 251/18</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">commits 8</span> <span class="ms-pill cs-pill cs-pill-gray">turns 253</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 32%</span></span> |
| [<ModelSpec base="Qwen3.6-35B-A3B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/Qwen3.6-35B-A3B-MTP-GGUF" drafter="mtp/3" kv="q8_0" effort="on" />](../reports/qwen3.6-35b-a3b.md) | <span class="ms-pill cs-pill cs-pill-yellow">mendel-blind</span> | <ScoreCell value="41.5" /> | 132 min | <span class="ctxuse">**96k**<br><TokCell shallow="43.7" deep="13.0" /></span> | 40k | <span class="ctxuse">196%<br><span class="ms-pill cs-pill cs-pill-yellow">1 compaction</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 258/28</span> <span class="ms-pill cs-pill cs-pill-gray">commits 13</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 5</span> <span class="ms-pill cs-pill cs-pill-gray">turns 210</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 27%</span></span> |
| [<ModelSpec base="Gemma-4-26B-A4B" quant="UD-Q4_K_XL" server="llama-server" publisher="unsloth" repo="unsloth/gemma-4-26b-a4b-it-GGUF" drafter="mtp/2" kv="q8_0" effort="on" />](../reports/gemma-4-26b-a4b.md) | <span class="ms-pill cs-pill cs-pill-yellow">mendel-blind</span> | <ScoreCell value="38" /> | **104 min** | **256k** | 17k | **54%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">1 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 115/20</span> <span class="ms-pill cs-pill cs-pill-gray">commits 9</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-red">failed commits 2</span> <span class="ms-pill cs-pill cs-pill-gray">turns 116</span></span> |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" />](../reports/bonsai-27b.md) | <span class="ms-pill cs-pill cs-pill-yellow">mendel-blind</span> | <ScoreCell value="37.5" note="38%" /> | **102 min** | <span class="ctxuse">56k<br><TokCell shallow="24.5" deep="17.3" /></span> | 9k | **49%** | <span class="pills"><span class="ms-pill cs-pill cs-pill-red">1 critical</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">2 medium</span> <span class="ms-pill cs-pill cs-pill-gray">1 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 53/5</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">commits 3</span> <span class="ms-pill cs-pill cs-pill-gray">turns 57</span></span> |
| [<ModelSpec base="Qwen3.8-27B" quant="4-bit" server="mlx_lm.server" publisher="mlx-community" repo="mlx-community/Qwen3.8-27B-4bit" kv="f16" effort="medium" />](../reports/qwen3.8-27b.md) | <span class="ms-pill cs-pill cs-pill-yellow">mendel-blind</span> | <ScoreCell value="37.5" note="38%" /> | 254 min | <span class="ctxuse">26k<br><TokCell shallow="17.3" deep="14.8" /></span> | 22k | 90% | <span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">2 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 135/12</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">commits 6</span> <span class="ms-pill cs-pill cs-pill-gray">turns 120</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 31%</span></span> |
| [<ModelSpec base="Ternary-Bonsai-27B" quant="2-bit" server="mlx_lm.server" publisher="prism-ml" repo="prism-ml/Ternary-Bonsai-27B-mlx-2bit" kv="f16" effort="on" />](../reports/bonsai-27b.md) | <span class="ms-pill cs-pill cs-pill-green">mendel-guided</span> | <ScoreCell value="37.5" note="38%" /> | 230 min | <span class="ctxuse">56k<br><TokCell shallow="24.5" deep="17.3" /></span> | 14k | 89% | <span class="pills"><span class="ms-pill cs-pill cs-pill-yellow">1 medium</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">3 minor</span></span> | <span class="pills"><span class="ms-pill cs-pill cs-pill-gray">calls 94/4</span> <span class="ms-pill cs-pill cs-pill-gray">commits 3</span></span><br><span class="pills"><span class="ms-pill cs-pill cs-pill-gray">turns 83</span> <span class="ms-pill cs-pill cs-pill-gray">trimmed 35%</span></span> |
<!-- gen:mendel-stale:end -->
