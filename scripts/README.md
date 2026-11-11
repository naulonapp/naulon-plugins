# scripts

`prose-voice.mjs` is the writing checker the git hooks call. It is byte-identical to the copy in
the `naulon` repository, so a fix in one is a fix in both. `.githooks/commit-msg` checks a commit
message against it and `.githooks/pre-commit` checks any staged Markdown.

A fresh clone has no hooks until `core.hooksPath` points at the tracked directory:

```bash
git config core.hooksPath .githooks
```
`check-version-bump.sh` is what CI runs on a pull request touching `plugins/`: a change there without a version bump in both manifests never reaches an installed copy, so it fails.

`check-registry.sh` is what CI runs on a pull request touching `server.json`: it holds the listing to
the mount `listing/.mcp.json` connects, to the npm release it names, and to a new version for every
change, because the registry never lets a published version be edited.
