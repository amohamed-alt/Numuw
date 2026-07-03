// ignore_for_file: prefer_initializing_formals

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/errors/app_error.dart';
import '../models/family_task.dart';
import 'repo_utils.dart';

class FamilyTaskRepository {
  FamilyTaskRepository({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;
  SupabaseClient get _supabase => _client ?? Supabase.instance.client;
  static const columns =
      'id,child_id,created_by,assigned_to,title,category,due_at,completed_at,visibility,created_at,updated_at';

  Future<List<FamilyTask>> fetch(String childId) async {
    final rows = await withRepositoryTimeout(
      _supabase
          .from('family_tasks')
          .select(columns)
          .eq('child_id', childId)
          .order('created_at', ascending: false),
    );
    return _mapRows(rows);
  }

  Future<List<FamilyTask>> incomplete(String childId) async {
    final rows = await withRepositoryTimeout(
      _supabase
          .from('family_tasks')
          .select(columns)
          .eq('child_id', childId)
          .filter('completed_at', 'is', null)
          .order('due_at'),
    );
    return _mapRows(rows).take(3).toList(growable: false);
  }

  Future<FamilyTask> add({
    required String childId,
    required String title,
    String? category,
    DateTime? dueAt,
    String? assignedTo,
    String visibility = 'family',
  }) async {
    if (!isValidTaskTitle(title)) {
      throw const AppException('اكتبي عنوان مهمة واضحا.');
    }
    final row = await withRepositoryTimeout(
      _supabase
          .from('family_tasks')
          .insert({
            'child_id': childId,
            'created_by': currentUserId(),
            'assigned_to': blankToNull(assignedTo),
            'title': title.trim(),
            'category': blankToNull(category),
            'due_at': dueAt?.toUtc().toIso8601String(),
            'visibility': visibility,
          })
          .select(columns)
          .single(),
    );
    return FamilyTask.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> setCompleted(String id, bool completed) => withRepositoryTimeout(
    _supabase
        .from('family_tasks')
        .update({
          'completed_at': completed
              ? DateTime.now().toUtc().toIso8601String()
              : null,
        })
        .eq('id', id),
  );

  Future<void> delete(String id) => withRepositoryTimeout(
    _supabase.from('family_tasks').delete().eq('id', id),
  );

  Future<FamilyTask> update({
    required String id,
    required String title,
    String? category,
    DateTime? dueAt,
    String? assignedTo,
    String visibility = 'family',
  }) async {
    if (!isValidTaskTitle(title)) {
      throw const AppException('اكتبي عنوان مهمة واضحا.');
    }
    final row = await withRepositoryTimeout(
      _supabase
          .from('family_tasks')
          .update({
            'assigned_to': blankToNull(assignedTo),
            'title': title.trim(),
            'category': blankToNull(category),
            'due_at': dueAt?.toUtc().toIso8601String(),
            'visibility': visibility,
          })
          .eq('id', id)
          .select(columns)
          .single(),
    );
    return FamilyTask.fromMap(Map<String, dynamic>.from(row));
  }

  List<FamilyTask> _mapRows(Object? rows) => (rows as List)
      .map((row) => FamilyTask.fromMap(Map<String, dynamic>.from(row as Map)))
      .where((task) => isValidTaskTitle(task.title))
      .toList();
}

bool isValidTaskTitle(String? title) {
  final value = title?.trim() ?? '';
  if (value.isEmpty) return false;
  if (value == '.' || value == '..' || value == '...') return false;
  return RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(value);
}
