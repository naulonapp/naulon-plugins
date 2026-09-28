---
name: ask
description: Use when the user wants a question answered from sources whose publishers charge for machine reading, with each claim cited and the author paid. Runs the free naulon survey first, shows what reading would cost, and only then pays through naulon_ask.
argument-hint: "<question>"
---

# Ask across tolled sources

Answer the user's question (`$ARGUMENTS` when run as a command) from naulon's tolled sources. The tools come from the hosted
naulon MCP server this plugin installs; if none of them are available, say the naulon server is not
connected and stop.

1. Call `naulon_status`. If `ready` is false, relay its `nextStep` to the user and stop: a paid read
   cannot go through, and guessing a fix wastes their money.
2. Call `naulon_survey` with the question. It is free. Show the free answer and the priced sources,
   each with its price and value band.
3. If no source matched, say so and offer `naulon_discover` with a broader topic. Do not pay.
4. Otherwise ask the user whether to read, and which sources, unless they already said to go ahead.
5. Call `naulon_ask` with the question, the survey's `quote` and `freeAnswer`, and the chosen
   source `key`s in `sources`. The quote holds the price for 30 minutes, so a stale one means
   surveying again rather than paying a different price.
6. Answer from the text each citation returns, quoting it where it matters. Put each source's
   `proofUrl` beside its citation, report the exact spend, and name any source that could not be
   reached.

A source that costs 0 because a licence is already held was paid for earlier: say it was already
licensed, not that it was free. Never describe a result with `settlementRefKind: "mock"` as a
payment: no money moved.
