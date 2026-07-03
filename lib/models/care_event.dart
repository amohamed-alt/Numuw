import 'map_reader.dart';

class CareEvent {
  const CareEvent({
    required this.id,
    required this.childId,
    required this.createdBy,
    required this.eventType,
    required this.startedAt,
    this.endedAt,
    this.side,
    this.feedingMethod,
    this.amountMl,
    this.diaperWet,
    this.diaperDirty,
    this.temperatureC,
    this.medicineName,
    this.medicineDose,
    this.burped,
    this.vomited,
    this.notes,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String childId;
  final String createdBy;
  final String eventType;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? side;
  final String? feedingMethod;
  final double? amountMl;
  final bool? diaperWet;
  final bool? diaperDirty;
  final double? temperatureC;
  final String? medicineName;
  final String? medicineDose;
  final bool? burped;
  final bool? vomited;
  final String? notes;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CareEvent.fromMap(Map<String, dynamic> map) => CareEvent(
    id: map['id'] as String,
    childId: map['child_id'] as String,
    createdBy: map['created_by'] as String,
    eventType: map['event_type'] as String,
    startedAt: MapReader.date(map['started_at']) ?? DateTime.now(),
    endedAt: MapReader.date(map['ended_at']),
    side: map['side'] as String?,
    feedingMethod: map['feeding_method'] as String?,
    amountMl: MapReader.doubleValue(map['amount_ml']),
    diaperWet: MapReader.boolValue(map['diaper_wet']),
    diaperDirty: MapReader.boolValue(map['diaper_dirty']),
    temperatureC: MapReader.doubleValue(map['temperature_c']),
    medicineName: map['medicine_name'] as String?,
    medicineDose: map['medicine_dose'] as String?,
    burped: MapReader.boolValue(map['burped']),
    vomited: MapReader.boolValue(map['vomited']),
    notes: map['notes'] as String?,
    metadata: Map<String, dynamic>.from(map['metadata'] ?? <String, dynamic>{}),
    createdAt: MapReader.date(map['created_at']),
    updatedAt: MapReader.date(map['updated_at']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'child_id': childId,
    'created_by': createdBy,
    'event_type': eventType,
    'started_at': startedAt.toUtc().toIso8601String(),
    'ended_at': endedAt?.toUtc().toIso8601String(),
    'side': side,
    'feeding_method': feedingMethod,
    'amount_ml': amountMl,
    'diaper_wet': diaperWet,
    'diaper_dirty': diaperDirty,
    'temperature_c': temperatureC,
    'medicine_name': medicineName,
    'medicine_dose': medicineDose,
    'burped': burped,
    'vomited': vomited,
    'notes': notes,
    'metadata': metadata ?? <String, dynamic>{},
    'created_at': createdAt?.toUtc().toIso8601String(),
    'updated_at': updatedAt?.toUtc().toIso8601String(),
  };

  bool get isPumping {
    if (eventType == 'pumping') return true;
    if (eventType != 'feeding') return false;
    if ((amountMl ?? 0) <= 0) return false;
    final methods = metadata?['feeding_methods'];
    if (methods is List) {
      return methods.any((item) => item.toString() == 'pumping');
    }
    return false;
  }

  double? get pumpedAmountMl {
    if (!isPumping) return null;
    final value = amountMl;
    return value != null && value > 0 ? value : null;
  }

  double? get leftPumpedAmountMl =>
      _metadataDouble('left_amount_ml') ?? _metadataDouble('left_pumped_ml');

  double? get rightPumpedAmountMl =>
      _metadataDouble('right_amount_ml') ?? _metadataDouble('right_pumped_ml');

  bool get hasSplitPumpingQuantity =>
      metadata?['quantity_mode'] == 'split' ||
      leftPumpedAmountMl != null ||
      rightPumpedAmountMl != null;

  Duration? get duration {
    final end = endedAt;
    if (end == null) return null;
    final value = end.difference(startedAt);
    return value.isNegative ? null : value;
  }

  double? _metadataDouble(String key) {
    final value = metadata?[key];
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String)
      return double.tryParse(value.trim().replaceAll(',', '.'));
    return null;
  }
}
