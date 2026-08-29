import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/core/theme/numuw_theme.dart';
import 'package:flutter_application_1/models/child_profile.dart';
import 'package:flutter_application_1/screens/classy/classy_quick_log_screen.dart';
import 'package:flutter_application_1/screens/main_shell.dart';
import 'package:flutter_application_1/screens/quick_log_screen.dart';
import 'package:flutter_application_1/screens/welcome_screen.dart';
import 'package:flutter_application_1/state/app_preferences.dart';
import 'package:flutter_application_1/state/child_session.dart';
import 'package:flutter_application_1/state/log_timer_state.dart';
import 'package:flutter_application_1/widgets/app_bottom_navigation.dart';
import 'package:flutter_application_1/widgets/app_widgets.dart';

ChildProfile _child() => const ChildProfile(
  id: '11111111-1111-4111-8111-111111111111',
  createdBy: '22222222-2222-4222-8222-222222222222',
  name: 'سلمى',
  stage: 'born',
  gender: 'female',
  feedingType: 'formula',
);

Widget _welcomeHost({required bool night}) {
  return MaterialApp(
    theme: buildNumuwTheme(night: night),
    home: WelcomeScreen(onSignIn: () {}, onSignUp: () {}),
  );
}

Widget _quickLogHost() {
  return MaterialApp(
    home: Material(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: const QuickLogScreen(),
      ),
    ),
  );
}

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

  testWidgets('welcome screen renders without overflow', (tester) async {
    await tester.pumpWidget(_welcomeHost(night: false));
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(PrimaryButton), findsOneWidget);
    expect(find.byType(SecondaryButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bottom navigation updates the selected tab', (tester) async {
    var selectedIndex = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Center(child: Text('selected:$selectedIndex')),
            bottomNavigationBar: AppBottomNavigation(
              selectedIndex: selectedIndex,
              onChanged: (index) => selectedIndex = index,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('المزيد'));
    await tester.pump();
    expect(selectedIndex, 4);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quick-log navigation opens the classy production tab', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: MainShell(),
        ),
      ),
    );
    await tester.tap(find.text('تسجيل'));
    await tester.pumpAndSettle();
    expect(find.byType(ClassyQuickLogScreen), findsOneWidget);
  });

  // Legacy QuickLog behavioral tests remain while each secondary pane migrates.
  // They protect the underlying timer/logging behavior during presentation work.
  testWidgets('feeding timer state updates quick log controls', (tester) async {
    final child = _child();
    ChildSession.instance.setChildren([child], notify: false);
    await LogTimerState.instance.startFeeding(child.id, DateTime(2026, 7, 4, 10, 0));
    await tester.pumpWidget(_quickLogHost());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(QuickLogTypeButton).at(0));
    await tester.pumpAndSettle();
    final timerCard = tester.widget<TimerCard>(find.byType(TimerCard));
    expect(timerCard.active, isTrue);
    expect(timerCard.color, AppColors.mint);
  });

  testWidgets('sleep timer state updates quick log controls', (tester) async {
    final child = _child();
    ChildSession.instance.setChildren([child], notify: false);
    await LogTimerState.instance.startSleep(child.id, DateTime(2026, 7, 4, 21, 30));
    await tester.pumpWidget(_quickLogHost());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(QuickLogTypeButton).at(2));
    await tester.pumpAndSettle();
    expect(
      find.byWidgetPredicate((widget) => widget is PrimaryButton && widget.color == AppColors.danger),
      findsOneWidget,
    );
  });

  testWidgets('diaper selection updates the selected choice pill', (tester) async {
    final child = _child();
    ChildSession.instance.setChildren([child], notify: false);
    await tester.pumpWidget(_quickLogHost());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(QuickLogTypeButton).at(3));
    await tester.pumpAndSettle();
    final dirtyText = find.text('متسخة');
    final before = tester.widget<Text>(dirtyText);
    expect(before.style?.color, isNot(AppColors.peach));
    await tester.tap(dirtyText);
    await tester.pumpAndSettle();
    final after = tester.widget<Text>(dirtyText);
    expect(after.style?.color, AppColors.peach);
  });

  testWidgets('light and dark theme smoke tests', (tester) async {
    await tester.pumpWidget(_welcomeHost(night: false));
    expect(find.byType(WelcomeScreen), findsOneWidget);
    await AppPreferences.instance.setNightMode(true);
    await tester.pumpWidget(_welcomeHost(night: true));
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('small-screen layouts do not overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_welcomeHost(night: false));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
