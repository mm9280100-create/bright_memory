import 'dart:convert';

import 'package:http/http.dart' as http;

import 'firebase_realtime_auth.dart';

class RoutineTaskState {
  final String id;
  final bool done;
  final int? completedAt;

  const RoutineTaskState({
    required this.id,
    required this.done,
    this.completedAt,
  });

  factory RoutineTaskState.fromJson(String id, Object? value) {
    if (value is! Map) {
      return RoutineTaskState(id: id, done: false);
    }
    final json = Map<String, dynamic>.from(value);
    final updatedBy = json['updatedBy']?.toString();
    final completedAt = int.tryParse(json['completedAt']?.toString() ?? '');
    final isFreshDone = completedAt != null && _isSameLocalDay(completedAt);
    return RoutineTaskState(
      id: id,
      done: updatedBy == 'br_memory' &&
          isFreshDone &&
          (json['status'] == 'done' || json['done'] == true),
      completedAt: completedAt,
    );
  }

  static bool _isSameLocalDay(int millis) {
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class RoutineSyncService {
  RoutineSyncService._();

  static final RoutineSyncService instance = RoutineSyncService._();
  static const _basePath = 'routines/br-memory-dad-omar/tasks';

  Future<Map<String, RoutineTaskState>> fetchTasks() async {
    final response = await http.get(await FirebaseRealtimeAuth.uri(_basePath));
    if (response.statusCode == 404 || response.body == 'null') return {};
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Routine sync failed: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) return {};
    return decoded.map(
      (key, value) => MapEntry(
        key.toString(),
        RoutineTaskState.fromJson(key.toString(), value),
      ),
    );
  }

  Future<void> markDone({
    required String taskId,
    required String title,
    required DateTime completedAt,
  }) async {
    await http.put(
      await FirebaseRealtimeAuth.uri('$_basePath/$taskId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': taskId,
        'title': title,
        'status': 'done',
        'done': true,
        'completedAt': completedAt.millisecondsSinceEpoch,
        'updatedBy': 'br_memory',
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }),
    );
  }
}
