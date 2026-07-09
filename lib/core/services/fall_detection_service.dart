import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'iot_sensor_service.dart';

class FallDetectionService extends ChangeNotifier {
  FallDetectionService._();
  static final FallDetectionService instance = FallDetectionService._();

  static const String defaultEndpoint = 'http://192.168.1.47:5000';

  Timer? _pollTimer;
  String _endpoint = defaultEndpoint;
  IotSensorSnapshot? _snapshot;
  bool _isPolling = false;
  bool _isOnline  = false;
  String? _errorMessage;

  String get endpoint       => _endpoint;
  IotSensorSnapshot? get snapshot => _snapshot;
  bool get isPolling        => _isPolling;
  bool get isOnline         => _isOnline;
  String? get errorMessage  => _errorMessage;

  void start({String endpoint = defaultEndpoint}) {
    _endpoint = endpoint.endsWith('/')
        ? endpoint.substring(0, endpoint.length - 1)
        : endpoint;
    refresh();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) => refresh());
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
      final response = await http
          .get(Uri.parse('$_endpoint/status'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        _snapshot = IotSensorSnapshot.fromJson(json);
        _isOnline = true;
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (_) {
      _isOnline = false;
      _errorMessage = 'AI fall model not connected';
    } finally {
      _isPolling = false;
      notifyListeners();
    }
  }
}

