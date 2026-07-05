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
        name: 'Salma',
        stage: 'born',
        gender: 'female',
        feedingType: 'formula',
      ),
    ]);
  });

  tearDown(ChildSession.instance.clear);

  testWidgets('assistant screen renders redesigned empty state', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AssistantScreen()));

    expect(find.byIcon(Icons.nightlight_round), findsOneWidget);
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.send_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('assistant screen can start a fresh chat', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AssistantScreen()));

    await tester.tap(find.byIcon(Icons.add_comment_outlined));
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('assistant screen dark theme smoke test', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: ThemeData.dark(), home: const AssistantScreen()),
    );

    expect(find.byIcon(Icons.nightlight_round), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
