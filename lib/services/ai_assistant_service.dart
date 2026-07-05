import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/errors/app_error.dart';
import '../models/ai_assistant_response.dart';
import '../models/care_event.dart';
import '../models/child_profile.dart';
import '../models/doctor_question.dart';
import '../models/vaccination.dart';
import 'ai_context_builder.dart';

const aiAssistantTimeout = Duration(seconds: 40);

abstract class AiAssistantTransport {
  Session? get currentSession;

  Future<Map<String, dynamic>> invoke({
    required String functionId,
    required Map<String, dynamic> body,
    required Duration timeout,
  });
}

class SupabaseAiAssistantTransport implements AiAssistantTransport {
  SupabaseAiAssistantTransport({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Session? get currentSession => _client.auth.currentSession;

  @override
  Future<Map<String, dynamic>> invoke({
    required String functionId,
    required Map<String, dynamic> body,
    required Duration timeout,
  }) async {
    final session = currentSession;
    if (session == null || session.accessToken.isEmpty) {
      throw const InvalidSessionException();
    }
    final response = await _client.functions
        .invoke(
          functionId,
          body: body,
          headers: {'Authorization': 'Bearer ${session.accessToken}'},
        )
        .timeout(timeout);
    return _normalizeResponse(response.data);
  }
}

class AiAssistantService {
  AiAssistantService({AiAssistantTransport? transport})
    : _transport = transport ?? SupabaseAiAssistantTransport();

  static const functionId = 'ai-assistant';
  static const defaultModel = 'gemini-3.5-flash';

  final AiAssistantTransport _transport;

  Future<AiAssistantResponse> chat({
    required ChildProfile child,
    required List<CareEvent> events,
    required String question,
    required DateTime now,
    required Locale locale,
  }) {
    final text = question.trim();
    if (text.isEmpty) {
      throw const LocalValidationException('اكتبي سؤالك أولًا.');
    }
    if (text.length > 700) {
      throw const LocalValidationException(
        'السؤال طويل جدًا. اختصريه وحاولي مرة أخرى.',
      );
    }
    if (containsEmergencyKeyword(text)) {
      throw const EmergencyDetectedException();
    }
    return _call(
      mode: AiAssistantMode.chat,
      childId: child.id,
      payload: {
        ...AiContextBuilder.dailySummary(
          child: child,
          events: events,
          now: now,
          locale: _localeTag(locale),
          timezoneOffsetMinutes: now.timeZoneOffset.inMinutes,
        ),
        'question': text,
      },
    );
  }

  Future<AiAssistantResponse> dailySummary({
    required ChildProfile child,
    required List<CareEvent> events,
    required DateTime now,
    required Locale locale,
  }) {
    return _call(
      mode: AiAssistantMode.dailySummary,
      childId: child.id,
      payload: AiContextBuilder.dailySummary(
        child: child,
        events: events,
        now: now,
        locale: _localeTag(locale),
        timezoneOffsetMinutes: now.timeZoneOffset.inMinutes,
      ),
    );
  }

  Future<AiAssistantResponse> doctorSummary({
    required ChildProfile child,
    required List<CareEvent> events,
    required List<DoctorQuestion> questions,
    required List<Vaccination> vaccinations,
    required DateTime now,
    required Locale locale,
  }) {
    return _call(
      mode: AiAssistantMode.doctorSummary,
      childId: child.id,
      payload: AiContextBuilder.doctorSummary(
        child: child,
        events: events,
        questions: questions,
        vaccinations: vaccinations,
        now: now,
        locale: _localeTag(locale),
        timezoneOffsetMinutes: now.timeZoneOffset.inMinutes,
      ),
    );
  }

  Future<AiAssistantResponse> parseCareEvent({
    required ChildProfile child,
    required String text,
    required DateTime now,
    required Locale locale,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw const LocalValidationException(
        'اكتبي النص الذي تريدين تسجيله أولًا.',
      );
    }
    if (containsEmergencyKeyword(trimmed)) {
      throw const EmergencyDetectedException();
    }
    return _call(
      mode: AiAssistantMode.parseCareEvent,
      childId: child.id,
      payload: AiContextBuilder.parseEvent(
        child: child,
        text: trimmed,
        now: now,
        locale: _localeTag(locale),
        timezoneOffsetMinutes: now.timeZoneOffset.inMinutes,
      ),
    );
  }

  Future<AiAssistantResponse> _call({
    required AiAssistantMode mode,
    required String childId,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _transport.invoke(
        functionId: functionId,
        body: {'mode': mode.value, 'child_id': childId, 'payload': payload},
        timeout: aiAssistantTimeout,
      );
      final parsed = AiAssistantResponse.fromJson(response);
      if (mode == AiAssistantMode.parseCareEvent &&
          parsed.actions.isEmpty &&
          parsed.message.trim().isEmpty) {
        throw const InvalidAiResponseException(
          'لم أتمكن من فهم تسجيل كامل. يمكنكِ تعديله يدويًا.',
        );
      }
      return parsed;
    } on AppException {
      rethrow;
    } on SocketException {
      throw const NoInternetException();
    } on TimeoutException {
      throw const RequestTimeoutException();
    } on FormatException {
      throw const InvalidAiResponseException();
    } catch (error) {
      throw mapAiAssistantError(error);
    }
  }

  static AppException mapAiAssistantError(Object error) {
    if (error is AppException) return error;
    final text = error.toString().toLowerCase();
    final code = _statusCode(text);
    if (code == 401) return const InvalidSessionException();
    if (code == 403) return const UnauthorizedChildException();
    if (code == 429) {
      if (text.contains('day') || text.contains('24')) {
        return const RateLimitException(
          'وصلتِ للحد اليومي للمساعد. حاولي غدًا.',
        );
      }
      return const RateLimitException('حاولي مرة أخرى بعد دقيقة.');
    }
    if (text.contains('no internet') ||
        text.contains('network') ||
        text.contains('socket') ||
        text.contains('failed host lookup')) {
      return const NoInternetException();
    }
    if (text.contains('timeout') || text.contains('timed out')) {
      return const RequestTimeoutException();
    }
    if (text.contains('json') ||
        text.contains('malformed') ||
        text.contains('parse') ||
        text.contains('format')) {
      return const InvalidAiResponseException();
    }
    if (text.contains('rate limit')) {
      return const RateLimitException();
    }
    if (text.contains('gemini') ||
        text.contains('function') ||
        text.contains('upstream') ||
        text.contains('unavailable') ||
        text.contains('fetch')) {
      return const AiUnavailableException();
    }
    return const AiUnavailableException();
  }

  static bool containsEmergencyKeyword(String text) {
    final normalized = text.toLowerCase();
    const keywords = <String>[
      'مش بيتنفس',
      'لا يتنفس',
      'صعوبة تنفس',
      'ازرقاق',
      'شفايفه زرقاء',
      'شفايفها زرقاء',
      'تشنج',
      'فاقد الوعي',
      'مش بيستجيب',
      'نزيف شديد',
    ];
    return keywords.any(normalized.contains);
  }

  static int? _statusCode(String text) {
    final match = RegExp(r'\b(4\d{2}|5\d{2})\b').firstMatch(text);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  static String _localeTag(Locale locale) =>
      locale.countryCode == null || locale.countryCode!.isEmpty
      ? locale.languageCode
      : '${locale.languageCode}-${locale.countryCode}';
}

Map<String, dynamic> _normalizeResponse(Object? data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  if (data is String) {
    final decoded = jsonDecode(data);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  }
  throw const InvalidAiResponseException();
}
