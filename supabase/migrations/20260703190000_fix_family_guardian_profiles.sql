-- Fixes family member listing without relying on a nonexistent FK from
-- child_guardians.user_id to public.profiles.
create or replace function public.get_child_guardians(p_child_id uuid)
returns table (
  child_id uuid,
  user_id uuid,
  role text,
  created_at timestamptz,
  display_name text,
  email text
)
language sql
security definer
set search_path = public
as $$
  select
    cg.child_id,
    cg.user_id,
    cg.role,
    cg.created_at,
    p.full_name as display_name,
    au.email::text as email
  from public.child_guardians cg
  left join public.profiles p on p.id = cg.user_id
  left join auth.users au on au.id = cg.user_id
  where cg.child_id = p_child_id
    and public.is_child_guardian(cg.child_id, auth.uid())
  order by cg.created_at;
$$;

revoke all on function public.get_child_guardians(uuid) from public;
grant execute on function public.get_child_guardians(uuid) to authenticated;

