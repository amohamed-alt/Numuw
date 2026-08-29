---
name: numuw-supabase-safety
description: Review or modify Numuw Supabase-backed Flutter behavior safely, preserving auth, repository contracts, RLS assumptions, ownership boundaries, and child/family data privacy. Use when production UI migration touches reads, writes, sharing, or auth.
argument-hint: "[feature or data flow]"
user-invocable: true
---

# Numuw Supabase safety

- Read the existing repository/service implementation before changing queries or writes.
- UI migrations must preserve current data contracts unless a schema change is explicitly part of the task.
- Never place service-role/admin credentials in Flutter, assets, source control, logs, or build arguments.
- Keep authorization server-enforced through Supabase RLS; client-side hiding is not authorization.
- Verify parent/child/family ownership and sharing boundaries for every new read/write path.
- Do not broaden queries just to simplify UI code.
- Preserve auth/session recovery and error handling.
- Avoid silently swallowing write failures; show recoverable UI state and keep retry/idempotency in mind for logging features.
- Schema or policy changes require explicit migration files and tests/review of existing data impact.
- Do not expose private notes or caregiver-restricted data in shared/weekly export flows.

After changes, run relevant repository/unit/widget tests and verify logged-out, unauthorized, offline/error, and successful paths.
