#!/bin/bash
# Install EvalPlus globally via pipx (PEP 668 blocks bare pip3 on this Mac).
set -e
pipx install evalplus 2>&1 | tail -3 || pipx upgrade evalplus 2>&1 | tail -3
evalplus.codegen --help >/dev/null 2>&1 || pipx inject evalplus openai
echo "--- verify ---"
evalplus.codegen --help 2>&1 | head -5
evalplus.evaluate --help 2>&1 | head -5
