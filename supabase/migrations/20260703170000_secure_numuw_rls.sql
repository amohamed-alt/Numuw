-- Numuw base RLS hardening for single-owner data model.
-- Apply this migration to the Supabase project used by config/dev.json.
-- It intentionally keeps access scoped to the row owner (created_by = auth.uid())
-- or to rows linked to a child owned by the current user through children.created_by.

alter table if exists public.children enable row level security;
alter table if exists public.care_events enable row level security;
alter table if exists public.growth_measurements enable row level security;
alter table if exists public.vaccinations enable row level security;
alter table if exists public.family_tasks enable row level security;
alter table if exists public.doctor_questions enable row level security;
alter table if exists public.profiles enable row level security;

-- children: direct owner access.
drop policy if exists "children_select_own" on public.children;
create policy "children_select_own"
on public.children for select
to authenticated
using (created_by = auth.uid());

drop policy if exists "children_insert_own" on public.children;
create policy "children_insert_own"
on public.children for insert
to authenticated
with check (created_by = auth.uid());

drop policy if exists "children_update_own" on public.children;
create policy "children_update_own"
on public.children for update
to authenticated
using (created_by = auth.uid())
with check (created_by = auth.uid());

drop policy if exists "children_delete_own" on public.children;
create policy "children_delete_own"
on public.children for delete
to authenticated
using (created_by = auth.uid());

-- profiles: each user can only read/write their own profile row.
drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
on public.profiles for select
to authenticated
using (id = auth.uid());

drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own"
on public.profiles for insert
to authenticated
with check (id = auth.uid());

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
on public.profiles for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

-- Child-linked tables: access is allowed only when the child belongs to the user.
drop policy if exists "care_events_select_own_child" on public.care_events;
create policy "care_events_select_own_child"
on public.care_events for select
to authenticated
using (exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()));

drop policy if exists "care_events_insert_own_child" on public.care_events;
create policy "care_events_insert_own_child"
on public.care_events for insert
to authenticated
with check (created_by = auth.uid() and exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()));

drop policy if exists "care_events_update_own_child" on public.care_events;
create policy "care_events_update_own_child"
on public.care_events for update
to authenticated
using (exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()))
with check (created_by = auth.uid() and exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()));

drop policy if exists "care_events_delete_own_child" on public.care_events;
create policy "care_events_delete_own_child"
on public.care_events for delete
to authenticated
using (exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()));

drop policy if exists "growth_measurements_select_own_child" on public.growth_measurements;
create policy "growth_measurements_select_own_child"
on public.growth_measurements for select
to authenticated
using (exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()));

drop policy if exists "growth_measurements_insert_own_child" on public.growth_measurements;
create policy "growth_measurements_insert_own_child"
on public.growth_measurements for insert
to authenticated
with check (created_by = auth.uid() and exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()));

drop policy if exists "growth_measurements_update_own_child" on public.growth_measurements;
create policy "growth_measurements_update_own_child"
on public.growth_measurements for update
to authenticated
using (exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()))
with check (created_by = auth.uid() and exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()));

drop policy if exists "growth_measurements_delete_own_child" on public.growth_measurements;
create policy "growth_measurements_delete_own_child"
on public.growth_measurements for delete
to authenticated
using (exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()));

drop policy if exists "vaccinations_select_own_child" on public.vaccinations;
create policy "vaccinations_select_own_child"
on public.vaccinations for select
to authenticated
using (exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()));

drop policy if exists "vaccinations_insert_own_child" on public.vaccinations;
create policy "vaccinations_insert_own_child"
on public.vaccinations for insert
to authenticated
with check (created_by = auth.uid() and exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()));

drop policy if exists "vaccinations_update_own_child" on public.vaccinations;
create policy "vaccinations_update_own_child"
on public.vaccinations for update
to authenticated
using (exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()))
with check (created_by = auth.uid() and exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()));

drop policy if exists "vaccinations_delete_own_child" on public.vaccinations;
create policy "vaccinations_delete_own_child"
on public.vaccinations for delete
to authenticated
using (exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()));

drop policy if exists "family_tasks_select_own_child" on public.family_tasks;
create policy "family_tasks_select_own_child"
on public.family_tasks for select
to authenticated
using (exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()));

drop policy if exists "family_tasks_insert_own_child" on public.family_tasks;
create policy "family_tasks_insert_own_child"
on public.family_tasks for insert
to authenticated
with check (created_by = auth.uid() and exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()));

drop policy if exists "family_tasks_update_own_child" on public.family_tasks;
create policy "family_tasks_update_own_child"
on public.family_tasks for update
to authenticated
using (exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()))
with check (created_by = auth.uid() and exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()));

drop policy if exists "family_tasks_delete_own_child" on public.family_tasks;
create policy "family_tasks_delete_own_child"
on public.family_tasks for delete
to authenticated
using (exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()));

drop policy if exists "doctor_questions_select_own_child" on public.doctor_questions;
create policy "doctor_questions_select_own_child"
on public.doctor_questions for select
to authenticated
using (exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()));

drop policy if exists "doctor_questions_insert_own_child" on public.doctor_questions;
create policy "doctor_questions_insert_own_child"
on public.doctor_questions for insert
to authenticated
with check (created_by = auth.uid() and exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()));

drop policy if exists "doctor_questions_update_own_child" on public.doctor_questions;
create policy "doctor_questions_update_own_child"
on public.doctor_questions for update
to authenticated
using (exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()))
with check (created_by = auth.uid() and exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()));

drop policy if exists "doctor_questions_delete_own_child" on public.doctor_questions;
create policy "doctor_questions_delete_own_child"
on public.doctor_questions for delete
to authenticated
using (exists (select 1 from public.children c where c.id = child_id and c.created_by = auth.uid()));
