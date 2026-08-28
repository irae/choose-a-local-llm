import json, os, threading, time, urllib.request
BASE = os.environ.get("SWEEP_BASE", "http://127.0.0.1:8081")
MODEL = os.environ["MLX_MODEL"]
MLOG = os.environ.get("MLOG", "")

def _watchdog():
    sigs = ("Insufficient Memory", "Command buffer execution failed", "Traceback (most recent call last)")
    while True:
        time.sleep(3)
        try:
            tail = open(MLOG, errors="ignore").read()[-8000:]
        except OSError:
            continue
        if any(x in tail for x in sigs):
            print("SERVER-THREAD-DEATH detected in log; exiting 42", flush=True)
            os._exit(42)

if MLOG:
    threading.Thread(target=_watchdog, daemon=True).start()
block = ("def parse_record_%04d(line):\n"
         "    fields = line.strip().split(',')\n"
         "    return {'id': int(fields[0]), 'name': fields[1], 'value': float(fields[2])}\n\n")
per_block = 52
prompt = "Here is a code base:\n\n"
bi = 0
est = 6
print("depth_tokens_est\tdecode_toks\tstep_seconds", flush=True)
for target in [int(x) for x in os.environ["DEPTH_LIST"].split(",")]:
    while est < target:
        add = (target - est) // per_block or 1
        prompt += "".join(block % (bi + i) for i in range(add))
        bi += add
        est += add * per_block
    payload = {"model": MODEL, "prompt": prompt, "max_tokens": 64,
               "temperature": 0, "stream": True}
    req = urllib.request.Request(BASE + "/v1/completions", json.dumps(payload).encode(),
                                 {"Content-Type": "application/json"})
    t0 = time.time()
    text = []
    times = []
    try:
        with urllib.request.urlopen(req, timeout=3600) as r:
            for line in r:
                if line.startswith(b"data:") and b"[DONE]" not in line:
                    d = json.loads(line[5:])
                    text.append(d["choices"][0].get("text") or "")
                    times.append(time.time())
    except Exception as e:
        print(f"{est}\tFAILED: {e}", flush=True)
        break
    if len(times) < 3:
        print(f"{est}\tFAILED: only {len(times)} chunks", flush=True)
        break
    tps = (len(times) - 1) / (times[-1] - times[0])
    gen = "".join(text)
    prompt += gen
    est += len(times)
    print(f"{est}\t{tps:.2f}\t{time.time()-t0:.0f}", flush=True)
    if tps < 8:
        print(f"stop: below 8 tok/s at depth {est}", flush=True)
        break
