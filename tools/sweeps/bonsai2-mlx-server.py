#!/usr/bin/env python3
"""bonsai2-mlx-server.py — an OpenAI-style chat server for the Bonsai 2 MLX pack.

Why it exists. The publisher ships no MLX server for this pack
(`PrismML-Eng/Bonsai-demo`, `scripts/start_mlx_server.sh` refuses). Stock
`mlx_lm.server` and `mlx_vlm.server` do not apply the pack's Hadamard
activation transform, so they either refuse the model type or return wrong
output. The context-creep tool needs a server. This file is a thin server
around the publisher's own one-shot path: the pack's `runtime/` loader
(`vision_artifact.load_vl_model`) and `mlx_vlm.stream_generate`, the same
calls as the demo's `scripts/mlx_generate_bonsai2.py`. A row measured
through it is served by this tool, not by a stock server. Say so in the
row's note.

What it does. It checks the pack's `runtime/*.py` against the publisher's
hash manifest, loads the pack, and serves `POST /v1/chat/completions`
(streamed or not), `POST /completion` (raw prompt, no chat template, the
shape the llama-server backend of the creep tool reads), `GET /v1/models`
and `GET /health` on the loopback address. Both POST routes return a
`timings` block with the decode and prompt speed that `mlx_vlm` counts for
the request (`predicted_per_second`, `prompt_per_second`), so a sweep reads
the server's own timing, as the method requires. One request runs at a time. It keeps no prompt cache: every request
reads its whole prompt again, so a depth sweep pays the full prefill at each
step. It changes nothing on the machine: no file is written, no setting is
touched. Reverse direction: stop the process.

Usage:
    <venv>/bin/python tools/sweeps/bonsai2-mlx-server.py

Environment:
    BONSAI2_PACK       the pack directory. Required.
    BONSAI2_MANIFEST   the publisher's `bonsai2-runtime.sha256`. Required.
    BONSAI2_PORT       port, default 8081.
    BONSAI2_TOP_P      default 1.0 (the request may override `top_p`).
    BONSAI2_TOP_K      default 0, no top-k (the request may override `top_k`).

Sampling. A request that sets `temperature` gets it, and 0 is greedy. A
request with no `temperature` gets 1.0, the publisher's thinking-mode value.

Exit codes: 0 stopped by signal, 2 a missing setting, 3 the runtime hash
check failed.

Validated 2026-09-22 against the demo's one-shot script: the same three
prompts gave the same answers.
"""

import hashlib
import json
import os
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

PACK = os.environ.get("BONSAI2_PACK")
MANIFEST = os.environ.get("BONSAI2_MANIFEST")
PORT = int(os.environ.get("BONSAI2_PORT", "8081"))
TOP_P = float(os.environ.get("BONSAI2_TOP_P", "1.0"))
TOP_K = int(os.environ.get("BONSAI2_TOP_K", "0"))

LOCK = threading.Lock()
STATE = {}


def check_runtime(pack, manifest):
    expected = {}
    for line in Path(manifest).read_text().splitlines():
        line = line.strip()
        if line and not line.startswith("#"):
            digest, name = line.split(None, 1)
            expected[name.strip()] = digest
    runtime = Path(pack) / "runtime"
    found = {f.name for f in runtime.glob("*.py")}
    problems = []
    for name in sorted(set(expected) | found):
        if name not in expected or name not in found:
            problems.append(name)
        elif hashlib.sha256((runtime / name).read_bytes()).hexdigest() != expected[name]:
            problems.append(name)
    if problems:
        print("runtime hash check failed: " + ", ".join(problems), file=sys.stderr)
        sys.exit(3)


def load():
    check_runtime(PACK, MANIFEST)
    sys.path.insert(0, str(Path(PACK) / "runtime"))
    import mlx.core as mx

    mx.set_default_device(mx.gpu)
    from mlx_vlm import stream_generate
    from mlx_vlm.prompt_utils import apply_chat_template
    from vision_artifact import chat_config, load_vl_model

    started = time.time()
    model, processor, config = load_vl_model(PACK)
    print("loaded %s in %.0fs" % (Path(PACK).name, time.time() - started), flush=True)
    STATE.update(model=model, processor=processor, config=config,
                 stream_generate=stream_generate,
                 apply_chat_template=apply_chat_template, chat_config=chat_config)


