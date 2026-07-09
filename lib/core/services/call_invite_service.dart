import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'call_push_service.dart';
import 'firebase_realtime_auth.dart';

enum CallInviteMode { audio, video }

class CallInvite {
  final CallInviteMode mode;
  final String from;
  final String sessionId;

  const CallInvite({
    required this.mode,
    required this.from,
    required this.sessionId,
  });

  factory CallInvite.fromJson(Map<String, dynamic> json) {
    return CallInvite(
      mode:
          json['mode'] == 'video' ? CallInviteMode.video : CallInviteMode.audio,
      from: json['from']?.toString() ?? 'Riayati',
      sessionId: json['sessionId']?.toString() ?? '',
    );
  }
}

class CallInviteService extends ChangeNotifier {
  CallInviteService._();

  static final CallInviteService instance = CallInviteService._();
  static const String roomId = 'br-memory-dad-omar';
  static const String selfId = 'br_memory';
  static const String peerId = 'riayati';
  static String? activeSessionId;
  static String? activeInitiatorId;
  static int? activeSessionStartedAt;

  final Set<String> _seenEvents = {};
  final Set<String> _endedSessions = {};
  Timer? _pollTimer;
  CallInvite? _incomingInvite;
  bool _connecting = false;
  bool _sendingInvite = false;
  String? _lastRemoteEvent;
  late final int _cutoff = DateTime.now().millisecondsSinceEpoch - 60000;

  CallInvite? get incomingInvite => _incomingInvite;
  bool get isSendingInvite => _sendingInvite;
  bool get hasActiveSession =>
      activeSessionId != null && activeSessionId!.isNotEmpty;
  String? get lastRemoteEvent => _lastRemoteEvent;

