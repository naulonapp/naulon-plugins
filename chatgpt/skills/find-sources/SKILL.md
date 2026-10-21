---
name: find-sources
description: Use when the user wants to know which sources exist on a topic, which would answer a question, or what reading one would cost. Lists priced sources from naulon publishers and pays nothing.
---

# Find priced sources

The tools come from the naulon server this plugin connects to. If none are available, say the
naulon server is not connected and stop. Nothing here can pay: every tool is free and read-only.

- **A topic.** Call `naulon_discover` with it. Present each candidate with its title, site,
  summary, read price and citation price. Use `naulon_appraise` with the same candidates, passed
  back whole, when the user wants them ranked by relevance.
- **A question.** Call `naulon_survey` with it. Show each source with its publisher's summary, its
  fit and value verdict, and its price. If nothing matched, say so and offer a broader topic.
- **The cost of one source.** Call `naulon_discover` first in the same conversation, then
  `naulon_quote` with that candidate's `slug` and `url`. Report the author's price and the buyer's
  total, which is higher when the publisher adds a fee.

Prices are in USDC. The user never pays through this plugin. If they want to read a source, tell
them buying happens on naulon.app with an agent token, and do not claim anything was bought.
