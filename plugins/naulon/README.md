# naulon

Find sources whose publishers charge AI agents to read them, see each price before anything is
spent, pay the author directly in USDC, and cite what you read with a Citation License that anyone
can verify offline against published keys. People always read these sources free; only agents pay.

## Setup

Mint an agent token at [naulon.app/buyer/agents](https://naulon.app/buyer/agents). Claude Code asks
for it when you enable the plugin and keeps it in your system's secure credential store. The token
carries a spending cap you set, and you can revoke it there at any time.

## Commands

| Command | Does | Pays |
|---|---|---|
| `/naulon:ask <question>` | prices every matching source, then answers from the ones you pick, cited | after you confirm |
| `/naulon:research <topic>` | finds, appraises and quotes sources, then pays only those worth it | yes |
| `/naulon:discover <topic>` | lists sources and their prices | no |
| `/naulon:fact-check <claim>` | a verdict, with the licence and the deciding quote for each source | only if needed |
| `/naulon:check-citations <references>` | whether each reference exists, and whether it was retracted or corrected | no |
| `/naulon:verify-citation-license` | checks a Citation License offline | no |

Every paying command stops before payment when your wallet is not ready, and reports what the free
steps found.

## What it connects to and sends

The plugin runs no code on your machine. It connects to one remote MCP server,
`https://gate.naulon.app/_naulon/mcp`, and sends your agent token as `Authorization: Bearer`.

- **Free tools** send your topic, question, claim or reference list, and return public summaries,
  prices and citation records.
- **Paying tools** send the sources you chose. naulon pays each author from your own naulon wallet
  and returns the text you bought with its Citation License. naulon never holds your funds.
- `verify-citation-license` sends no licence anywhere. It fetches only the public keys of the gate
  that issued the licence, `https://gate.naulon.app/.well-known/naulon-jwks.json` for the hosted
  service, and checks the licence locally.

How naulon handles that data: [naulon.app/privacy](https://naulon.app/privacy). Terms:
[naulon.app/terms](https://naulon.app/terms).

## Support

Open an issue at [github.com/naulonapp/naulon-plugins](https://github.com/naulonapp/naulon-plugins/issues).
