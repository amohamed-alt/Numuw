import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/design/numuw_organic_icons.dart';
import 'package:flutter_application_1/screens/auth/sign_up_screen.dart';

void main() {
  testWidgets('signup shows organic privacy visual and password strength', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);

    await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is NumuwOrganicIcon &&
            widget.name == NumuwOrganicIconName.privacy,
      ),
      findsOneWidget,
    );

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(4));

    await tester.enterText(fields.at(2), 'Numuw2026!Safe#');
    await tester.pump();

    expect(
      find.bySemanticsLabel(RegExp(r'قوة كلمة المرور: قوية')),
      findsOneWidget,
    );
  });

  testWidgets('signup blocks mismatched password confirmation before auth call', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(4));

    await tester.enterText(fields.at(0), 'أمينة');
    await tester.enterText(fields.at(1), 'amina@example.com');
    await tester.enterText(fields.at(2), 'Numuw2026!Safe#');
    await tester.enterText(fields.at(3), 'Numuw2026!Other#');

    final submitButton = find.text('إنشاء الحساب');
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    await tester.pump();

    expect(find.text('كلمتا المرور غير متطابقتين.'), findsOneWidget);
  });
}
