# naulon research listing

The free, read-only package naulon submits to the Anthropic and OpenAI directories. It finds
sources and judges which answer a question, checks references for retractions, traces where a
passage came from, verifies a Citation License, and shows what a source costs. Nothing in it can
spend.

It connects to `https://gate.naulon.app/_naulon/mcp/public` with no authentication, so a reviewer
needs no account. The paying plugin for Claude Code and Codex is `../plugins/naulon`. Both
directories refuse software that moves money, so the two are separate, and this one is in neither
marketplace in this repo: the two share the name `naulon`.

- **Anthropic** reads this folder: `.claude-plugin/plugin.json`, `.mcp.json`, `skills/`.
- **OpenAI** takes a ZIP. `scripts/package-listing.sh` writes `dist/naulon-listing-<version>.zip`
  without the Claude manifest. The listing text, review cases and release notes live in
  `.codex-plugin/plugin.json`, so the portal fills them in from the upload.

One `.mcp.json` serves both: `type` is read by Claude Code and ignored by Codex, and
`extensions["com.openai"]` the other way round.
