import 'map_reader.dart';

class Vaccination {
  const Vaccination({
    required this.id,
    required this.childId,
    required this.createdBy,
    required this.name,
    this.doseLabel,
    this.scheduledDate,
    this.administeredDate,
    this.provider,
    required this.status,
    this.cardImagePath,
    this.sourceName,
    this.sourceUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String childId;
  final String createdBy;
  final String name;
  final String? doseLabel;
  final DateTime? scheduledDate;
  final DateTime? administeredDate;
  final String? provider;
  final String status;
  final String? cardImagePath;
  final String? sourceName;
  final String? sourceUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Vaccination.fromMap(Map<String, dynamic> map) => Vaccination(
    id: map['id'] as String,
    childId: map['child_id'] as String,
    createdBy: map['created_by'] as String,
    name: map['name'] as String? ?? '',
    doseLabel: map['dose_label'] as String?,
    scheduledDate: MapReader.date(map['scheduled_date']),
    administeredDate: MapReader.date(map['administered_date']),
    provider: map['provider'] as String?,
    status: map['status'] as String? ?? 'scheduled',
    cardImagePath: map['card_image_path'] as String?,
    sourceName: map['source_name'] as String?,
    sourceUrl: map['source_url'] as String?,
    createdAt: MapReader.date(map['created_at']),
    updatedAt: MapReader.date(map['updated_at']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'child_id': childId,
    'created_by': createdBy,
    'name': name,
    'dose_label': doseLabel,
    'scheduled_date': _dateOnly(scheduledDate),
    'administered_date': _dateOnly(administeredDate),
    'provider': provider,
    'status': status,
    'card_image_path': cardImagePath,
    'source_name': sourceName,
    'source_url': sourceUrl,
    'created_at': createdAt?.toUtc().toIso8601String(),
    'updated_at': updatedAt?.toUtc().toIso8601String(),
  };

  static String? _dateOnly(DateTime? value) {
    if (value == null) return null;
    return '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }
}
