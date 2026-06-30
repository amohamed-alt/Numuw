import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/family_task.dart';
import 'repo_utils.dart';

class FamilyTaskRepository {
  FamilyTaskRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;
  final SupabaseClient _client;
  static const columns =
      'id,child_id,created_by,assigned_to,title,category,due_at,completed_at,visibility,created_at,updated_at';

  Future<List<FamilyTask>> fetch(String childId) async {
    final rows = await _client
        .from('family_tasks')
        .select(columns)
        .eq('child_id', childId)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((row) => FamilyTask.fromMap(Map<String, dynamic>.from(row as Map)))
        .where((task) => _validTitle(task.title))
        .toList();
  }

  Future<List<FamilyTask>> incomplete(String childId) async {
    final rows = await _client
        .from('family_tasks')
        .select(columns)
        .eq('child_id', childId)
        .filter('completed_at', 'is', null)
        .order('due_at');
    return (rows as List)
        .map((row) => FamilyTask.fromMap(Map<String, dynamic>.from(row as Map)))
        .where((task) => _validTitle(task.title))
        .toList();
  }

  Future<FamilyTask> add({
    required String childId,
    required String title,
    String? category,
    DateTime? dueAt,
    String visibility = 'family',
  }) async {
    final row = await _client
        .from('family_tasks')
        .insert({
          'child_id': childId,
          'created_by': currentUserId(),
          'title': title.trim(),
          'category': blankToNull(category),
          'due_at': dueAt?.toUtc().toIso8601String(),
          'visibility': visibility,
        })
        .select(columns)
        .single();
    return FamilyTask.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> setCompleted(String id, bool completed) async {
    await _client
        .from('family_tasks')
        .update({
          'completed_at': completed
              ? DateTime.now().toUtc().toIso8601String()
              : null,
        })
        .eq('id', id);
  }

  Future<void> delete(String id) async =>
      _client.from('family_tasks').delete().eq('id', id);

  Future<FamilyTask> update({
    required String id,
    required String title,
    String? category,
    DateTime? dueAt,
    String visibility = 'family',
  }) async {
    final row = await _client
        .from('family_tasks')
        .update({
          'title': title.trim(),
          'category': blankToNull(category),
          'due_at': dueAt?.toUtc().toIso8601String(),
          'visibility': visibility,
        })
        .eq('id', id)
        .select(columns)
        .single();
    return FamilyTask.fromMap(Map<String, dynamic>.from(row));
  }

  bool _validTitle(String title) {
    final value = title.trim();
    return value.isNotEmpty && value != '..' && value != '.';
  }
}
