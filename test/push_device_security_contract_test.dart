import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('push registration claims a token through the authenticated server RPC', () {
    final source = File(
      'lib/repositories/push_device_repository.dart',
    ).readAsStringSync();

    expect(source, contains("_supabase.rpc("));
    expect(source, contains("'claim_push_device'"));
    expect(source, contains("'p_token': normalizedToken"));
    expect(source, contains("'p_platform': normalizedPlatform"));
    expect(source, isNot(contains("onConflict: 'user_id,token'")));
  });

  test('push token claim migration enforces single-installation ownership', () {
    final source = File(
      'supabase/migrations/20260829211500_claim_push_device_tokens.sql',
    ).readAsStringSync();

    expect(source, contains('create unique index if not exists push_devices_token_unique_idx'));
    expect(source, contains('create or replace function public.claim_push_device'));
    expect(source, contains('v_user_id uuid := auth.uid()'));
    expect(source, contains('security definer'));
    expect(source, contains('on conflict (token) do update'));
    expect(source, contains('user_id = excluded.user_id'));
    expect(source, contains('grant execute on function public.claim_push_device'));
    expect(source, contains('to authenticated'));
  });
}
