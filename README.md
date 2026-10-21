# naulon plugins

The naulon plugin for Claude Code and Codex, from one repo.

naulon lets an agent find sources whose publishers charge for machine reading, see the price
before committing, pay the author directly, and come away with a **Citation License** that
anyone can verify against published keys without calling naulon. Discovery and quotes are free.
Humans always read free; only agents are tolled.

## Install

Mint an agent token at [naulon.app/buyer/agents](https://naulon.app/buyer/agents). Every tool needs
it, free ones included: the token is how the server knows who is asking, and it carries the spending
cap you set.

**Claude Code**

```
/plugin marketplace add naulonapp/naulon-plugins
/plugin install naulon@naulon
```

Claude Code asks for the token when you enable the plugin and keeps it in your system's secure
credential store. To set or change it later, run `/plugin configure naulon@naulon`. From a script:

```bash
claude plugin install naulon@naulon --config NAULON_AGENT_TOKEN=nln_agent_…
```

**Codex CLI.** Codex reads the token from your environment, so add this line to `~/.zshrc` or
`~/.bashrc` first:

```bash
export NAULON_AGENT_TOKEN=nln_agent_…
codex plugin marketplace add naulonapp/naulon-plugins
```

Then run `codex`, type `/plugins`, install `naulon`, and start a new session. The Codex IDE
extension does not support plugins.

**ChatGPT.** A workspace admin can import this repository as a GitHub marketplace for their team.
naulon is not in the public Plugins Directory yet, so an individual account cannot install it.

### If the tools do not appear

- **Codex fails silently without the token.** The server does not start, and nothing says so at
  the default log level. The log line is
  `MCP startup failed: Environment variable NAULON_AGENT_TOKEN for MCP server 'naulon' is not set`.
- **Claude Code without a token** does not start the server, so no naulon tool appears.
  `/plugin configure naulon@naulon` sets it.
- **A rejected token removes every tool**, so a missing tool usually means a revoked or mistyped
  token. Once connected, `naulon_status` says what is wrong.
- **Already connected by hand?** Claude Code de-duplicates MCP servers by URL, whatever they are
  named. A server you added with `claude mcp add` at `https://gate.naulon.app/_naulon/mcp` wins, and
  this plugin's copy is silently dropped. It works the same either way. To let the plugin own it:

  ```bash
  claude mcp remove naulon -s local; claude mcp remove naulon -s user
  ```

## Updating

An installed copy only changes when the plugin's `version` does, and neither client updates a
third-party marketplace on its own.

**Updating Claude Code to 0.1.8 or later from an earlier version:** the plugin now takes the token
from its own setting instead of `NAULON_AGENT_TOKEN`, so run `/plugin configure naulon@naulon` once
after updating. Codex still reads the environment variable.

```bash
# Claude Code (or turn on auto-update for this marketplace under /plugin, Marketplaces tab)
claude plugin marketplace update naulon
claude plugin update naulon@naulon

# Codex
codex plugin marketplace upgrade naulon
```

## Commands

In Claude Code each skill is also a command. Codex picks a skill up when your request matches it.

| Command | Does | Pays |
|---|---|---|
| `/naulon:ask <question>` | prices every matching source, then answers from the ones you pick, cited | after you confirm |
| `/naulon:research <topic>` | discovers, appraises and quotes, then pays only the sources worth it | yes |
| `/naulon:discover <topic>` | lists sources and their prices | no |
| `/naulon:fact-check <claim>` | a verdict, with the licence and the deciding quote for each source | only if needed |
| `/naulon:check-citations <references>` | whether each reference exists, and whether it was retracted or corrected | no |
| `/naulon:verify-citation-license` | checks a Citation License offline, against published keys | no |

## Tools

The hosted server at `https://gate.naulon.app/_naulon/mcp`:

| Tool | Does | Pays |
|---|---|---|
| `naulon_status` | whether you are ready to pay, and the next step when you are not | no |
| `naulon_discover` | candidate sources for a topic, with teaser and citation prices | no |
| `naulon_appraise` | how relevant each candidate is, from its teaser | no |
| `naulon_quote` | the exact price and terms for one source | no |
| `naulon_survey` | every source matching a question, priced, with a signed quote | no |
| `naulon_ask` | buys the sources you chose from a survey and answers from them | yes |
| `naulon_pay_and_read` | pays for one source and returns its text and licence | yes |
| `naulon_read_held` | re-reads a source you already hold a licence for | no |
| `naulon_research` | runs discover, appraise and pay in one call, within a budget | yes |
| `naulon_check_citations` | existence and retraction status for up to 25 references | no |
| `naulon_retrieve` | an answer from CC0 and CC BY papers, every quote proven (test USDC for now) | yes |

## Verifying a licence without trusting us

Every paid read returns a Citation License: an RFC 7519 JWT signed EdDSA/Ed25519. Verify it with
stock `jose` or `pyjwt` against
[`/.well-known/naulon-jwks.json`](https://gate.naulon.app/.well-known/naulon-jwks.json), with no
naulon API call and no account. The `verify-citation-license` skill walks through it, including
the part people get wrong: `exp` is the re-read window, not the validity of the record.

## Custody

Payment settles from your own wallet straight to the author. naulon never holds funds.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## Licence

MIT. See [LICENSE](./LICENSE).
