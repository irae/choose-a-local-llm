import concurrent.futures, json, os, sys, time, urllib.request

# True concurrent-request probe: N independent HTTP requests fired at once
# (not evalplus --bs, which asks for N samples of ONE prompt in a single
# request -- not the same thing). Times how LM Studio's continuous
# batching actually scales with real parallel connections.

BASE = os.environ.get("SWEEP_BASE", "http://127.0.0.1:8081")
MODEL = os.environ["LMS_MODEL"]
N = int(sys.argv[1]) if len(sys.argv) > 1 else 1
MAX_TOKENS = int(os.environ.get("MAX_TOKENS", "150"))

PROMPTS = [
    "Write a Python function that parses ISO dates.",
    "Write a JavaScript function that deep clones an object.",
    "Write a Python function that checks if a string is a palindrome.",
    "Write a function that computes the nth Fibonacci number iteratively.",
]

def one_request(i):
    prompt = PROMPTS[i % len(PROMPTS)] + f" (variant {i})"
    payload = {"model": MODEL, "messages": [{"role": "user", "content": prompt}],
               "max_tokens": MAX_TOKENS, "temperature": 0, "stream": True}
    req = urllib.request.Request(BASE + "/v1/chat/completions",
                                  json.dumps(payload).encode(),
                                  {"Content-Type": "application/json"})
    t0 = time.time()
    n_chunks = 0
    first_token_t = None
    with urllib.request.urlopen(req, timeout=600) as r:
        for line in r:
            if line.startswith(b"data:") and b"[DONE]" not in line:
                d = json.loads(line[5:])
                delta = d["choices"][0].get("delta", {})
                if delta.get("content") or delta.get("reasoning_content"):
                    if first_token_t is None:
                        first_token_t = time.time()
                    n_chunks += 1
    t1 = time.time()
    return {"i": i, "chunks": n_chunks, "ttft": (first_token_t - t0) if first_token_t else None,
            "wall": t1 - t0}

t_start = time.time()
with concurrent.futures.ThreadPoolExecutor(max_workers=N) as ex:
    results = list(ex.map(one_request, range(N)))
t_total = time.time() - t_start

total_chunks = sum(r["chunks"] for r in results)
print(f"N={N} wall_total={t_total:.2f}s total_chunks={total_chunks} "
      f"aggregate_tok/s={total_chunks/t_total:.2f}")
for r in results:
    print(f"  req[{r['i']}] wall={r['wall']:.2f}s ttft={r['ttft']:.2f}s chunks={r['chunks']}")
