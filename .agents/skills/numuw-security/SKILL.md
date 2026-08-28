---
name: numuw-security
description: Security review rules for Numuw Flutter, Supabase, storage, Edge Functions, GitHub Actions, and third-party skills/dependencies.
metadata:
  project: Numuw
  upstream:
    - trailofbits/skills
    - getsentry/skills
---
# Numuw Security Review

## Threat model priorities
Numuw handles family/child information and health-related records. Protect confidentiality, authorization boundaries, account recovery/deletion, uploaded files, AI endpoints, and CI/release credentials.

## Insecure defaults to reject
- No public child-document bucket.
- No service-role or provider key in client code, repository, build args, logs, or screenshots.
- No RLS policy that grants broad access simply because a user is authenticated.
- No trusting client-provided user IDs, child summaries, guardian role, or privileged status.
- No silent fallback from authorization failure to permissive behavior.
- No debug signing for production Android artifacts.

## Static/differential review
For security-sensitive diffs, inspect exactly what changed in auth, RLS, storage paths, Edge Functions, permissions, workflows, and secrets. Compare old/new behavior and test negative authorization cases.

## Sharp edges
Treat these as high risk: null assertions at auth boundaries, client-side role checks, unbounded uploads, arbitrary file types, open redirects/deep links, broad CORS, long-lived tokens in insecure storage, dependency scripts, and workflow permissions broader than required.

## Property and negative testing
Test invariants such as:
- User A cannot read/update child B.
- Viewer cannot mutate editor-only resources.
- Expired/used invite cannot create membership.
- AI endpoint rejects invalid/unauthorized child ID.
- Storage object path cannot bypass child membership.
- Logged-out client cannot perform authenticated operations.

## GitHub Actions
- Use least-privilege `permissions`.
- Pin or review third-party actions before adding them.
- Never echo secrets.
- Keep Pages/release workflows separated from privileged signing workflows.
- Do not run untrusted PR code with write tokens or production secrets.

## Third-party agent skills
Before adopting an external skill, inspect its instructions/scripts for destructive commands, secret exfiltration, remote execution, hidden tool calls, or attempts to override repository safety rules. Prefer local curated skills over executing arbitrary external scripts.

## Upstream guidance incorporated
Adapted from Trail of Bits skills such as `insecure-defaults`, `static-analysis`, `differential-review`, `sharp-edges`, and `property-based-testing`, plus Sentry security and GitHub Actions review guidance.