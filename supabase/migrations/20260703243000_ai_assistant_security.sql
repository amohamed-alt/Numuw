revoke all on table public.ai_usage_events from anon, authenticated;

grant select, insert on table public.ai_usage_events to authenticated;

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'service_role') then
    execute 'grant select, insert on table public.ai_usage_events to service_role';
  end if;
end
$$;

do $$
declare
  r record;
begin
  for r in
    select p.oid::regprocedure as signature, p.proname
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname in (
        'rls_auto_enable',
        'can_edit_child',
        'is_child_member',
        'is_child_owner'
      )
  loop
    execute format('alter function %s set search_path = public, pg_temp', r.signature);
    if r.proname = 'rls_auto_enable' then
      execute format('revoke execute on function %s from public, anon, authenticated', r.signature);
    elsif r.proname in ('can_edit_child', 'is_child_member', 'is_child_owner') then
      execute format('revoke execute on function %s from public, anon', r.signature);
    end if;
  end loop;
end
$$;
