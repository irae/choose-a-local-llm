import glob
import hashlib
import os

base = os.path.expanduser('~/.cache/huggingface/hub')
rows = []
for repo in sorted(glob.glob(base + '/models--*')):
    name = os.path.basename(repo).replace('models--', '').replace('--', '/', 1)
    name = name.replace('--', '/')
    revs = []
    for ref in glob.glob(repo + '/refs/*'):
        revs.append((os.path.basename(ref), open(ref).read().strip()))
    snaps = [os.path.basename(p) for p in glob.glob(repo + '/snapshots/*')]
    size = 0
    for root, _dirs, files in os.walk(repo + '/blobs'):
        for f in files:
            try:
                size += os.path.getsize(os.path.join(root, f))
            except OSError:
                pass
    rows.append((name, revs, snaps, size))

for name, revs, snaps, size in rows:
    ref = revs[0][1] if revs else (snaps[0] if snaps else '?')
    print('| `%s` | `%s` | %.1f GB |' % (name, ref, size / 1e9))
