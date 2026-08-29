import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/screens/design_preview/ui_review_app.dart';

void main() {
  testWidgets('UI review candidate exposes every major review surface', (tester) async {
    await tester.pumpWidget(const NumuwUiReviewApp());
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
    expect(find.text('متابعة النمو والصحة', findRichText: true), findsNothing);
    expect(find.text('النمو'), findsOneWidget);

    await tester.tap(find.text('العائلة'));
    await tester.pumpAndSettle();
    expect(find.text('مشاركة العائلة'), findsOneWidget);
    expect(find.text('أفراد العائلة'), findsOneWidget);

    await tester.tap(find.text('المساعد'));
    await tester.pumpAndSettle();
    expect(find.text('مساعد نُمُوّ'), findsOneWidget);
    expect(find.text('ملخص اليوم'), findsOneWidget);

    await tester.tap(find.text('المزيد'));
    await tester.pumpAndSettle();
    expect(find.text('الحمل'), findsOneWidget);
    expect(find.text('التغذية'), findsOneWidget);
    expect(find.text('صحة الأم'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });
}
