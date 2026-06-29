import 'map_reader.dart';

class FamilyTask {
  const FamilyTask({
    required this.id,
    required this.childId,
    required this.createdBy,
    this.assignedTo,
    required this.title,
    this.category,
    this.dueAt,
    this.completedAt,
    required this.visibility,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String childId;
  final String createdBy;
  final String? assignedTo;
  final String title;
  final String? category;
  final DateTime? dueAt;
  final DateTime? completedAt;
  final String visibility;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isCompleted => completedAt != null;

  factory FamilyTask.fromMap(Map<String, dynamic> map) => FamilyTask(
    id: map['id'] as String,
    childId: map['child_id'] as String,
    createdBy: map['created_by'] as String,
    assignedTo: map['assigned_to'] as String?,
    title: map['title'] as String? ?? '',
    category: map['category'] as String?,
    dueAt: MapReader.date(map['due_at']),
    completedAt: MapReader.date(map['completed_at']),
    visibility: map['visibility'] as String? ?? 'family',
    createdAt: MapReader.date(map['created_at']),
    updatedAt: MapReader.date(map['updated_at']),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'child_id': childId,
    'created_by': createdBy,
    'assigned_to': assignedTo,
    'title': title,
    'category': category,
    'due_at': dueAt?.toUtc().toIso8601String(),
    'completed_at': completedAt?.toUtc().toIso8601String(),
    'visibility': visibility,
    'created_at': createdAt?.toUtc().toIso8601String(),
    'updated_at': updatedAt?.toUtc().toIso8601String(),
  };
}
