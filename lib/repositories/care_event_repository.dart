// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/errors/app_error.dart';
import '../models/care_event.dart';
import '../services/offline_care_event_queue.dart';
import 'repo_utils.dart';

class CareEventRepository {
  CareEventRepository({
    SupabaseClient? client,
    OfflineCareEventQueue? offlineQueue,
  }) : _client = client,
       _offlineQueue = offlineQueue ?? OfflineCareEventQueue.instance;

  final SupabaseClient? _client;
  final OfflineCareEventQueue _offlineQueue;
  SupabaseClient get _supabase => _client ?? Supabase.instance.client;
  static const columns =
      'id,child_id,created_by,event_type,started_at,ended_at,side,feeding_method,amount_ml,diaper_wet,diaper_dirty,temperature_c,medicine_name,medicine_dose,burped,vomited,notes,metadata,created_at,updated_at';

  Future<List<CareEvent>> fetchRecent(String childId, {int limit = 30}) async {
    await _trySyncPending();
    final rows = await withRepositoryTimeout(
      _supabase
          .from('care_events')
          .select(columns)
          .eq('child_id', childId)
          .order('started_at', ascending: false)
          .limit(limit),
    );
    return _mapRows(rows);
  }

  Future<List<CareEvent>> fetchBetween(
    String childId,
    DateTime start,
    DateTime end,
  ) async {
    await _trySyncPending();
    final rows = await withRepositoryTimeout(
      _supabase
          .from('care_events')
          .select(columns)
          .eq('child_id', childId)
          .gte('started_at', start.toUtc().toIso8601String())
          .lt('started_at', end.toUtc().toIso8601String())
          .order('started_at', ascending: false),
    );
    return _mapRows(rows);
  }

  Future<List<CareEvent>> fetchPumpingBetween(
    String childId,
    DateTime start,
    DateTime end,
  ) async {
    final rows = await withRepositoryTimeout(
      _supabase
          .from('care_events')
          .select(columns)
          .eq('child_id', childId)
          .gte('started_at', start.toUtc().toIso8601String())
          .lt('started_at', end.toUtc().toIso8601String())
          .or('event_type.eq.pumping,event_type.eq.feeding')
          .order('started_at', ascending: false),
    );
    return _mapRows(rows).where((event) => event.isPumping).toList();
  }

  Future<List<CareEvent>> fetchRecentPumping(
    String childId, {
    int limit = 20,
  }) async {
    final rows = await withRepositoryTimeout(
      _supabase
          .from('care_events')
          .select(columns)
          .eq('child_id', childId)
          .or('event_type.eq.pumping,event_type.eq.feeding')
          .order('started_at', ascending: false)
          .limit(limit),
    );
    return _mapRows(rows).where((event) => event.isPumping).toList();
  }

  Future<List<CareEvent>> fetchPumpingForComparison(
    String childId, {
    DateTime? now,
  }) {
    final end = (now ?? DateTime.now()).toLocal();
    final start = end.subtract(const Duration(days: 14));
    return fetchPumpingBetween(childId, start, end);
  }

  Future<List<CareEvent>> fetchSleepOverlappingDay(
    String childId,
    DateTime start,
    DateTime end,
  ) async {
    final rows = await withRepositoryTimeout(
      _supabase
          .from('care_events')
          .select(columns)
          .eq('child_id', childId)
          .eq('event_type', 'sleep')
          .lt('started_at', end.toUtc().toIso8601String())
          .or(
            'ended_at.is.null,ended_at.gte.${start.toUtc().toIso8601String()}',
          )
          .order('started_at', ascending: false),
    );
    return _mapRows(rows);
  }

  Future<CareEvent?> latestByType(String childId, String eventType) async {
    final rows = await withRepositoryTimeout(
      _supabase
          .from('care_events')
          .select(columns)
          .eq('child_id', childId)
          .eq('event_type', eventType)
          .order('started_at', ascending: false)
          .limit(1),
    );
    final list = rows as List;
    if (list.isEmpty) return null;
    return CareEvent.fromMap(Map<String, dynamic>.from(list.first as Map));
  }

  Future<CareEvent> insert({
    required String childId,
    required String eventType,
    required DateTime startedAt,
    DateTime? endedAt,
    String? side,
    String? feedingMethod,
    double? amountMl,
    bool? diaperWet,
    bool? diaperDirty,
    double? temperatureC,
    String? medicineName,
    String? medicineDose,
    bool? burped,
    bool? vomited,
    String? notes,
    Map<String, dynamic>? metadata,
  }) async {
    await _trySyncPending();
    final payload = _insertPayload(
      childId: childId,
      eventType: eventType,
      startedAt: startedAt,
      endedAt: endedAt,
      side: side,
      feedingMethod: feedingMethod,
      amountMl: amountMl,
      diaperWet: diaperWet,
      diaperDirty: diaperDirty,
      temperatureC: temperatureC,
      medicineName: medicineName,
      medicineDose: medicineDose,
      burped: burped,
      vomited: vomited,
      notes: notes,
      metadata: metadata,
    );
    try {
      final row = await _insertPayloadOnline(payload);
      return CareEvent.fromMap(Map<String, dynamic>.from(row));
    } catch (error) {
      if (!_isConnectivityError(error)) rethrow;
      await _offlineQueue.enqueueInsert(payload);
      throw const OfflineCareEventQueuedException();
    }
  }

