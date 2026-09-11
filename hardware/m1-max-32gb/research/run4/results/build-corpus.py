import hashlib
import os
import sys

from transformers import AutoTokenizer

root = os.path.expanduser("~/code/mendel")
out = sys.argv[1]
target = 150000
skip_dirs = {"node_modules", ".git"}
paths = []
for d, dirs, files in os.walk(root):
    dirs[:] = sorted(x for x in dirs if x not in skip_dirs)
    for f in sorted(files):
        if not f.endswith(".js"):
            continue
        if f.endswith(".min.js") or "lock" in f:
            continue
        paths.append(os.path.join(d, f))
paths.sort()
tok = AutoTokenizer.from_pretrained("Qwen/Qwen3.8-27B")
parts, total, used = [], 0, 0
for p in paths:
    rel = os.path.relpath(p, root)
    with open(p, encoding="utf-8", errors="replace") as fh:
        body = fh.read()
    chunk = f"// file: {rel}\n{body}\n"
    parts.append(chunk)
    total += len(tok(chunk)["input_ids"])
    used += 1
    if total >= target:
        break
text = "".join(parts)
with open(out, "w", encoding="utf-8") as fh:
    fh.write(text)
sha = hashlib.sha256(text.encode("utf-8")).hexdigest()
print(f"files {used} of {len(paths)}, tokens {total}, bytes {len(text.encode())}, sha256 {sha}")
print("first", os.path.relpath(paths[0], root), "last", os.path.relpath(paths[used - 1], root))
