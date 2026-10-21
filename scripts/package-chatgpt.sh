#!/usr/bin/env bash
# Build the ChatGPT Plugins Directory upload from chatgpt/.
#
# The ZIP holds the package at its root (.codex-plugin/plugin.json, .mcp.json, skills/, assets/),
# with entries sorted and timestamps fixed, so one commit always yields the same bytes.
#
# usage: scripts/package-chatgpt.sh
set -euo pipefail
cd "$(dirname "$0")/.."
version=$(node -p "require('./chatgpt/.codex-plugin/plugin.json').version")
out="dist/naulon-chatgpt-${version}.zip"
mkdir -p dist
rm -f "$out"
(
  cd chatgpt
  find . -type f ! -name 'README.md' | LC_ALL=C sort | sed 's#^\./##' > ../dist/.files
  TZ=UTC touch -t 202601010000 $(cat ../dist/.files)
  zip -X -q "../$out" -@ < ../dist/.files
)
rm -f dist/.files
echo "$out"
unzip -l "$out" | tail -n +4 | head -n -2 | awk '{print "  " $4}'
