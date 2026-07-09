import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'iot_sensor_service.dart';

class SensorAlertMonitor {
  SensorAlertMonitor._();

  static final SensorAlertMonitor instance = SensorAlertMonitor._();
  static const MethodChannel _alertsChannel = MethodChannel('br_memory/alerts');

  final IotSensorService _iotService = IotSensorService.instance;
  bool _started = false;
  final Set<String> _activeAlerts = <String>{};
  String? _lastSpokenRoom;

  Future<void> start() async {
    if (_started) return;
    _started = true;

    await Permission.notification.request();
    _iotService.addListener(_handleSensorUpdate);
    _iotService.start();
  }

  void _handleSensorUpdate() {
    final snapshot = _iotService.snapshot;
    if (snapshot == null) return;

    final currentAlerts = <String>{};
    if (snapshot.flameDetected == true) currentAlerts.add('fire');
    if (snapshot.waterDetected == true) currentAlerts.add('water');
    if (snapshot.gasAlert == true) currentAlerts.add('gas');

    final room = snapshot.detectedRoomLabel ?? _iotService.lastDetectedRoomLabel;
    if (room != null && room.isNotEmpty && room != _lastSpokenRoom) {
      _lastSpokenRoom = room;
      _showSensorAlert('Patient is in $room', title: 'Patient location');
    }

    for (final alert in currentAlerts) {
      if (!_activeAlerts.contains(alert)) {
        _showSensorAlert(_messageFor(alert));
      }
    }

    _activeAlerts
      ..clear()
      ..addAll(currentAlerts);
  }

  String _messageFor(String alert) {
    switch (alert) {
      case 'fire':
        return 'Detect fire';
      case 'water':
        return 'Detect water';
      case 'gas':
        return 'Detect gas';
      default:
        return 'Sensor alert';
    }
  }

  Future<void> _showSensorAlert(
    String message, {
    String title = 'Sensor alert',
  }) async {
    try {
      await _alertsChannel.invokeMethod('showSensorAlert', {
        'title': title,
        'message': message,
        'speak': true,
      });
    } catch (_) {
      // The UI still shows live sensor state if native alerts are unavailable.
    }
  }
}
