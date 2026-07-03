// ignore_for_file: prefer_initializing_formals

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/doctor_question.dart';
import 'repo_utils.dart';

class DoctorQuestionRepository {
  DoctorQuestionRepository({SupabaseClient? client}) : _client = client;
  final SupabaseClient? _client;
  SupabaseClient get _supabase => _client ?? Supabase.instance.client;
  static const columns =
      'id,child_id,created_by,question,answered_at,created_at';

  Future<List<DoctorQuestion>> fetch(String childId) async {
    final rows = await _supabase
        .from('doctor_questions')
        .select(columns)
        .eq('child_id', childId)
        .order('created_at', ascending: false);
    return (rows as List)
        .map(
          (row) =>
              DoctorQuestion.fromMap(Map<String, dynamic>.from(row as Map)),
        )
        .toList();
  }

  Future<DoctorQuestion> add({
    required String childId,
    required String question,
  }) async {
    final row = await _supabase
        .from('doctor_questions')
        .insert({
          'child_id': childId,
          'created_by': currentUserId(),
          'question': question.trim(),
        })
        .select(columns)
        .single();
    return DoctorQuestion.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> setAnswered(String id, bool answered) async {
    await _supabase
        .from('doctor_questions')
        .update({
          'answered_at': answered
              ? DateTime.now().toUtc().toIso8601String()
              : null,
        })
        .eq('id', id);
  }

  Future<void> delete(String id) async =>
      _supabase.from('doctor_questions').delete().eq('id', id);
}
