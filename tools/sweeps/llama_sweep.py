import json, os, time, urllib.request
BASE = "http://127.0.0.1:8081"
def post(path, payload, timeout=3600):
    req = urllib.request.Request(BASE + path, json.dumps(payload).encode(),
                                 {"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return json.load(r)
block = ("def parse_record_%04d(line):\n"
         "    fields = line.strip().split(',')\n"
         "    return {'id': int(fields[0]), 'name': fields[1], 'value': float(fields[2])}\n\n")
def ntok(text):
    return len(post("/tokenize", {"content": text})["tokens"])
prompt = "Here is a code base:\n\n"
bi = 0
print("depth_tokens\tdecode_toks\tpp_delta\tstep_seconds", flush=True)
for target in [int(x) for x in os.environ["DEPTH_LIST"].split(",")]:
    cur = ntok(prompt)
    per_block = ntok(block % bi)
    while cur < target:
        add = (target - cur) // per_block or 1
        prompt += "".join(block % (bi + i) for i in range(add))
        bi += add
        cur = ntok(prompt)
    t0 = time.time()
    try:
        r = post("/completion", {"prompt": prompt, "n_predict": 64,
                                 "temperature": 0, "cache_prompt": True})
    except Exception as e:
        print(f"{cur}\tFAILED: {e}", flush=True)
        break
    prompt += r.get("content", "")
    tm = r.get("timings", {})
    tps = tm.get("predicted_per_second") or 0
    print(f"{cur}\t{tps:.2f}\t{tm.get('prompt_n','?')}\t{time.time()-t0:.0f}", flush=True)
    if tps < 8:
        print(f"stop: below 8 tok/s at depth {cur}", flush=True)
        break
    time.sleep(float(os.environ.get("STEP_PAUSE_S", "25")))
