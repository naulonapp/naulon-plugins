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
listing/                              the directory package for Anthropic and OpenAI (free, read-only)
```

`listing/` is not in either marketplace. It is the package for both directories, which do not
accept tools that move money, so it connects the anonymous mount `/_naulon/mcp/public` with no
credential and skills that use only that mount's tools. Build the ZIP with
`scripts/package-listing.sh`; its listing text, review cases and release notes live in its
`.codex-plugin/plugin.json`. It has its own version, raised for each upload.

Two manifest dialects, one plugin. Adding, renaming or removing anything means editing **both**
marketplaces and **both** `plugin.json` files in the same commit.

## Releasing

Any change under `plugins/` is a release. Bump `version` in both `plugin.json` files to the same
value. Installed copies only update when the version changes, so an unbumped change reaches nobody,
and CI refuses it (`scripts/check-version-bump.sh`).

## The two credential keys in `.mcp.json`

Both are load-bearing, one per ecosystem, and both name `NAULON_AGENT_TOKEN`.

- **Claude Code** reads `headers` and fills `${user_config.NAULON_AGENT_TOKEN}` from the sensitive
  `userConfig` option in `.claude-plugin/plugin.json`, which it asks for when the plugin is enabled
  and keeps in the secure credential store. Anthropic's directory holds a plugin that reads a
  credential from the user's environment for review, which is why Claude Code does not use the
  variable. With the option unset, Claude Code does not start the server.
- **Codex** has no `headers` field: its field is `http_headers`, whose values are sent verbatim with
  no expansion, so the credential travels only on `bearer_token_env_var`.

Each ecosystem drops the other's key rather than rejecting it. Deleting either one silently breaks
that half, and neither may ever hold a literal token.

Verified: Claude Code 2.1.306 sends `Authorization: Bearer <the configured value>`, and no request at
all with the option unset. Codex last verified with codex-cli 0.153.4.

## What must be kept current, and against what

Everything here derives from something that lives elsewhere.

| Here | Derives from | Breaks how |
|---|---|---|
| `.mcp.json` `url` | the deployed gate mount | a moved mount installs a plugin that cannot connect |
| `.mcp.json` auth keys | the mount's auth scheme | a mount that needs a bearer and a manifest that supplies none falls back to OAuth discovery and dies on a Cloudflare 502 |
| plugin `version` | a deliberate release decision | an unbumped change never reaches an installed copy |
| the tools table in `README.md` | what the hosted server registers | a renamed tool makes the README lie |
| `plugins/naulon/README.md` | what the plugin runs, sends and connects to | the directory's security scan rejects behaviour the README does not disclose |
| `listing/` listing and review cases | the tools the public mount serves (`PUBLIC_TOOLS`, `PUBLIC_CLOUD_TOOLS`) and OpenAI's listing limits | a case naming a tool the mount lacks fails review; an over-long field fails the upload |
| `skills/*` | the hosted server's tool names, arguments and result fields | a renamed tool or field makes a skill call something that does not exist |
| `skills/verify-citation-license` | the JWKS path, the `naulon` claim shape, and the `/licenses/:jti` scoping rule | a claim rename makes the instructions wrong, silently |
| `privacyPolicyURL`, `privacyPolicyUrl`, `termsOfServiceURL`, `termsOfServiceUrl`, `documentationUrl`, `supportUrl`, `websiteURL` | live pages | a 404 fails plugin review |
| `icon`, `logo`, `composerIcon`, `brandColor` | the naulon brand kit | drifts from the product's look |

The listing icon is read once, when the plugin is first submitted to a directory. Changing it
afterwards does not change the listing, so get it right before submitting.

Before opening a pull request, run `claude plugin validate plugins/naulon`. It should report
nothing.
