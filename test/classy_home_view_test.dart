import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/app_colors.dart';
import 'package:flutter_application_1/widgets/classy/classy_home_view.dart';
import 'package:flutter_application_1/widgets/classy/reference_home_view.dart';
import 'package:flutter_application_1/widgets/icons/numuw_icon.dart';

void main() {
  const data = ClassyHomeViewData(
    greeting: 'مرحباً يا ماما',
    subtitle: 'اليوم، 28 أغسطس',
    childName: 'ليان أحمد',
    childAge: '9 أشهر و12 يوم',
    latestFeeding: '5',
    sleepToday: '2',
    latestDiaper: '3',
    nextVaccination: '1',
    timeline: [
      ClassyHomeTimelineItem(
        title: 'رضاعة طبيعية',
        subtitle: '15 دقيقة',
        time: '12:30',
      ),
      ClassyHomeTimelineItem(
        title: 'حفاضة',
        subtitle: 'مبللة',
        time: '11:20',
        color: AppColors.info,
      ),
    ],
  );

  Future<void> pumpHome(
    WidgetTester tester, {
    Brightness brightness = Brightness.light,
  }) async {
    await tester.binding.setSurfaceSize(const Size(430, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: brightness, useMaterial3: true),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: NumuwReferenceHomeView(
                  data: data,
                  onRefresh: () {},
                  onChildTap: () {},
                  onVaccinationTap: () {},
                  onViewAll: () {},
                  onFeeding: () {},
                  onPumping: () {},
                  onSleep: () {},
                  onDiaper: () {},
                  onFood: () {},
                  onMedicine: () {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders reference production home without layout exceptions', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.text('ليان أحمد'), findsOneWidget);
    expect(find.text('نظرة سريعة لليوم'), findsOneWidget);
    expect(find.text('تسجيل سريع'), findsOneWidget);
    expect(find.text('آخر الأنشطة'), findsOneWidget);
    expect(find.byType(NumuwIcon), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders reference home in evening mode without layout exceptions', (
    tester,
  ) async {
    await pumpHome(tester, brightness: Brightness.dark);

    expect(find.text('تسجيل سريع'), findsOneWidget);
    expect(find.text('عرض كل الأنشطة'), findsOneWidget);
    expect(find.byType(NumuwIcon), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
