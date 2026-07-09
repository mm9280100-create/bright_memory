import 'dart:convert';

import 'package:http/http.dart' as http;

import 'firebase_realtime_auth.dart';

class RoutineAlertService {
  RoutineAlertService._();

  static final RoutineAlertService instance = RoutineAlertService._();
  static const String roomId = 'br-memory-dad-omar';

  Future<void> sendTaskDone({
    required String taskTitle,
    required String scheduledLabel,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final taskKey = _taskKey(taskTitle);
    await http.put(
      await FirebaseRealtimeAuth.uri('routineAlerts/$roomId/status/$taskKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'status': 'done',
        'taskTitle': taskTitle,
        'scheduledLabel': scheduledLabel,
        'updatedBy': 'br_memory',
        'updatedAt': now,
      }),
    );
    await http.post(
      await FirebaseRealtimeAuth.uri('routineAlerts/$roomId/events'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'type': 'routine-task-done',
        'taskKey': taskKey,
        'taskTitle': taskTitle,
        'scheduledLabel': scheduledLabel,
        'message': 'Routine task completed',
        'sender': 'br_memory',
        'target': 'riayati',
        'createdAt': now,
      }),
    );
  }

  String _taskKey(String title) {
    return title.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }
}
