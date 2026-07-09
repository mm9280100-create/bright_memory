import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class IotSensorSnapshot {
  final bool? flameDetected;
  final bool? waterDetected;
  final double? waterLevel;
  final double? temperatureC;
  final int? lightLevel;
  final bool? lightDetected;
  final int? gasLevel;
  final bool? gasDetected;
  final bool? gasAcknowledged;
  final bool? gasBuzzerEnabled;
  final bool? gasAlert;
  final double? accelX;
  final double? accelY;
  final double? accelZ;
  final double? gyroX;
  final double? gyroY;
  final double? gyroZ;
  final double? ultrasonicDistanceCm;
  final bool? obstacleDetected;
  final bool? roomDetected;
  final String? currentRoomZone;
  final int? currentRoomIndex;
  final double? currentRoomDistanceCm;
  final String? nearestUltrasonicZone;
  final int? nearestUltrasonicIndex;
  final List<String> ultrasonicZones;
  final List<double?> ultrasonicDistancesCm;
  final bool? fallDetected;
  final double? fallConfidence;
  final bool? cameraOnline;
  final String? fallLocation;
  final String? fallZone;
  final double? fallX;
  final double? fallY;
  final int? fallPixelX;
  final int? fallPixelY;
  final bool? buzzerActive;
  final int? servoAngle;
  final DateTime? updatedAt;

  const IotSensorSnapshot({
    this.flameDetected,
    this.waterDetected,
    this.waterLevel,
    this.temperatureC,
    this.lightLevel,
    this.lightDetected,
    this.gasLevel,
    this.gasDetected,
    this.gasAcknowledged,
    this.gasBuzzerEnabled,
    this.gasAlert,
    this.accelX,
    this.accelY,
    this.accelZ,
    this.gyroX,
    this.gyroY,
    this.gyroZ,
    this.ultrasonicDistanceCm,
    this.obstacleDetected,
    this.roomDetected,
    this.currentRoomZone,
    this.currentRoomIndex,
    this.currentRoomDistanceCm,
    this.nearestUltrasonicZone,
    this.nearestUltrasonicIndex,
    this.ultrasonicZones = const [],
    this.ultrasonicDistancesCm = const [],
    this.fallDetected,
    this.fallConfidence,
    this.cameraOnline,
    this.fallLocation,
    this.fallZone,
    this.fallX,
    this.fallY,
    this.fallPixelX,
    this.fallPixelY,
    this.buzzerActive,
    this.servoAngle,
    this.updatedAt,
  });

  String? get fallPositionLabel {
    final location = fallLocation?.trim();
    final coordinate = fallX != null && fallY != null
        ? 'X ${(fallX! * 100).toStringAsFixed(0)}%, Y ${(fallY! * 100).toStringAsFixed(0)}%'
        : fallPixelX != null && fallPixelY != null
            ? 'px $fallPixelX, $fallPixelY'
            : null;

    if (location != null && location.isNotEmpty && coordinate != null) {
      return '$location - $coordinate';
    }
    if (location != null && location.isNotEmpty) return location;
    return coordinate;
  }

  String? get detectedRoomLabel {
    if (roomDetected == false && obstacleDetected != true) return null;

    final directZone = currentRoomZone?.trim();
    if (directZone != null && directZone.isNotEmpty) {
      return _normalizeRoomLabel(directZone);
    }

    if (currentRoomIndex != null &&
        currentRoomIndex! >= 0 &&
        currentRoomIndex! < ultrasonicZones.length) {
      return _normalizeRoomLabel(ultrasonicZones[currentRoomIndex!]);
    }

    final nearestZone = nearestUltrasonicZone?.trim();
    if (nearestZone != null && nearestZone.isNotEmpty) {
      return _normalizeRoomLabel(nearestZone);
    }

    if (nearestUltrasonicIndex != null &&
        nearestUltrasonicIndex! >= 0 &&
        nearestUltrasonicIndex! < ultrasonicZones.length) {
      return _normalizeRoomLabel(ultrasonicZones[nearestUltrasonicIndex!]);
    }

    return null;
  }

  static String _normalizeRoomLabel(String value) {
    final text = value.trim().toLowerCase();
    if (text.contains('bath')) return 'Bathroom';
    if (text.contains('kid') || text.contains('child')) return "Kid's room";
    if (text.contains('kitchen')) return 'Kitchen';
    if (text.contains('dining') || text.contains('dinging')) {
      return 'Dining room';
    }
    if (text.contains('living')) return 'Living room';
    if (text.contains('bed')) return 'Bedroom';
    return value.trim();
  }

  factory IotSensorSnapshot.fromJson(Map<String, dynamic> json) {
    return IotSensorSnapshot(
      flameDetected: _asBool(json['flameDetected'] ?? json['flame']),
      waterDetected: _asBool(json['waterDetected'] ?? json['water']),
      waterLevel: _asDouble(json['waterLevel']),
      temperatureC: _asDouble(json['temperatureC'] ?? json['temperature']),
      lightLevel: _asInt(json['lightLevel'] ?? json['ldrLevel'] ?? json['ldr']),
      lightDetected: _asBool(json['lightDetected']),
      gasLevel: _asInt(json['gasLevel'] ?? json['gas']),
      gasDetected: _asBool(json['gasDetected']),
      gasAcknowledged: _asBool(json['gasAcknowledged']),
      gasBuzzerEnabled: _asBool(json['gasBuzzerEnabled']),
      gasAlert: _asBool(json['gasAlert']),
      accelX: _asDouble(json['accelX'] ?? json['ax']),
      accelY: _asDouble(json['accelY'] ?? json['ay']),
      accelZ: _asDouble(json['accelZ'] ?? json['az']),
      gyroX: _asDouble(json['gyroX'] ?? json['gx']),
      gyroY: _asDouble(json['gyroY'] ?? json['gy']),
      gyroZ: _asDouble(json['gyroZ'] ?? json['gz']),
      ultrasonicDistanceCm: _asDouble(
        json['ultrasonicDistanceCm'] ??
            json['currentRoomDistanceCm'] ??
            json['distanceCm'] ??
            json['distance'],
      ),
      obstacleDetected: _asBool(
        json['obstacleDetected'] ?? json['obstacle'],
      ),
      roomDetected: _asBool(json['roomDetected']),
      currentRoomZone: _asString(json['currentRoomZone']),
      currentRoomIndex: _asInt(json['currentRoomIndex']),
      currentRoomDistanceCm: _asDouble(json['currentRoomDistanceCm']),
      nearestUltrasonicZone: _asString(json['nearestUltrasonicZone']),
      nearestUltrasonicIndex: _asInt(json['nearestUltrasonicIndex']),
      ultrasonicZones: _asStringList(json['ultrasonicZones']),
      ultrasonicDistancesCm: _asDoubleList(json['ultrasonicDistancesCm']),
      fallDetected: _asFallBool(
        json['fallDetected'] ??
            json['fall'] ??
            json['fallen'] ??
            json['modelFall'] ??
            json['isFall'] ??
            json['prediction'] ??
            json['label'] ??
            json['status'],
      ),
      fallConfidence: _asDouble(
        json['fallConfidence'] ??
            json['confidence'] ??
            json['modelConfidence'] ??
            json['score'],
      ),
      cameraOnline: _asBool(json['cameraOnline'] ?? json['online']),
      fallLocation: _asString(json['fallLocation'] ?? json['location']),
      fallZone: _asString(json['fallZone'] ?? json['zone']),
      fallX: _asDouble(json['fallX'] ?? json['x']),
      fallY: _asDouble(json['fallY'] ?? json['y']),
      fallPixelX: _asInt(json['fallPixelX'] ?? json['pixelX']),
      fallPixelY: _asInt(json['fallPixelY'] ?? json['pixelY']),
      buzzerActive: _asBool(json['buzzerActive'] ?? json['buzzer']),
      servoAngle: _asInt(json['servoAngle'] ?? json['servo']),
      updatedAt: DateTime.now(),
    );
  }

  static String? _asString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static List<String> _asStringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map(_asString)
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static List<double?> _asDoubleList(dynamic value) {
    if (value is! List) return const [];
    return value.map(_asDouble).toList(growable: false);
  }

  static bool? _asBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value.toString().toLowerCase().trim();
    if (text == 'true' || text == 'yes' || text == 'detected' || text == '1') {
      return true;
    }
    if (text == 'false' || text == 'no' || text == 'safe' || text == '0') {
      return false;
    }
    return null;
  }

  static bool? _asFallBool(dynamic value) {
    final boolValue = _asBool(value);
    if (boolValue != null) return boolValue;
    if (value == null) return null;

    final text = value.toString().toLowerCase().trim();
    if (text.contains('safe') ||
        text.contains('normal') ||
        text.contains('no fall') ||
        text.contains('not fallen')) {
      return false;
    }
    if (text.contains('fall') || text.contains('fallen')) return true;
    return null;
  }

  static double? _asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value.toString());
  }
}

