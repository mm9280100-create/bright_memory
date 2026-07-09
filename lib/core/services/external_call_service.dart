import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class ExternalCallService {
  ExternalCallService._();

  static const MethodChannel _channel = MethodChannel('br_memory/contact');

  static const String dadPhoneNumber = '+201000000000';
  static const String voiceRoomUrl =
      'https://meet.jit.si/br-memory-omar-dad-voice#config.startWithVideoMuted=true';
  static const String videoRoomUrl =
      'https://meet.jit.si/br-memory-omar-dad-video';

  static Future<bool> openPhoneCall({
    String phoneNumber = dadPhoneNumber,
  }) async {
    try {
      await Permission.phone.request();
      final result = await _channel.invokeMethod<bool>('openPhoneCall', {
        'phoneNumber': phoneNumber,
      });
      return result == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> openVoiceCallRoom() async {
    try {
      final result = await _channel.invokeMethod<bool>('openMeetingRoom', {
        'url': voiceRoomUrl,
      });
      return result == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> openVideoCallRoom() async {
    try {
      final result = await _channel.invokeMethod<bool>('openMeetingRoom', {
        'url': videoRoomUrl,
      });
      return result == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> openWhatsApp({
    String phoneNumber = dadPhoneNumber,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('openWhatsApp', {
        'phoneNumber': phoneNumber,
      });
      return result == true;
    } catch (_) {
      return false;
    }
  }
}
