---
name: verify-citation-license
description: Use when someone presents a naulon Citation License (a "LICENSE eyJ…" string or a bare JWT) and you need to establish whether a source was really licensed, who was paid, and how much — or when asked to check, audit, or explain a citation's provenance. Verification is offline against published keys; naulon is never called and cannot vouch for itself.
---

# Verify a Citation License

A Citation License (CLT) is a signed statement that a specific source was paid for: which
resource, how much, which author wallets received it, and the on-chain settlement reference.
It is an ordinary RFC 7519 JWT signed with **EdDSA / Ed25519**, so any standard library
verifies it — `jose` in JavaScript, `pyjwt` or `python-jose` in Python. No naulon API call is
required, and that is the whole point: a claim you have to ask the issuer about is worth less
than one you can check yourself.

## When to use this

- Someone cites a source and claims it was licensed.
- You are auditing a research output for provenance.
- A publisher or author wants to confirm they were actually paid for a citation.
- Someone asks what a `LICENSE eyJ…` string means.

## Two things people get wrong

**1. `exp` is the re-read window, not the validity of the record.** A licence's lifetime is short
by design — it is an unrevocable bearer credential, so a short TTL is the kill switch on the
offline tier. An expired licence still proves the payment happened. It only stops entitling a
fresh fetch of the bytes.

So an out-of-window licence is **"issued at T, re-read window closed"** — never "invalid", and
never "this citation is fake". Say it that way.

**2. Two different objects arrive here, and `naulon.grant` tells them apart.**

| | `grant` absent or `"read"` | `grant: "none"` |
|---|---|---|
| What it is | an **access licence** — the token an agent presents to re-read | a **citation record** |
| `exp` | always present; short | **absent — it never expires** |
| Entitles | a free re-read within the window | nothing at all |

A record carrying no `exp` is correct, not malformed: it is permanent precisely *because* it
grants nothing, so there is nothing to revoke. Never report a missing `exp` on a record as a
defect, and never treat a record as proof that someone may fetch the bytes — it is proof that a
payment happened, which is the question a citation actually raises.

An **absent** `grant` means `"read"` (every licence minted before records existed). Anything
else you do not recognise, treat as granting nothing.

## Steps

### 1. Get the keys

```
GET https://gate.naulon.app/.well-known/naulon-jwks.json
```

Returns a JWKS of `{"kty":"OKP","crv":"Ed25519","alg":"EdDSA","use":"sig","kid":…}` entries.
Match the token header's `kid`.

If the licence was issued by a self-hosted gate, its `iss` claim names that gate
(`naulon:<gate host>`) — fetch the JWKS from that host instead.

### 2. Verify the signature — pin the algorithm

```js
import { createRemoteJWKSet, jwtVerify } from "jose";

const JWKS = createRemoteJWKSet(
  new URL("https://gate.naulon.app/.well-known/naulon-jwks.json"),
);

const { payload } = await jwtVerify(token, JWKS, {
  algorithms: ["EdDSA"],          // REQUIRED — never let the token pick
  clockTolerance: 60,
});
```

**Always pass `algorithms`.** Trusting a token's own `alg` header is the classic JWT
forgery hole, and naulon's own verifier hard-pins Ed25519 for exactly this reason. If you
need to inspect an expired licence rather than reject it, verify with the expiry check
disabled and report the timestamps yourself — do not skip the signature check to do it.

### 3. Read the claims

Registered: `iss`, `aud`, `sub`, `jti`, `iat`, `nbf`, `exp`. The domain payload sits under the
namespaced `naulon` object:

| Field | Meaning |
|---|---|
| `slug`, `title` | the resource that was licensed |
| `kind` | which toll was paid |
| `amount` | **integer micro-USDC as a string** — `"1000"` is $0.001. Never parse as a float. |
| `currency` | always `USDC` |
| `network` | `{chainId, usdc, gateway}` — the chain it settled on |
| `settlementRef` | the on-chain reference |
| `payees` | the author shares, in `full` payees mode — **the wallets that actually received the money** |
| `payeesHash` / `payTo` | `hashed` mode: a digest plus the advertised primary recipient |
| `grant` | `"read"` (or absent) = an access licence · `"none"` = a permanent citation record |
| `scope` | present on a licence covering MANY paths: `{patterns: […]}`, RFC 9309 (`*` crosses segments, trailing `$` anchors). When present it, not `slug`, is what the licence covers. |
| `terms` | the RSL 1.0 usage terms this executes — `ai-input`, `ai-index`, `search` |
| `period` | the purchased period; `until: null` is permanent |

`sub` is the licence's subject — the payer's wallet, or a stable buyer identity when the licence
was issued to an account. It is a provenance claim, not a person: do not treat it as an identity
you can attribute to a human.

`jti` is the settlement event's id. A `cnf` claim with `naulon:addr` means the licence is
holder-of-key bound: re-reading requires a signature from that wallet, so possessing the token
alone is not enough.

### 4. Optional — cross-check against the ledger, and know its limits

**The signature check in step 2 is the authority.** This step is corroboration and it is often
not available. Measured 2026-09-02:

| Request | Result |
|---|---|
| `https://<publisher host>/licenses/<jti>` | `404` when the publisher serves their own site |
| `https://gate.naulon.app/licenses/<jti>` with a publisher `Host` header | `403` — spoofing is blocked at the edge |
| `https://gate.naulon.app/licenses/<jti>` | works, but only for licences issued for hosts that gate routes |
| `https://gate.naulon.app/licenses/<jti>/record` | the permanent citation record for that same settlement, same scoping |

The route is scoped by `Host`, and a publisher running the naulon SDK in front of their own app
is legitimately not in that routing set — so their `/licenses/:jti` is simply not a route on
their origin. That is the common case, not an edge case.

**Therefore: never read a `404` here as evidence of forgery.** It means "this host does not
answer that question", which is a statement about routing, not about the licence. A licence whose
signature verifies against the issuer's published key is proven, full stop.

### 4b. A human can check it too

`https://naulon.app/verify` takes a pasted licence and does exactly what step 2 does — the
signature check against the issuer's published keys — in the visitor's own browser, with naulon
offline. Nothing pasted there is sent anywhere.

Offer it when the person you are answering will need to show someone else. Your report is a
claim they have to take on trust; that page is a check they can run themselves, and so can the
sceptic they are trying to convince.

### 5. Report it honestly

State what you verified and what you did not:

- signature valid against key `<kid>` from `<issuer host>`
- resource, amount (converted from micro-USDC), and the author wallets paid
- issued at `<iat>`; re-read window closed at `<exp>` if past
- whether the ledger cross-check ran, what it said, and — if it 404'd — that this is
  expected for a self-served publisher and is not a negative result

Do not describe a licence as "verified by naulon". It is verified against published keys, by
you. That distinction is the reason the artifact is worth anything.

## What this does not prove

A licence proves a payment was made and settled for a named resource. It does **not** attest
that the content is accurate, that the buyer read it, or that the buyer has any right to
redistribute it. It is a receipt with provenance, not a grant of downstream rights.
