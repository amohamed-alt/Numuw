import '../core/formatters/arabic_formatters.dart';
import '../models/care_event.dart';
import '../models/child_profile.dart';
import '../models/doctor_question.dart';
import '../models/vaccination.dart';
import '../repositories/dashboard_repository.dart';

class AiContextBuilder {
  const AiContextBuilder._();

  static Map<String, dynamic> dailySummary({
    required ChildProfile child,
    required List<CareEvent> events,
    required DateTime now,
    required String locale,
    required int timezoneOffsetMinutes,
  }) {
    final dayStart = DashboardRepository.localDayStart(now);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final dailyEvents = events
        .where(
          (event) => event.startedAt.isAfter(
            dayStart.subtract(const Duration(seconds: 1)),
          ),
        )
        .where((event) => event.startedAt.isBefore(dayEnd))
        .toList(growable: false);

    final feeding = dailyEvents
        .where((event) => event.eventType == 'feeding' && !event.isPumping)
        .toList(growable: false);
    final pumping = dailyEvents
        .where((event) => event.isPumping)
        .toList(growable: false);
    final sleepEvents = dailyEvents
        .where((event) => event.eventType == 'sleep')
        .toList(growable: false);
    final diapers = dailyEvents
        .where((event) => event.eventType == 'diaper')
        .toList(growable: false);
    final temperatures = dailyEvents
        .where(
          (event) =>
              event.eventType == 'temperature' && event.temperatureC != null,
        )
        .map((event) => event.temperatureC!.toStringAsFixed(1))
        .toList(growable: false);
    final medicine = dailyEvents
        .where((event) => event.eventType == 'medicine')
        .toList(growable: false);
    return {
      'range': '24h',
      'child': {
        'id': child.id,
        'stage': child.stage,
        'age_days': ArabicFormatters.ageInDays(child),
        'feeding_type': child.feedingType,
      },
      'current_local_datetime': now.toIso8601String(),
      'timezone_offset_minutes': timezoneOffsetMinutes,
      'locale': locale,
      'metrics': {
        'feeding_count': feeding.length,
        'feeding_total_ml': _totalAmount(feeding),
        'sleep_minutes': _sleepMinutes(sleepEvents, now),
        'sleep_sessions': sleepEvents.length,
        'wet_diaper_count': diapers
            .where((event) => event.diaperWet == true)
            .length,
        'dirty_diaper_count': diapers
            .where((event) => event.diaperDirty == true)
            .length,
        'pumping_sessions': pumping.length,
        'pumping_total_ml': _totalAmount(pumping),
        'temperature_readings': temperatures,
        'medicine_count': medicine.length,
      },
      'recent_notes': _recentNotes(dailyEvents),
    };
  }

  static Map<String, dynamic> doctorSummary({
    required ChildProfile child,
    required List<CareEvent> events,
    required List<DoctorQuestion> questions,
    required List<Vaccination> vaccinations,
    required DateTime now,
    required String locale,
    required int timezoneOffsetMinutes,
  }) {
    final start = now.subtract(const Duration(days: 7));
    final scoped = events
        .where((event) => event.startedAt.isAfter(start))
        .toList(growable: false);
    final feeding = scoped
        .where((event) => event.eventType == 'feeding' && !event.isPumping)
        .toList(growable: false);
    final pumping = scoped
        .where((event) => event.isPumping)
        .toList(growable: false);
    final sleepEvents = scoped
        .where((event) => event.eventType == 'sleep')
        .toList(growable: false);
    final diapers = scoped
        .where((event) => event.eventType == 'diaper')
        .toList(growable: false);
    final temperatures = scoped
        .where(
          (event) =>
              event.eventType == 'temperature' && event.temperatureC != null,
        )
        .map((event) => event.temperatureC!.toStringAsFixed(1))
        .toList(growable: false);
    final medicine = scoped
        .where((event) => event.eventType == 'medicine')
        .toList(growable: false);
    return {
      'range': '7d',
      'child': {
        'id': child.id,
        'stage': child.stage,
        'age_days': ArabicFormatters.ageInDays(child),
        'feeding_type': child.feedingType,
      },
      'current_local_datetime': now.toIso8601String(),
      'timezone_offset_minutes': timezoneOffsetMinutes,
      'locale': locale,
      'metrics': {
        'feeding_count': feeding.length,
        'feeding_total_ml': _totalAmount(feeding),
        'pumping_sessions': pumping.length,
        'pumping_total_ml': _totalAmount(pumping),
        'sleep_minutes': _sleepMinutes(sleepEvents, now),
        'sleep_sessions': sleepEvents.length,
        'wet_diaper_count': diapers
            .where((event) => event.diaperWet == true)
            .length,
        'dirty_diaper_count': diapers
            .where((event) => event.diaperDirty == true)
            .length,
        'temperature_readings': temperatures,
        'medicine_count': medicine.length,
      },
      'vaccinations': vaccinations
          .take(8)
          .map((item) => _vaccination(item))
          .toList(growable: false),
      'doctor_questions': questions
          .take(8)
          .map(
            (question) => {
              'question': _trim(question.question, 220),
              'answered': question.isAnswered,
            },
          )
          .toList(growable: false),
      'recent_notes': _recentNotes(scoped),
    };
  }

  static Map<String, dynamic> parseEvent({
    required ChildProfile child,
    required String text,
    required DateTime now,
    required String locale,
    required int timezoneOffsetMinutes,
  }) {
    return {
      'mode': 'parse_care_event',
      'child': {
        'id': child.id,
        'stage': child.stage,
        'age_days': ArabicFormatters.ageInDays(child),
        'feeding_type': child.feedingType,
      },
      'text': _trim(text, 480),
      'current_local_datetime': now.toIso8601String(),
      'timezone_offset_minutes': timezoneOffsetMinutes,
      'locale': locale,
    };
  }

  static double _totalAmount(List<CareEvent> events) {
    return events.fold<double>(0, (sum, event) => sum + (event.amountMl ?? 0));
  }

  static int _sleepMinutes(List<CareEvent> events, DateTime now) {
    var total = Duration.zero;
    for (final event in events) {
      final ended = event.endedAt ?? now;
      final delta = ended.difference(event.startedAt);
      if (delta.isNegative) continue;
      total += delta;
    }
    return total.inMinutes;
  }

  static List<String> _recentNotes(List<CareEvent> events) {
    return events
        .where((event) => event.notes?.trim().isNotEmpty == true)
        .map((event) => _trim(event.notes!.trim(), 160))
        .whereType<String>()
        .take(5)
        .toList(growable: false);
  }

  static Map<String, dynamic> _vaccination(Vaccination item) => {
    'name': _trim(item.name, 80),
    'dose_label': _trim(item.doseLabel, 40),
    'scheduled_date': item.scheduledDate?.toIso8601String(),
    'administered_date': item.administeredDate?.toIso8601String(),
    'status': item.status,
    'provider': _trim(item.provider, 80),
  };

  static String? _trim(String? value, int maxLength) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return null;
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength);
  }
}
