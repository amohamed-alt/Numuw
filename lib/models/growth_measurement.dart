import 'map_reader.dart';

class GrowthMeasurement {
  const GrowthMeasurement({
    required this.id,
    required this.childId,
    required this.createdBy,
    required this.measuredAt,
    this.weightKg,
    this.heightCm,
    this.headCircumferenceCm,
    this.source,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String childId;
  final String createdBy;
  final DateTime measuredAt;
  final double? weightKg;
  final double? heightCm;
  final double? headCircumferenceCm;
  final String? source;
  final String? notes;
  final DateTime? createdAt;

  factory GrowthMeasurement.fromMap(Map<String, dynamic> map) =>
      GrowthMeasurement(
        id: map['id'] as String,
        childId: map['child_id'] as String,
        createdBy: map['created_by'] as String,
        measuredAt: MapReader.date(map['measured_at']) ?? DateTime.now(),
        weightKg: MapReader.doubleValue(map['weight_kg']),
        heightCm: MapReader.doubleValue(map['height_cm']),
        headCircumferenceCm: MapReader.doubleValue(
          map['head_circumference_cm'],
        ),
        source: map['source'] as String?,
        notes: map['notes'] as String?,
        createdAt: MapReader.date(map['created_at']),
      );

  Map<String, dynamic> toMap() => {
    'id': id,
    'child_id': childId,
    'created_by': createdBy,
    'measured_at': measuredAt.toUtc().toIso8601String(),
    'weight_kg': weightKg,
    'height_cm': heightCm,
    'head_circumference_cm': headCircumferenceCm,
    'source': source,
    'notes': notes,
    'created_at': createdAt?.toUtc().toIso8601String(),
  };
}
