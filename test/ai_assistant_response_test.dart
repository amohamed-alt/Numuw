import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/models/ai_assistant_response.dart';

void main() {
  test('parse daily summary response', () {
    final response = AiAssistantResponse.fromJsonString('''
      {
        "message": "ملخص اليوم جاهز",
        "requires_confirmation": false,
        "sections": [
          {"title": "الرضاعة", "items": ["3 مرات", "120 مل"]},
          {"title": "النوم", "items": ["4 ساعات"]}
        ],
        "disclaimer": "هذا ملخص للسجلات وليس تقييمًا طبيًا."
      }
    ''');

    expect(response.message, 'ملخص اليوم جاهز');
    expect(response.requiresConfirmation, isFalse);
    expect(response.sections, hasLength(2));
    expect(response.disclaimer, isNotNull);
  });

  test('parse doctor summary response', () {
    final response = AiAssistantResponse.fromJsonString('''
      {
        "message": "تقرير الطبيب جاهز",
        "requires_confirmation": false,
        "sections": [
          {"title": "البيانات المسجلة", "items": ["7 أيام"]},
          {"title": "أسئلة للطبيب", "items": ["سؤال 1"]}
        ],
        "disclaimer": "هذا التقرير مبني على سجلات الأسرة ولا يمثل تشخيصًا طبيًا."
      }
    ''');

    expect(response.sections.first.title, 'البيانات المسجلة');
    expect(response.sections.last.items, contains('سؤال 1'));
  });

  test('parse one care event', () {
    final response = AiAssistantResponse.fromJsonString('''
      {
        "message": "تم فهم تسجيل واحد",
        "requires_confirmation": true,
        "actions": [
          {
            "event_type": "feeding",
            "started_at": "2026-07-03T15:30:00+02:00",
            "feeding_methods": ["formula"],
            "amount_ml": 75,
            "needs_review": true,
            "time_needs_review": false,
            "date_needs_review": false
          }
        ]
      }
    ''');

    expect(response.actions, hasLength(1));
    expect(response.actions.single.eventType, 'feeding');
    expect(response.actions.single.amountMl, 75);
    expect(response.actions.single.feedingMethods, ['formula']);
  });

  test('parse multiple care events', () {
    final response = AiAssistantResponse.fromJsonString('''
      {
        "message": "تم فهم تسجيلين",
        "requires_confirmation": true,
        "actions": [
          {
            "event_type": "feeding",
            "started_at": "2026-07-03T15:30:00+02:00",
            "feeding_methods": ["formula"],
            "amount_ml": 75,
            "needs_review": true
          },
          {
            "event_type": "diaper",
            "started_at": "2026-07-03T15:31:00+02:00",
            "diaper_wet": true,
            "diaper_dirty": false,
            "needs_review": true
          }
        ]
      }
    ''');

    expect(response.actions, hasLength(2));
    expect(response.actions[1].eventType, 'diaper');
    expect(response.actions[1].diaperWet, isTrue);
  });

  test('reject unsupported event type', () {
    expect(
      () => AiAssistantResponse.fromJsonString('''
        {
          "message": "x",
          "requires_confirmation": true,
          "actions": [
            {"event_type": "unsupported", "needs_review": true}
          ]
        }
      '''),
      throwsFormatException,
    );
  });

  test('handle missing optional fields', () {
    final response = AiAssistantResponse.fromJsonString('''
      {
        "message": "بدون حقول إضافية",
        "requires_confirmation": true,
        "actions": [
          {
            "event_type": "medicine",
            "needs_review": true
          }
        ]
      }
    ''');

    expect(response.actions.single.medicineName, isNull);
    expect(response.actions.single.needsReview, isTrue);
  });

  test('handle invalid JSON safely', () {
    expect(
      () => AiAssistantResponse.fromJsonString('{'),
      throwsFormatException,
    );
  });

  test('feeding methods mapping', () {
    final response = AiAssistantResponse.fromJsonString('''
      {
        "message": "طرق الرضاعة",
        "requires_confirmation": true,
        "actions": [
          {
            "event_type": "feeding",
            "feeding_methods": ["formula", "breast"],
            "needs_review": true
          }
        ]
      }
    ''');

    expect(
      response.actions.single.feedingMethods,
      containsAll(['formula', 'breast']),
    );
  });

  test('feeding follow-up fields survive parsing and save mapping', () {
    final response = AiAssistantResponse.fromJsonString('''
      {
        "message": "تم فهم الرضاعة",
        "requires_confirmation": true,
        "actions": [
          {
            "event_type": "feeding",
            "started_at": "2026-07-03T15:30:00+02:00",
            "feeding_methods": ["formula"],
            "amount_ml": 75,
            "burped": true,
            "vomited": false,
            "needs_review": true
          }
        ]
      }
    ''');

    final draft = response.actions.single;
    expect(draft.burped, isTrue);
    expect(draft.vomited, isFalse);
    expect(draft.toSaveArguments()['burped'], isTrue);
    expect(draft.toSaveArguments()['vomited'], isFalse);
  });

  test('pumping left/right quantity calculation', () {
    final response = AiAssistantResponse.fromJsonString('''
      {
        "message": "شفط",
        "requires_confirmation": true,
        "actions": [
          {
            "event_type": "pumping",
            "left_amount_ml": 35,
            "right_amount_ml": 40,
            "amount_ml": 75,
            "needs_review": true
          }
        ]
      }
    ''');

    final draft = response.actions.single;
    expect(draft.pumpingLeftAmountMl, 35);
    expect(draft.pumpingRightAmountMl, 40);
    expect(draft.amountMl, 75);
  });

  test('diaper wet dirty mapping', () {
    final response = AiAssistantResponse.fromJsonString('''
      {
        "message": "حفاضة",
        "requires_confirmation": true,
        "actions": [
          {
            "event_type": "diaper",
            "diaper_wet": true,
            "diaper_dirty": false,
            "needs_review": true
          }
        ]
      }
    ''');

    final draft = response.actions.single;
    expect(draft.diaperWet, isTrue);
    expect(draft.diaperDirty, isFalse);
  });

  test('ambiguous time remains reviewable', () {
    final response = AiAssistantResponse.fromJsonString('''
      {
        "message": "وقت يحتاج مراجعة",
        "requires_confirmation": true,
        "actions": [
          {
            "event_type": "feeding",
            "started_at": "2026-07-03T15:00:00+02:00",
            "feeding_methods": ["formula"],
            "amount_ml": 75,
            "needs_review": true,
            "time_needs_review": true
          }
        ]
      }
    ''');

    final draft = response.actions.single;
    expect(draft.hasAmbiguousTime, isTrue);
    expect(draft.timeNeedsReview, isTrue);
  });
}
