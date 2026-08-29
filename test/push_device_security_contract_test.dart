import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('push registration claims a token through the authenticated Edge Function', () {
    final source = File(
      'lib/repositories/push_device_repository.dart',
    ).readAsStringSync();

    expect(source, contains("_supabase.functions.invoke("));
    expect(source, contains("'register-push-device'"));
    expect(source, contains("'token': normalizedToken"));
    expect(source, contains("'platform': normalizedPlatform"));
    expect(source, isNot(contains("_supabase.rpc(")));
  });

  test('push tokens are globally unique and public privileged RPC is removed', () {
    final ownershipMigration = File(
      'supabase/migrations/20260829211500_claim_push_device_tokens.sql',
    ).readAsStringSync();
    final cleanupMigration = File(
      'supabase/migrations/20260829213000_remove_public_push_claim_rpc.sql',
    ).readAsStringSync();

    expect(
      ownershipMigration,
      contains('create unique index if not exists push_devices_token_unique_idx'),
    );
    expect(
      cleanupMigration,
      contains('drop function if exists public.claim_push_device'),
    );
  });

  test('server claim verifies caller and never exposes the service role key', () {
    final source = File(
      'supabase/functions/register-push-device/index.ts',
    ).readAsStringSync();

    expect(source, contains('caller.auth.getUser()'));
    expect(source, contains('SUPABASE_SERVICE_ROLE_KEY'));
    expect(source, contains('{ onConflict: "token" }'));
    expect(source, contains('user_id: user.id'));
    expect(source, isNot(contains('serviceRoleKey:')));
    expect(source, isNot(contains('console.log(token')));
  });
}
