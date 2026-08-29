import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/screens/classy/classy_home_screen.dart';
import 'package:flutter_application_1/screens/main_shell.dart';
import 'package:flutter_application_1/screens/quick_log_screen.dart';

void main() {
  testWidgets('MainShell lazily creates Classy Home and unopened tabs', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: MainShell(),
        ),
      ),
    );

    expect(find.byType(ClassyHomeScreen), findsOneWidget);
    expect(find.byType(QuickLogScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
