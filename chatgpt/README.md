# naulon for ChatGPT

The package naulon submits to the ChatGPT Plugins Directory. It is the free, read-only side of
naulon: find priced sources, judge which answer a question, quote one source's live price, check
references for retractions, and preview an answer from open-access papers. Nothing in it can spend.

It connects to `https://gate.naulon.app/_naulon/mcp/public` with no authentication. The paying
plugin for Claude Code and Codex is in `../plugins/naulon`; OpenAI's directory does not accept tools
that move money, so the two are separate.

Build the upload with `scripts/package-chatgpt.sh`, which writes `dist/naulon-chatgpt-<version>.zip`.
The listing text, review cases and release notes live in `.codex-plugin/plugin.json`, so the portal
fills them in from the upload. Reviewer access needs nothing: the server has no sign-in.
