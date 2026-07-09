import 'dart:convert';

import 'package:http/http.dart' as http;

class FirebaseRealtimeAuth {
  FirebaseRealtimeAuth._();

  static const apiKey = 'AIzaSyD5_aclFTQ_V5YhAbDsv76u_RdVNP38rGk';
  static const databaseUrl =
      'https://ri3ayati-ca85f-default-rtdb.europe-west1.firebasedatabase.app';

  static String? _idToken;
  static int _expiresAt = 0;

  static Future<Uri> uri(String path) async {
    final token = await _token();
    return Uri.parse('$databaseUrl/$path.json?auth=$token');
  }

  static Future<String> _token() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_idToken != null && now < _expiresAt) return _idToken!;

    final response = await http.post(
      Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'returnSecureToken': true}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Firebase anonymous auth failed');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    _idToken = json['idToken'] as String;
    final expiresIn = int.tryParse(json['expiresIn']?.toString() ?? '') ?? 3600;
    _expiresAt = now + ((expiresIn - 60) * 1000);
    return _idToken!;
  }
}
