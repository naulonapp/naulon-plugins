---
name: discover
description: Use when the user wants to see which naulon-tolled sources exist for a topic and what they cost, without paying for anything.
argument-hint: "<topic>"
---

# Discover tolled sources

List what naulon holds on the topic the user gave (`$ARGUMENTS` when run as a command). This spends nothing.

Call `naulon_discover` with the topic and present the candidates as a ranked list: title, one-line
summary, site, teaser price and citation price. If the naulon tools are not available, say the
naulon server is not connected.

Do not call any tool that pays. If the user wants a grounded answer next, point them at the `ask`
or `research` skill.
