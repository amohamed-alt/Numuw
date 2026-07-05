import 'dart:convert';

enum AiAssistantMode {
  chat('chat'),
  dailySummary('daily_summary'),
  doctorSummary('doctor_summary'),
  parseCareEvent('parse_care_event');

  const AiAssistantMode(this.value);
  final String value;

  static AiAssistantMode? fromValue(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    for (final mode in AiAssistantMode.values) {
      if (mode.value == text) return mode;
    }
    return null;
  }
}

class AiSummarySection {
  const AiSummarySection({required this.title, required this.items});

  final String title;
  final List<String> items;

  factory AiSummarySection.fromJson(Map<String, dynamic> map) =>
      AiSummarySection(
        title: _string(map['title']) ?? _string(map['name']) ?? '',
        items: _stringList(map['items'] ?? map['lines'] ?? map['values']),
      );

  factory AiAssistantResponse.fromJsonString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('Assistant response must be a JSON object.');
    }
    return AiAssistantResponse.fromJson(Map<String, dynamic>.from(decoded));
  }

  Map<String, dynamic> toJson() => {'title': title, 'items': items};
}

class AiCareEventDraft {
  const AiCareEventDraft({
    required this.eventType,
    required this.startedAt,
    this.endedAt,
    this.feedingMethods = const [],
    this.side,
    this.amountMl,
    this.diaperWet,
    this.diaperDirty,
    this.temperatureC,
    this.medicineName,
    this.medicineDose,
    this.foodName,
    this.pumpingLeftAmountMl,
    this.pumpingRightAmountMl,
    this.burped,
    this.vomited,
    this.notes,
    this.confidence,
    this.needsReview = true,
    this.timeNeedsReview = false,
    this.dateNeedsReview = false,
    this.raw = const <String, dynamic>{},
  });

  final String eventType;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final List<String> feedingMethods;
  final String? side;
  final double? amountMl;
  final bool? diaperWet;
  final bool? diaperDirty;
  final double? temperatureC;
  final String? medicineName;
  final String? medicineDose;
  final String? foodName;
  final double? pumpingLeftAmountMl;
  final double? pumpingRightAmountMl;
  final bool? burped;
  final bool? vomited;
  final String? notes;
  final double? confidence;
  final bool needsReview;
  final bool timeNeedsReview;
  final bool dateNeedsReview;
  final Map<String, dynamic> raw;

  bool get isComplete => switch (eventType) {
    'feeding' => amountMl != null || feedingMethods.isNotEmpty,
    'sleep' => startedAt != null,
    'diaper' => diaperWet != null || diaperDirty != null,
    'food' => foodName != null || notes != null,
    'medicine' => medicineName != null,
    'temperature' => temperatureC != null,
    'note' => notes != null,
    'pumping' =>
      amountMl != null ||
          pumpingLeftAmountMl != null ||
          pumpingRightAmountMl != null,
    _ => false,
  };

  bool get hasAmbiguousTime => timeNeedsReview || dateNeedsReview;

  AiCareEventDraft copyWith({
    String? eventType,
    DateTime? startedAt,
    bool clearStartedAt = false,
    DateTime? endedAt,
    bool clearEndedAt = false,
    List<String>? feedingMethods,
    String? side,
    bool clearSide = false,
    double? amountMl,
    bool clearAmountMl = false,
    bool? diaperWet,
    bool clearDiaperWet = false,
    bool? diaperDirty,
    bool clearDiaperDirty = false,
    double? temperatureC,
    bool clearTemperatureC = false,
    String? medicineName,
    bool clearMedicineName = false,
    String? medicineDose,
    bool clearMedicineDose = false,
    String? foodName,
    bool clearFoodName = false,
    double? pumpingLeftAmountMl,
    bool clearPumpingLeftAmountMl = false,
    double? pumpingRightAmountMl,
    bool clearPumpingRightAmountMl = false,
    bool? burped,
    bool clearBurped = false,
    bool? vomited,
    bool clearVomited = false,
    String? notes,
    bool clearNotes = false,
    double? confidence,
    bool? needsReview,
    bool? timeNeedsReview,
    bool? dateNeedsReview,
  }) => AiCareEventDraft(
    eventType: eventType ?? this.eventType,
    startedAt: clearStartedAt ? null : startedAt ?? this.startedAt,
    endedAt: clearEndedAt ? null : endedAt ?? this.endedAt,
    feedingMethods: feedingMethods ?? this.feedingMethods,
    side: clearSide ? null : side ?? this.side,
    amountMl: clearAmountMl ? null : amountMl ?? this.amountMl,
    diaperWet: clearDiaperWet ? null : diaperWet ?? this.diaperWet,
    diaperDirty: clearDiaperDirty ? null : diaperDirty ?? this.diaperDirty,
    temperatureC: clearTemperatureC ? null : temperatureC ?? this.temperatureC,
    medicineName: clearMedicineName ? null : medicineName ?? this.medicineName,
    medicineDose: clearMedicineDose ? null : medicineDose ?? this.medicineDose,
    foodName: clearFoodName ? null : foodName ?? this.foodName,
    pumpingLeftAmountMl: clearPumpingLeftAmountMl
        ? null
        : pumpingLeftAmountMl ?? this.pumpingLeftAmountMl,
    pumpingRightAmountMl: clearPumpingRightAmountMl
        ? null
        : pumpingRightAmountMl ?? this.pumpingRightAmountMl,
    burped: clearBurped ? null : burped ?? this.burped,
    vomited: clearVomited ? null : vomited ?? this.vomited,
    notes: clearNotes ? null : notes ?? this.notes,
    confidence: confidence ?? this.confidence,
    needsReview: needsReview ?? this.needsReview,
    timeNeedsReview: timeNeedsReview ?? this.timeNeedsReview,
    dateNeedsReview: dateNeedsReview ?? this.dateNeedsReview,
    raw: raw,
  );

