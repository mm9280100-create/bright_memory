import 'package:flutter/material.dart';
import '../core/constants/app_assets.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/content_action_service.dart';
import '../core/services/imilab_w12_service.dart';

class BloodSugarScreen extends StatefulWidget {
  const BloodSugarScreen({super.key});

  @override
  State<BloodSugarScreen> createState() => _BloodSugarScreenState();
}

class _BloodSugarScreenState extends State<BloodSugarScreen> {
  final _watchService = ImilabW12Service.instance;

  @override
  void initState() {
    super.initState();
    _watchService.addListener(_refresh);
  }

  @override
  void dispose() {
    _watchService.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  static const _pink = Color(0xFFF2AAC3);
  static const _blue = Color(0xFFBED2FF);
  static const _darkPink = Color(0xFFFFD7E5);
  static const _green = Color(0xFF059669);

  @override
  Widget build(BuildContext context) {
    final bloodSugar = _watchService.bloodSugar;
    final sugarText = bloodSugar == null ? '--' : bloodSugar.toStringAsFixed(1);
    final sugarUnit = bloodSugar == null ? '' : 'mmol/L';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _TopBar(text: 'Blood Sugar report: $sugarText $sugarUnit'),
              const SizedBox(height: 16),

              // Title
              Text(
                context.tr('Blood Sugar'),
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
                  color: _pink,
                  borderRadius: BorderRadius.circular(24),
                ),
                height: 161,
                child: Stack(
                  children: [
                    // Icon + label
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Row(
                        children: [
                          _WhiteCircle(
                            child: Image.asset(
                              AppAssets.vitalBloodSugar,
                              width: 16,
                              height: 16,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.water_drop_outlined,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.tr('Glucose'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF212121),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Value
                    Positioned(
                      left: 16,
                      top: 75,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            sugarText,
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
                              context.tr(sugarUnit),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF212121),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status
                    Positioned(
                      left: 16,
                      top: 125,
                      child: Text(
                        context.tr(
                          'Status: High / Normal',
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ),
                    // Photo
                    Positioned(
                      right: 8,
                      top: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          AppAssets.bloodSugarPhoto,
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
              const SizedBox(height: 12),

              // Before / After meal cards
              Row(
                children: [
                  Expanded(
                    child: _MealCard(
                      color: _blue,
                      label: 'Before Meal',
                      icon: AppAssets.hungryIcon,
                      value: bloodSugar == null
                          ? '--'
                          : '${bloodSugar.toStringAsFixed(1)} mmol/L',
                      time: '1:30 PM',
                      note: 'Ate sweets',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MealCard(
                      color: _darkPink,
                      label: 'After Meal',
                      icon: AppAssets.healthyFoodIcon,
                      value: '6.5 mmol/L',
                      time: '8:00 PM',
                      note: 'Missed medication',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Chart
              const _BloodSugarChart(),
              const SizedBox(height: 12),

              // Legend
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  children: [
                    _LegendDot(color: _pink, label: 'Highest: 90 mg/dL'),
                    const SizedBox(width: 10),
                    _LegendDot(color: _green, label: 'Average: 59 mg/dL'),
                    const SizedBox(width: 10),
                    _LegendDot(
                      color: const Color(0xFFFB923C),
                      label: 'Lowest: 48mg/dL',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final Color color;
  final String label, icon, value, time, note;
  const _MealCard({
    required this.color,
    required this.label,
    required this.icon,
    required this.value,
    required this.time,
    required this.note,
  });

  @override
  Widget build(BuildContext context) => Container(
        height: 101,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _WhiteCircle(
                  child: Image.asset(
                    icon,
                    width: 16,
                    height: 16,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.restaurant, size: 14),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    context.tr(label),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF575555),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              context.tr(note),
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w500,
                color: Color(0xFF212121),
              ),
            ),
          ],
        ),
      );
}

class _BloodSugarChart extends StatelessWidget {
  static const _points = <double>[
    55,
    70,
    56,
    69,
    74,
    65,
    68,
    77,
    66,
    74,
    70,
    74
  ];
  static const _xLabels = <String>[
    '7:00',
    '9:00',
    '11:00',
    '1:00',
    '3:00',
    '5:00',
    '6:00',
    '8:00',
  ];

  const _BloodSugarChart();

  static const _yLabels = ['30', '50', '70', '90'];

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
                context.tr('Today Blood Sugar'),
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
                    // Y labels
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
                        const SizedBox(height: 2),
                      ],
                    ),
                    const SizedBox(width: 4),
                    // Chart area
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) => CustomPaint(
                          size:
                              Size(constraints.maxWidth, constraints.maxHeight),
                          painter: _LinePainter(
                            _points,
                            const Color(0xFF059669),
                          ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            l,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF54555A),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
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

class _LinePainter extends CustomPainter {
  final List<double> points;
  final Color color;
  const _LinePainter(this.points, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final gridPaint = Paint()
      ..color = const Color(0xFFDBDEE4)
      ..strokeWidth = 0.82;

    // Grid lines
    for (int i = 0; i < 4; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (points.isEmpty) return;
    const minV = 30.0, maxV = 90.0;
    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1);
      final y = size.height * (1 - (points[i] - minV) / (maxV - minV));
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.points != points;
}

// ── Shared widgets ──────────────────────────────────────────────────────────
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

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            context.tr(label),
            style: const TextStyle(fontSize: 10, color: Color(0xFF212121)),
          ),
        ],
      );
}
