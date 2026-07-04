import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_application_1/core/errors/app_error.dart';
import 'package:flutter_application_1/models/care_event.dart';
import 'package:flutter_application_1/models/child_profile.dart';
import 'package:flutter_application_1/services/ai_assistant_service.dart';

class _FakeTransport implements AiAssistantTransport {
  _FakeTransport({this.response, this.error, this.requireSession = false});

  final Map<String, dynamic>? response;
  final Object? error;
  final bool requireSession;

  @override
  Session? get currentSession => null;

  @override
  Future<Map<String, dynamic>> invoke({
    required String functionId,
    required Map<String, dynamic> body,
    required Duration timeout,
  }) async {
    if (requireSession) {
      throw const InvalidSessionException();
    }
    if (error != null) throw error!;
    return response ?? <String, dynamic>{};
  }
}

ChildProfile _child() => const ChildProfile(
  id: '11111111-1111-4111-8111-111111111111',
  createdBy: '22222222-2222-4222-8222-222222222222',
  name: 'سلمى',
  stage: 'born',
  gender: 'female',
  feedingType: 'formula',
);

CareEvent _event({
  required String type,
  required DateTime startedAt,
  DateTime? endedAt,
  double? amountMl,
  bool? diaperWet,
  bool? diaperDirty,
  double? temperatureC,
  String? medicineName,
  String? medicineDose,
  Map<String, dynamic>? metadata,
}) {
  return CareEvent(
    id: '1',
    childId: '11111111-1111-4111-8111-111111111111',
    createdBy: '22222222-2222-4222-8222-222222222222',
    eventType: type,
    startedAt: startedAt,
    endedAt: endedAt,
    amountMl: amountMl,
    diaperWet: diaperWet,
    diaperDirty: diaperDirty,
    temperatureC: temperatureC,
    medicineName: medicineName,
    medicineDose: medicineDose,
    metadata: metadata,
  );
}

void main() {
  test('missing session maps to invalid session', () async {
    final service = AiAssistantService(
      transport: _FakeTransport(requireSession: true),
    );

    await expectLater(
      service.parseCareEvent(
        child: _child(),
        text: 'رضعت 75 مل',
        now: DateTime.now(),
        locale: const Locale('ar'),
      ),
      throwsA(isA<InvalidSessionException>()),
    );
  });

  test('service maps timeout errors', () async {
    final service = AiAssistantService(
      transport: _FakeTransport(error: TimeoutException('timeout')),
    );

    await expectLater(
      service.dailySummary(
        child: _child(),
        events: [_event(type: 'feeding', startedAt: DateTime.now())],
        now: DateTime.now(),
        locale: const Locale('ar'),
      ),
      throwsA(isA<RequestTimeoutException>()),
    );
  });

  test('service maps HTTP 401', () {
    final mapped = AiAssistantService.mapAiAssistantError(
      Exception('HTTP 401 unauthorized'),
    );
    expect(mapped, isA<InvalidSessionException>());
  });

  test('service maps HTTP 403', () {
    final mapped = AiAssistantService.mapAiAssistantError(
      Exception('HTTP 403 forbidden'),
    );
    expect(mapped, isA<UnauthorizedChildException>());
  });

  test('service maps HTTP 429', () {
    final mapped = AiAssistantService.mapAiAssistantError(
      Exception('HTTP 429 rate limit'),
    );
    expect(mapped, isA<RateLimitException>());
  });

  test('service returns structured success response', () async {
    final service = AiAssistantService(
      transport: _FakeTransport(
        response: {
          'message': 'تم الفهم',
          'requires_confirmation': true,
          'actions': [
            {'event_type': 'feeding', 'needs_review': true},
          ],
        },
      ),
    );

    final response = await service.parseCareEvent(
      child: _child(),
      text: 'رضعت',
      now: DateTime.now(),
      locale: const Locale('ar'),
    );

    expect(response.message, 'تم الفهم');
    expect(response.actions, hasLength(1));
  });

  test('service allows parse responses with message but no actions', () async {
    final service = AiAssistantService(
      transport: _FakeTransport(
        response: {
          'message': 'لم أتمكن من استخراج حدث واضح',
          'requires_confirmation': false,
          'actions': const [],
        },
      ),
    );

    final response = await service.parseCareEvent(
      child: _child(),
      text: 'أمضيت اليوم',
      now: DateTime.now(),
      locale: const Locale('ar'),
    );

    expect(response.message, 'لم أتمكن من استخراج حدث واضح');
    expect(response.actions, isEmpty);
    expect(response.requiresConfirmation, isFalse);
  });

  test('malformed response maps to invalid ai response', () {
    final mapped = AiAssistantService.mapAiAssistantError(
      FormatException('bad json'),
    );
    expect(mapped, isA<InvalidAiResponseException>());
  });
}
