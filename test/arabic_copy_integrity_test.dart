import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('critical Arabic UI sources contain no common mojibake markers', () {
    const paths = <String>[
      'lib/screens/child_screen.dart',
      'lib/screens/welcome_screen.dart',
      'lib/screens/splash_screen.dart',
    ];
    const badMarkers = <String>[
      'Ã',
      'Â',
      'â€',
      'ðŸ',
      '™',
      '˜',
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

    expect(
      failures,
      isEmpty,
      reason: failures.join('\n'),
    );
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
}
