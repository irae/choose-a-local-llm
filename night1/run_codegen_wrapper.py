#!/usr/bin/env python3
# EvalPlus 0.3.1's openai backend hardcodes max_new_tokens=768 (evalplus/provider/base.py)
# and run_codegen has no CLI flag for it. A tight cap truncates thinking-model output
# mid-thought and falsely tanks scores (see README's "Gate mechanics"). This wrapper
# patches the decoder's max_new_tokens after construction, then runs the normal Fire CLI.
#
# 3072 was found too low for all three models tonight (blocks 1, 2, and 3 all show
# empty completions from reasoning exhausting the token budget: 2%, 38%, and ~30-40%
# respectively). Deliberately kept at 3072 rather than raised: the user wants tonight's
# three blocks to stay apples-to-apples under the same (known-flawed) budget, and will
# have a separate effort design the corrected methodology (see night1/state.md).
#
# It also has no way to send extra JSON body fields (e.g. mlx_lm.server's
# chat_template_kwargs for reasoning_effort). Set EVALPLUS_EXTRA_BODY to a JSON
# object to merge it into every chat completion request (openai backend only).
import json
import os

import evalplus.codegen as codegen_mod

# A chat response can come back with content=None (e.g. a cut-off or
# empty-answer turn). EvalPlus's sanitize() calls text.split() on it directly
# and crashes the whole run instead of scoring that one problem as failed.
from evalplus.provider.openai import OpenAIChatDecoder

_orig_openai_codegen = OpenAIChatDecoder.codegen


def _safe_openai_codegen(self, prompt, do_sample=True, num_samples=200):
    outputs = _orig_openai_codegen(
        self, prompt, do_sample=do_sample, num_samples=num_samples
    )
    return [o if o is not None else "" for o in outputs]


OpenAIChatDecoder.codegen = _safe_openai_codegen

MAX_NEW_TOKENS = 3072
_orig_make_model = codegen_mod.make_model

_extra_body_raw = os.environ.get("EVALPLUS_EXTRA_BODY")
_extra_body = json.loads(_extra_body_raw) if _extra_body_raw else None


def _patched_make_model(*args, **kwargs):
    decoder = _orig_make_model(*args, **kwargs)
    decoder.max_new_tokens = MAX_NEW_TOKENS
    if _extra_body and kwargs.get("backend") == "openai":
        from evalplus.gen.util import openai_request as oreq

        _orig_make_request = oreq.make_request

        def _patched_make_request(*a, **kw):
            kw.setdefault("extra_body", {}).update(_extra_body)
            return _orig_make_request(*a, **kw)

        oreq.make_request = _patched_make_request
    return decoder


codegen_mod.make_model = _patched_make_model

if __name__ == "__main__":
    from fire import Fire

    Fire(codegen_mod.run_codegen)
