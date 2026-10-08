---
name: fact-check
description: Use when the user wants a claim checked against naulon-tolled sources, with a verdict and the licence behind every source used.
argument-hint: "<claim>"
---

# Fact-check a claim against tolled sources

Check the claim the user gave (`$ARGUMENTS` when run as a command). The tools come from the hosted naulon MCP server this plugin
installs; if none are available, say the naulon server is not connected and stop.

1. Call `naulon_status`. If `ready` is false, relay its `nextStep` and stop.
2. Find relevant sources with `naulon_discover`, then use `naulon_appraise` and `naulon_quote`
   (both free) to see relevance and price.
3. Only if the verdict needs it, pay the most relevant sources with `naulon_pay_and_read`.
4. State SUPPORTED, REFUTED or UNVERIFIABLE. Cite each paid source by title with its `proofUrl`,
   report the spend, and keep the sources' evidence separate from your own general knowledge.
   Quote the passage that decides the verdict word for word, and link it as `proofUrl` followed by
   `#quote=` and that passage, percent-encoded, so the reader can confirm it is in the source.

To check a licence someone else presents, use the `verify-citation-license` skill instead.
