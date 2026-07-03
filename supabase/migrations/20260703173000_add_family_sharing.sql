-- Numuw family sharing.
-- Adds child_guardians and family_invites, then widens child-linked RLS from
-- single owner (children.created_by) to explicit guardianship.

create extension if not exists pgcrypto;

create table if not exists public.child_guardians (
  child_id uuid not null references public.children(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'guardian' check (role in ('owner', 'guardian')),
  created_at timestamptz not null default now(),
  primary key (child_id, user_id)
);

create table if not exists public.family_invites (
  id uuid primary key default gen_random_uuid(),
  child_id uuid not null references public.children(id) on delete cascade,
  created_by uuid not null references auth.users(id) on delete cascade,
  invite_code text not null unique default upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8)),
  invited_email text,
  role text not null default 'guardian' check (role in ('guardian')),
  status text not null default 'pending' check (status in ('pending', 'accepted', 'revoked', 'expired')),
  accepted_by uuid references auth.users(id),
  accepted_at timestamptz,
  expires_at timestamptz not null default (now() + interval '14 days'),
  created_at timestamptz not null default now()
);

create index if not exists child_guardians_user_id_idx on public.child_guardians(user_id);
create index if not exists family_invites_child_id_idx on public.family_invites(child_id);
create index if not exists family_invites_invite_code_idx on public.family_invites(invite_code);

alter table public.child_guardians enable row level security;
alter table public.family_invites enable row level security;

insert into public.child_guardians (child_id, user_id, role)
select id, created_by, 'owner'
from public.children
where created_by is not null
on conflict (child_id, user_id) do nothing;

create or replace function public.is_child_guardian(p_child_id uuid, p_user_id uuid default auth.uid())
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.child_guardians cg
    where cg.child_id = p_child_id and cg.user_id = p_user_id
  );
$$;

revoke all on function public.is_child_guardian(uuid, uuid) from public;
grant execute on function public.is_child_guardian(uuid, uuid) to authenticated;

