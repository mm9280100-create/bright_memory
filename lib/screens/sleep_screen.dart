import 'dart:async';

import 'package:flutter/material.dart';
import '../core/constants/app_assets.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/content_action_service.dart';
import '../core/services/imilab_w12_service.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  final _watchService = ImilabW12Service.instance;

  @override
  void initState() {
    super.initState();
    _watchService.addListener(_refresh);
    unawaited(_watchService.refreshMeasurements());
  }

  @override
  void dispose() {
    _watchService.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  static const _blueCard = Color(0xFFA5BBEC);

  @override
  Widget build(BuildContext context) {
    final sleepMinutes = _watchService.sleepMinutes;
    final hours = sleepMinutes == null ? '--' : '${sleepMinutes ~/ 60}';
    final minutes = sleepMinutes == null ? '--' : '${sleepMinutes % 60}';
    const sleepStages = <double>[0, 1, 1, 0, 2, 1, 0, 1, 1];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _TopBar(text: 'Sleep report: $hours h $minutes m'),
              const SizedBox(height: 16),
              Text(
                context.tr('Sleep'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 8),

              // Main card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _blueCard,
                  borderRadius: BorderRadius.circular(24),
                ),
                height: 161,
                child: Stack(
                  children: [
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Row(
                        children: [
                          Container(
                            width: 35,
                            height: 35,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Image.asset(
                                AppAssets.vitalSleep,
                                width: 16,
                                height: 16,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.bedtime_outlined,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.tr('Sleep Analysis'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF212121),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 16,
                      top: 75,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            hours,
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF212121),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              context.tr('H'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF212121),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            minutes,
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF212121),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              context.tr('Min'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF212121),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 16,
                      top: 125,
                      child: Text(
                        context.tr(
                          'Status: Sleep',
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          AppAssets.sleepPhoto,
                          width: 130,
                          height: 145,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 130,
                            height: 145,
                            color: Colors.white24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Chart
              _SleepChart(
                sleepStages: sleepStages,
                xLabels: const [
                  '10pm',
                  '11pm',
                  '12am',
                  '1am',
                  '2am',
                  '3am',
                  '4am',
                  '5am',
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SleepChart extends StatelessWidget {
  final List<double> sleepStages;
  final List<String> xLabels;

  const _SleepChart({required this.sleepStages, required this.xLabels});

  @override
  Widget build(BuildContext context) => Container(
        height: 246,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF575555), width: 0.6),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            children: [
              Text(
                context.tr('Sleep Timeline'),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF575555),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            context.tr('Deep\nSleep'),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 7, color: Color(0xFF54555A)),
                          ),
                          Text(
                            context.tr('Light\nSleep'),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 7, color: Color(0xFF54555A)),
                          ),
                          Text(
                            context.tr('Awake'),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                fontSize: 7, color: Color(0xFF54555A)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) => CustomPaint(
                          size:
                              Size(constraints.maxWidth, constraints.maxHeight),
                          painter: _SleepPainter(
                            sleepStages,
                            const Color(0xFFA5BBEC),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: xLabels
                    .map(
                      (l) => Text(
                        l,
                        style: const TextStyle(
                          fontSize: 8,
                          color: Color(0xFF54555A),
                        ),
                      ),
                    )
                    .toList(),
              ),
              Text(
                context.tr('Time'),
                style: const TextStyle(fontSize: 9, color: Color(0xFF212121)),
              ),
            ],
          ),
        ),
      );
}

class _SleepPainter extends CustomPainter {
  final List<double> pts;
  final Color color;
  const _SleepPainter(this.pts, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFDBDEE4)
      ..strokeWidth = 0.82;
    for (int i = 0; i < 3; i++) {
      final y = size.height * i / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    if (pts.length < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path();
    for (int i = 0; i < pts.length; i++) {
      final x = size.width * i / (pts.length - 1);
      final y = size.height * (1 - pts[i] / 2.0);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SleepPainter old) => old.pts != pts;
}

class _TopBar extends StatelessWidget {
  final String text;
  const _TopBar({required this.text});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleBtn(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Color(0xFF212121),
            ),
          ),
          Row(
            children: [
              _CircleBtn(
                onTap: () => ContentActionService.copyText(context, text),
                child: const Icon(
                  Icons.copy_outlined,
                  size: 18,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(width: 8),
              _CircleBtn(
                onTap: () => ContentActionService.shareText(context, text),
                child: const Icon(
                  Icons.ios_share_outlined,
                  size: 18,
                  color: Color(0xFF212121),
                ),
              ),
            ],
          ),
        ],
      );
}

class _CircleBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _CircleBtn({required this.child, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: Color(0xFFEDEDED),
            shape: BoxShape.circle,
          ),
          child: Center(child: child),
        ),
      );
}
