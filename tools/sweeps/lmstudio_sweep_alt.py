import glob, json, os, threading, time, urllib.request

# Alternating multi-context creep for LM Studio: N independent append-only
# prompts, grown round-robin (A, wait, B, wait, A, ...) instead of one
# prompt filled to its ceiling before the next starts. Simulates several
# agents each slowly growing their own session, not all decoding at once.
# LM Studio has no id_slot param like llama-server -- context identity is
# whatever the server's own prompt-cache keys on (verified: distinct
# prefixes get distinct cache records). Each context here uses a disjoint
# block-number range so their prefixes never collide.

PAUSE = float(os.environ.get("STEP_SLEEP", "0"))
BASE = os.environ.get("SWEEP_BASE", "http://127.0.0.1:8081")
MODEL = os.environ["LMS_MODEL"]
N_CONTEXTS = int(os.environ.get("N_CONTEXTS", "2"))

def _latest_log():
    files = sorted(glob.glob(os.path.expanduser(
        "~/.cache/lm-studio/server-logs/*/*.log")))
    return files[-1] if files else ""

LOG = os.environ.get("LM_LOG") or _latest_log()
_log_pos = 0

def _watchdog():
    global _log_pos
    sigs = ("[ERROR]", "OutOfMemory", "crashed", "Traceback")
    while True:
        time.sleep(3)
        try:
            with open(LOG, errors="ignore") as f:
                f.seek(_log_pos)
                chunk = f.read()
                _log_pos = f.tell()
        except OSError:
            continue
        if any(x in chunk for x in sigs):
            print(f"SERVER-LOG-ERROR detected in {LOG}; exiting 42", flush=True)
            os._exit(42)

if LOG:
    with open(LOG, errors="ignore") as f:
        f.seek(0, os.SEEK_END)
        _log_pos = f.tell()
    threading.Thread(target=_watchdog, daemon=True).start()

def post_chat(content, max_tokens=64):
    payload = {"model": MODEL, "messages": [{"role": "user", "content": content}],
               "max_tokens": max_tokens, "temperature": 0, "stream": True}
    req = urllib.request.Request(BASE + "/v1/chat/completions",
                                  json.dumps(payload).encode(),
                                  {"Content-Type": "application/json"})
    times, text = [], []
    with urllib.request.urlopen(req, timeout=3600) as r:
        for line in r:
            if line.startswith(b"data:") and b"[DONE]" not in line:
                d = json.loads(line[5:])
                delta = d["choices"][0].get("delta", {})
                piece = delta.get("content") or delta.get("reasoning_content")
                if piece:
                    times.append(time.time())
                    text.append(piece)
    return times, "".join(text)

def last_cache_line():
    if not LOG:
        return None
    try:
        lines = open(LOG, errors="ignore").readlines()
    except OSError:
        return None
    for line in reversed(lines):
        if "Prompt cache restore" in line:
            cached = int(line.split("cached_tokens=")[1].split()[0])
            uncached = int(line.split("uncached_tokens=")[1].split()[0])
            return cached, uncached
    return None

block = ("def parse_record_%05d(line):\n"
         "    fields = line.strip().split(',')\n"
         "    return {'id': int(fields[0]), 'name': fields[1], 'value': float(fields[2])}\n\n")
per_block = 52

# Each context gets a disjoint block-number range so prefixes never collide.
RANGE_SPAN = 200000
contexts = []
for c in range(N_CONTEXTS):
    contexts.append({
        "label": chr(ord("A") + c),
        "prompt": f"Here is code base {chr(ord('A') + c)}:\n\n",
        "bi": c * RANGE_SPAN,
        "est": 6,
    })

DEPTH_LIST = [int(x) for x in os.environ["DEPTH_LIST"].split(",")]
print("context\tdepth_tokens_est\tdecode_toks\tstep_seconds\tcache_hit", flush=True)
stop_all = False
for target in DEPTH_LIST:
    if stop_all:
        break
    for ctx in contexts:
        while ctx["est"] < target:
            add = (target - ctx["est"]) // per_block or 1
            ctx["prompt"] += "".join(block % (ctx["bi"] + i) for i in range(add))
            ctx["bi"] += add
            ctx["est"] += add * per_block
        t0 = time.time()
        try:
            times, gen = post_chat(ctx["prompt"], max_tokens=64)
        except Exception as e:
            print(f"{ctx['label']}\t{ctx['est']}\tFAILED: {e}", flush=True)
            stop_all = True
            break
        if len(times) < 3:
            print(f"{ctx['label']}\t{ctx['est']}\tFAILED: only {len(times)} chunks", flush=True)
            stop_all = True
            break
        tps = (len(times) - 1) / (times[-1] - times[0])
        ctx["prompt"] += gen
        ctx["est"] += len(times)
        cache = last_cache_line()
        hit = f"{cache[0]/(cache[0]+cache[1]):.2f}" if cache and (cache[0] + cache[1]) else "?"
        print(f"{ctx['label']}\t{ctx['est']}\t{tps:.2f}\t{time.time()-t0:.0f}\t{hit}", flush=True)
        if PAUSE:
            time.sleep(PAUSE)
        if tps < 8:
            print(f"stop: context {ctx['label']} below 8 tok/s at depth {ctx['est']}", flush=True)
            stop_all = True
            break