create or replace function public.ensure_child_owner_guardian()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.child_guardians (child_id, user_id, role)
  values (new.id, new.created_by, 'owner')
  on conflict (child_id, user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists ensure_child_owner_guardian_trigger on public.children;
create trigger ensure_child_owner_guardian_trigger
after insert on public.children
for each row execute function public.ensure_child_owner_guardian();

create or replace function public.accept_family_invite(invite_code text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_invite public.family_invites%rowtype;
  v_email text := lower(coalesce(auth.jwt() ->> 'email', ''));
begin
  if auth.uid() is null then
    raise exception 'missing session';
  end if;

  select * into v_invite
  from public.family_invites
  where family_invites.invite_code = upper(trim(accept_family_invite.invite_code))
    and status = 'pending'
    and expires_at > now()
  for update;

  if not found then
    raise exception 'invalid or expired invite';
  end if;

  if v_invite.invited_email is not null and lower(v_invite.invited_email) <> v_email then
    raise exception 'invite email does not match current user';
  end if;

  insert into public.child_guardians (child_id, user_id, role)
  values (v_invite.child_id, auth.uid(), v_invite.role)
  on conflict (child_id, user_id) do update set role = excluded.role;

  update public.family_invites
  set status = 'accepted', accepted_by = auth.uid(), accepted_at = now()
  where id = v_invite.id;
end;
$$;

revoke all on function public.accept_family_invite(text) from public;
grant execute on function public.accept_family_invite(text) to authenticated;

-- Guardian policies.
drop policy if exists "child_guardians_select_same_child" on public.child_guardians;
create policy "child_guardians_select_same_child"
on public.child_guardians for select
to authenticated
using (public.is_child_guardian(child_id));

drop policy if exists "child_guardians_owner_insert" on public.child_guardians;
create policy "child_guardians_owner_insert"
on public.child_guardians for insert
to authenticated
with check (
  exists (
    select 1 from public.child_guardians owner_row
    where owner_row.child_id = child_id
      and owner_row.user_id = auth.uid()
      and owner_row.role = 'owner'
  )
);

drop policy if exists "family_invites_select_child_guardian" on public.family_invites;
create policy "family_invites_select_child_guardian"
on public.family_invites for select
to authenticated
using (public.is_child_guardian(child_id));

drop policy if exists "family_invites_insert_owner" on public.family_invites;
create policy "family_invites_insert_owner"
on public.family_invites for insert
to authenticated
with check (
  created_by = auth.uid()
  and exists (
    select 1 from public.child_guardians owner_row
    where owner_row.child_id = child_id
      and owner_row.user_id = auth.uid()
      and owner_row.role = 'owner'
  )
);

drop policy if exists "family_invites_update_owner" on public.family_invites;
create policy "family_invites_update_owner"
on public.family_invites for update
to authenticated
using (
  exists (
    select 1 from public.child_guardians owner_row
    where owner_row.child_id = child_id
      and owner_row.user_id = auth.uid()
      and owner_row.role = 'owner'
  )
)
with check (
  exists (
    select 1 from public.child_guardians owner_row
    where owner_row.child_id = child_id
      and owner_row.user_id = auth.uid()
      and owner_row.role = 'owner'
  )
);

-- Replace core table policies with guardian-aware access.
drop policy if exists "children_select_own" on public.children;
drop policy if exists "children_update_own" on public.children;
drop policy if exists "children_delete_own" on public.children;
create policy "children_select_guardian" on public.children for select to authenticated using (public.is_child_guardian(id));
create policy "children_update_guardian" on public.children for update to authenticated using (public.is_child_guardian(id)) with check (public.is_child_guardian(id));
create policy "children_delete_owner" on public.children for delete to authenticated using (exists (select 1 from public.child_guardians cg where cg.child_id = id and cg.user_id = auth.uid() and cg.role = 'owner'));

-- Keep children_insert_own from the base migration: new children must still be created by the signed-in user.

-- Child-linked policies are recreated as guardian-aware for every data table.
drop policy if exists "care_events_select_own_child" on public.care_events;
drop policy if exists "care_events_insert_own_child" on public.care_events;
drop policy if exists "care_events_update_own_child" on public.care_events;
drop policy if exists "care_events_delete_own_child" on public.care_events;
create policy "care_events_select_guardian" on public.care_events for select to authenticated using (public.is_child_guardian(child_id));
create policy "care_events_insert_guardian" on public.care_events for insert to authenticated with check (created_by = auth.uid() and public.is_child_guardian(child_id));
create policy "care_events_update_guardian" on public.care_events for update to authenticated using (public.is_child_guardian(child_id)) with check (public.is_child_guardian(child_id));
create policy "care_events_delete_guardian" on public.care_events for delete to authenticated using (public.is_child_guardian(child_id));

drop policy if exists "growth_measurements_select_own_child" on public.growth_measurements;
drop policy if exists "growth_measurements_insert_own_child" on public.growth_measurements;
drop policy if exists "growth_measurements_update_own_child" on public.growth_measurements;
drop policy if exists "growth_measurements_delete_own_child" on public.growth_measurements;
create policy "growth_measurements_select_guardian" on public.growth_measurements for select to authenticated using (public.is_child_guardian(child_id));
create policy "growth_measurements_insert_guardian" on public.growth_measurements for insert to authenticated with check (created_by = auth.uid() and public.is_child_guardian(child_id));
create policy "growth_measurements_update_guardian" on public.growth_measurements for update to authenticated using (public.is_child_guardian(child_id)) with check (public.is_child_guardian(child_id));
create policy "growth_measurements_delete_guardian" on public.growth_measurements for delete to authenticated using (public.is_child_guardian(child_id));

drop policy if exists "vaccinations_select_own_child" on public.vaccinations;
drop policy if exists "vaccinations_insert_own_child" on public.vaccinations;
drop policy if exists "vaccinations_update_own_child" on public.vaccinations;
drop policy if exists "vaccinations_delete_own_child" on public.vaccinations;
create policy "vaccinations_select_guardian" on public.vaccinations for select to authenticated using (public.is_child_guardian(child_id));
create policy "vaccinations_insert_guardian" on public.vaccinations for insert to authenticated with check (created_by = auth.uid() and public.is_child_guardian(child_id));
create policy "vaccinations_update_guardian" on public.vaccinations for update to authenticated using (public.is_child_guardian(child_id)) with check (public.is_child_guardian(child_id));
create policy "vaccinations_delete_guardian" on public.vaccinations for delete to authenticated using (public.is_child_guardian(child_id));

drop policy if exists "family_tasks_select_own_child" on public.family_tasks;
drop policy if exists "family_tasks_insert_own_child" on public.family_tasks;
drop policy if exists "family_tasks_update_own_child" on public.family_tasks;
drop policy if exists "family_tasks_delete_own_child" on public.family_tasks;
create policy "family_tasks_select_guardian" on public.family_tasks for select to authenticated using (public.is_child_guardian(child_id));
create policy "family_tasks_insert_guardian" on public.family_tasks for insert to authenticated with check (created_by = auth.uid() and public.is_child_guardian(child_id));
create policy "family_tasks_update_guardian" on public.family_tasks for update to authenticated using (public.is_child_guardian(child_id)) with check (public.is_child_guardian(child_id));
create policy "family_tasks_delete_guardian" on public.family_tasks for delete to authenticated using (public.is_child_guardian(child_id));

drop policy if exists "doctor_questions_select_own_child" on public.doctor_questions;
drop policy if exists "doctor_questions_insert_own_child" on public.doctor_questions;
drop policy if exists "doctor_questions_update_own_child" on public.doctor_questions;
drop policy if exists "doctor_questions_delete_own_child" on public.doctor_questions;
create policy "doctor_questions_select_guardian" on public.doctor_questions for select to authenticated using (public.is_child_guardian(child_id));
create policy "doctor_questions_insert_guardian" on public.doctor_questions for insert to authenticated with check (created_by = auth.uid() and public.is_child_guardian(child_id));
create policy "doctor_questions_update_guardian" on public.doctor_questions for update to authenticated using (public.is_child_guardian(child_id)) with check (public.is_child_guardian(child_id));
create policy "doctor_questions_delete_guardian" on public.doctor_questions for delete to authenticated using (public.is_child_guardian(child_id));
