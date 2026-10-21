#!/usr/bin/env bash
# Build the ChatGPT Plugins Directory upload from listing/.
#
# The ZIP holds the package at its root (.codex-plugin/plugin.json, .mcp.json, skills/, assets/),
# with entries sorted and timestamps fixed, so one commit always yields the same bytes. The Claude
# manifest stays out: Anthropic's directory reads the folder, not this ZIP.
#
# usage: scripts/package-listing.sh
set -euo pipefail
cd "$(dirname "$0")/.."
version=$(node -p "require('./listing/.codex-plugin/plugin.json').version")
out="dist/naulon-listing-${version}.zip"
mkdir -p dist
rm -f "$out"
(
  cd listing
  find . -type f ! -name 'README.md' ! -path './.claude-plugin/*' | LC_ALL=C sort | sed 's#^\./##' > ../dist/.files
  TZ=UTC touch -t 202601010000 $(cat ../dist/.files)
  zip -X -q "../$out" -@ < ../dist/.files
)
rm -f dist/.files
echo "$out"
unzip -l "$out" | tail -n +4 | head -n -2 | awk '{print "  " $4}'
