import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('release security guards', () {
    test('client source never contains privileged Supabase credentials', () {
      final findings = <String>[];
      for (final file in _sourceFiles()) {
        final text = file.readAsStringSync();
        final lowered = text.toLowerCase();
        if (lowered.contains('service_role') ||
            lowered.contains('service-role') ||
            lowered.contains('supabase_secret_key')) {
          findings.add(file.path);
        }
      }
      expect(
        findings,
        isEmpty,
        reason:
            'Privileged Supabase credentials/labels must never appear in client source: ${findings.join(', ')}',
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
      final review = File('lib/ui_review_main.dart').readAsStringSync();
      expect(review, isNot(contains('Supabase.initialize')));
      expect(review, isNot(contains('NotificationService')));
      expect(review, isNot(contains('SentryFlutter.init')));
      expect(review, isNot(contains('SUPABASE_PUBLISHABLE_KEY')));
    });

    test('production auth uses PKCE flow', () {
      final main = File('lib/main.dart').readAsStringSync();
      expect(main, contains('AuthFlowType.pkce'));
    });
  });
}

Iterable<File> _sourceFiles() sync* {
  for (final root in ['lib', 'supabase/functions']) {
    final directory = Directory(root);
    if (!directory.existsSync()) continue;
    for (final entity in directory.listSync(recursive: true)) {
      if (entity is! File) continue;
      if (entity.path.endsWith('.dart') ||
          entity.path.endsWith('.ts') ||
          entity.path.endsWith('.js')) {
        yield entity;
      }
    }
  }
}