class IotSensorService extends ChangeNotifier {
  IotSensorService._();

  static final IotSensorService instance = IotSensorService._();

  static const String defaultEndpoint = 'http://192.168.1.8';
  static const List<String> fallbackEndpoints = [
    'http://192.168.1.8',
    'http://192.168.4.1',
  ];

  final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 3);

  Timer? _pollTimer;
  String _endpoint = defaultEndpoint;
  IotSensorSnapshot? _snapshot;
  String? _lastDetectedRoomLabel;
  bool _isPolling = false;
  bool _isOnline = false;
  String? _errorMessage;

  String get endpoint => _endpoint;
  IotSensorSnapshot? get snapshot => _snapshot;
  String? get lastDetectedRoomLabel => _lastDetectedRoomLabel;
  bool get isPolling => _isPolling;
  bool get isOnline => _isOnline;
  String? get errorMessage => _errorMessage;

  void start({String endpoint = defaultEndpoint}) {
    _endpoint = endpoint.endsWith('/')
        ? endpoint.substring(0, endpoint.length - 1)
        : endpoint;
    refresh();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => refresh(),
    );
  }

  void stop() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> refresh() async {
    if (_isPolling) return;
    _isPolling = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final json = await _readStatusWithFallback();
      _applySnapshot(json);
      _isOnline = true;
    } catch (error) {
      _isOnline = false;
      _errorMessage = 'ESP32 not connected';
    } finally {
      _isPolling = false;
      notifyListeners();
    }
  }

  Future<void> setServoAngle(int angle) async {
    final safeAngle = angle.clamp(0, 90);
    try {
      final json = await _commandWithFallback('/servo?angle=$safeAngle');
      _applySnapshot(json);
      _isOnline = true;
      _errorMessage = null;
    } catch (error) {
      _isOnline = false;
      _errorMessage = 'Servo command failed';
    }
    notifyListeners();
  }

  Future<void> acknowledgeGasAlert() async {
    try {
      final json = await _commandWithFallback('/gas-ok');
      _applySnapshot(json);
      _isOnline = true;
      _errorMessage = null;
    } catch (error) {
      _isOnline = false;
      _errorMessage = 'Gas OK command failed';
    }
    notifyListeners();
  }

  Future<void> setGasBuzzerEnabled(bool enabled) async {
    try {
      final json = await _commandWithFallback(
        '/gas-buzzer?enabled=${enabled ? 1 : 0}',
      );
      _applySnapshot(json);
      _isOnline = true;
      _errorMessage = null;
    } catch (error) {
      _isOnline = false;
      _errorMessage = 'Gas buzzer command failed';
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> _readStatusWithFallback() async {
    return _commandWithFallback('/status');
  }

  Future<Map<String, dynamic>> _commandWithFallback(String path) async {
    final endpoints = <String>[
      _endpoint,
      ...fallbackEndpoints.where((endpoint) => endpoint != _endpoint),
    ];
    Object? lastError;

    for (final endpoint in endpoints) {
      try {
        final json = await _getJson('$endpoint$path');
        _endpoint = endpoint;
        return json;
      } catch (error) {
        lastError = error;
      }
    }

    throw lastError ?? const HttpException('No ESP32 endpoint available');
  }

  void _applySnapshot(Map<String, dynamic> json) {
    _snapshot = IotSensorSnapshot.fromJson(json);
    final roomLabel = _snapshot?.detectedRoomLabel;
    if (roomLabel != null && roomLabel.isNotEmpty) {
      _lastDetectedRoomLabel = roomLabel;
    }
  }

  Future<Map<String, dynamic>> _getJson(String url) async {
    final request = await _client.getUrl(Uri.parse(url));
    final response = await request.close().timeout(const Duration(seconds: 5));
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('HTTP ${response.statusCode}: $body');
    }
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected JSON object');
    }
    return decoded;
  }
}








