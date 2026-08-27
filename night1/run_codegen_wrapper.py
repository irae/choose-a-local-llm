#!/usr/bin/env python3
# EvalPlus 0.3.1's openai backend hardcodes max_new_tokens=768 (evalplus/provider/base.py)
# and run_codegen has no CLI flag for it. A tight cap truncates thinking-model output
# mid-thought and falsely tanks scores (see README's "Gate mechanics"). This wrapper
# patches the decoder's max_new_tokens after construction, then runs the normal Fire CLI.
#
# 3072 was found too low on night 1 (blocks 1, 2, and 3 all show empty completions
# from reasoning exhausting the token budget: 2%, 38%, and ~30-40%). Night 1 kept
# 3072 on purpose so its three blocks stayed apples-to-apples (see night1/state.md).
# Night 2 sets a calibrated per-model budget via the EVALPLUS_MAX_NEW_TOKENS env
# var (see night2/NIGHT-AGENT.md); without it the flawed 3072 default still applies.
#
# It also has no way to send extra JSON body fields (e.g. mlx_lm.server's
# chat_template_kwargs for reasoning_effort). Set EVALPLUS_EXTRA_BODY to a JSON
# object to merge it into every chat completion request (openai backend only).
import json
import os
import signal

import openai

import evalplus.codegen as codegen_mod

# A chat response can come back with content=None (e.g. a cut-off or
# empty-answer turn). EvalPlus's sanitize() calls text.split() on it directly
# and crashes the whole run instead of scoring that one problem as failed.
from evalplus.provider.openai import OpenAIChatDecoder

# EvalPlus's own request helper (evalplus/gen/util/openai_request.py)
# hardcodes signal.alarm(100) around every request, and the OpenAI client
# it builds uses the SDK's ~600s default HTTP timeout. Whichever fires
# first cancels the request and retries with an identical (temperature=0)
# prompt, so a completion that genuinely needs longer than ~600s to finish
# retries forever and never completes. Found night 2 (2026-08-27) after a
# qwen36-think regeneration sat at 0 progress for 52 minutes; the server
# log showed the same task being launched and cancelled on a ~100s/~600s
# cycle. Fix: replace the alarm-based retry with a plain retry loop (no
# artificial deadline) and give the client a timeout long enough for any
# calibrated budget used tonight.
import evalplus.gen.util.openai_request as oreq


def _patient_make_auto_request(*args, **kwargs):
    ret = None
    while ret is None:
        try:
            ret = oreq.make_request(*args, **kwargs)
        except openai.RateLimitError:
            print("Rate limit exceeded. Waiting...")
            import time

            time.sleep(5)
        except openai.APIConnectionError:
            print("API connection error. Waiting...")
            import time

            time.sleep(5)
        except openai.APIError as e:
            print(e)
    return ret


oreq.make_auto_request = _patient_make_auto_request
signal.alarm(0)

_orig_openai_codegen = OpenAIChatDecoder.codegen


def _safe_openai_codegen(self, prompt, do_sample=True, num_samples=200):
    outputs = _orig_openai_codegen(
        self, prompt, do_sample=do_sample, num_samples=num_samples
    )
    return [o if o is not None else "" for o in outputs]


OpenAIChatDecoder.codegen = _safe_openai_codegen

MAX_NEW_TOKENS = int(os.environ.get("EVALPLUS_MAX_NEW_TOKENS", "3072"))
_orig_make_model = codegen_mod.make_model

_extra_body_raw = os.environ.get("EVALPLUS_EXTRA_BODY")
_extra_body = json.loads(_extra_body_raw) if _extra_body_raw else None


def _patched_make_model(*args, **kwargs):
    decoder = _orig_make_model(*args, **kwargs)
    decoder.max_new_tokens = MAX_NEW_TOKENS
    if kwargs.get("backend") == "openai":
        # Rebuild the client with a timeout long enough for any calibrated
        # budget tonight (up to 30000 tokens); the SDK's ~600s default cuts
        # off legitimate long completions, not just hung ones.
        decoder.client = openai.OpenAI(
            api_key=os.getenv("OPENAI_API_KEY", "none"),
            base_url=str(decoder.client.base_url),
            timeout=7200.0,
        )
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
