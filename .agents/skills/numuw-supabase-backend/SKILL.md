---
name: numuw-supabase-backend
description: Supabase production rules for Numuw. Use for schema, migrations, RLS, auth, storage, Edge Functions, family sharing, and database performance.
metadata:
  project: Numuw
  upstream:
    - supabase/agent-skills
---
# Numuw Supabase Backend

## Safety contract
- Never expose service-role, database passwords, provider keys, signing keys, or private secrets to Flutter or GitHub source.
- Flutter may use only the Supabase project URL and publishable key.
- User-facing data tables must have RLS enabled and policies based on ownership/membership, not merely `TO authenticated`.
- Privileged provider credentials belong in Edge Function secrets.

## Schema and migrations
- Treat `supabase/migrations/` as the canonical source-controlled history for production schema changes.
- Use additive, idempotent, reversible-safe migrations where possible.
- Avoid destructive changes without explicit data migration and rollback thinking.
- Add indexes for foreign keys and query predicates that matter.
- Do not remove an index only because it appears unused in an empty/young database.

## Numuw authorization model
- `profiles`: user owns profile.
- `children`: creator/guardian membership determines visibility; edit/delete privileges are stricter than read.
- Child-linked tables inherit access from child membership.
- Family invites must validate session, invite status/expiry, and intended recipient constraints before membership mutation.
- Storage paths must be authorized by child membership/edit rights.

## Edge Functions
- Validate method, body size, UUIDs, enum values, and text lengths.
- Resolve the caller from the Authorization bearer token; do not trust a client-supplied user id.
- Use caller auth context/RLS for child and event reads when appropriate.
- Apply rate limits to AI endpoints.
- Emergency keyword handling must remain fast and independent of model availability.
- Log usage success/failure without logging sensitive content unnecessarily.

## Auth
- Email confirmation and session expiry must have safe UI states.
- Account deletion must be a verified server-side operation; never delete an auth user directly from an untrusted client.
- Enable leaked-password protection in Supabase Auth before production release.

## Storage
- Keep child documents private.
- Restrict MIME types and file sizes.
- Never infer authorization only from a filename; policy must resolve child access.

## Performance checklist
- Foreign-key indexes.
- Avoid N+1 client query loops when a single relational/RPC query is practical.
- Prefer bounded result sets for timelines/events.
- Keep JSONB only where flexible metadata is justified; index queried JSONB fields.
- Re-run Supabase security and performance advisors after schema/RLS changes.

## Upstream guidance incorporated
Curated from `supabase/agent-skills`, especially `supabase-postgres-best-practices`, and adapted to Numuw's current child membership, health-data, Edge Function, and storage model.