-- A native push token identifies one app installation and must never remain
-- enabled for multiple Numuw accounts. Claiming is intentionally server-side so
-- RLS cannot leave a stale previous-owner row behind when a device changes user.

with ranked_tokens as (
  select
    id,
    row_number() over (
      partition by token
      order by enabled desc, last_seen_at desc, updated_at desc, id desc
    ) as token_rank
  from public.push_devices
)
delete from public.push_devices as device
using ranked_tokens as ranked
where device.id = ranked.id
  and ranked.token_rank > 1;

create unique index if not exists push_devices_token_unique_idx
  on public.push_devices (token);

create or replace function public.claim_push_device(
  p_token text,
  p_platform text,
  p_timezone text default null,
  p_locale text default null,
  p_app_version text default null
)
returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_user_id uuid := auth.uid();
  v_token text := btrim(coalesce(p_token, ''));
  v_platform text := lower(btrim(coalesce(p_platform, '')));
begin
  if v_user_id is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;

  if char_length(v_token) < 20 or char_length(v_token) > 4096 then
    raise exception 'Invalid push token' using errcode = '22023';
  end if;

  if v_platform not in ('android', 'ios', 'web') then
    raise exception 'Unsupported push platform' using errcode = '22023';
  end if;

  insert into public.push_devices (
    user_id,
    platform,
    token,
    timezone,
    locale,
    app_version,
    enabled,
    last_seen_at
  )
  values (
    v_user_id,
    v_platform,
    v_token,
    nullif(btrim(p_timezone), ''),
    nullif(btrim(p_locale), ''),
    nullif(btrim(p_app_version), ''),
    true,
    now()
  )
  on conflict (token) do update
  set
    user_id = excluded.user_id,
    platform = excluded.platform,
    timezone = excluded.timezone,
    locale = excluded.locale,
    app_version = excluded.app_version,
    enabled = true,
    last_seen_at = now();
end;
$$;

revoke all on function public.claim_push_device(text, text, text, text, text) from public;
revoke all on function public.claim_push_device(text, text, text, text, text) from anon;
grant execute on function public.claim_push_device(text, text, text, text, text) to authenticated;

comment on function public.claim_push_device(text, text, text, text, text) is
  'Atomically transfers a push token to the currently authenticated user and refreshes device metadata.';
