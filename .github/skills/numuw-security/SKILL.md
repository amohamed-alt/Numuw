---
name: numuw-security
description: Review Numuw Flutter, Supabase, auth, storage, sharing, exports, notifications, and repository changes for mobile security and child/family data privacy risks.
argument-hint: "[feature, diff, or flow]"
user-invocable: true
---

# Numuw security review

Review the target change for:

- Secrets/API keys accidentally committed, logged, embedded in assets, or exposed as build arguments.
- Supabase service-role/admin credentials in the client: never allowed.
- RLS/authorization assumptions: UI visibility is not access control.
- Incorrect parent/child/family ownership boundaries or over-broad sharing queries.
- Private mother notes, medical documents, child records, or caregiver-restricted content leaking into Family Sharing or Weekly Share.
- Unsafe storage paths/public buckets or predictable object access without authorization.
- Auth/session recovery, logout, account switching, and stale cached user data.
- Sensitive content in logs, crash messages, notifications, clipboard, or screenshots where avoidable.
- Input validation and unsafe dynamic values crossing repository/API boundaries.
- External links/deep links and auth callbacks with insufficient validation.

Do not weaken an existing policy or permission merely to make a client request succeed. Security-sensitive schema or RLS changes require explicit migration/review.
