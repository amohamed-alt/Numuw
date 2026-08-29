import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Quick Log uses the Organic SVG vocabulary instead of direct emoji UI', () {
    final source = File('lib/screens/quick_log_screen.dart').readAsStringSync();

    expect(source, contains("import '../design/numuw_organic_icons.dart';"));
    expect(source, contains('NumuwOrganicIconName.breastfeeding'));
    expect(source, contains('NumuwOrganicIconName.bottle'));
    expect(source, contains('NumuwOrganicIconName.sleep'));
    expect(source, contains('NumuwOrganicIconName.diaper'));
    expect(source, contains('NumuwOrganicIconName.food'));
    expect(source, contains('NumuwOrganicIconName.medicine'));
    expect(source, contains('NumuwOrganicIconName.temperature'));
    expect(source, contains('NumuwOrganicIconName.edit'));

    for (final emoji in ['🍼', '🌙', '🧷', '🥣', '💊', '🌡️', '📝', '✏️']) {
      expect(source, isNot(contains(emoji)), reason: 'Quick Log still contains $emoji');
    }
  });

  test('Quick Log keeps reduced-motion-aware interaction primitives', () {
    final source = File('lib/screens/quick_log_screen.dart').readAsStringSync();

    expect(source, contains('NumuwPressable'));
    expect(source, contains('NumuwSuccessPulse'));
    expect(source, contains('disableAnimations'));
    expect(source, contains('AnimatedSwitcher'));
  });
}
