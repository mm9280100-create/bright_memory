import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import 'call_invite_service.dart';
import 'firebase_realtime_auth.dart';
import 'webrtc_ice_config.dart';

enum WebRtcCallMode { audio, video }

class WebRtcCallService extends ChangeNotifier {
  WebRtcCallService();

  static const String roomId = 'br-memory-dad-omar';
  static const String selfId = 'br_memory';

  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  Timer? _pollTimer;
  Timer? _restartTimer;
  Timer? _setupTimer;
  Timer? _ringbackTimer;
  Timer? _callTimeoutTimer;
  Timer? _sessionTimer;
  final Set<String> _seenEvents = {};
  final List<RTCIceCandidate> _pendingCandidates = [];
  WebRtcCallMode _mode = WebRtcCallMode.video;
  bool _muted = false;
  bool _speaker = true;
  String _status = 'Connecting...';
  bool _offerCreated = false;
  bool _isOfferer = false;
  bool _remoteDescriptionSet = false;
  bool _restartInProgress = false;
  bool _ended = false;
  bool _remoteEnded = false;
  String? _sessionId;

  bool get muted => _muted;
  bool get speaker => _speaker;
  bool get isVideo => _mode == WebRtcCallMode.video;
  String get status => _status;
  bool get hasEnded => _ended || _remoteEnded;