def prompt_text(messages):
    users = [m for m in messages if m.get("role") == "user"]
    content = (users[-1] if users else messages[-1]).get("content", "")
    if isinstance(content, list):
        content = "".join(p.get("text", "") for p in content if isinstance(p, dict))
    return content


def timings(last):
    if last is None:
        return {}
    return {"predicted_per_second": last.generation_tps,
            "prompt_per_second": last.prompt_tps,
            "predicted_n": last.generation_tokens,
            "prompt_n": last.prompt_tokens}


def raw_generate(body):
    kwargs = {"max_tokens": int(body.get("n_predict") or 64),
              "temperature": float(body.get("temperature", 1.0)),
              "top_p": float(body.get("top_p", TOP_P))}
    return STATE["stream_generate"](STATE["model"], STATE["processor"],
                                    body["prompt"], **kwargs)


def generate(body):
    prompt = STATE["apply_chat_template"](
        STATE["processor"], STATE["chat_config"](STATE["config"]),
        prompt_text(body.get("messages", [])), num_images=0)
    kwargs = {
        "max_tokens": int(body.get("max_tokens") or 256),
        "temperature": float(body.get("temperature", 1.0)),
        "top_p": float(body.get("top_p", TOP_P)),
    }
    top_k = int(body.get("top_k", TOP_K))
    if top_k:
        kwargs["top_k"] = top_k
    return STATE["stream_generate"](STATE["model"], STATE["processor"], prompt, **kwargs)


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        print("%s %s" % (self.address_string(), fmt % args), flush=True)

    def send_json(self, code, payload):
        data = json.dumps(payload).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def do_GET(self):
        if self.path == "/health":
            self.send_json(200, {"status": "ok", "model": PACK})
        elif self.path in ("/v1/models", "/models"):
            self.send_json(200, {"object": "list", "data": [{"id": PACK, "object": "model"}]})
        else:
            self.send_json(404, {"error": "not found"})

    def do_POST(self):
        if self.path not in ("/v1/chat/completions", "/chat/completions", "/completion"):
            self.send_json(404, {"error": "not found"})
            return
        body = json.loads(self.rfile.read(int(self.headers.get("Content-Length", 0))))
        if self.path == "/completion":
            with LOCK:
                text, last = "", None
                for piece in raw_generate(body):
                    text += piece.text
                    last = piece
                self.send_json(200, {"content": text, "timings": timings(last)})
            return
        with LOCK:
            if body.get("stream"):
                self.stream(body)
            else:
                self.whole(body)

    def whole(self, body):
        text, last = "", None
        for piece in generate(body):
            text += piece.text
            last = piece
        finish = "length" if last and last.generation_tokens >= int(body.get("max_tokens") or 256) else "stop"
        self.send_json(200, {
            "object": "chat.completion", "model": PACK,
            "choices": [{"index": 0, "finish_reason": finish,
                         "message": {"role": "assistant", "content": text}}],
            "usage": {"prompt_tokens": getattr(last, "prompt_tokens", 0),
                      "completion_tokens": getattr(last, "generation_tokens", 0)},
            "timings": timings(last),
        })

    def stream(self, body):
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream")
        self.send_header("Cache-Control", "no-cache")
        self.end_headers()
        for piece in generate(body):
            if not piece.text:
                continue
            chunk = {"object": "chat.completion.chunk", "model": PACK,
                     "choices": [{"index": 0, "delta": {"content": piece.text}}]}
            self.wfile.write(b"data: " + json.dumps(chunk).encode() + b"\n\n")
            self.wfile.flush()
        self.wfile.write(b"data: [DONE]\n\n")
        self.wfile.flush()


def main():
    if not PACK or not MANIFEST:
        print("BONSAI2_PACK and BONSAI2_MANIFEST are required", file=sys.stderr)
        sys.exit(2)
    load()
    print("serving on 127.0.0.1:%d" % PORT, flush=True)
    ThreadingHTTPServer(("127.0.0.1", PORT), Handler).serve_forever()


if __name__ == "__main__":
    main()
