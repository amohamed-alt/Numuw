create table if not exists public.notification_preferences (
  user_id uuid primary key references auth.users(id) on delete cascade,
  push_enabled boolean not null default false,
  care_reminders boolean not null default true,
  vaccination_reminders boolean not null default true,
  medication_reminders boolean not null default true,
  quiet_hours_start time,
  quiet_hours_end time,
  timezone text,
  locale text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint notification_preferences_quiet_hours_pair check (
    (quiet_hours_start is null and quiet_hours_end is null)
    or (quiet_hours_start is not null and quiet_hours_end is not null)
  )
);

alter table public.notification_preferences enable row level security;

create policy notification_preferences_select_own
on public.notification_preferences
for select
to authenticated
using (user_id = (select auth.uid()));

create policy notification_preferences_insert_own
on public.notification_preferences
for insert
to authenticated
with check (user_id = (select auth.uid()));

create policy notification_preferences_update_own
on public.notification_preferences
for update
to authenticated
using (user_id = (select auth.uid()))
with check (user_id = (select auth.uid()));

create policy notification_preferences_delete_own
on public.notification_preferences
for delete
to authenticated
using (user_id = (select auth.uid()));

create or replace function public.set_notification_preferences_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

revoke all on function public.set_notification_preferences_updated_at() from public;
revoke all on function public.set_notification_preferences_updated_at() from anon;
revoke all on function public.set_notification_preferences_updated_at() from authenticated;

drop trigger if exists set_notification_preferences_updated_at on public.notification_preferences;
create trigger set_notification_preferences_updated_at
before update on public.notification_preferences
for each row execute function public.set_notification_preferences_updated_at();
