import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContentActionService {
  ContentActionService._();

  static const MethodChannel _channel = MethodChannel('br_memory/contact');

  static Future<void> copyText(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied')),
    );
  }

  static Future<void> shareText(BuildContext context, String text) async {
    try {
      final shared = await _channel.invokeMethod<bool>('shareText', {
        'text': text,
      });
      if (!context.mounted || shared == true) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open share menu')),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open share menu')),
      );
    }
  }
}
