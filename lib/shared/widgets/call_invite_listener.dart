import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_routes.dart';
import '../../core/services/call_invite_service.dart';

final appNavigatorKey = GlobalKey<NavigatorState>();

class CallInviteListener extends StatefulWidget {
  final Widget child;

  const CallInviteListener({super.key, required this.child});

  @override
  State<CallInviteListener> createState() => _CallInviteListenerState();
}

class _CallInviteListenerState extends State<CallInviteListener> {
  static const _incomingCallChannel = MethodChannel('br_memory/incoming_call');
  final _service = CallInviteService.instance;
  bool _dialogVisible = false;
  bool _handlingAction = false;
  CallInvite? _lastInvite;
  String? _shownSessionId;

  @override
  void initState() {
    super.initState();
    _service.addListener(_handleInvite);
    _incomingCallChannel.setMethodCallHandler(_handleNativeCallAction);
    _service.start();
    _readInitialNativeCallAction();
  }

  @override
  void dispose() {
    _service.removeListener(_handleInvite);
    super.dispose();
  }

  void _handleInvite() {
    final invite = _service.incomingInvite;
    if (invite == null) {
      if (_dialogVisible && !_handlingAction) {
        appNavigatorKey.currentState?.pop();
      }
      _dialogVisible = false;
      _lastInvite = null;
      _shownSessionId = null;
      unawaited(_incomingCallChannel.invokeMethod('clearIncomingCall'));
      return;
    }
    if (_dialogVisible || !mounted || _shownSessionId == invite.sessionId) {
      return;
    }
    _dialogVisible = true;
    _lastInvite = invite;
    _shownSessionId = invite.sessionId;

    unawaited(_showIncomingCallNotification(invite));
    _showIncomingCallDialog(invite);
  }

  Future<void> _showIncomingCallNotification(CallInvite invite) async {
    await _incomingCallChannel.invokeMethod('showIncomingCall', {
      'callerName': invite.from,
      'isVideo': invite.mode == CallInviteMode.video,
      'sessionId': invite.sessionId,
    });
  }

  Future<void> _readInitialNativeCallAction() async {
    final result = await _incomingCallChannel.invokeMapMethod<String, dynamic>(
      'getInitialAction',
    );
    final action = result?['action']?.toString();
    if (action == null || !mounted) return;
    await _handleCallAction(
      action,
      result?['isVideo'] == true,
      result?['callerName']?.toString(),
      result?['sessionId']?.toString(),
    );
  }

  Future<void> _handleNativeCallAction(MethodCall call) async {
    if (call.method != 'incomingCallAction') return;
    final args = Map<String, dynamic>.from(call.arguments as Map);
    await _handleCallAction(
      args['action']?.toString(),
      args['isVideo'] == true,
      args['callerName']?.toString(),
      args['sessionId']?.toString(),
    );
  }

  Future<void> _handleCallAction(
    String? action,
    bool isVideo, [
    String? callerName,
    String? sessionId,
  ]) async {
    if (!mounted || action == null || _handlingAction) return;
    _handlingAction = true;
    await _incomingCallChannel.invokeMethod('clearIncomingCall');

    if (action == 'decline') {
      final invite = _lastInvite ?? _service.incomingInvite;
      final effectiveSessionId = invite?.sessionId ?? sessionId;
      await _service.sendCallDeclined(
        sessionId: effectiveSessionId,
      );
      _service.clearInvite();
      _dialogVisible = false;
      _lastInvite = null;
      _shownSessionId = null;
      _handlingAction = false;
      return;
    }

    if (action == 'answer') {
      final invite = _lastInvite ?? _service.incomingInvite;
      final effectiveSessionId = invite?.sessionId ?? sessionId;
      final shouldOpenVideo = isVideo || invite?.mode == CallInviteMode.video;
      if (effectiveSessionId != null && effectiveSessionId.isNotEmpty) {
        CallInviteService.activeSessionId = effectiveSessionId;
        CallInviteService.activeInitiatorId ??= CallInviteService.peerId;
        CallInviteService.activeSessionStartedAt ??=
            DateTime.now().millisecondsSinceEpoch;
      }
      await _service.sendCallAccepted(
        sessionId: effectiveSessionId,
      );
      _service.clearInvite();
      _dialogVisible = false;
      _lastInvite = null;
      _shownSessionId = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _openCallRoute(shouldOpenVideo ? AppRoutes.videoCall : AppRoutes.call);
      });
    }
    _handlingAction = false;
  }

  void _openCallRoute(String routeName) {
    final navigator = appNavigatorKey.currentState;
    if (navigator == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _openCallRoute(routeName),
      );
      return;
    }
    navigator.pushNamed(routeName);
  }

  void _showIncomingCallDialog(CallInvite invite) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.24),
      builder: (dialogContext) {
        final isVideo = invite.mode == CallInviteMode.video;
        return IncomingCallDialog(
          callerName: invite.from,
          callType: isVideo ? 'Video call' : 'Audio call',
          declineLabel: 'Decline',
          answerLabel: 'Answer',
          isVideo: isVideo,
          onDecline: () {
            Navigator.pop(dialogContext);
            unawaited(
              _handleCallAction('decline', isVideo, invite.from, invite.sessionId),
            );
          },
          onAnswer: () {
            Navigator.pop(dialogContext);
            unawaited(
              _handleCallAction(
                'answer',
                isVideo,
                invite.from,
                invite.sessionId,
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      _dialogVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class IncomingCallDialog extends StatelessWidget {
  final String callerName;
  final String callType;
  final String declineLabel;
  final String answerLabel;
  final bool isVideo;
  final VoidCallback onDecline;
  final VoidCallback onAnswer;

  const IncomingCallDialog({
    super.key,
    required this.callerName,
    required this.callType,
    required this.declineLabel,
    required this.answerLabel,
    required this.isVideo,
    required this.onDecline,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final initial = callerName.trim().isEmpty
        ? '?'
        : callerName.trim().characters.first.toUpperCase();

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: const Color(0xFF0B64D8),
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              isVideo ? Icons.videocam : Icons.call,
                              color: const Color(0xFF0B64D8),
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            callerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF151515),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            callType,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4B4F47),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _CallActionButton(
                        label: declineLabel.toUpperCase(),
                        icon: Icons.call_end,
                        color: const Color(0xFFE0312B),
                        onTap: onDecline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CallActionButton(
                        label: answerLabel.toUpperCase(),
                        icon: isVideo ? Icons.videocam : Icons.call,
                        color: const Color(0xFF1E8E3E),
                        onTap: onAnswer,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CallActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CallActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(32),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