  Future<CareEvent> update({
    required String id,
    DateTime? startedAt,
    DateTime? endedAt,
    String? side,
    String? feedingMethod,
    double? amountMl,
    bool? diaperWet,
    bool? diaperDirty,
    double? temperatureC,
    String? medicineName,
    String? medicineDose,
    bool? burped,
    bool? vomited,
    String? notes,
    Map<String, dynamic>? metadata,
  }) async {
    final values = <String, dynamic>{
      if (startedAt != null) 'started_at': startedAt.toUtc().toIso8601String(),
      if (endedAt != null) 'ended_at': endedAt.toUtc().toIso8601String(),
      if (side != null) 'side': side,
      if (feedingMethod != null) 'feeding_method': feedingMethod,
      if (amountMl != null) 'amount_ml': amountMl,
      if (diaperWet != null) 'diaper_wet': diaperWet,
      if (diaperDirty != null) 'diaper_dirty': diaperDirty,
      if (temperatureC != null) 'temperature_c': temperatureC,
      if (medicineName != null) 'medicine_name': blankToNull(medicineName),
      if (medicineDose != null) 'medicine_dose': blankToNull(medicineDose),
      if (burped != null) 'burped': burped,
      if (vomited != null) 'vomited': vomited,
      'notes': blankToNull(notes),
      'metadata': metadata ?? <String, dynamic>{},
    };
    final row = await withRepositoryTimeout(
      _supabase
          .from('care_events')
          .update(values)
          .eq('id', id)
          .select(columns)
          .single(),
    );
    return CareEvent.fromMap(Map<String, dynamic>.from(row));
  }

  Future<CareEvent> updateFields({
    required String id,
    required Map<String, dynamic> values,
  }) async {
    final row = await withRepositoryTimeout(
      _supabase
          .from('care_events')
          .update(values)
          .eq('id', id)
          .select(columns)
          .single(),
    );
    return CareEvent.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> delete(String id) => withRepositoryTimeout(
    _supabase.from('care_events').delete().eq('id', id),
  );

  Future<int> syncPending() async {
    final pending = await _offlineQueue.pendingInserts();
    if (pending.isEmpty) return 0;
    final remaining = <Map<String, dynamic>>[];
    var synced = 0;
    for (final payload in pending) {
      try {
        await _insertPayloadOnline(payload);
        synced++;
      } catch (error) {
        remaining.add(payload);
        if (_isConnectivityError(error)) {
          final index = pending.indexOf(payload);
          remaining.addAll(pending.skip(index + 1));
          break;
        }
      }
    }
    await _offlineQueue.replacePending(remaining);
    return synced;
  }

  Future<void> _trySyncPending() async {
    try {
      await syncPending();
    } catch (_) {
      // Pending records stay in local storage and will be retried later.
    }
  }

  Future<Map<String, dynamic>> _insertPayloadOnline(
    Map<String, dynamic> payload,
  ) => withRepositoryTimeout(
    _supabase.from('care_events').insert(payload).select(columns).single(),
  ).then((row) => Map<String, dynamic>.from(row));

  Map<String, dynamic> _insertPayload({
    required String childId,
    required String eventType,
    required DateTime startedAt,
    DateTime? endedAt,
    String? side,
    String? feedingMethod,
    double? amountMl,
    bool? diaperWet,
    bool? diaperDirty,
    double? temperatureC,
    String? medicineName,
    String? medicineDose,
    bool? burped,
    bool? vomited,
    String? notes,
    Map<String, dynamic>? metadata,
  }) => {
    'child_id': childId,
    'created_by': currentUserId(),
    'event_type': eventType,
    'started_at': startedAt.toUtc().toIso8601String(),
    'ended_at': endedAt?.toUtc().toIso8601String(),
    'side': side,
    'feeding_method': feedingMethod,
    'amount_ml': amountMl,
    'diaper_wet': diaperWet,
    'diaper_dirty': diaperDirty,
    'temperature_c': temperatureC,
    'medicine_name': blankToNull(medicineName),
    'medicine_dose': blankToNull(medicineDose),
    'burped': burped,
    'vomited': vomited,
    'notes': blankToNull(notes),
    'metadata': metadata ?? <String, dynamic>{},
  };

  bool _isConnectivityError(Object error) {
    if (error is RequestTimeoutException ||
        error is TimeoutException ||
        error is SocketException) {
      return true;
    }
    final message = error.toString().toLowerCase();
    return message.contains('socket') ||
        message.contains('network') ||
        message.contains('failed host lookup') ||
        message.contains('connection refused') ||
        message.contains('connection closed') ||
        message.contains('timed out') ||
        message.contains('timeout');
  }

  List<CareEvent> _mapRows(Object? rows) => (rows as List)
      .map((row) => CareEvent.fromMap(Map<String, dynamic>.from(row as Map)))
      .toList();
}