  factory AiCareEventDraft.fromJson(Map<String, dynamic> map) {
    final eventType = _normalizeEventType(
      map['event_type'] ?? map['eventType'],
    );
    if (eventType == null) {
      throw const FormatException('Unsupported or missing event type.');
    }

    final startedAt = _dateTimeFromAny(
      map['started_at'] ?? map['startedAt'] ?? map['time'],
    );
    final endAt = _dateTimeFromAny(map['ended_at'] ?? map['endedAt']);
    final feedingMethods = _normalizeMethods(
      map['feeding_methods'] ?? map['feedingMethods'] ?? map['feeding_method'],
    );
    final side = _normalizeSide(map['side']);
    final amountMl = _double(map['amount_ml'] ?? map['amountMl']);
    final diaperWet = _bool(map['diaper_wet'] ?? map['diaperWet']);
    final diaperDirty = _bool(map['diaper_dirty'] ?? map['diaperDirty']);
    final temperatureC = _double(map['temperature_c'] ?? map['temperatureC']);
    final medicineName = _string(map['medicine_name'] ?? map['medicineName']);
    final medicineDose = _string(map['medicine_dose'] ?? map['medicineDose']);
    final foodName = _string(map['food_name'] ?? map['foodName']);
    final left = _double(
      map['left_amount_ml'] ??
          map['leftAmountMl'] ??
          map['left_pumped_ml'] ??
          map['leftPumpedAmountMl'],
    );
    final right = _double(
      map['right_amount_ml'] ??
          map['rightAmountMl'] ??
          map['right_pumped_ml'] ??
          map['rightPumpedAmountMl'],
    );
    final burped = _bool(map['burped']);
    final vomited = _bool(map['vomited']);
    final notes = _string(map['notes']);
    final confidence = _double(map['confidence']);
    final needsReview =
        _bool(map['needs_review'] ?? map['needsReview']) ?? true;
    final timeNeedsReview =
        _bool(map['time_needs_review'] ?? map['timeNeedsReview']) ?? false;
    final dateNeedsReview =
        _bool(map['date_needs_review'] ?? map['dateNeedsReview']) ?? false;

    return AiCareEventDraft(
      eventType: eventType,
      startedAt: startedAt,
      endedAt: endAt,
      feedingMethods: feedingMethods,
      side: side,
      amountMl: amountMl ?? _combinedAmount(left, right),
      diaperWet: diaperWet,
      diaperDirty: diaperDirty,
      temperatureC: temperatureC,
      medicineName: medicineName,
      medicineDose: medicineDose,
      foodName: foodName,
      pumpingLeftAmountMl: left,
      pumpingRightAmountMl: right,
      burped: burped,
      vomited: vomited,
      notes: notes,
      confidence: confidence,
      needsReview: needsReview,
      timeNeedsReview: timeNeedsReview,
      dateNeedsReview: dateNeedsReview,
      raw: Map<String, dynamic>.from(map),
    );
  }

  Map<String, dynamic> toJson() => {
    'event_type': eventType,
    'started_at': startedAt?.toUtc().toIso8601String(),
    'ended_at': endedAt?.toUtc().toIso8601String(),
    'feeding_methods': feedingMethods,
    'side': side,
    'amount_ml': amountMl,
    'diaper_wet': diaperWet,
    'diaper_dirty': diaperDirty,
    'temperature_c': temperatureC,
    'medicine_name': medicineName,
    'medicine_dose': medicineDose,
    'food_name': foodName,
    'left_amount_ml': pumpingLeftAmountMl,
    'right_amount_ml': pumpingRightAmountMl,
    'burped': burped,
    'vomited': vomited,
    'notes': notes,
    'confidence': confidence,
    'needs_review': needsReview,
    'time_needs_review': timeNeedsReview,
    'date_needs_review': dateNeedsReview,
  };

