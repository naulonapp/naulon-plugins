#!/usr/bin/env bash
# Hold server.json, the MCP Registry listing, to the facts it restates.
#
# The registry accepts any well-formed file, so a wrong one publishes cleanly and fails later, in
# front of whoever tries to connect. A published version can never be edited, only superseded.
#
# usage: scripts/check-registry.sh [<base-ref>]
#   With a base ref, a server.json that differs from it must also carry a new version.
#   NAULON_SKIP_NPM=1 skips the one check that needs the network.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
base="${1:-}"

node - <<'NODE'
const fs = require("fs");
const read = (p) => JSON.parse(fs.readFileSync(p, "utf8"));
const server = read("server.json");
const fail = (m) => { console.error(`server.json: ${m}`); process.exitCode = 1; };

// The name is the listing's identity and the domain proof behind it. A changed name is a second
// listing, and the first one stays up with nobody able to update it.
if (server.name !== "app.naulon/naulon") fail(`name is ${server.name}, expected app.naulon/naulon`);
if (!server.description || server.description.length > 100) fail("description must be 1 to 100 characters");
if (!/^\d+\.\d+\.\d+$/.test(server.version ?? "")) fail(`version ${server.version} is not plain semver`);

// One hosted mount is listed: the anonymous one the directory package connects. It takes no
// credential, so a header here would ask every client for a token the mount ignores.
const listed = read("listing/.mcp.json").mcpServers.naulon.url;
const remotes = server.remotes ?? [];
if (remotes.length !== 1) fail(`expected one remote, found ${remotes.length}`);
for (const r of remotes) {
  if (r.type !== "streamable-http") fail(`remote type ${r.type}, expected streamable-http`);
  if (r.url !== listed) fail(`remote ${r.url} is not the mount listing/.mcp.json connects (${listed})`);
  if (r.headers?.length) fail("the anonymous mount takes no headers");
}

for (const p of server.packages ?? []) {
  for (const v of p.environmentVariables ?? []) {
    if (/KEY|SECRET|TOKEN/.test(v.name) && !v.isSecret) fail(`${v.name} must be marked isSecret`);
    if ("value" in v || ("default" in v && v.isSecret)) fail(`${v.name} must not carry a literal value`);
  }
}

const glama = read("glama.json");
if (!Array.isArray(glama.maintainers) || glama.maintainers.length === 0) {
  console.error("glama.json: maintainers must name at least one GitHub user");
  process.exitCode = 1;
}
NODE

# The registry reads mcpName from the PUBLISHED package, so a version that is not on npm yet, or
# was published without the field, fails the publish after the merge.
if [ "${NAULON_SKIP_NPM:-}" != "1" ]; then
  name=$(node -p "require('./server.json').name")
  node -p "(require('./server.json').packages ?? []).filter(p => p.registryType === 'npm').map(p => p.identifier + '@' + p.version).join('\n')" |
    while IFS= read -r spec; do
      [ -z "$spec" ] && continue
      got=$(npm view "$spec" mcpName 2>/dev/null || true)
      if [ "$got" != "$name" ]; then
        echo "server.json: $spec on npm has mcpName '${got}', expected '$name'." >&2
        echo "Release the package with that field first." >&2
        exit 1
      fi
    done
fi

if [ -n "$base" ] && git cat-file -e "$base:server.json" 2>/dev/null && ! git diff --quiet "$base" -- server.json; then
  v_base=$(git show "$base:server.json" | node -p "JSON.parse(require('fs').readFileSync(0,'utf8')).version")
  v_now=$(node -p "require('./server.json').version")
  if [ "$v_base" = "$v_now" ]; then
    echo "server.json changed but the version is still $v_now. The registry refuses a version twice." >&2
    exit 1
  fi
fi
echo "server.json $(node -p "require('./server.json').version") ok"
