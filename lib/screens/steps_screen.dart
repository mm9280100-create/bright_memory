import 'dart:async';

import 'package:flutter/material.dart';
import '../core/constants/app_assets.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/content_action_service.dart';
import '../core/services/imilab_w12_service.dart';

class StepsScreen extends StatefulWidget {
  const StepsScreen({super.key});

  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
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

  static const _yellow = Color(0xFFF7E39A);

  @override
  Widget build(BuildContext context) {
    final steps = _watchService.steps;
    final stepsText = steps == null ? '--' : '$steps';
    final chartPoints = steps == null
        ? <double>[95, 70, 180, 220, 350, 580, 370, 430]
        : <double>[
            (steps * 0.15).toDouble(),
            (steps * 0.35).toDouble(),
            (steps * 0.55).toDouble(),
            (steps * 0.75).toDouble(),
            steps.toDouble(),
          ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _TopBar(text: 'Steps report: $stepsText steps'),
              const SizedBox(height: 16),
              Text(
                context.tr('Steps'),
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
                  color: _yellow,
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
                                AppAssets.vitalStep,
                                width: 16,
                                height: 16,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.directions_walk, size: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.tr('Daily Activity'),
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
                            stepsText,
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              context.tr('steps'),
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
                          'Status: Normal',
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
                          AppAssets.stepsPhoto,
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
              _StepsChart(
                activity: chartPoints,
                xLabels: const [
                  '6am',
                  '8am',
                  '10am',
                  '12pm',
                  '2pm',
                  '4pm',
                  '6pm',
                  '8pm',
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

class _StepsChart extends StatelessWidget {
  final List<double> activity;
  final List<String> xLabels;

  const _StepsChart({required this.activity, required this.xLabels});

  static const _yLabels = ['0', '200', '400', '600', '800'];

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
              Row(
                children: [
                  _ChartLegendDot(
                    color: const Color(0xFFF7E39A),
                    label: context.tr('activity'),
                  ),
                  Expanded(
                    child: Text(
                      context.tr('Activity Steps'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3C3C41),
                      ),
                    ),
                  ),
                  _ChartLegendDot(
                    color: const Color(0xFFFF8A84),
                    label: context.tr('Time'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ..._yLabels.reversed.map(
                          (l) => Text(
                            l,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF54555A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) => CustomPaint(
                          size:
                              Size(constraints.maxWidth, constraints.maxHeight),
                          painter:
                              _StepsPainter(activity, const Color(0xFFF7E39A)),
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
                          fontSize: 9,
                          color: Color(0xFF54555A),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      );
}

class _ChartLegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _ChartLegendDot({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF575555)),
          ),
        ],
      );
}

class _StepsPainter extends CustomPainter {
  final List<double> pts;
  final Color color;
  const _StepsPainter(this.pts, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFDBDEE4)
      ..strokeWidth = 0.82;
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(
        Offset(0, size.height * i / 4),
        Offset(size.width, size.height * i / 4),
        gridPaint,
      );
    }
    if (pts.length < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.64
      ..style = PaintingStyle.stroke;
    const minV = 0.0, maxV = 800.0;
    final path = Path();
    for (int i = 0; i < pts.length; i++) {
      final x = size.width * i / (pts.length - 1);
      final y = size.height * (1 - (pts[i] - minV) / (maxV - minV));
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      canvas.drawCircle(
        Offset(x, y),
        3,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        Offset(x, y),
        3,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StepsPainter old) => old.pts != pts;
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
