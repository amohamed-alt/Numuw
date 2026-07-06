-- Adds vaccination metadata and private child document storage.
-- This migration is intentionally committed first; apply it to Supabase only
-- after review from the dashboard or CLI.

alter table public.vaccinations
  add column if not exists official_dose_id text,
  add column if not exists notes text;

create index if not exists vaccinations_child_official_dose_idx
  on public.vaccinations(child_id, official_dose_id)
  where official_dose_id is not null;

create index if not exists vaccinations_child_status_scheduled_idx
  on public.vaccinations(child_id, status, scheduled_date);

create or replace function public.try_uuid(p_value text)
returns uuid
language plpgsql
immutable
set search_path = public, pg_temp
as $$
begin
  return p_value::uuid;
exception when others then
  return null;
end;
$$;

create table if not exists public.child_documents (
  id uuid primary key default gen_random_uuid(),
  child_id uuid not null references public.children(id) on delete cascade,
  uploaded_by uuid not null references auth.users(id) on delete cascade,
  document_type text not null check (
    document_type in (
      'vaccination_card',
      'prescription',
      'lab_report',
      'doctor_note',
      'other'
    )
  ),
  title text not null,
  storage_bucket text not null default 'numuw-child-documents',
  storage_path text not null,
  mime_type text,
  size_bytes bigint check (size_bytes is null or size_bytes >= 0),
  linked_vaccination_id uuid references public.vaccinations(id) on delete set null,
  linked_care_event_id uuid references public.care_events(id) on delete set null,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(storage_bucket, storage_path)
);

alter table public.child_documents enable row level security;

create index if not exists child_documents_child_id_idx
  on public.child_documents(child_id);
create index if not exists child_documents_uploaded_by_idx
  on public.child_documents(uploaded_by);
create index if not exists child_documents_type_idx
  on public.child_documents(document_type);

create policy child_documents_select_members on public.child_documents
  for select to authenticated
  using (public.is_child_member(child_id));

create policy child_documents_insert_editors on public.child_documents
  for insert to authenticated
  with check ((uploaded_by = (select auth.uid())) and public.can_edit_child(child_id));

create policy child_documents_update_editors on public.child_documents
  for update to authenticated
  using (public.can_edit_child(child_id))
  with check (public.can_edit_child(child_id));

create policy child_documents_delete_editors on public.child_documents
  for delete to authenticated
  using (public.can_edit_child(child_id));

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'numuw-child-documents',
  'numuw-child-documents',
  false,
  10485760,
  array['image/jpeg','image/png','image/webp','application/pdf']::text[]
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

create policy child_documents_storage_select_members on storage.objects
  for select to authenticated
  using (
    bucket_id = 'numuw-child-documents'
    and public.is_child_member(public.try_uuid((storage.foldername(name))[1]))
  );

create policy child_documents_storage_insert_editors on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'numuw-child-documents'
    and public.can_edit_child(public.try_uuid((storage.foldername(name))[1]))
  );

create policy child_documents_storage_update_editors on storage.objects
  for update to authenticated
  using (
    bucket_id = 'numuw-child-documents'
    and public.can_edit_child(public.try_uuid((storage.foldername(name))[1]))
  )
  with check (
    bucket_id = 'numuw-child-documents'
    and public.can_edit_child(public.try_uuid((storage.foldername(name))[1]))
  );

create policy child_documents_storage_delete_editors on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'numuw-child-documents'
    and public.can_edit_child(public.try_uuid((storage.foldername(name))[1]))
  );
