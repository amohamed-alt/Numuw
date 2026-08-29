import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('More uses Organic SVG icons for product and account actions', () {
    final source = File('lib/screens/more_screen.dart').readAsStringSync();

    expect(source, contains("import '../design/numuw_organic_icons.dart';"));
    expect(source, contains('NumuwOrganicIconName.sleep'));
    expect(source, contains('NumuwOrganicIconName.diaper'));
    expect(source, contains('NumuwOrganicIconName.medicine'));
    expect(source, contains('NumuwOrganicIconName.vaccine'));
    expect(source, contains('NumuwOrganicIconName.family'));
    expect(source, contains('NumuwOrganicIconName.documents'));
    expect(source, contains('NumuwOrganicIconName.privacy'));
    expect(source, contains('NumuwOrganicIconName.delete'));
    expect(
      source,
      isNot(matches(RegExp(r'(^|[^A-Za-z0-9_])SettingsRow\(', multiLine: true))),
    );
  });

  test('More keeps reduced-motion-aware entrance and press feedback', () {
    final source = File('lib/screens/more_screen.dart').readAsStringSync();

    expect(source, contains("import '../design/numuw_motion_widgets.dart';"));
    expect(source, contains('NumuwEntrance('));
    expect(source, contains('NumuwPressable('));
    expect(source, contains('semanticLabel: title'));
  });
}
