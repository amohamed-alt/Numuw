import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/design_preview/numuw_master_preview.dart';

void main() {
  testWidgets('master preview opens all four approved screens', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: NumuwMasterPreview(),
        ),
      ),
    );

    expect(find.text('مرحباً ماما'), findsOneWidget);

    await tester.tap(find.text('التسجيل السريع').first);
    await tester.pumpAndSettle();
    expect(find.text('آخر التسجيلات'), findsOneWidget);

    await tester.tap(find.text('الرضاعة').first);
    await tester.pumpAndSettle();
    expect(find.text('جلسة جارية الآن'), findsOneWidget);
    expect(find.text('إيقاف وحفظ'), findsOneWidget);

    await tester.tap(find.text('ملف الطفل').first);
    await tester.pumpAndSettle();
    expect(find.text('التطعيمات'), findsOneWidget);
    expect(find.text('أسئلة الطبيب'), findsOneWidget);
  });

  testWidgets('theme switch changes the master preview mode', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: NumuwMasterPreview(),
        ),
      ),
    );

    expect(find.text('الوضع الداكن'), findsOneWidget);
    await tester.tap(find.text('الوضع الداكن'));
    await tester.pumpAndSettle();
    expect(find.text('الوضع الفاتح'), findsOneWidget);
  });
}
