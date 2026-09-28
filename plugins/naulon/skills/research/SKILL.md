---
name: research
description: Use when the user wants a topic researched from naulon's tolled sources within a budget, choosing which sources are worth paying for before reading them.
argument-hint: "<topic>"
---

# Research a topic from tolled sources

Research the topic the user gave (`$ARGUMENTS` when run as a command). The tools come from the hosted naulon MCP server this plugin installs; if
none are available, say the naulon server is not connected and stop.

1. Call `naulon_status`. If `ready` is false, relay its `nextStep` and stop.
2. Call `naulon_discover` with the topic. It is free and lists candidates with teaser prices.
3. Use `naulon_appraise` and `naulon_quote`, both free, to judge relevance and see exact prices.
4. Pay only the sources worth it with `naulon_pay_and_read`, or call `naulon_research` to run the
   whole loop within the session budget. `naulon_pay_and_read` serves a licence you already hold
   for free, so re-reading a source never pays twice.
5. Return a grounded answer with numbered citations, each with its `proofUrl`, and the exact
   spend. Keep what the sources say separate from your own general knowledge.

If a re-read fails with `refused_by_publisher`, the licence was valid and the publisher rejected
it. Report that; paying again can charge twice without fixing anything.
