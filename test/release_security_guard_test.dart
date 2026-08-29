import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('release security guards', () {
    test('client source never contains privileged Supabase credentials', () {
      final findings = <String>[];
      for (final file in _clientSourceFiles()) {
        final text = file.readAsStringSync().toLowerCase();
        if (text.contains('service_role') ||
            text.contains('service-role') ||
            text.contains('supabase_secret_key')) {
          findings.add(file.path);
        }
      }
      expect(
        findings,
        isEmpty,
        reason:
            'Privileged Supabase credentials/labels must never appear in Flutter client source: ${findings.join(', ')}',
      );
    });

    test('runtime Supabase configuration remains dart-define based', () {
      final main = File('lib/main.dart').readAsStringSync();
      expect(main, contains("String.fromEnvironment('SUPABASE_URL')"));
      expect(
        main,
        contains("String.fromEnvironment(\n    'SUPABASE_PUBLISHABLE_KEY'"),
      );
      expect(main, isNot(contains('serviceRoleKey')));
      expect(main, isNot(contains('service_role')));
    });

    test('Sentry defaults remain privacy conscious', () {
      final main = File('lib/main.dart').readAsStringSync();
      expect(main, contains('sendDefaultPii = false'));
      expect(main, contains('attachScreenshot = false'));
      expect(main, contains("String.fromEnvironment('SENTRY_DSN')"));
    });

    test('isolated UI review does not initialize backend services', () {
      final review = File('lib/main_ui_review_v3.dart').readAsStringSync();
      expect(review, isNot(contains('Supabase.initialize')));
      expect(review, isNot(contains('NotificationService')));
      expect(review, isNot(contains('SentryFlutter.init')));
      expect(review, isNot(contains('SUPABASE_PUBLISHABLE_KEY')));
    });

    test('production auth uses PKCE flow', () {
      final main = File('lib/main.dart').readAsStringSync();
      expect(main, contains('AuthFlowType.pkce'));
    });

    test('Edge Functions do not hardcode service-role JWT values', () {
      final findings = <String>[];
      final functions = Directory('supabase/functions');
      if (functions.existsSync()) {
        for (final entity in functions.listSync(recursive: true)) {
          if (entity is! File || !entity.path.endsWith('.ts')) continue;
          final text = entity.readAsStringSync();
          final jwtLike = RegExp(
            r'eyJ[a-zA-Z0-9_-]{20,}\.[a-zA-Z0-9_-]{20,}\.[a-zA-Z0-9_-]{20,}',
          );
          if (jwtLike.hasMatch(text)) findings.add(entity.path);
        }
      }
      expect(
        findings,
        isEmpty,
        reason:
            'Edge Functions must load privileged keys from environment variables, never hardcode JWTs: ${findings.join(', ')}',
      );
    });
  });
}

Iterable<File> _clientSourceFiles() sync* {
  final directory = Directory('lib');
  if (!directory.existsSync()) return;
  for (final entity in directory.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) yield entity;
  }
}