  Future<void> start({
    required WebRtcCallMode mode,
  }) async {
    _mode = mode;
    _ended = false;
    _remoteEnded = false;
    _status = 'Connecting...';
    await _prepareSession();
    notifyListeners();

    try {
      await _requestPermissions();
      await localRenderer.initialize();
      await remoteRenderer.initialize();
      await _createPeerConnection();
      await _openLocalMedia();
      await _startFirebaseSignaling();
    } catch (_) {
      _status = 'Signaling error';
      notifyListeners();
    }
  }

  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    if (isVideo) {
      await Permission.camera.request();
    }
  }

  Future<void> _prepareSession() async {
    final activeSession = CallInviteService.activeSessionId;
    if (activeSession != null && activeSession.isNotEmpty) {
      _sessionId = activeSession;
      _isOfferer = CallInviteService.isSelfInitiator ||
          activeSession.startsWith('${selfId}_');
      CallInviteService.activeSessionStartedAt ??=
          DateTime.now().millisecondsSinceEpoch;
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final response = await http
        .get(await FirebaseRealtimeAuth.uri('calls/$roomId/currentSession'))
        .timeout(const Duration(seconds: 8));

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        response.body != 'null') {
      final data = jsonDecode(response.body);
      if (data is Map) {
        final createdAt = (data['createdAt'] as num?)?.toInt() ?? 0;
        final sessionId = data['sessionId']?.toString();
        final initiator = data['initiator']?.toString();
        final status = data['status']?.toString();
        if (sessionId != null &&
            sessionId.isNotEmpty &&
            status != 'ended' &&
            now - createdAt < const Duration(seconds: 90).inMilliseconds) {
          CallInviteService.activeSessionId = sessionId;
          CallInviteService.activeInitiatorId = initiator;
          CallInviteService.activeSessionStartedAt = createdAt;
          _sessionId = sessionId;
          _isOfferer = initiator == selfId;
          return;
        }
      }
    }

    _sessionId = CallInviteService.ensureActiveSession();
    CallInviteService.activeInitiatorId = selfId;
    CallInviteService.activeSessionStartedAt = now;
    _isOfferer = true;
    await http.put(
      await FirebaseRealtimeAuth.uri('calls/$roomId/currentSession'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'sessionId': _sessionId,
        'initiator': selfId,
        'mode': isVideo ? 'video' : 'audio',
        'status': 'ringing',
        'createdAt': now,
      }),
    );
  }

  Future<void> _createPeerConnection() async {
    _peerConnection = await createPeerConnection(
      WebRtcIceConfig.peerConnectionConfig(),
    );

    _peerConnection!.onIceCandidate = (candidate) {
      unawaited(_send({
        'type': 'ice',
        'candidate': candidate.toMap(),
      }));
    };

    _peerConnection!.onTrack = (event) {
      unawaited(_handleRemoteTrack(event));
    };

    _peerConnection!.onAddStream = _attachRemoteStream;

    _peerConnection!.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _status = 'Connected';
        _restartInProgress = false;
        _stopRingback();
        _stopCallTimeout();
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        _status = 'Reconnecting...';
        _scheduleIceRestart();
      } else if (state ==
          RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        _status = 'Reconnecting...';
        _scheduleIceRestart();
      }
      notifyListeners();
    };
  }

  Future<void> _openLocalMedia() async {
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': isVideo
          ? {
              'facingMode': 'user',
              'width': {'ideal': 640},
              'height': {'ideal': 480},
            }
          : false,
    });

    localRenderer.srcObject = _localStream;
    for (final track in _localStream!.getTracks()) {
      track.enabled = true;
      await _peerConnection!.addTrack(track, _localStream!);
    }
    _speaker = true;
    await Helper.setSpeakerphoneOn(true);
  }

  void _attachRemoteStream(MediaStream stream) {
    for (final track in stream.getAudioTracks()) {
      track.enabled = true;
    }
    for (final track in stream.getVideoTracks()) {
      track.enabled = true;
    }
    remoteRenderer.srcObject = stream;
    _status = 'Connected';
    _stopRingback();
    _stopCallTimeout();
    notifyListeners();
  }

  Future<void> _handleRemoteTrack(RTCTrackEvent event) async {
    if (event.streams.isNotEmpty) {
      _attachRemoteStream(event.streams.first);
      return;
    }

    _remoteStream ??= await createLocalMediaStream('remote_$_sessionId');
    await _remoteStream!.addTrack(event.track);
    _attachRemoteStream(_remoteStream!);
  }

  Future<void> _startFirebaseSignaling() async {
    _status = 'Waiting for second app...';
    notifyListeners();
    if (_isOfferer) _startRingback();
    _startCallTimeout();
    await _send({'type': 'ready'});
    await _safePollSignals();
    Timer(const Duration(seconds: 2), () {
      if (_isOfferer && _peerConnection != null && !_offerCreated) {
        _offerCreated = true;
        unawaited(_createOffer());
      }
    });
    _setupTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _nudgeCallSetup(),
    );
    _sessionTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _safePollSessionState(),
    );
    _pollTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _safePollSignals(),
    );
  }

  Future<void> _safePollSessionState() async {
    try {
      await _pollSessionState();
    } catch (_) {}
  }

  Future<void> _pollSessionState() async {
    if (_sessionId == null || _sessionId!.isEmpty || hasEnded) return;
    final response = await http
        .get(await FirebaseRealtimeAuth.uri('calls/$roomId/currentSession'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode < 200 || response.statusCode >= 300) return;
    if (response.body == 'null') return;
    final data = jsonDecode(response.body);
    if (data is! Map) return;
    if (data['sessionId']?.toString() != _sessionId) return;
    final status = data['status']?.toString();
    final endedBy = data['endedBy']?.toString();
    if ((status == 'ended' || status == 'declined') && endedBy != selfId) {
      _remoteEnded = true;
      _status = status == 'declined' ? 'Call declined' : 'Call ended';
      notifyListeners();
      await end(notifyPeer: false);
    }
  }

  Future<void> _nudgeCallSetup() async {
    if (hasEnded || _peerConnection == null || _status == 'Connected') return;
    if (_isOfferer) {
      if (!_offerCreated) {
        _offerCreated = true;
        await _createOffer();
      } else {
        final localDescription = await _peerConnection!.getLocalDescription();
        if (localDescription?.sdp != null) {
          await _send({'type': 'offer', 'sdp': localDescription!.sdp});
        }
      }
      return;
    }
    await _send({'type': 'ready'});
  }

  Future<void> _safePollSignals() async {
    try {
      await _pollSignals();
    } catch (_) {
      // Keep the call alive while temporary network/Firebase errors recover.
    }
  }

  Future<void> _pollSignals() async {
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
      final sessionId = data['sessionId']?.toString();
      if (sessionId != _sessionId) continue;
      if (data['sender'] == selfId) continue;
      await _handleSignal(data);
    }
  }

  Future<void> _handleSignal(Map<String, dynamic> data) async {
    final type = data['type'];

    if (type == 'call-ended' || type == 'peer-left' || type == 'call-declined') {
      _remoteEnded = true;
      _status = type == 'call-declined' ? 'Call declined' : 'Call ended';
      notifyListeners();
      await end(notifyPeer: false);
      return;
    }

    if (type == 'call-accepted') {
      _stopRingback();
      _status = 'Call accepted';
      notifyListeners();
      if (_isOfferer && !_offerCreated) {
        _offerCreated = true;
        await _createOffer();
      }
      return;
    }

    if (type == 'ready') {
      _status = 'Calling...';
      notifyListeners();
      if (_isOfferer && !_offerCreated) {
        _offerCreated = true;
        await _createOffer();
      }
      return;
    }

    if (type == 'offer') {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(data['sdp'] as String, 'offer'),
      );
      _remoteDescriptionSet = true;
      await _flushPendingCandidates();
      final answer = await _peerConnection!.createAnswer(_sdpConstraints());
      await _peerConnection!.setLocalDescription(answer);
      await _send({'type': 'answer', 'sdp': answer.sdp});
      return;
    }

    if (type == 'answer') {
      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(data['sdp'] as String, 'answer'),
      );
      _remoteDescriptionSet = true;
      await _flushPendingCandidates();
      return;
    }

    if (type == 'ice') {
      final candidate = data['candidate'] as Map<String, dynamic>;
      await _addRemoteCandidate(
        RTCIceCandidate(
          candidate['candidate'] as String?,
          candidate['sdpMid'] as String?,
          candidate['sdpMLineIndex'] as int?,
        ),
      );
    }
  }

  Future<void> _createOffer() async {
    _status = 'Calling...';
    notifyListeners();
    final offer = await _peerConnection!.createOffer(_sdpConstraints());
    await _peerConnection!.setLocalDescription(offer);
    await _send({'type': 'offer', 'sdp': offer.sdp});
  }

  void _startRingback() {
    _ringbackTimer?.cancel();
    unawaited(SystemSound.play(SystemSoundType.alert));
    _ringbackTimer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
      if (hasEnded || _status == 'Connected') {
        _stopRingback();
        return;
      }
      unawaited(SystemSound.play(SystemSoundType.alert));
    });
  }

  void _stopRingback() {
    _ringbackTimer?.cancel();
    _ringbackTimer = null;
  }

  void _startCallTimeout() {
    _callTimeoutTimer?.cancel();
    _callTimeoutTimer = Timer(const Duration(seconds: 75), () {
      if (hasEnded || _status == 'Connected') return;
      _status = 'No answer';
      notifyListeners();
      unawaited(end());
    });
  }

  void _stopCallTimeout() {
    _callTimeoutTimer?.cancel();
    _callTimeoutTimer = null;
  }

  Future<void> _restartIce() async {
    if (!_isOfferer || _peerConnection == null || _restartInProgress) return;
    _restartInProgress = true;
    _status = 'Reconnecting...';
    notifyListeners();
    try {
      final offer = await _peerConnection!.createOffer({'iceRestart': true});
      await _peerConnection!.setLocalDescription(offer);
      await _send({'type': 'offer', 'sdp': offer.sdp});
    } catch (_) {
      _restartInProgress = false;
    }
  }

  Map<String, dynamic> _sdpConstraints() {
    return {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
      'optional': [],
    };
  }

  void _scheduleIceRestart() {
    if (!_isOfferer || _peerConnection == null) return;
    _restartTimer?.cancel();
    _restartTimer = Timer(
      const Duration(seconds: 2),
      () => unawaited(_restartIce()),
    );
  }

  Future<void> _addRemoteCandidate(RTCIceCandidate candidate) async {
    if (!_remoteDescriptionSet) {
      _pendingCandidates.add(candidate);
      return;
    }
    try {
      await _peerConnection!.addCandidate(candidate);
    } catch (_) {
      // Ignore duplicate/late ICE candidates during reconnect.
    }
  }

  Future<void> _flushPendingCandidates() async {
    if (_pendingCandidates.isEmpty) return;
    final candidates = List<RTCIceCandidate>.from(_pendingCandidates);
    _pendingCandidates.clear();
    for (final candidate in candidates) {
      await _addRemoteCandidate(candidate);
    }
  }

  Future<void> _send(Map<String, dynamic> payload) async {
    if (_ended && payload['type'] != 'call-ended') return;
    await http.post(
      await FirebaseRealtimeAuth.uri('calls/$roomId/events'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        ...payload,
        'sender': selfId,
        'sessionId': _sessionId,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      }),
    );
  }

  Future<void> toggleMute() async {
    _muted = !_muted;
    for (final track
        in _localStream?.getAudioTracks() ?? <MediaStreamTrack>[]) {
      track.enabled = !_muted;
    }
    notifyListeners();
  }

  Future<void> toggleSpeaker() async {
    _speaker = !_speaker;
    await Helper.setSpeakerphoneOn(_speaker);
    notifyListeners();
  }

  Future<void> switchCamera() async {
    final tracks = _localStream?.getVideoTracks() ?? <MediaStreamTrack>[];
    if (tracks.isEmpty) return;
    await Helper.switchCamera(tracks.first);
  }

  Future<void> end({bool notifyPeer = true}) async {
    if (_ended) return;
    _ended = true;
    _status = 'Call ended';
    notifyListeners();
    _pollTimer?.cancel();
    _pollTimer = null;
    _restartTimer?.cancel();
    _restartTimer = null;
    _setupTimer?.cancel();
    _setupTimer = null;
    _sessionTimer?.cancel();
    _sessionTimer = null;
    _stopRingback();
    _stopCallTimeout();
    final sessionId = _sessionId;
    if (notifyPeer && sessionId != null && sessionId.isNotEmpty) {
      unawaited(CallInviteService.instance.sendCallEnded(sessionId: sessionId));
      unawaited(_send({'type': 'call-ended'}));
    }
    if (sessionId != null && sessionId.isNotEmpty) {
      await _markRemoteSessionEnded();
    }
    await _peerConnection?.close();
    _peerConnection = null;
    for (final track in _localStream?.getTracks() ?? <MediaStreamTrack>[]) {
      await track.stop();
    }
    await _localStream?.dispose();
    _localStream = null;
    await _remoteStream?.dispose();
    _remoteStream = null;
    try {
      localRenderer.srcObject = null;
      remoteRenderer.srcObject = null;
    } catch (_) {}
    CallInviteService.clearActiveSession();
  }

  Future<void> _markRemoteSessionEnded() async {
    try {
      await http
          .patch(await FirebaseRealtimeAuth.uri('calls/$roomId/currentSession'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'status': 'ended',
                'endedAt': DateTime.now().millisecondsSinceEpoch,
                'endedBy': selfId,
              }))
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  @override
  Future<void> dispose() async {
    await end();
    await localRenderer.dispose();
    await remoteRenderer.dispose();
    super.dispose();
  }
}