  Future<void> start() async {
    if (_pollTimer != null || _connecting) return;
    _connecting = true;
    await _safePoll();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _safePoll());
    _connecting = false;
  }

  Future<bool> sendInvite(CallInviteMode mode) async {
    if (_sendingInvite || hasActiveSession) return false;
    _sendingInvite = true;
    notifyListeners();
    try {
      await start();
      activeSessionId = _newSessionId();
      activeInitiatorId = selfId;
      activeSessionStartedAt = DateTime.now().millisecondsSinceEpoch;
      await _clearPreviousEvents();
      await _putCurrentSession(mode);
      await _postEvent({
        'type': 'call-invite',
        'mode': mode == CallInviteMode.video ? 'video' : 'audio',
        'from': 'BR Memory',
        'sender': selfId,
        'target': peerId,
        'sessionId': activeSessionId,
        'initiator': selfId,
      });
      await _sendPushWithRetry(mode);
      return true;
    } finally {
      _sendingInvite = false;
      notifyListeners();
    }
  }

  Future<void> _sendPushWithRetry(CallInviteMode mode) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await CallPushService.instance.requestPeerCallPush(
          roomId: roomId,
          mode: mode == CallInviteMode.video ? 'video' : 'audio',
          sender: selfId,
          target: peerId,
          callerName: 'BR Memory',
          sessionId: activeSessionId!,
          createdAt: activeSessionStartedAt!,
        );
        return;
      } catch (_) {
        await Future<void>.delayed(Duration(milliseconds: 600 * (attempt + 1)));
      }
    }
  }

  static String ensureActiveSession() {
    activeSessionId ??= _newSessionId();
    return activeSessionId!;
  }

  static bool get isSelfInitiator => activeInitiatorId == selfId;

  static void clearActiveSession() {
    activeSessionId = null;
    activeInitiatorId = null;
    activeSessionStartedAt = null;
  }

  Future<void> sendCallEnded({String? sessionId}) async {
    final endedSession = sessionId ?? activeSessionId;
    if (endedSession == null || endedSession.isEmpty) return;
    _endedSessions.add(endedSession);
    await _postEvent({
      'type': 'call-ended',
      'sender': selfId,
      'target': peerId,
      'sessionId': endedSession,
    });
    await _markCurrentSessionEnded(endedSession);
    if (activeSessionId == endedSession) clearActiveSession();
    clearInvite();
  }

  Future<void> sendCallAccepted({String? sessionId}) async {
    final acceptedSession = sessionId ?? activeSessionId;
    if (acceptedSession == null || acceptedSession.isEmpty) return;
    await _postEvent({
      'type': 'call-accepted',
      'sender': selfId,
      'target': peerId,
      'sessionId': acceptedSession,
    });
    await _patchCurrentSession({
      'status': 'accepted',
      'acceptedBy': selfId,
      'acceptedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> sendCallDeclined({String? sessionId}) async {
    final declinedSession = sessionId ?? activeSessionId;
    if (declinedSession == null || declinedSession.isEmpty) return;
    _endedSessions.add(declinedSession);
    await _postEvent({
      'type': 'call-declined',
      'sender': selfId,
      'target': peerId,
      'sessionId': declinedSession,
    });
    await _markCurrentSessionEnded(declinedSession, status: 'declined');
    if (activeSessionId == declinedSession) clearActiveSession();
    clearInvite();
  }

  void clearInvite() {
    _incomingInvite = null;
    notifyListeners();
  }

  Future<void> _poll() async {
    final response = await http
        .get(await FirebaseRealtimeAuth.uri('calls/$roomId/events'))
        .timeout(const Duration(seconds: 8));
    if (response.statusCode < 200 || response.statusCode >= 300) return;
    if (response.body == 'null') return;

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) return;

    for (final entry in decoded.entries) {
      final eventId = entry.key.toString();
      if (_seenEvents.contains(eventId)) continue;
      _seenEvents.add(eventId);

      final data = Map<String, dynamic>.from(entry.value as Map);
      final createdAt = (data['createdAt'] as num?)?.toInt() ?? 0;
      if (createdAt < _cutoff) continue;
      _handleMessage(data);
    }
  }

  Future<void> _safePoll() async {
    try {
      await _poll();
    } catch (_) {
      // Keep polling; Firebase rules or network may become available later.
    }
  }

  void _handleMessage(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    final sessionId = data['sessionId']?.toString() ?? '';
    if (sessionId.isNotEmpty && _endedSessions.contains(sessionId)) return;
    if (data['sender'] == selfId) return;
    if (type == 'call-ended' || type == 'call-declined') {
      if (sessionId.isNotEmpty) _endedSessions.add(sessionId);
      if (activeSessionId == sessionId) clearActiveSession();
      _lastRemoteEvent = type;
      clearInvite();
      notifyListeners();
      return;
    }
    if (type == 'call-accepted') {
      _lastRemoteEvent = type;
      notifyListeners();
      return;
    }
    if (type != 'call-invite') return;
    if (data['target'] != selfId) return;
    final createdAt = (data['createdAt'] as num?)?.toInt() ?? 0;
    if (DateTime.now().millisecondsSinceEpoch - createdAt >
        const Duration(seconds: 45).inMilliseconds) {
      return;
    }
    _incomingInvite = CallInvite.fromJson(data);
    activeSessionId = _incomingInvite!.sessionId.isEmpty
        ? _newSessionId()
        : _incomingInvite!.sessionId;
    activeInitiatorId =
        data['initiator']?.toString() ?? data['sender']?.toString();
    activeSessionStartedAt = (data['createdAt'] as num?)?.toInt();
    notifyListeners();
  }

  static String _newSessionId() {
    return '${selfId}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _clearPreviousEvents() async {
    _seenEvents.clear();
    await http
        .delete(await FirebaseRealtimeAuth.uri('calls/$roomId/events'))
        .timeout(const Duration(seconds: 8));
  }

  Future<void> _postEvent(Map<String, dynamic> event) async {
    await http.post(
      await FirebaseRealtimeAuth.uri('calls/$roomId/events'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        ...event,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      }),
    );
  }

  Future<void> _putCurrentSession(CallInviteMode mode) async {
    await http.put(
      await FirebaseRealtimeAuth.uri('calls/$roomId/currentSession'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sessionId': activeSessionId,
        'initiator': activeInitiatorId,
        'mode': mode == CallInviteMode.video ? 'video' : 'audio',
        'status': 'ringing',
        'createdAt':
            activeSessionStartedAt ?? DateTime.now().millisecondsSinceEpoch,
      }),
    );
  }

  Future<void> _markCurrentSessionEnded(
    String sessionId, {
    String status = 'ended',
  }) async {
    await http.put(
      await FirebaseRealtimeAuth.uri('calls/$roomId/currentSession'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sessionId': sessionId,
        'status': status,
        'endedBy': selfId,
        'endedAt': DateTime.now().millisecondsSinceEpoch,
      }),
    );
  }

  Future<void> _patchCurrentSession(Map<String, dynamic> data) async {
    await http.patch(
      await FirebaseRealtimeAuth.uri('calls/$roomId/currentSession'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }
}
