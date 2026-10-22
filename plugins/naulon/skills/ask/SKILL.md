---
name: ask
description: Use when the user wants a question answered from sources whose publishers charge for machine reading, with each claim cited and the author paid. Runs the free naulon search first, shows what reading would cost, and only then pays through naulon_read.
argument-hint: "<question>"
---

# Ask across tolled sources

Answer the user's question (`$ARGUMENTS` when run as a command) from naulon's tolled sources. The tools come from the hosted
naulon MCP server this plugin installs; if none of them are available, say the naulon server is not
connected and stop.

1. Call `naulon_status` and keep its `ready` and `nextStep`. The survey below is free and runs
   either way.
2. Call `naulon_search` with the question. It is free. Show the priced sources, each with its
   publisher's summary, its fit, its price and its value band.
3. If no source matched, say so and offer `naulon_discover` with a broader topic. Do not pay.
4. If `ready` was false, show the survey, relay `nextStep`, and stop: a paid read cannot go through,
   and guessing a fix wastes their money. Otherwise ask the user whether to read, and which sources,
   unless they already said to go ahead.
5. Call `naulon_read` with the question, the search's `quote`, and the chosen source `key`s in
   `sources`. The quote holds the price for 30 minutes, so a stale one means
   searching again rather than paying a different price. Use `naulon_answer` instead only when the
   user wants naulon's own cited answer; where it is priced, the search shows the fee as
   `writeFeeUsdc`, and `tier: "extractive"` is the cheaper quoted-passages answer at `extractFeeUsdc`.
6. Answer from the text each citation returns, quoting it where it matters. Put each source's
   `proofUrl` beside its citation, report the exact spend, and name any source that could not be
   reached.

A source that costs 0 because a licence is already held was paid for earlier: say it was already
licensed, not that it was free. A `settlementRef` that starts with `mock-` is test data: no money
moved, so never call it a payment.
