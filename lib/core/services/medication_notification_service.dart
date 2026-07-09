import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MedicationNotificationService {
  MedicationNotificationService._();

  static final MedicationNotificationService instance =
      MedicationNotificationService._();

  final _notifications = FlutterLocalNotificationsPlugin();
  bool _started = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));

    await _notifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    await Permission.notification.request();
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    await _scheduleDailyMedicationReminder();
  }

  Future<void> _scheduleDailyMedicationReminder() async {
    const hour = 10;
    const minute = 0;
    final now = tz.TZDateTime.now(tz.local);
    var next =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      1000,
      'Medication time',
      'Time to take your medication. Please take 3 tablets of Panadol with water.',
      next,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_reminders',
          'Medication reminders',
          channelDescription: 'Daily reminders for medication time.',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
