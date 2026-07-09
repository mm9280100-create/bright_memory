import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/webrtc_call_service.dart';

class WebRtcCallView extends StatefulWidget {
  final WebRtcCallMode mode;

  const WebRtcCallView({super.key, required this.mode});

  @override
  State<WebRtcCallView> createState() => _WebRtcCallViewState();
}

class _WebRtcCallViewState extends State<WebRtcCallView> {
  late final WebRtcCallService _service;
  Timer? _timer;
  int _seconds = 0;
  bool _ending = false;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _service = WebRtcCallService()..addListener(_refresh);
    _start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  Future<void> _start() async {
    try {
      await _service.start(mode: widget.mode);
    } catch (_) {
      if (!mounted) return;
      setState(() {});
    }
  }

  void _refresh() {
    if (!mounted) return;
    if (_service.hasEnded && !_closed) {
      _closed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.maybePop(context);
      });
      return;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _service.removeListener(_refresh);
    _service.dispose();
    super.dispose();
  }

  String get _timeStr {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.mode == WebRtcCallMode.video;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (isVideo)
            RTCVideoView(
              _service.remoteRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            )
          else
            _AudioBackground(status: context.tr(_service.status)),
          Container(color: Colors.black.withValues(alpha: isVideo ? 0.12 : 0)),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 18,
                  left: 18,
                  child: _CircleIconButton(
                    icon: Icons.arrow_back,
                    onTap: _endCall,
                  ),
                ),
                Positioned(
                  top: isVideo ? 28 : 220,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        context.tr('Dad'),
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${context.tr(_service.status)}  $_timeStr',
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEDEDED),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isVideo)
                  Positioned(
                    top: 86,
                    right: 16,
                    child: GestureDetector(
                      onTap: _service.switchCamera,
                      child: Container(
                        width: 104,
                        height: 154,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: RTCVideoView(
                          _service.localRenderer,
                          mirror: true,
                          objectFit:
                              RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 34,
                  right: 34,
                  bottom: 36,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CallControl(
                        icon: Icons.volume_up_outlined,
                        active: _service.speaker,
                        onTap: _service.toggleSpeaker,
                      ),
                      _CallControl(
                        icon: _service.muted ? Icons.mic_off : Icons.mic_none,
                        active: _service.muted,
                        onTap: _service.toggleMute,
                      ),
                      if (isVideo)
                        _CallControl(
                          icon: Icons.cameraswitch_outlined,
                          onTap: _service.switchCamera,
                        )
                      else
                        _CallControl(
                          icon: Icons.videocam_outlined,
                          onTap: () => Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.videoCall,
                          ),
                        ),
                      _CallControl(
                        icon: Icons.call_end,
                        danger: true,
                        onTap: _endCall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _endCall() async {
    if (_ending) return;
    _ending = true;
    await _service.end();
    if (!mounted) return;
    if (!_closed) {
      _closed = true;
      Navigator.maybePop(context);
    }
  }
}

class _AudioBackground extends StatelessWidget {
  final String status;

  const _AudioBackground({required this.status});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          AppAssets.dad,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Container(color: const Color(0xFF333333)),
        ),
        Container(color: Colors.black.withValues(alpha: 0.48)),
        Center(
          child: Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.person, size: 64, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black, size: 22),
      ),
    );
  }
}

class _CallControl extends StatelessWidget {
  final IconData icon;
  final bool active;
  final bool danger;
  final VoidCallback onTap;

  const _CallControl({
    required this.icon,
    required this.onTap,
    this.active = false,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final background = danger
        ? AppColors.emergency
        : active
            ? Colors.white
            : Colors.white.withValues(alpha: 0.16);
    final foreground = danger || !active ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: danger ? null : Border.all(color: Colors.white, width: 1.4),
        ),
        child: Icon(icon, color: foreground, size: 24),
      ),
    );
  }
}
