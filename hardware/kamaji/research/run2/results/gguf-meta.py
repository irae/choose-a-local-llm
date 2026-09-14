#!/usr/bin/env python3
"""gguf-meta.py — read the metadata header of a GGUF file.

Research run 2, experiment T0.1. The `gguf` python package is not
installed on this machine and this run may not install one, so this
reads the header itself. It only reads; it never writes a model file.

Usage:
    gguf-meta.py <file.gguf> [key ...]

With no keys it prints every scalar key and the size of every array.
With keys it prints only those, in full.
"""

import json
import struct
import sys

UINT8, INT8, UINT16, INT16, UINT32, INT32, FLOAT32, BOOL, STRING, ARRAY, UINT64, INT64, FLOAT64 = range(13)

FIXED = {
    UINT8: ("<B", 1), INT8: ("<b", 1),
    UINT16: ("<H", 2), INT16: ("<h", 2),
    UINT32: ("<I", 4), INT32: ("<i", 4),
    FLOAT32: ("<f", 4), BOOL: ("<?", 1),
    UINT64: ("<Q", 8), INT64: ("<q", 8), FLOAT64: ("<d", 8),
}


def read_fixed(f, kind):
    fmt, size = FIXED[kind]
    return struct.unpack(fmt, f.read(size))[0]


def read_string(f):
    length = struct.unpack("<Q", f.read(8))[0]
    return f.read(length).decode("utf-8", errors="replace")


def skip_value(f, kind):
    if kind in FIXED:
        f.seek(FIXED[kind][1], 1)
    elif kind == STRING:
        length = struct.unpack("<Q", f.read(8))[0]
        f.seek(length, 1)
    elif kind == ARRAY:
        inner = struct.unpack("<I", f.read(4))[0]
        count = struct.unpack("<Q", f.read(8))[0]
        if inner in FIXED:
            f.seek(FIXED[inner][1] * count, 1)
        else:
            for _ in range(count):
                skip_value(f, inner)
    else:
        raise ValueError("unknown gguf value type %d" % kind)


def read_value(f, kind):
    if kind in FIXED:
        return read_fixed(f, kind)
    if kind == STRING:
        return read_string(f)
    if kind == ARRAY:
        inner = struct.unpack("<I", f.read(4))[0]
        count = struct.unpack("<Q", f.read(8))[0]
        return ("array", inner, count)
    raise ValueError("unknown gguf value type %d" % kind)


def read_header(path, wanted):
    out = {}
    with open(path, "rb") as f:
        magic = f.read(4)
        if magic != b"GGUF":
            raise SystemExit("not a GGUF file: %s" % path)
        version = struct.unpack("<I", f.read(4))[0]
        struct.unpack("<Q", f.read(8))[0]
        kv_count = struct.unpack("<Q", f.read(8))[0]
        out["_gguf_version"] = version
        for _ in range(kv_count):
            key = read_string(f)
            kind = struct.unpack("<I", f.read(4))[0]
            if wanted and key not in wanted:
                skip_value(f, kind)
                continue
            if kind == ARRAY and not wanted:
                out[key] = read_value(f, kind)
                inner = out[key][1]
                count = out[key][2]
                if inner in FIXED:
                    f.seek(FIXED[inner][1] * count, 1)
                else:
                    for _ in range(count):
                        skip_value(f, inner)
                out[key] = "array(type=%d, count=%d)" % (inner, count)
            else:
                out[key] = read_value(f, kind)
    return out


def main():
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    path = sys.argv[1]
    wanted = set(sys.argv[2:])
    meta = read_header(path, wanted)
    print(json.dumps(meta, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
