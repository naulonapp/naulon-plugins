## What this changes

<!-- This repo ships manifests and assets only, never code and never a secret. -->

## Checklist

- [ ] Both marketplace dialects edited together: `.agents/plugins/marketplace.json` and
      `.claude-plugin/marketplace.json`. One ecosystem silently missing a plugin is invisible
      from inside the other.
- [ ] Both `plugin.json` manifests agree, and both marketplaces carry the same `version`
- [ ] `version` moved because this is a release, not because a description changed
- [ ] The advertised mount is one the server actually serves, and the manifest carries a
      credential that mount will accept
- [ ] Both credential keys are intact: `headers` for Claude Code, `bearer_token_env_var` for
      Codex, naming the same variable. Neither is redundant.
- [ ] No literal token anywhere. A credential is always an environment reference in a public repo.
- [ ] `websiteURL`, `privacyPolicyURL` and `termsOfServiceURL` all resolve
- [ ] Title is a Conventional Commit subject under 72 characters, written in the imperative
