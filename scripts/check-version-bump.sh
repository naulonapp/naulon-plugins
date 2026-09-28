#!/usr/bin/env bash
# Refuse a change under plugins/ that leaves the plugin version where it was.
#
# Claude Code fetches an installed plugin again only when its version changes, so an unbumped edit
# ships to nobody. Both manifests must also agree, since each ecosystem reads its own.
#
# usage: scripts/check-version-bump.sh <base-ref>
set -euo pipefail
base="${1:?base ref}"
claude=plugins/naulon/.claude-plugin/plugin.json
codex=plugins/naulon/.codex-plugin/plugin.json
v_claude=$(node -p "require('./$claude').version")
v_codex=$(node -p "require('./$codex').version")
if [ "$v_claude" != "$v_codex" ]; then
  echo "version mismatch: $claude says $v_claude, $codex says $v_codex" >&2; exit 1
fi
if ! git diff --quiet "$base" -- plugins/; then
  v_base=$(git show "$base:$claude" | node -p "JSON.parse(require('fs').readFileSync(0,'utf8')).version")
  if [ "$v_base" = "$v_claude" ]; then
    echo "plugins/ changed but the version is still $v_claude. Installed copies will not update." >&2
    echo "Bump \"version\" in both $claude and $codex." >&2
    exit 1
  fi
fi
echo "version $v_claude ok"
