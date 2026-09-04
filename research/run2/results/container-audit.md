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

### Which one is newer — settled, and it is the opposite of the guess

Fetched from `google/gemma-4-12b-it` and hashed the same way:

| Revision | Length | Hash | Has the tool-response branch |
| --- | --- | --- | --- |
| `657684f`, 2026-06-03, before the fix | 17466 | `a23ecdbb9d01` | no |
| `main`, after commit `711c136` of 2026-07-15 | 18681 | `ac8703caf039` | **yes** |

That commit is the one Google closed the thought-loop discussion with:
*"fix: chat template — null handling, reasoning preservation, turn-tag
balance, input validation (#35)"*.

So the extra branch is **the fix, not the defect**. Opening the thought
channel after a tool response is the reasoning-preservation behaviour
Google added. And the short template — the one every local
`chat_template.jinja` ships — is the pre-fix file.

### The consequence: our MLX containers carry the stale template

Line the hashes up against what is on the machine:

| File on this Mac | Hash | Verdict |
| --- | --- | --- |
| `mlx-community/gemma-4-12B-it-4bit` `chat_template.jinja` | `a23ecdbb9d01` | **pre-fix** |
| `mlx-community/gemma-4-26b-a4b-it-4bit` `chat_template.jinja` | `a23ecdbb9d01` | **pre-fix** |
| `lmstudio-community/gemma-4-12B-it-MLX-4bit` `chat_template.jinja` | `a23ecdbb9d01` | **pre-fix** |
| `lmstudio-community/gemma-4-12B-it-MLX-4bit` `tokenizer_config.json` | `ac8703caf039` | current |
| `unsloth/gemma-4-12b-it-GGUF` embedded | `e78e690d773f` | post-fix base, plus unsloth's own edits |

**Every MLX Gemma-4 container on this machine ships the chat template
Google replaced to fix the thought loop.** The LM Studio repo carries
both: a current template in `tokenizer_config.json` and a stale one in
`chat_template.jinja`. Which of the two ran depends on which file the LM
Studio MLX engine prefers, and that is now the single most valuable
thing to check about the LM Studio path.

This does not yet prove the stale template caused the flood. It proves
the flood ran on a container whose template Google had already fixed for
that exact failure, and it turns the T1.1 arms into a clean before/after:

- arm `embedded` — the GGUF's own post-fix template
- arm `short` — the same GGUF forced onto the pre-fix template with
  `--chat-template-file`

All five template texts, including both fetched revisions, are archived
in `~/.local/share/choose-a-local-llm/evidence/run2-context-ramp/`.

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

## Finding 1b — the MLX path resolves to the stale template. Measured.

The container LM Studio actually served Gemma-12B from is
`~/.cache/lm-studio/models/lmstudio-community/gemma-4-12B-it-MLX-4bit/`.
It holds both files:

| File | Hash | Verdict |
| --- | --- | --- |
| `chat_template.jinja` | `a23ecdbb9d01` | pre-fix |
| `tokenizer_config.json` inline template | `ac8703caf039` | current |

Which one wins is not a guess. `AutoTokenizer.from_pretrained` on that
directory, run with the homebrew mlx-lm 0.31.3 python, resolves to:

```
resolved template len=17466 sha=a23ecdbb9d01
has tool_response branch: False
```

**The pre-fix template.** transformers prefers `chat_template.jinja`
over the inline copy, and mlx-lm loads its tokenizer through
transformers. So every mlx-lm serving of this container runs the
template Google replaced on 2026-07-15 to fix the thought loop, while a
current template sits unused in the same folder.

LM Studio's MLX engine is a separate build
(`llm_engine_mlx_amphibian.node`, backend 1.11.0) and its binaries do
not name either file in their strings, so this measurement covers
upstream mlx-lm directly and LM Studio only by strong inference.

### Proposed fix — one file, no re-download

**Do not apply without the owner.** It changes a model container behind
published measurements.

```
cd ~/.cache/lm-studio/models/lmstudio-community/gemma-4-12B-it-MLX-4bit
mv chat_template.jinja chat_template.jinja.pre-fix-20260603
python3 -c "import json; open('chat_template.jinja','w').write(json.load(open('tokenizer_config.json'))['chat_template'])"
```

That makes the resolved template the current one the repo already ships.
The same check and the same fix apply to
`mlx-community/gemma-4-12B-it-4bit` and
`mlx-community/gemma-4-26b-a4b-it-4bit`, except those two have no inline
copy to restore from, so their replacement has to come from
`google/gemma-4-12b-it` at revision `main`. Both fetched revisions are
archived beside the ramp evidence.

Anything measured after this change is a different configuration from
every Gemma-4 row published so far. That is the owner's call, not this
run's.

## Finding 1c — what the template actually renders, from the live server

`POST /apply-template` on the running llama-server renders a prompt
without generating anything, so the template in effect can be read
directly rather than argued about. The conversation used ends in a tool
response, which is the situation the fix changed:

```
user:      list the files
assistant: tool_call bash {"command": "ls"}
tool:      error: invalid flag
```

With the GGUF's embedded post-fix template and `enable_thinking` true,
the rendered prompt ends:

```
...<|tool_response>response:bash{value:<|"|>error: invalid flag<|"|>}<tool_response|><|channel>thought\n
```

**The prompt ends with the thought channel opened and not closed.** The
model's first generated token continues inside a thought channel. That
is Google's intended behaviour after the 2026-07-15 fix, and it is also
the exact token the newline floods contain.

With the pre-fix template the same conversation renders nothing after
`<tool_response|>`: no generation prefix at all, so the model chooses
what to open by itself. The arm-2 rendering will be captured the same
way and stored beside this one.

The request and the rendering are archived in
`~/.local/share/choose-a-local-llm/evidence/run2-context-ramp/`
as `apply-template.json` and `rendered-embedded.json`.
