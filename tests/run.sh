#!/bin/bash
# Runs every test for the shared tools in benchmarks/. Exits non-zero
# when any test fails. Run it after you touch any script under
# benchmarks/.
#
# It needs bash, git, curl and python3. It starts a fake completion
# server on a free loopback port and puts a fake vm_stat on PATH, so it
# runs on Linux and on macOS and it touches no real server.
#
# Python coverage runs only when `python3 -m coverage` is already
# installed. There is no coverage for the bash tests.

set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
STATUS=0

echo "== bash tests"
bash "$HERE/test-run-watch.sh" || STATUS=1
bash "$HERE/test-mendel-smoke.sh" || STATUS=1
bash "$HERE/test-run-pi-rpc.sh" || STATUS=1

echo
echo "== python tests"
if python3 -m coverage --version > /dev/null 2>&1; then
    python3 -m coverage run --source "$HERE/../benchmarks" \
        -m unittest discover -s "$HERE" -p 'test_*.py' || STATUS=1
    python3 -m coverage report -m || true
else
    echo "coverage is not installed, running without it"
    python3 -W ignore::ResourceWarning \
        -m unittest discover -s "$HERE" -p 'test_*.py' || STATUS=1
fi

echo
if [ "$STATUS" = "0" ]; then
    echo "all tests passed"
else
    echo "TESTS FAILED"
fi
exit "$STATUS"
