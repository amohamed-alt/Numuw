import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/design_preview/numuw_master_preview.dart';

Widget _buildPreview({bool dark = false}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: MediaQuery(
        data: const MediaQueryData(
          size: Size(393, 852),
          textScaler: TextScaler.linear(.94),
        ),
        child: NumuwMasterPreview(initialDark: dark),
      ),
    ),
  );
}

Future<void> _openScreen(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('home light mode renders the approved master content', (tester) async {
    await tester.pumpWidget(_buildPreview());

    expect(find.text('مرحباً ماما'), findsOneWidget);
    expect(find.text('يوسف'), findsOneWidget);
    expect(find.text('نبتة يوسف'), findsOneWidget);
    expect(find.text('ملخص اليوم'), findsOneWidget);
    expect(find.text('التطعيم القادم'), findsOneWidget);
    expect(find.text('نصيحة اليوم'), findsOneWidget);
    expect(find.text('الوضع الداكن'), findsOneWidget);
  });

  testWidgets('home dark mode renders without losing core content', (tester) async {
    await tester.pumpWidget(_buildPreview(dark: true));

    expect(find.text('مرحباً ماما'), findsOneWidget);
    expect(find.text('يوسف'), findsOneWidget);
    expect(find.text('نبتة يوسف'), findsOneWidget);
    expect(find.text('ملخص اليوم'), findsOneWidget);
    expect(find.text('الوضع الفاتح'), findsOneWidget);
  });

  testWidgets('master preview opens all four approved screens', (tester) async {
    await tester.pumpWidget(_buildPreview());

    expect(find.text('مرحباً ماما'), findsOneWidget);

    await _openScreen(tester, 'التسجيل السريع');
    expect(find.text('آخر التسجيلات'), findsOneWidget);
    expect(find.text('رضاعة'), findsWidgets);
    expect(find.text('حفاضة'), findsWidgets);

    await _openScreen(tester, 'الرضاعة');
    expect(find.text('جلسة جارية الآن'), findsOneWidget);
    expect(find.text('إيقاف وحفظ'), findsOneWidget);
    expect(find.text('الجهة'), findsOneWidget);

    await _openScreen(tester, 'ملف الطفل');
    expect(find.text('التطعيمات'), findsOneWidget);
    expect(find.text('أسئلة الطبيب'), findsOneWidget);
    expect(find.text('مهام العائلة'), findsOneWidget);
  });

  testWidgets('theme switch changes the master preview mode', (tester) async {
    await tester.pumpWidget(_buildPreview());

    expect(find.text('الوضع الداكن'), findsOneWidget);
    await tester.tap(find.text('الوضع الداكن'));
    await tester.pumpAndSettle();
    expect(find.text('الوضع الفاتح'), findsOneWidget);
  });

  testWidgets('all master screens smoke render in dark mode', (tester) async {
    await tester.pumpWidget(_buildPreview(dark: true));

    await _openScreen(tester, 'التسجيل السريع');
    expect(find.text('آخر التسجيلات'), findsOneWidget);

    await _openScreen(tester, 'الرضاعة');
    expect(find.text('إيقاف وحفظ'), findsOneWidget);

    await _openScreen(tester, 'ملف الطفل');
    expect(find.text('أسئلة الطبيب'), findsOneWidget);
  });
}
