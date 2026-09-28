# naulon plugins

Distribution for the naulon plugin, in both plugin ecosystems, from one repo.

naulon lets an agent find sources whose publishers charge for machine reading, see the price
before committing, pay the author directly, and come away with a **Citation License** that
anyone can verify against published keys without calling naulon. Discovery and quotes are free.
Humans always read free; only agents are tolled.

## Install

The server is authenticated, so set your agent token first. Mint one at
[naulon.app/buyer/agents](https://naulon.app/buyer/agents) and export it where your client will
read it:

```
export NAULON_AGENT_TOKEN=nln_agent_…
```

An export lasts one shell. Put the line in `~/.zshrc` or `~/.bashrc`, or the next terminal starts
the client with no token.

**ChatGPT and Codex.** Add this repo as a plugin marketplace, then install `naulon`.

**Claude Code**
```
/plugin marketplace add naulonapp/naulon-plugins
/plugin install naulon@naulon
```

Both read the same plugin directory. Nothing is stored in this repo: the token travels as
`Authorization: Bearer`, read from your environment at connect time.

`.mcp.json` carries **two** credential keys and both are load-bearing, one per ecosystem. Claude
Code reads `headers` and expands `${NAULON_AGENT_TOKEN}` inside it. Codex has no `headers` field:
its field is `http_headers` and its values are sent verbatim with no expansion, so for Codex the
credential travels only on `bearer_token_env_var`. Each ecosystem drops the other's key rather than
rejecting it. Deleting either one silently breaks that half.

The export is a hard requirement in Codex, and it fails quietly: with the variable unset the MCP
server simply does not come up: no prompt, no OAuth fallback (`bearer_token_env_var` turns that
off), and nothing on screen at the default log level. The reason is in the log, verbatim:
`MCP startup failed: Environment variable NAULON_AGENT_TOKEN for MCP server 'naulon' is not set`.
Claude Code is louder: a named startup warning plus a `401`. Either way the fix is the export.
Discovery and quotes cost nothing, but the token is how the fleet knows who is asking, so every
tool needs it.

Verified with codex-cli 0.153.4 and Claude Code, against a live gate.

**Already connected by hand?** Claude Code de-duplicates MCP servers by URL, whatever they are
named. If you previously ran `claude mcp add --transport http naulon https://gate.naulon.app/_naulon/mcp …`
that server wins and this plugin's server is silently suppressed. You are not missing anything,
but you are also not gaining anything. Remove the hand-added one (`claude mcp remove naulon`) if
you would rather the plugin owned it: `claude mcp remove naulon -s local; claude mcp remove naulon -s user`.

## Updating

Claude Code turns auto-update off for marketplaces it does not ship, and it only fetches a plugin
again when its `version` changes. So an installed copy stays where it is until you ask:

```
claude plugin marketplace update naulon
claude plugin update naulon@naulon
```

Or turn on auto-update for this marketplace under `/plugin`, in the Marketplaces tab.

## What you get

The hosted MCP server's tools, plus these skills. In Claude Code each is also a command:

| Command | Does |
|---|---|
| `/naulon:ask <question>` | free survey first, then a paid, cited answer through `naulon_ask` |
| `/naulon:research <topic>` | discover, price, and pay only the sources worth it |
| `/naulon:discover <topic>` | list sources and prices, pays nothing |
| `/naulon:fact-check <claim>` | a verdict with the licence behind each source |
| `/naulon:verify-citation-license` | check a Citation License offline |

When the token is rejected the server's tools disappear from the client entirely, so a missing tool
usually means a revoked or mistyped token. `naulon_status` says what is wrong once it connects.

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
| plugin `version` | a deliberate release decision | installed copies only update when it changes, so a change under `plugins/` that is not released with a bump never reaches anyone. CI refuses that |
| tool list implied by the descriptions | what `buildServer()` registers in `@naulon/wayfarer-mcp` | a renamed tool makes the listing lie |
| `skills/ask`, `research`, `discover`, `fact-check` | the hosted server's tool names and the `naulon_survey` → `naulon_ask` quote contract | a renamed tool or argument makes the skill call something that does not exist |
| `skills/verify-citation-license` | the JWKS path, the `naulon` claim shape, and the `/licenses/:jti` scoping rule | a claim rename makes the instructions wrong, silently |
| `privacyPolicyURL`, `termsOfServiceURL`, `websiteURL` | live pages on naulon.app | a 404 fails plugin review |
| `brandColor`, `logo`, `composerIcon` | the portal brand kit | drifts from the product's look |

The rule that governs this repo, and the test that enforces the first three rows, live in the
private source of the hosted service.

## Verification, without trusting us

Every paid read returns a Citation License: an RFC 7519 JWT signed EdDSA/Ed25519. Verify it
with stock `jose` or `pyjwt` against
[`/.well-known/naulon-jwks.json`](https://gate.naulon.app/.well-known/naulon-jwks.json), with no
naulon API call and no account. The bundled `verify-citation-license` skill walks it, including
the part people get wrong: `exp` is the re-read window, not the validity of the record.

## Custody

Payment settles from the buyer's own wallet straight to the author. naulon never holds funds.

## Licence

MIT. See [LICENSE](./LICENSE).
