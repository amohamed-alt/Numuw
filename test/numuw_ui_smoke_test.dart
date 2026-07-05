import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/core/theme/numuw_theme.dart';
import 'package:flutter_application_1/models/child_profile.dart';
import 'package:flutter_application_1/screens/quick_log_screen.dart';
import 'package:flutter_application_1/screens/welcome_screen.dart';
import 'package:flutter_application_1/state/app_preferences.dart';
import 'package:flutter_application_1/state/child_session.dart';
import 'package:flutter_application_1/state/log_timer_state.dart';
import 'package:flutter_application_1/widgets/app_bottom_navigation.dart';
import 'package:flutter_application_1/widgets/app_widgets.dart';
import 'package:flutter_application_1/widgets/quick_log_sheet.dart';

ChildProfile _child() => const ChildProfile(
  id: '11111111-1111-4111-8111-111111111111',
  createdBy: '22222222-2222-4222-8222-222222222222',
  name: 'سلمى',
  stage: 'born',
  gender: 'female',
  feedingType: 'formula',
);

Widget _welcomeHost({required bool night}) => MaterialApp(
  theme: buildNumuwTheme(night: night),
  home: WelcomeScreen(onSignIn: () {}, onSignUp: () {}),
);

Widget _quickLogHost(String mode) => MaterialApp(
  home: Material(
    child: Directionality(
      textDirection: TextDirection.rtl,
      child: QuickLogScreen(initialMode: mode),
    ),
  ),
);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    ChildSession.instance.clear();
    await LogTimerState.instance.cancelFeeding();
    await LogTimerState.instance.cancelSleep();
    await LogTimerState.instance.cancelPumping();
    await AppPreferences.instance.setNightMode(false);
  });

  tearDown(() async {
    await AppPreferences.instance.setNightMode(false);
    ChildSession.instance.clear();
    await LogTimerState.instance.cancelFeeding();
    await LogTimerState.instance.cancelSleep();
    await LogTimerState.instance.cancelPumping();
  });

  testWidgets('welcome screen renders final onboarding controls', (
    tester,
  ) async {
    await tester.pumpWidget(_welcomeHost(night: false));

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(PrimaryButton), findsOneWidget);
    expect(find.text('التالي'), findsOneWidget);
    expect(
      find.textContaining('تسجيل الدخول', findRichText: true),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('bottom navigation updates the selected tab', (tester) async {
    var selectedIndex = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            bottomNavigationBar: AppBottomNavigation(
              selectedIndex: selectedIndex,
              onChanged: (index) => selectedIndex = index,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.grid_view_rounded));
    await tester.pump();
    expect(selectedIndex, 4);
    expect(tester.takeException(), isNull);
  });

  testWidgets('center action opens quick logging sheet', (tester) async {
    String? selectedMode;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  selectedMode = await showModalBottomSheet<String>(
                    context: context,
                    builder: (_) => const QuickLogSheet(),
                  );
                },
                child: const Text('افتحي التسجيل'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('افتحي التسجيل'));
    await tester.pumpAndSettle();
    expect(find.text('ماذا تريدين أن تسجّلي؟'), findsOneWidget);
    await tester.tap(find.text('رضاعة'));
    await tester.pumpAndSettle();
    expect(selectedMode, 'feeding');
  });

  testWidgets('active feeding timer appears in final feeding screen', (
    tester,
  ) async {
    final child = _child();
    ChildSession.instance.setChildren([child], notify: false);
    await LogTimerState.instance.startFeeding(
      child.id,
      DateTime.now().subtract(const Duration(minutes: 5)),
    );

    await tester.pumpWidget(_quickLogHost('feeding'));
    await tester.pump();
    expect(find.text('تسجيل الرضاعة'), findsOneWidget);
    expect(find.textContaining('الإجمالي'), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
  });

  testWidgets('active sleep timer shows wake action', (tester) async {
    final child = _child();
    ChildSession.instance.setChildren([child], notify: false);
    await LogTimerState.instance.startSleep(
      child.id,
      DateTime.now().subtract(const Duration(minutes: 20)),
    );

    await tester.pumpWidget(_quickLogHost('sleep'));
    await tester.pump();
    expect(find.text('النوم'), findsOneWidget);
    expect(find.text('جلسة نوم جارية'), findsOneWidget);
    expect(find.text('استيقظ الآن'), findsOneWidget);
  });

  testWidgets('dirty diaper choice reveals color controls', (tester) async {
    final child = _child();
    ChildSession.instance.setChildren([child], notify: false);

    await tester.pumpWidget(_quickLogHost('diaper'));
    await tester.pump();
    expect(find.text('تسجيل الحفاضة'), findsOneWidget);
    await tester.tap(find.text('حفاضة متسخة'));
    await tester.pump();
    expect(find.text('اللون'), findsOneWidget);
    expect(find.text('أصفر'), findsOneWidget);
  });

  testWidgets('light and dark theme smoke tests', (tester) async {
    await tester.pumpWidget(_welcomeHost(night: false));
    expect(find.byType(WelcomeScreen), findsOneWidget);

    await AppPreferences.instance.setNightMode(true);
    await tester.pumpWidget(_welcomeHost(night: true));
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('small-screen onboarding does not overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_welcomeHost(night: false));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
