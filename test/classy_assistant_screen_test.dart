import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_application_1/screens/classy/classy_assistant_screen.dart';
import 'package:flutter_application_1/services/ai_assistant_service.dart';
import 'package:flutter_application_1/state/child_session.dart';

class _FakeTransport implements AiAssistantTransport {
  @override
  Session? get currentSession => null;

  @override
  Future<Map<String, dynamic>> invoke({
    required String functionId,
    required Map<String, dynamic> body,
    required Duration timeout,
  }) async => <String, dynamic>{'message': 'ok'};
}

void main() {
  tearDown(() => ChildSession.instance.clear());

  testWidgets('classy assistant renders safe empty state without Supabase', (
    tester,
  ) async {
    final service = AiAssistantService(transport: _FakeTransport());
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: ClassyAssistantScreen(service: service),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('اسألي المساعد'), findsOneWidget);
    expect(find.textContaining('لا يشخّص'), findsOneWidget);
    expect(find.text('تسجيل ذكي'), findsOneWidget);
    expect(find.text('سؤال للطبيب'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
