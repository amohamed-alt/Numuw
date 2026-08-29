import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/design/numuw_organic_icons.dart';
import 'package:flutter_application_1/screens/welcome_screen.dart';

void main() {
  testWidgets('welcome renders valid Arabic copy and organic SVG icons', (
    tester,
  ) async {
    var signedIn = false;
    var signedUp = false;

    await tester.pumpWidget(
      MaterialApp(
        home: WelcomeScreen(
          onSignIn: () => signedIn = true,
          onSignUp: () => signedUp = true,
        ),
      ),
    );

    expect(find.text('نُموّ'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('إنشاء حساب جديد'), findsOneWidget);
    expect(find.textContaining('خصوصيتك واضحة'), findsOneWidget);
    expect(find.textContaining('Ã'), findsNothing);
    expect(find.byType(NumuwOrganicIcon), findsWidgets);

    await tester.tap(find.text('تسجيل الدخول'));
    await tester.pump();
    expect(signedIn, isTrue);

    await tester.tap(find.text('إنشاء حساب جديد'));
    await tester.pump();
    expect(signedUp, isTrue);
  });
}
