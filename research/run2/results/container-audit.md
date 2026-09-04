# Container audit — templates and quantization (T0.1, T0.2, T0.3)

Run 2, session 1, 2026-09-04. Reads only. No model was downloaded and no
file was changed. Tool: `gguf-meta.py` in this folder, written for this
audit because the `gguf` python package is not installed and this run
does not install one.

## Finding 1 — two different Gemma-4 chat templates are in the cache, and they disagree about tool responses

Three template texts exist across the local Gemma-4 containers. The
comparison ignores whitespace.

| Container | Template source | Length | Hash |
| --- | --- | --- | --- |
| `unsloth/gemma-4-12b-it-GGUF` (Q4_K_XL) | GGUF `tokenizer.chat_template` | 18922 | `e78e690d773f` |
| `mlx-community/gemma-4-12B-it-4bit` | `chat_template.jinja` | 17466 | `a23ecdbb9d01` |
| `mlx-community/gemma-4-26b-a4b-it-4bit` | `chat_template.jinja` | 17466 | `a23ecdbb9d01` |
| `lmstudio-community/gemma-4-12B-it-MLX-4bit` | `chat_template.jinja` | 17466 | `a23ecdbb9d01` |
| `lmstudio-community/gemma-4-12B-it-MLX-4bit` | `tokenizer_config.json` `chat_template` | 18681 | `ac8703caf039` |

Read the last two rows together. **One repo ships two different
templates in two files.** Which one runs depends on which file the
loader reads. That is a silent fork inside a single download.

### The difference that matters

The short template (17466) ends its generation prompt like this:

```jinja
{%- if add_generation_prompt -%}
    {%- if ns.prev_message_type != 'tool_response' and ns.prev_message_type != 'tool_call' -%}
        {{- '<|turn>model\n' -}}
        {%- if not enable_thinking | default(false) -%}
            {{- '<|channel>thought\n<channel|>' -}}
        {%- endif -%}
    {%- endif -%}
{%- endif -%}
```

After a tool response it emits **nothing**.

The long templates (18922 in the GGUF, 18681 in the LM Studio
`tokenizer_config.json`) add one branch:

```jinja
    {%- elif ns.prev_message_type == 'tool_response' and enable_thinking -%}
        {{- '<|channel>thought\n' -}}
```

After a tool response, with thinking on, they **open the thought channel
and do not close it**. The model must continue inside an open thought
channel.

Now put that beside the measured failure. The Gemma-12B newline flood
contains only newlines and `<|channel>`, and run 1's diagnosis
(`../run1/results/backend-diagnosis.md`) states the flood is a thought
channel that opens and never proceeds. The draft notes say it appears
right after a failed-edit turn — that is, right after a tool response.
The long template's extra branch produces exactly that opening.

### What this does NOT yet prove

Which template is the newer one. The local files cannot say. The
snapshot dates are download dates: the GGUF landed 2026-08-25 and the
MLX repos 2026-08-28 and 2026-08-29, all after the Google chat-template
fix of 2026-07-15, so the dates separate nothing. The long template also
carries a comment about avoiding an "O(n) backward scan", which reads
like a later refactor, not an older file. So the extra branch may be the
fix rather than the defect: after a tool response the model turn is
still open, and re-opening `<|turn>model` would be wrong.

The direction is a measurement, not an opinion. It is testable with the
containers already on the machine, and the test is cheap: serve the same
GGUF twice, once on the embedded template and once with
`--chat-template-file` pointing at the short template, and replay the
same failing conversation. That arm is now added to T1.1.

Both template texts are archived in
`~/.local/share/choose-a-local-llm/evidence/run2-context-ramp/` beside
the ramp logs.

## Finding 2 — the quantized-PLE claim does not reproduce on our containers

`results/web-quant-and-models.md` reports that every HF mlx-community
Gemma-4 quant is broken by a quantized per-layer embedding. That defect
needs a per-layer embedding tensor. **Our containers do not have one.**

`mlx-community/gemma-4-12B-it-4bit` holds 1341 tensors. Every tensor
name under the language model is one of `embed_tokens`, the 48 decoder
layers, and the final norm. There is no `per_layer` tensor of any name,
although `config.json` does declare
`text_config.vocab_size_per_layer_input = 262144`. The
`lmstudio-community` MLX 4-bit repo has the identical tensor list.

So the reported defect cannot be present as described. What IS present
is a different and smaller thing, worth recording:

| Repo | Quantization | `embed_tokens` |
| --- | --- | --- |
| `mlx-community/gemma-4-12B-it-4bit` | 4 bits, group 64, affine, no per-module override | 4 bits |
| `lmstudio-community/gemma-4-12B-it-MLX-4bit` | same | 4 bits |
| `mlx-community/gemma-4-12B-it-qat-OptiQ-4bit` | 330 per-module overrides | **8 bits** |
| `mlx-community/gemma-4-26b-a4b-it-4bit` | 31 overrides, all `router.proj` | 4 bits |

The plain 4-bit quants keep the 262144-entry embedding matrix at 4 bits.
The QAT OptiQ repo protects it at 8 bits, and the 26B MoE quant protects
its routers at 8 bits. That is a real quality lever and a cheap A/B, but
it is not the PLE story the report told. Note the OptiQ repo is only
partly downloaded here: `config.json` and nothing else.

## Finding 3 — instruction sets and KV policy

`sysctl` on this Mac, and what our configs assume: recorded in
`instruction-sets.md` when that check runs. Not complete in this
session.
