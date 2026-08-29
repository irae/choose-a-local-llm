import glob, json, os, threading, time, urllib.request

PAUSE = float(os.environ.get("STEP_SLEEP", "0"))
BASE = os.environ.get("SWEEP_BASE", "http://127.0.0.1:8081")
MODEL = os.environ["LMS_MODEL"]

# LM Studio's /v1/completions endpoint on this build returns garbage and
# streams the whole reply in one burst (no real per-token pacing) --
# verified 2026-08-29. /v1/chat/completions streams correctly and reuses
# the prompt cache on append-only growth (confirmed via server-log
# cached_tokens). Use chat, not raw completions, for this server.

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

def cache_hit_ratio():
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
            total = cached + uncached
            return cached / total if total else 0
    return None

block = ("def parse_record_%04d(line):\n"
         "    fields = line.strip().split(',')\n"
         "    return {'id': int(fields[0]), 'name': fields[1], 'value': float(fields[2])}\n\n")
per_block = 52
prompt = "Here is a code base:\n\n"
bi = 0
est = 6
print("depth_tokens_est\tdecode_toks\tstep_seconds\tcache_hit", flush=True)
for target in [int(x) for x in os.environ["DEPTH_LIST"].split(",")]:
    while est < target:
        add = (target - est) // per_block or 1
        prompt += "".join(block % (bi + i) for i in range(add))
        bi += add
        est += add * per_block
    t0 = time.time()
    try:
        times, gen = post_chat(prompt, max_tokens=64)
    except Exception as e:
        print(f"{est}\tFAILED: {e}", flush=True)
        break
    if len(times) < 3:
        print(f"{est}\tFAILED: only {len(times)} chunks", flush=True)
        break
    tps = (len(times) - 1) / (times[-1] - times[0])
    prompt += gen
    est += len(times)
    hit = cache_hit_ratio()
    print(f"{est}\t{tps:.2f}\t{time.time()-t0:.0f}\t{hit if hit is None else f'{hit:.2f}'}", flush=True)
    if PAUSE:
        time.sleep(PAUSE)
    if tps < 8:
        print(f"stop: below 8 tok/s at depth {est}", flush=True)
        break
