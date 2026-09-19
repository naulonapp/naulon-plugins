# scripts

`prose-voice.mjs` is the writing checker the git hooks call. It is byte-identical to the copy in
the `naulon` repository, so a fix in one is a fix in both. `.githooks/commit-msg` checks a commit
message against it and `.githooks/pre-commit` checks any staged Markdown.

A fresh clone has no hooks until `core.hooksPath` points at the tracked directory:

```bash
git config core.hooksPath .githooks
```
