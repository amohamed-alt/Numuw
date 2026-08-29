import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/core/theme/numuw_theme.dart';
import 'package:flutter_application_1/widgets/classy/reference_feeding_pane.dart';
import 'package:flutter_application_1/widgets/icons/numuw_icon.dart';

void main() {
  Future<void> pumpFeeding(
    WidgetTester tester, {
    required bool night,
  }) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final amount = TextEditingController(text: '60');
    final notes = TextEditingController();
    addTearDown(amount.dispose);
    addTearDown(notes.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildNumuwTheme(night: night),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: NumuwReferenceFeedingPane(
                  active: true,
                  timerText: '00:18',
                  side: 'right',
                  feedingMethods: const {'breast'},
                  amountController: amount,
                  notesController: notes,
                  amountMl: 60,
                  burped: false,
                  vomited: false,
                  loading: false,
                  onBack: () {},
                  onTimerPressed: () {},
                  onSideChanged: (_) {},
                  onPrimaryMethodChanged: (_) {},
                  onMethodToggled: (_) {},
                  onAmountChanged: (_) {},
                  onAmountDelta: (_) {},
                  onBurpedChanged: (_) {},
                  onVomitedChanged: (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('feeding reference renders custom side artwork in Morning', (
    tester,
  ) async {
    await pumpFeeding(tester, night: false);
    expect(find.text('تسجيل رضاعة'), findsOneWidget);
    expect(find.text('رضاعة طبيعية'), findsOneWidget);
    expect(find.text('اليمين'), findsOneWidget);
    expect(find.text('اليسار'), findsOneWidget);
    expect(find.text('00:18'), findsOneWidget);
    expect(find.byType(NumuwIcon), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('feeding reference renders safely in Evening', (tester) async {
    await pumpFeeding(tester, night: true);
    expect(find.text('إيقاف وحفظ'), findsOneWidget);
    expect(find.text('إضافة ملاحظة أو تفاصيل'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
