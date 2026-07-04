create extension if not exists pgcrypto;

create table if not exists public.ai_usage_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  mode text not null check (mode in ('daily_summary', 'doctor_summary', 'parse_care_event')),
  request_chars integer not null default 0,
  succeeded boolean,
  created_at timestamptz not null default now()
);

alter table public.ai_usage_events enable row level security;

drop policy if exists "ai_usage_events_select_own" on public.ai_usage_events;
create policy "ai_usage_events_select_own"
on public.ai_usage_events for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "ai_usage_events_insert_own" on public.ai_usage_events;
create policy "ai_usage_events_insert_own"
on public.ai_usage_events for insert
to authenticated
with check (user_id = auth.uid());
