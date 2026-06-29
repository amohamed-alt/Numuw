import 'map_reader.dart';

class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.createdBy,
    required this.name,
    required this.stage,
    this.birthDate,
    this.dueDate,
    required this.gender,
    required this.feedingType,
    this.bloodType,
    this.birthWeightKg,
    this.photoPath,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String createdBy;
  final String name;
  final String stage;
  final DateTime? birthDate;
  final DateTime? dueDate;
  final String gender;
  final String feedingType;
  final String? bloodType;
  final double? birthWeightKg;
  final String? photoPath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isBorn => stage == 'born';

  factory ChildProfile.fromMap(Map<String, dynamic> map) => ChildProfile(
    id: map['id'] as String,
    createdBy: map['created_by'] as String,
    name: map['name'] as String? ?? '',
    stage: map['stage'] as String? ?? 'born',
    birthDate: MapReader.date(map['birth_date']),
    dueDate: MapReader.date(map['due_date']),
    gender: map['gender'] as String? ?? 'unspecified',
    feedingType: map['feeding_type'] as String? ?? 'not_set',
    bloodType: map['blood_type'] as String?,
    birthWeightKg: MapReader.doubleValue(map['birth_weight_kg']),
    photoPath: map['photo_path'] as String?,
    createdAt: MapReader.date(map['created_at']),
    updatedAt: MapReader.date(map['updated_at']),
  );

  factory ChildProfile.fromJson(Map<String, dynamic> map) =>
      ChildProfile.fromMap(map);

  Map<String, dynamic> toMap() => {
    'id': id,
    'created_by': createdBy,
    'name': name,
    'stage': stage,
    'birth_date': _dateOnly(birthDate),
    'due_date': _dateOnly(dueDate),
    'gender': gender,
    'feeding_type': feedingType,
    'blood_type': bloodType,
    'birth_weight_kg': birthWeightKg,
    'photo_path': photoPath,
    'created_at': createdAt?.toUtc().toIso8601String(),
    'updated_at': updatedAt?.toUtc().toIso8601String(),
  };

  ChildProfile copyWith({
    String? name,
    String? stage,
    DateTime? birthDate,
    DateTime? dueDate,
    String? gender,
    String? feedingType,
    String? bloodType,
    double? birthWeightKg,
  }) => ChildProfile(
    id: id,
    createdBy: createdBy,
    name: name ?? this.name,
    stage: stage ?? this.stage,
    birthDate: birthDate ?? this.birthDate,
    dueDate: dueDate ?? this.dueDate,
    gender: gender ?? this.gender,
    feedingType: feedingType ?? this.feedingType,
    bloodType: bloodType ?? this.bloodType,
    birthWeightKg: birthWeightKg ?? this.birthWeightKg,
    photoPath: photoPath,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static String? _dateOnly(DateTime? value) {
    if (value == null) return null;
    return '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }
}