  Map<String, dynamic> toSaveArguments() {
    final metadata = <String, dynamic>{
      if (foodName != null) 'food_name': foodName,
      if (pumpingLeftAmountMl != null) 'left_amount_ml': pumpingLeftAmountMl,
      if (pumpingRightAmountMl != null) 'right_amount_ml': pumpingRightAmountMl,
      if (eventType == 'pumping' &&
          (pumpingLeftAmountMl != null || pumpingRightAmountMl != null))
        'quantity_mode': 'split',
      if (eventType == 'feeding' && feedingMethods.isNotEmpty)
        'feeding_methods': feedingMethods,
      if (burped != null) 'burped': burped,
      if (vomited != null) 'vomited': vomited,
    };
    return {
      'eventType': eventType,
      'startedAt': startedAt ?? DateTime.now(),
      'endedAt': endedAt,
      'side': side,
      'feedingMethod': feedingMethods.isEmpty ? null : feedingMethods.first,
      'amountMl': amountMl,
      'diaperWet': diaperWet,
      'diaperDirty': diaperDirty,
      'temperatureC': temperatureC,
      'medicineName': medicineName,
      'medicineDose': medicineDose,
      'burped': burped,
      'vomited': vomited,
      'notes': notes,
      'metadata': metadata.isEmpty ? <String, dynamic>{} : metadata,
    };
  }

  static double? _combinedAmount(double? left, double? right) {
    if (left == null && right == null) return null;
    return (left ?? 0) + (right ?? 0);
  }
}

class AiAssistantResponse {
  const AiAssistantResponse({
    required this.message,
    this.requiresConfirmation = false,
    this.sections = const [],
    this.actions = const [],
    this.disclaimer,
    this.raw = const <String, dynamic>{},
  });

  final String message;
  final bool requiresConfirmation;
  final List<AiSummarySection> sections;
  final List<AiCareEventDraft> actions;
  final String? disclaimer;
  final Map<String, dynamic> raw;

  bool get hasActions => actions.isNotEmpty;

  factory AiAssistantResponse.fromJson(Map<String, dynamic> map) {
    final sections =
        (map['sections'] is List ? map['sections'] as List : const [])
            .whereType<Map>()
            .map(
              (item) =>
                  AiSummarySection.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(growable: false);
    final actions = (map['actions'] is List ? map['actions'] as List : const [])
        .whereType<Map>()
        .map(
          (item) => AiCareEventDraft.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
    return AiAssistantResponse(
      message: _string(map['message'] ?? map['reply'] ?? map['summary']) ?? '',
      requiresConfirmation:
          _bool(map['requires_confirmation'] ?? map['requiresConfirmation']) ??
          actions.isNotEmpty,
      sections: sections,
      actions: actions,
      disclaimer: _string(map['disclaimer']),
      raw: Map<String, dynamic>.from(map),
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'requires_confirmation': requiresConfirmation,
    'sections': sections.map((section) => section.toJson()).toList(),
    'actions': actions.map((action) => action.toJson()).toList(),
    'disclaimer': disclaimer,
  };

  String encode() => jsonEncode(toJson());
}

String? _string(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];
  return value.map(_string).whereType<String>().toList(growable: false);
}

bool? _bool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().trim().toLowerCase();
  if (text == 'true' || text == '1' || text == 'yes') return true;
  if (text == 'false' || text == '0' || text == 'no') return false;
  return null;
}

double? _double(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

DateTime? _dateTimeFromAny(Object? value) {
  final text = _string(value);
  if (text == null) return null;
  return DateTime.tryParse(text)?.toLocal();
}

String? _normalizeEventType(Object? value) {
  final text = _string(value)?.toLowerCase();
  const allowed = <String>{
    'feeding',
    'sleep',
    'diaper',
    'food',
    'medicine',
    'temperature',
    'note',
    'pumping',
  };
  return allowed.contains(text) ? text : null;
}

List<String> _normalizeMethods(Object? value) {
  final values = value is List ? value : [value];
  const allowed = <String>{'breast', 'formula', 'mixed', 'bottle'};
  return values
      .map(_string)
      .whereType<String>()
      .map((item) => item.toLowerCase())
      .where(allowed.contains)
      .toSet()
      .toList(growable: false);
}

String? _normalizeSide(Object? value) {
  final text = _string(value)?.toLowerCase();
  return text == 'left' || text == 'right' ? text : null;
}
