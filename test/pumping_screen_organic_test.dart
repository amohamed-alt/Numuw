import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Pumping uses Organic SVG visuals instead of emoji pictograms', () {
    final source = File('lib/screens/pumping_screen.dart').readAsStringSync();

    expect(source, contains("import '../design/numuw_organic_icons.dart';"));
    expect(source, contains('NumuwOrganicIconName.calendar'));
    expect(source, contains('NumuwOrganicIconName.edit'));
    expect(source, contains('NumuwOrganicIconName.bottle'));
    expect(source, isNot(contains('🍼')));
    expect(source, isNot(contains('🕒')));
  });

  test('Pumping keeps reduced-motion-aware motion integration', () {
    final source = File('lib/screens/pumping_screen.dart').readAsStringSync();

    expect(source, contains("import '../design/numuw_motion_widgets.dart';"));
    expect(source, contains('NumuwEntrance('));
    expect(source, contains('NumuwPressable('));
    expect(source, contains('disableAnimations == true'));
    expect(source, contains("semanticLabel: 'تعديل وقت بدء جلسة الشفط'"));
  });
}
