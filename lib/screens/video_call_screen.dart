import 'package:flutter/material.dart';

import '../core/services/webrtc_call_service.dart';
import 'webrtc_call_view.dart';

class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const WebRtcCallView(mode: WebRtcCallMode.video);
  }
}
