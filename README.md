# naulon plugins

Distribution for the naulon plugin, in both plugin ecosystems, from one repo.

naulon lets an agent find sources whose publishers charge for machine reading, see the price
before committing, pay the author directly, and come away with a **Citation License** that
anyone can verify against published keys without calling naulon. Discovery and quotes are free.
Humans always read free — only agents are tolled.

## Install

The server is authenticated, so set your agent token first — mint one at
[naulon.app/buyer/agents](https://naulon.app/buyer/agents) and export it where your client will
read it:

```
export NAULON_AGENT_TOKEN=nln_agent_…
```

**ChatGPT / Codex** — add this repo as a plugin marketplace, then install `naulon`.

**Claude Code**
```
/plugin marketplace add naulonapp/naulon-plugins
/plugin install naulon@naulon
```

Both read the same plugin directory. The token travels as `Authorization: Bearer` — Claude Code
expands it into `headers`, Codex reads `bearer_token_env_var`; both keys name the same variable
and each ecosystem ignores the other's. Nothing is stored in this repo.

Without the variable set, Claude Code names it in a startup warning and the server answers `401`.
Discovery and quotes cost nothing, but the token is how the fleet knows who is asking, so every
tool needs it.

## Layout

```
.agents/plugins/marketplace.json      ChatGPT / Codex marketplace
.claude-plugin/marketplace.json       Claude Code marketplace
plugins/naulon/
  .codex-plugin/plugin.json           ChatGPT / Codex manifest
  .claude-plugin/plugin.json          Claude Code manifest
  .mcp.json                           the hosted MCP server
  skills/                             shared by both ecosystems
  assets/                             logo + composer icon
```

Two manifest dialects, one plugin. Adding or renaming anything means editing **both** in the
same commit.

## What must be kept current, and against what

This repo is a plane strangers read, and it derives from things that live elsewhere. Nothing
here is self-evidently true, so each row names its upstream.

| Here | Derives from | Breaks how |
|---|---|---|
| `.mcp.json` `url` | the deployed gate mount | a moved mount installs a plugin that cannot connect |
| `.mcp.json` auth keys | the mount's auth scheme | a mount that needs a bearer and a manifest that supplies none installs a plugin whose client falls back to OAuth discovery and dies on a Cloudflare 502 |
| plugin `version` | a deliberate release decision | never bump it as a side effect of an edit |
| tool list implied by the descriptions | what `buildServer()` registers in `@naulon/wayfarer-mcp` | a renamed tool makes the listing lie |
| `skills/verify-citation-license` | the JWKS path, the `naulon` claim shape, and the `/licenses/:jti` scoping rule | a claim rename makes the instructions wrong, silently |
| `privacyPolicyURL`, `termsOfServiceURL`, `websiteURL` | live pages on naulon.app | a 404 fails plugin review |
| `brandColor`, `logo`, `composerIcon` | the portal brand kit | drifts from the product's look |

The control plane carries the rule that governs this repo and the test that enforces the
first three rows: `.claude/rules/plugin-marketplace-sync.md` in `naulon-cloud`.

## Verification, without trusting us

Every paid read returns a Citation License: an RFC 7519 JWT signed EdDSA/Ed25519. Verify it
with stock `jose` or `pyjwt` against
[`/.well-known/naulon-jwks.json`](https://gate.naulon.app/.well-known/naulon-jwks.json) — no
naulon API call, no account. The bundled `verify-citation-license` skill walks it, including
the part people get wrong: `exp` is the re-read window, not the validity of the record.

## Custody

Payment settles from the buyer's own wallet straight to the author. naulon never holds funds.

## Licence

MIT — see [LICENSE](./LICENSE).
