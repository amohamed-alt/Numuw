import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main_ui_review_fixed.dart';

void main() {
  testWidgets('UI review candidate exposes every major review surface', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const NumuwReviewFixedApp());
    await tester.pumpAndSettle();

    expect(find.text('صباح الخير يا ماما'), findsOneWidget);
    expect(find.text('اليوم'), findsOneWidget);
    expect(find.text('تسجيل'), findsOneWidget);
    expect(find.text('الطفل'), findsOneWidget);
    expect(find.text('العائلة'), findsOneWidget);
    expect(find.text('المساعد'), findsOneWidget);
    expect(find.text('المزيد'), findsOneWidget);

    await tester.tap(find.text('تسجيل'));
    await tester.pumpAndSettle();
    expect(find.text('تسجيل سريع'), findsOneWidget);
    expect(find.text('رضاعة'), findsWidgets);

    await tester.tap(find.text('الطفل'));
    await tester.pumpAndSettle();
    expect(find.text('النمو'), findsOneWidget);
    expect(find.text('التطعيمات'), findsOneWidget);

    await tester.tap(find.text('العائلة'));
    await tester.pumpAndSettle();
    expect(find.text('العائلة'), findsWidgets);
    expect(find.text('دعوة فرد من العائلة'), findsOneWidget);

    await tester.tap(find.text('المساعد'));
    await tester.pumpAndSettle();
    expect(find.text('مساعد نُمُوّ'), findsOneWidget);
    expect(find.text('ملخص اليوم'), findsOneWidget);

    await tester.tap(find.text('المزيد'));
    await tester.pumpAndSettle();
    expect(find.text('تقارير الطبيب'), findsOneWidget);
    expect(find.text('الخصوصية والأمان'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });
}
