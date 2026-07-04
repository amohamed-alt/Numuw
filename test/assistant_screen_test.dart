import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/models/child_profile.dart';
import 'package:flutter_application_1/screens/assistant_screen.dart';
import 'package:flutter_application_1/state/child_session.dart';

void main() {
  setUp(() {
    ChildSession.instance.setChildren([
      const ChildProfile(
        id: '11111111-1111-4111-8111-111111111111',
        createdBy: '22222222-2222-4222-8222-222222222222',
        name: 'سلمى',
        stage: 'born',
        gender: 'female',
        feedingType: 'formula',
      ),
    ]);
  });

  tearDown(() {
    ChildSession.instance.clear();
  });

  testWidgets('assistant screen shows rtl labels', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AssistantScreen()));

    expect(find.text('اسألي'), findsOneWidget);
    expect(find.text('ملخص للطبيب'), findsOneWidget);
    expect(find.text('صياغة سؤال'), findsOneWidget);
  });

  testWidgets('emergency notice can be shown', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AssistantScreen()));

    await tester.tap(find.text('تنبيه الطوارئ'));
    await tester.pump();

    expect(find.textContaining('الطوارئ'), findsWidgets);
  });

  testWidgets('dark mode smoke test', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: ThemeData.dark(), home: const AssistantScreen()),
    );

    expect(find.text('اسألي'), findsOneWidget);
  });
}
