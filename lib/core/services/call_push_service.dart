import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import 'firebase_options.dart';
import 'firebase_realtime_auth.dart';

class CallPushService {
  CallPushService._();

  static final CallPushService instance = CallPushService._();
  bool _started = false;

  static Future<void> initializeFirebase() async {
    if (Firebase.apps.isNotEmpty) return;
    await Firebase.initializeApp(
      options: BrMemoryFirebaseOptions.currentPlatform,
    );
  }

  Future<void> start() async {
    await initializeFirebase();

    final messaging = FirebaseMessaging.instance;
    if (!_started) {
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      FirebaseMessaging.instance.onTokenRefresh.listen(
        (token) => unawaited(_saveToken(token)),
      );
      _started = true;
    }
    await _saveToken(await messaging.getToken());
  }

  Future<void> requestPeerCallPush({
    required String roomId,
    required String mode,
    required String sender,
    required String target,
    required String callerName,
    required String sessionId,
    required int createdAt,
  }) async {
    await start();
    final requestId = '${createdAt}_${DateTime.now().microsecondsSinceEpoch}';
    final response = await http.put(
      await FirebaseRealtimeAuth.uri(
        'calls/$roomId/pushRequests/$requestId',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'type': 'call-invite',
        'mode': mode,
        'from': callerName,
        'sender': sender,
        'target': target,
        'sessionId': sessionId,
        'roomId': roomId,
        'createdAt': createdAt,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Call push request failed: ${response.statusCode}');
    }
  }

  Future<void> _saveToken(String? token) async {
    if (token == null || token.isEmpty) return;
    final response = await http.put(
      await FirebaseRealtimeAuth.uri('calls/br-memory-dad-omar/devices/br_memory'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'platform': 'android',
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Call token save failed: ${response.statusCode}');
    }
  }
}
