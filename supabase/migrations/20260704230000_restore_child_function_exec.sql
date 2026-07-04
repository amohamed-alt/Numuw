do $$
declare
  r record;
begin
  for r in
    select p.oid::regprocedure as signature, p.proname
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname in ('can_edit_child', 'is_child_member')
  loop
    execute format('grant execute on function %s to authenticated', r.signature);
    execute format('revoke execute on function %s from public, anon', r.signature);
  end loop;

  for r in
    select p.oid::regprocedure as signature
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname = 'is_child_owner'
  loop
    execute format('revoke execute on function %s from public, anon, authenticated', r.signature);
  end loop;
end
$$;
