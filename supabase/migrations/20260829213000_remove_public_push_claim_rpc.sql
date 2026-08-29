-- Push token transfer requires privileged cross-user cleanup, but that privilege
-- should not be exposed as a SECURITY DEFINER PostgREST RPC. The authenticated
-- register-push-device Edge Function now performs the same atomic ownership
-- transfer with service-role credentials after verifying the caller JWT.

drop function if exists public.claim_push_device(text, text, text, text, text);
