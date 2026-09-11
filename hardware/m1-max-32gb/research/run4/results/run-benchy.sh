#!/bin/bash
set -u
arm="$1"; shift
out="hardware/m1-max-32gb/research/run4/results"
date '+%Y-%m-%d %H:%M:%S' > "$out/benchy-$arm.start"
grep -c print_timing "$out/server-benchy-$arm.log" >> "$out/benchy-$arm.start"
llama-benchy --base-url http://127.0.0.1:8081/v1 --model qwen3.8-27b \
  --tokenizer Qwen/Qwen3.8-27B \
  --pp 512 --tg 256 --depth "$@" \
  --runs 2 \
  --post-run-cmd "sleep 60; vm_stat | head -12 >> $out/benchy-$arm-vm.log" \
  --format md --save-result "$out/benchy-$arm.md" \
  > "$out/benchy-$arm.stdout.log" 2>&1
echo "benchy exit $?" >> "$out/benchy-$arm.stdout.log"
date '+%Y-%m-%d %H:%M:%S' >> "$out/benchy-$arm.stdout.log"
