import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sign out disables user push subscriptions before ending auth session', () {
    final source = File('lib/services/auth_service.dart').readAsStringSync();

    final signOutStart = source.indexOf('Future<void> signOut() async');
    expect(signOutStart, greaterThanOrEqualTo(0));

    final signOutSource = source.substring(signOutStart);
    final disableCall = signOutSource.indexOf(
      '_pushDevices.disableAllForCurrentUser()',
    );
    final authSignOutCall = signOutSource.indexOf('_client.auth.signOut()');

    expect(disableCall, greaterThanOrEqualTo(0));
    expect(authSignOutCall, greaterThan(disableCall));
  });

  test('account deletion still relies on server deletion and local sign out', () {
    final source = File('lib/services/auth_service.dart').readAsStringSync();

    expect(source, contains("'delete-account'"));
    expect(source, contains("'DELETE_NUMUW_ACCOUNT'"));
    expect(
      source,
      contains('await _client.auth.signOut(scope: SignOutScope.local);'),
    );
  });
}
