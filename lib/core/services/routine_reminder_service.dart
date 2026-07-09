import 'dart:async';

import 'package:flutter/services.dart';

class RoutineReminderService {
  RoutineReminderService._();

  static final RoutineReminderService instance = RoutineReminderService._();
  static const _channel = MethodChannel('br_memory/reminders');

  final Set<String> _shownToday = {};
  Timer? _timer;

  final List<_RoutineReminderTask> _tasks = const [
    _RoutineReminderTask('Eat Breakfast', 8, 0),
    _RoutineReminderTask('Drink Water', 9, 30),
    _RoutineReminderTask('Medication', 10, 0),
    _RoutineReminderTask('Eat Lunch', 12, 30),
  ];

  void start() {
    if (_timer != null) return;
    _checkDueTasks();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _checkDueTasks());
  }

  void _checkDueTasks() {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month}-${now.day}';
    for (final task in _tasks) {
      final taskKey = '$todayKey-${task.title}';
      if (_shownToday.contains(taskKey)) continue;
      if (now.hour != task.hour || now.minute != task.minute) continue;
      _shownToday.add(taskKey);
      _showReminder(task);
    }
  }

  Future<void> _showReminder(_RoutineReminderTask task) async {
    await _channel.invokeMethod('showRoutineReminder', {
      'title': 'Routine reminder',
      'message': 'Time for ${task.title}',
    });
  }
}

class _RoutineReminderTask {
  final String title;
  final int hour;
  final int minute;

  const _RoutineReminderTask(this.title, this.hour, this.minute);
}
