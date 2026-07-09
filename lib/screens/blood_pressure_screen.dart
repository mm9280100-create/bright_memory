import 'dart:async';

import 'package:flutter/material.dart';
import '../core/constants/app_assets.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/content_action_service.dart';
import '../core/services/imilab_w12_service.dart';

class BloodPressureScreen extends StatefulWidget {
  const BloodPressureScreen({super.key});

  @override
  State<BloodPressureScreen> createState() => _BloodPressureScreenState();
}

class _BloodPressureScreenState extends State<BloodPressureScreen> {
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

  static const _orange = Color(0xFFF39764);
  static const _blue = Color(0xFF2E72EE);

  @override
  Widget build(BuildContext context) {
    final bloodPressure = _watchService.bloodPressure;
    final pressureText = bloodPressure ?? '--';
    final chartPoints = bloodPressure == null
        ? <double>[120, 126, 118, 123, 119, 122, 117, 121, 122, 116, 123]
        : <double>[
            double.tryParse(bloodPressure.split('/').first) ?? 0,
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
              _TopBar(text: 'Blood Pressure report: $pressureText'),
              const SizedBox(height: 16),

              Text(
                context.tr('Blood Pressure'),
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
                  color: _orange,
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
                          _WhiteCircle(
                            child: Image.asset(
                              AppAssets.vitalArm,
                              width: 16,
                              height: 16,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.monitor_heart_outlined,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.tr('Pressure'),
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
                      top: 84,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            pressureText,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              context.tr('mmHg'),
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
                          'Status: Normal / Hypertension',
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
                          AppAssets.bloodPressurePhoto,
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

              // Legend
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  children: [
                    _LineLegend(color: _blue, label: 'Morning'),
                    const SizedBox(width: 16),
                    _LineLegend(color: _orange, label: 'Evening'),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Chart
              _BPChart(morningPts: chartPoints),
              const SizedBox(height: 16),

              // Stats
              _StatRow(
                bgColor: const Color(0xFFECF2FC),
                iconWidget: const _BarIcon(color: _blue),
                label: 'Average',
                value: bloodPressure == null
                    ? '127/78 mmHg'
                    : '$bloodPressure mmHg',
                valueColor: _blue,
              ),
              const SizedBox(height: 12),
              _StatRow(
                bgColor: const Color(0xFFFFF2EE),
                iconWidget: const _TrendIcon(up: true, color: _orange),
                label: 'Highest',
                value: bloodPressure == null
                    ? '145/92 mmHg'
                    : '$bloodPressure mmHg',
                valueColor: _orange,
              ),
              const SizedBox(height: 12),
              _StatRow(
                bgColor: const Color(0xFFEDF7F1),
                iconWidget: const _TrendIcon(
                  up: false,
                  color: Color(0xFF53A87A),
                ),
                label: 'Lowest',
                value: bloodPressure == null
                    ? '145/92 mmHg'
                    : '$bloodPressure mmHg',
                valueColor: const Color(0xFF53A87A),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _BPChart extends StatelessWidget {
  final List<double> morningPts;
  static const _xLabels = <String>[
    'May 10',
    'May 11',
    'May 12',
    'May 13',
    'May 14',
    'May 15',
    'May 16',
  ];

  const _BPChart({
    this.morningPts = const [120, 135, 128, 145, 132, 127, 138],
  });

  static const _yLabels = ['80', '100', '120', '140', '160'];

  @override
  Widget build(BuildContext context) => Container(
        height: 246,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF575555), width: 0.66),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            children: [
              Text(
                context.tr('Blood Pressure'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF575555),
                ),
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
                              fontSize: 8,
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
                              _BPPainter(morningPts, const Color(0xFF2E72EE)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  children: _xLabels
                      .map(
                        (l) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: Text(
                            l,
                            style: const TextStyle(
                              fontSize: 7,
                              color: Color(0xFF54555A),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      );
}

class _BPPainter extends CustomPainter {
  final List<double> pts;
  final Color color;
  const _BPPainter(this.pts, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFDBDEE4)
      ..strokeWidth = 0.82;
    for (int i = 0; i < 5; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    if (pts.length < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.64
      ..style = PaintingStyle.stroke;
    final path = Path();
    const minV = 80.0, maxV = 160.0;
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
  bool shouldRepaint(_BPPainter old) => old.pts != pts;
}

class _StatRow extends StatelessWidget {
  final Color bgColor, valueColor;
  final Widget iconWidget;
  final String label, value;
  const _StatRow({
    required this.bgColor,
    required this.iconWidget,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: iconWidget),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr(label),
                style: const TextStyle(fontSize: 12, color: Color(0xFF575555)),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ],
      );
}

class _BarIcon extends StatelessWidget {
  final Color color;
  const _BarIcon({required this.color});
  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 12,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 1.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 2),
          Container(
            width: 6,
            height: 22,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 1.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 2),
          Container(
            width: 6,
            height: 16,
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 1.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      );
}

class _TrendIcon extends StatelessWidget {
  final bool up;
  final Color color;
  const _TrendIcon({required this.up, required this.color});
  @override
  Widget build(BuildContext context) => Icon(
        up ? Icons.trending_up_rounded : Icons.trending_down_rounded,
        color: color,
        size: 26,
      );
}

class _LineLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _LineLegend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(
        children: [
          SizedBox(
            width: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(height: 2, color: color),
                Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            context.tr(label),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF212121),
            ),
          ),
        ],
      );
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

class _WhiteCircle extends StatelessWidget {
  final Widget child;
  const _WhiteCircle({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        width: 35,
        height: 35,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      );
}
