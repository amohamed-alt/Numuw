create table if not exists public.push_devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  platform text not null check (platform in ('android','ios','web')),
  token text not null check (char_length(token) between 20 and 4096),
  timezone text,
  locale text,
  app_version text,
  enabled boolean not null default true,
  last_seen_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, token)
);

alter table public.push_devices enable row level security;

create policy push_devices_select_own
on public.push_devices
for select
to authenticated
using (user_id = (select auth.uid()));

create policy push_devices_insert_own
on public.push_devices
for insert
to authenticated
with check (user_id = (select auth.uid()));

create policy push_devices_update_own
on public.push_devices
for update
to authenticated
using (user_id = (select auth.uid()))
with check (user_id = (select auth.uid()));

create policy push_devices_delete_own
on public.push_devices
for delete
to authenticated
using (user_id = (select auth.uid()));

create index if not exists push_devices_user_enabled_idx
  on public.push_devices (user_id, enabled)
  where enabled = true;

create index if not exists push_devices_last_seen_idx
  on public.push_devices (last_seen_at desc);

create or replace function public.set_push_devices_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

revoke all on function public.set_push_devices_updated_at() from public;
revoke all on function public.set_push_devices_updated_at() from anon;
revoke all on function public.set_push_devices_updated_at() from authenticated;

drop trigger if exists set_push_devices_updated_at on public.push_devices;
create trigger set_push_devices_updated_at
before update on public.push_devices
for each row execute function public.set_push_devices_updated_at();
