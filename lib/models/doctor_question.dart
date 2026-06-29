import 'map_reader.dart';

class DoctorQuestion {
  const DoctorQuestion({
    required this.id,
    required this.childId,
    required this.createdBy,
    required this.question,
    this.answeredAt,
    this.createdAt,
  });

  final String id;
  final String childId;
  final String createdBy;
  final String question;
  final DateTime? answeredAt;
  final DateTime? createdAt;

  bool get isAnswered => answeredAt != null;

  factory DoctorQuestion.fromMap(Map<String, dynamic> map) => DoctorQuestion(
    id: map['id'] as String,
    childId: map['child_id'] as String,
    createdBy: map['created_by'] as String,
    question: map['question'] as String? ?? '',
    answeredAt: MapReader.date(map['answered_at']),
    createdAt: MapReader.date(map['created_at']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'child_id': childId,
    'created_by': createdBy,
    'question': question,
    'answered_at': answeredAt?.toUtc().toIso8601String(),
    'created_at': createdAt?.toUtc().toIso8601String(),
  };
}
