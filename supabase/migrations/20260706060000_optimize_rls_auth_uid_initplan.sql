-- Mirrors the applied production migration optimize_rls_auth_uid_initplan.
-- Keeps the same authorization behavior while using the Supabase-recommended
-- (select auth.uid()) form to avoid per-row auth function evaluation.

create or replace function public.is_child_member(p_child_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1
    from public.child_members cm
    where cm.child_id = p_child_id
      and cm.user_id = (select auth.uid())
  );
$$;

create or replace function public.can_edit_child(p_child_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public, pg_temp
as $$
  select exists (
    select 1
    from public.child_members cm
    where cm.child_id = p_child_id
      and cm.user_id = (select auth.uid())
      and (cm.can_edit or cm.role in ('owner', 'parent'))
  );
$$;

drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles
  for select to authenticated
  using (id = (select auth.uid()));

drop policy if exists profiles_insert_own on public.profiles;
create policy profiles_insert_own on public.profiles
  for insert to authenticated
  with check (id = (select auth.uid()));

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

drop policy if exists children_insert_creator on public.children;
create policy children_insert_creator on public.children
  for insert to authenticated
  with check (created_by = (select auth.uid()));

drop policy if exists children_select_members on public.children;
create policy children_select_members on public.children
  for select to authenticated
  using ((created_by = (select auth.uid())) or public.is_child_member(id));

drop policy if exists care_events_insert_editors on public.care_events;
create policy care_events_insert_editors on public.care_events
  for insert to authenticated
  with check ((created_by = (select auth.uid())) and public.can_edit_child(child_id));

drop policy if exists growth_insert_editors on public.growth_measurements;
create policy growth_insert_editors on public.growth_measurements
  for insert to authenticated
  with check ((created_by = (select auth.uid())) and public.can_edit_child(child_id));

drop policy if exists vaccinations_insert_editors on public.vaccinations;
create policy vaccinations_insert_editors on public.vaccinations
  for insert to authenticated
  with check ((created_by = (select auth.uid())) and public.can_edit_child(child_id));

drop policy if exists tasks_select_visible on public.family_tasks;
create policy tasks_select_visible on public.family_tasks
  for select to authenticated
  using (
    public.is_child_member(child_id)
    and (visibility = 'family'::text or created_by = (select auth.uid()))
  );

drop policy if exists tasks_insert_editors on public.family_tasks;
create policy tasks_insert_editors on public.family_tasks
  for insert to authenticated
  with check ((created_by = (select auth.uid())) and public.can_edit_child(child_id));

drop policy if exists doctor_questions_insert_editors on public.doctor_questions;
create policy doctor_questions_insert_editors on public.doctor_questions
  for insert to authenticated
  with check ((created_by = (select auth.uid())) and public.can_edit_child(child_id));
