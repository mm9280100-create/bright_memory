class WebRtcIceConfig {
  WebRtcIceConfig._();

  static const _turnUrls = String.fromEnvironment('TURN_URLS');
  static const _turnUsername = String.fromEnvironment('TURN_USERNAME');
  static const _turnCredential = String.fromEnvironment('TURN_CREDENTIAL');
  static const _forceTurn = bool.fromEnvironment(
    'FORCE_TURN',
    defaultValue: false,
  );

  static Map<String, dynamic> peerConnectionConfig() {
    return {
      'iceServers': _iceServers(),
      'iceTransportPolicy': _forceTurn ? 'relay' : 'all',
      'sdpSemantics': 'unified-plan',
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
      'iceCandidatePoolSize': 10,
    };
  }

  static List<Map<String, dynamic>> _iceServers() {
    final servers = <Map<String, dynamic>>[
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ];

    if (_turnUrls.trim().isNotEmpty &&
        _turnUsername.trim().isNotEmpty &&
        _turnCredential.trim().isNotEmpty) {
      servers.add({
        'urls': _turnUrls.split(',').map((url) => url.trim()).toList(),
        'username': _turnUsername,
        'credential': _turnCredential,
      });
      return servers;
    }

    servers.add({
      'urls': [
        'turn:openrelay.metered.ca:80',
        'turn:openrelay.metered.ca:80?transport=tcp',
        'turn:openrelay.metered.ca:443',
        'turn:openrelay.metered.ca:443?transport=tcp',
        'turns:openrelay.metered.ca:443?transport=tcp',
      ],
      'username': 'openrelayproject',
      'credential': 'openrelayproject',
    });
    return servers;
  }
}
