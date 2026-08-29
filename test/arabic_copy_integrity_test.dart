import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('critical Arabic UI sources contain no common mojibake markers', () {
    const paths = <String>[
      'lib/screens/child_screen.dart',
      'lib/screens/welcome_screen.dart',
      'lib/screens/splash_screen.dart',
      'lib/screens/assistant_screen.dart',
      'lib/screens/family/family_screen.dart',
    ];
    const badMarkers = <String>[
      'Ã',
      'Â',
      'â€',
      'ðŸ',
      '™',
      '˜',
      'Ø',
      'Ù',
    ];

    final failures = <String>[];
    for (final path in paths) {
      final source = File(path).readAsStringSync();
      for (final marker in badMarkers) {
        if (source.contains(marker)) {
          failures.add('$path contains mojibake marker "$marker"');
        }
      }
    }

    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  test('ChildScreen keeps the approved organic visual vocabulary', () {
    final source = File('lib/screens/child_screen.dart').readAsStringSync();

    expect(source, contains('NumuwOrganicIconName.newborn'));
    expect(source, contains('NumuwOrganicIconName.growth'));
    expect(source, contains('NumuwOrganicIconName.vaccine'));
    expect(source, contains('NumuwOrganicIconName.tasks'));
    expect(source, contains('NumuwOrganicIconName.doctor'));
    expect(source, contains('NumuwEntrance'));
  });

  test('FamilyScreen keeps valid Arabic and organic family visuals', () {
    final source = File(
      'lib/screens/family/family_screen.dart',
    ).readAsStringSync();

    expect(source, contains('مشاركة العائلة'));
    expect(source, contains('NumuwOrganicIconName.family'));
    expect(source, contains('NumuwOrganicIconName.account'));
    expect(source, contains('NumuwEntrance'));
  });
}
