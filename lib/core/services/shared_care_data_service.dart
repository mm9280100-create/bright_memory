import 'dart:convert';

import 'package:http/http.dart' as http;

import 'firebase_realtime_auth.dart';

class SharedCareDataService {
  SharedCareDataService._();

  static final SharedCareDataService instance = SharedCareDataService._();

  static const _basePath = 'shared_care_data';
  static const _timeout = Duration(seconds: 15);
  static const _careNotesKey = 'care_notes';
  static const _patientInfoKey = 'patient_info';

  final _http = http.Client();

  Map<String, String> get _headers =>
      {'Content-Type': 'application/json', 'Accept': 'application/json'};

  Future<List<Map<String, dynamic>>?> fetchCareNotes() async {
    final readings = await _latestReadings(
      key: _careNotesKey,
    );
    final notes = readings?['notes'];
    if (notes is! List) return null;
    return notes.whereType<Map>().map((item) {
      return Map<String, dynamic>.from(item);
    }).toList();
  }

  Future<void> saveCareNotes(List<Map<String, dynamic>> notes) async {
    await _save(
      key: _careNotesKey,
      readings: {
        'notes': notes,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<Map<String, dynamic>?> fetchPatientInfo() async {
    return _latestReadings(
      key: _patientInfoKey,
    );
  }

  Future<void> savePatientInfo(Map<String, dynamic> data) async {
    await _save(
      key: _patientInfoKey,
      readings: {
        ...data,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<Map<String, dynamic>?> _latestReadings({
    required String key,
  }) async {
    final response = await _http
        .get(await FirebaseRealtimeAuth.uri('$_basePath/$key'),
            headers: _headers)
        .timeout(_timeout);
    if (response.statusCode == 404 || response.body == 'null') return null;
    if (response.statusCode != 200) return null;
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) return null;
    return Map<String, dynamic>.from(decoded);
  }

  Future<void> _save({
    required String key,
    required Map<String, dynamic> readings,
  }) async {
    final response = await _http
        .put(
          await FirebaseRealtimeAuth.uri('$_basePath/$key'),
          headers: _headers,
          body: jsonEncode(readings),
        )
        .timeout(_timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Shared data save failed: ${response.statusCode}');
    }
  }
}
