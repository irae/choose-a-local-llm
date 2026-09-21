#!/bin/bash
# Drive the laya-cost cells. One argument: cuda or cpu.
set -u
DEV="$1"
ROOT=/home/irae/code/choose-a-local-llm-research1
PY=$ROOT/scratchpad/laya-venv/bin/python
RUN=$ROOT/hardware/arrietty/research/laya-decision-engine/laya-run.py
CELL=$ROOT/hardware/arrietty/research/run1/results/laya-cost
OUT=$CELL/summaries
mkdir -p "$OUT" "$CELL/answers"

# Calls per cell. The GPU takes the full 200 everywhere. The CPU keeps 200
# where a cell fits five minutes, and drops to what fits otherwise.
calls_for() {
    if [ "$DEV" = "cuda" ]; then echo 200; return; fi
    case "$1" in
        1) echo 200 ;;
        5) echo 200 ;;
        10) echo 64 ;;
        50) echo 20 ;;
    esac
}

for ck in english multilingual typed-decisions; do
    for lang in en pt; do
        # cold load, three repeats in three new processes
        for i in 1 2 3; do
            [ -f "$OUT/cold-$DEV-$ck-$i.json" ] && continue
            CUDA_VISIBLE_DEVICES=$([ "$DEV" = cpu ] && echo "" || echo "0") \
            $PY "$RUN" --questions "$CELL/questions-01.json" --data "$CELL/data-$lang.jsonl" \
                --checkpoint "$ck" --device "$DEV" --limit 1 --warmup 0 \
                --out "$CELL/answers/cold-$DEV-$ck-$i.jsonl" \
                --json-summary "$OUT/cold-$DEV-$ck-$i.json" > /dev/null 2>&1 || echo "FAIL cold $DEV $ck $i"
        done
        for k in 1 5 10 50; do
            tag="$DEV-$ck-$lang-q$k"
            [ -f "$OUT/$tag.json" ] && continue
            n=$(calls_for "$k")
            echo "=== $tag  calls=$n  $(date '+%H:%M:%S')"
            CUDA_VISIBLE_DEVICES=$([ "$DEV" = cpu ] && echo "" || echo "0") \
            $PY "$RUN" --questions "$CELL/questions-$(printf %02d "$k").json" \
                --data "$CELL/data-$lang.jsonl" --checkpoint "$ck" --device "$DEV" \
                --batch 1 --warmup 20 --limit "$n" \
                --out "$CELL/answers/$tag.jsonl" --json-summary "$OUT/$tag.json" > /dev/null 2>&1 \
                || echo "FAIL $tag"
        done
    done
done
echo "=== done $DEV $(date '+%H:%M:%S')"
