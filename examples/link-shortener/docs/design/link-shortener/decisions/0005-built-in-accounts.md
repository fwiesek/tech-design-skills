# 0005. Built-in member accounts with session cookies and API tokens

**Status:** accepted
**Date:** 2026-10-25

## Context

Only team members may create links or read analytics. Visitors never authenticate. The team is small, there's no company identity provider to rely on, and there's one maintainer. Both the browser UI and scripts need access.

## Decision

- Members live in the App's database with argon2id password hashes. They're created and reset only through an App CLI command; there's no sign-up.
- The browser gets an opaque server-side session in a `HttpOnly; Secure; SameSite=Lax` cookie with a 30-day sliding expiry.
- Scripts use per-member API tokens, shown once and stored as SHA-256 hashes, sent as `Authorization: Bearer`.
- Login is rate-limited to 5 failures per 15 min per email and IP.

## Alternatives considered

- **Caddy basic auth in front of /api and /admin**: zero app code, but one shared credential, no per-member attribution, and a poor fit for scripts and logout.
- **OIDC via an external identity provider**: strongest option, but needs a provider the team doesn't run, and adds a dependency for a handful of users.
- **Stateless JWT sessions**: no session table, but revocation is hard and there's no scaling need that would justify it.

## Consequences

- Every link records which member created it; sessions and tokens can be revoked one at a time.
- The App owns password handling, so argon2id parameters and rate limiting must stay correct.
- Adding SSO later means a new ADR that supersedes this one.
