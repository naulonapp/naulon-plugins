# Contributing

This repo ships manifests, skills and assets only: never code, never a secret.

## Setup

```bash
git config core.hooksPath .githooks
```

`.githooks/commit-msg` checks commit messages and `.githooks/pre-commit` checks staged Markdown,
both with `scripts/prose-voice.mjs`.

## Layout

```
.agents/plugins/marketplace.json      ChatGPT / Codex marketplace
.claude-plugin/marketplace.json       Claude Code marketplace
plugins/naulon/
  .codex-plugin/plugin.json           ChatGPT / Codex manifest
  .claude-plugin/plugin.json          Claude Code manifest
  .mcp.json                           the hosted MCP server
  skills/                             shared by both ecosystems
  assets/                             listing icon + composer icon
```

Two manifest dialects, one plugin. Adding, renaming or removing anything means editing **both**
marketplaces and **both** `plugin.json` files in the same commit.

## Releasing

Any change under `plugins/` is a release. Bump `version` in both `plugin.json` files to the same
value. Installed copies only update when the version changes, so an unbumped change reaches nobody,
and CI refuses it (`scripts/check-version-bump.sh`).

## The two credential keys in `.mcp.json`

Both are load-bearing, one per ecosystem. Claude Code reads `headers` and expands
`${NAULON_AGENT_TOKEN}` inside it. Codex has no `headers` field: its field is `http_headers`, whose
values are sent verbatim with no expansion, so for Codex the credential travels only on
`bearer_token_env_var`. Each ecosystem drops the other's key rather than rejecting it. Deleting
either one silently breaks that half. Both must name the same variable, and neither may ever hold
a literal token.

Verified with codex-cli 0.153.4 and Claude Code, against a live gate.

## What must be kept current, and against what

Everything here derives from something that lives elsewhere.

| Here | Derives from | Breaks how |
|---|---|---|
| `.mcp.json` `url` | the deployed gate mount | a moved mount installs a plugin that cannot connect |
| `.mcp.json` auth keys | the mount's auth scheme | a mount that needs a bearer and a manifest that supplies none falls back to OAuth discovery and dies on a Cloudflare 502 |
| plugin `version` | a deliberate release decision | an unbumped change never reaches an installed copy |
| the tools table in `README.md` | what the hosted server registers | a renamed tool makes the README lie |
| `skills/*` | the hosted server's tool names, arguments and result fields | a renamed tool or field makes a skill call something that does not exist |
| `skills/verify-citation-license` | the JWKS path, the `naulon` claim shape, and the `/licenses/:jti` scoping rule | a claim rename makes the instructions wrong, silently |
| `privacyPolicyURL`, `privacyPolicyUrl`, `termsOfServiceURL`, `websiteURL` | live pages on naulon.app | a 404 fails plugin review |
| `icon`, `logo`, `composerIcon`, `brandColor` | the naulon brand kit | drifts from the product's look |

The listing icon is read once, when the plugin is first submitted to a directory. Changing it
afterwards does not change the listing, so get it right before submitting.

Before opening a pull request, run `claude plugin validate plugins/naulon`. It should report
nothing.
