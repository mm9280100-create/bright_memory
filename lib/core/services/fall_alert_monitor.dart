import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'fall_detection_service.dart';

class FallAlertMonitor {
  FallAlertMonitor._();

  static final FallAlertMonitor instance = FallAlertMonitor._();
  static const MethodChannel _alertsChannel = MethodChannel('br_memory/alerts');

  final FallDetectionService _fallService = FallDetectionService.instance;
  bool _started = false;
  bool _wasFalling = false;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    await Permission.notification.request();
    _fallService.addListener(_handleFallUpdate);
    _fallService.start();
  }

  void _handleFallUpdate() {
    final snapshot = _fallService.snapshot;
    final fallDetected = snapshot?.fallDetected == true;

    if (!fallDetected) {
      _wasFalling = false;
      return;
    }

    if (_wasFalling) return;
    _wasFalling = true;

    final position = snapshot?.fallPositionLabel;
    final message = position == null || position.isEmpty
        ? 'تم رصد سقوط المريض بواسطة موديل AI'
        : 'تم رصد سقوط المريض بواسطة موديل AI - $position';

    _showFallNotification(message);
  }

  Future<void> _showFallNotification(String message) async {
    try {
      await _alertsChannel.invokeMethod('showFallAlert', {
        'title': 'تنبيه سقوط',
        'message': message,
      });
    } catch (_) {
      // The location card still shows the fall state if native notifications fail.
    }
  }
}
