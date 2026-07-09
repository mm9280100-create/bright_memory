import 'package:flutter/material.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/content_action_service.dart';
import '../core/services/imilab_w12_service.dart';
import '../shared/widgets/app_widgets.dart';

class HeartScreen extends StatefulWidget {
  const HeartScreen({super.key});

  @override
  State<HeartScreen> createState() => _HeartScreenState();
}

class _HeartScreenState extends State<HeartScreen>
    with SingleTickerProviderStateMixin {
  final _watchService = ImilabW12Service.instance;
  late final AnimationController _pulseController;
  final List<double> _heartHistory = [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _watchService.addListener(_refresh);
    _recordHeartRate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_watchService.isConnected) {
        _watchService.refreshMeasurements();
      }
    });
  }

  @override
  void dispose() {
    _watchService.removeListener(_refresh);
    _pulseController.dispose();
    super.dispose();
  }

  void _refresh() {
    _recordHeartRate();
    if (mounted) setState(() {});
  }

  void _recordHeartRate() {
    final value = _watchService.heartRate;
    if (value == null) return;
    final next = value.toDouble();
    if (_heartHistory.isNotEmpty && _heartHistory.last == next) return;
    _heartHistory.add(next);
    if (_heartHistory.length > 14) {
      _heartHistory.removeAt(0);
    }
  }

  Future<void> _handleWatchTap() async {
    if (_watchService.isConnected) {
      await _watchService.refreshMeasurements();
    }
  }

  @override
  Widget build(BuildContext context) {
    final heartRate = _watchService.heartRate;
    final isMeasuring = _watchService.isReadingMeasurements;
    final isConnected = _watchService.isConnected;
    final heartText = heartRate == null ? '--' : '$heartRate';
    final statusText = isMeasuring
        ? 'Status: Measuring'
        : !isConnected
            ? 'Status: Watch not connected'
            : heartRate == null
                ? 'Status: Not available'
                : 'Status: Normal';
    final shareText = 'Heart report: $heartText bpm. $statusText.';
    final waveReadings = heartRate == null
        ? <double>[]
        : <double>[
            (heartRate - 4).toDouble(),
            heartRate.toDouble(),
            (heartRate + 3).toDouble(),
            (heartRate - 2).toDouble(),
            (heartRate + 1).toDouble(),
          ];
    final chartReadings = _heartHistory.length >= 2
        ? _heartHistory
        : heartRate == null
            ? const <double>[]
            : <double>[
                (heartRate - 3).toDouble(),
                heartRate.toDouble(),
                (heartRate + 2).toDouble(),
              ];

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Status bar ──────────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: AppStatusBar(),
              ),
              const SizedBox(height: 12),

              // ── Top bar: back + copy + share ────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: AppColors.greyBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textDark,
                        size: 20,
                      ),
                    ),
                  ),
                  // Copy + Share
                  Row(
                    children: [
                      _IconBtn(
                        onTap: () =>
                            ContentActionService.copyText(context, shareText),
                        child: const Icon(
                          Icons.copy_outlined,
                          size: 20,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _IconBtn(
                        onTap: () =>
                            ContentActionService.shareText(context, shareText),
                        child: const Icon(
                          Icons.ios_share,
                          size: 20,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ── Title ────────────────────────────────────────────────────
              Text(
                context.tr('Heart'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 14),

              // ── Heartbeat card ───────────────────────────────────────────
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  final pulse = isMeasuring ? _pulseController.value : 0.0;
                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.vitalHeart,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Tooltip(
                              message: context.tr('Refresh readings'),
                              child: GestureDetector(
                                onTap: isConnected ? _handleWatchTap : null,
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Image.asset(
                                    AppAssets.vitalHeart,
                                    width: 18,
                                    height: 18,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.favorite,
                                      size: 18,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              context.tr('Heartbeat'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              heartText,
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textDark,
                              ),
                            ),
                            if (heartRate != null) ...[
                              const SizedBox(width: 4),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  context.tr('bpm'),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          context.tr(statusText),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRect(
                              child: SizedBox(
                                width: double.infinity,
                                height: 80,
                                child: _EcgWavePainter(
                                  bpmReadings: waveReadings,
                                  phase: pulse,
                                  animate: isMeasuring,
                                ),
                              ),
                            ),
                            Container(
                              width: 73,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  heartRate == null
                                      ? '--'
                                      : '$heartRate ${context.tr('bpm')}',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // ── Current Reading ──────────────────────────────────────────
              Text(
                context.tr('Current Reading:'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 174,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8E2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        heartRate == null
                            ? '--'
                            : '$heartRate ${context.tr('bpm')}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF059669),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        context.tr(statusText),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF212121),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Today Heart Activity chart ────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF575555),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        context.tr('Today Heart Activity'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF575555),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 180,
                        child: Row(
                          children: [
                            // Rotated Y-axis title
                            RotatedBox(
                              quarterTurns: 3,
                              child: Text(
                                context.tr('Heart Rate (BPM)'),
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Color(0xFF54555A),
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),
                            // Y-axis numbers
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: const [
                                _AxisLabel('120'),
                                _AxisLabel('90'),
                                _AxisLabel('60'),
                                _AxisLabel('30'),
                                _AxisLabel('0'),
                              ],
                            ),
                            const SizedBox(width: 4),
                            // Chart area
                            Expanded(
                              child: ClipRect(
                                child: Stack(
                                  children: [
                                    CustomPaint(
                                      size: const Size(double.infinity, 180),
                                      painter: _GridPainter(),
                                    ),
                                    AnimatedBuilder(
                                      animation: _pulseController,
                                      builder: (context, _) => CustomPaint(
                                        size: const Size(double.infinity, 180),
                                        painter: _ChartPainter(
                                          dataPoints: chartReadings,
                                          minVal: 0,
                                          maxVal: 120,
                                          phase: _pulseController.value,
                                          animate: isMeasuring,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // X-axis labels
                      Padding(
                        padding: const EdgeInsets.only(left: 48),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              _AxisLabel('8:00'),
                              SizedBox(width: 22),
                              _AxisLabel('10:00'),
                              SizedBox(width: 22),
                              _AxisLabel('13:00'),
                              SizedBox(width: 22),
                              _AxisLabel('15:00'),
                              SizedBox(width: 22),
                              _AxisLabel('17:00'),
                              SizedBox(width: 22),
                              _AxisLabel('19:00'),
                              SizedBox(width: 22),
                              _AxisLabel('21:00'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('Time'),
                        style: const TextStyle(
                            fontSize: 9, color: Color(0xFF3C3C41)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Legend ───────────────────────────────────────────────────
              _HeartStatsLegend(values: _heartHistory),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _IconBtn({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: AppColors.greyBg,
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _AxisLabel extends StatelessWidget {
  final String text;
  const _AxisLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 8, color: Color(0xFF54555A)),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(context.tr(label), style: TextStyle(fontSize: 10, color: color)),
      ],
    );
  }
}

// ─── Painters ─────────────────────────────────────────────────────────────────

class _HeartStatsLegend extends StatelessWidget {
  final List<double> values;

  const _HeartStatsLegend({required this.values});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return Text(
        context.tr('No watch reading yet'),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF575555),
        ),
      );
    }

    final highest = values.reduce((a, b) => a > b ? a : b).round();
    final lowest = values.reduce((a, b) => a < b ? a : b).round();
    final average = (values.reduce((a, b) => a + b) / values.length).round();

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        children: [
          _Legend(
            color: const Color(0xFFDC2626),
            label: 'Highest: $highest bpm',
          ),
          const SizedBox(width: 12),
          _Legend(
            color: const Color(0xFF059669),
            label: 'Average: $average bpm',
          ),
          const SizedBox(width: 12),
          _Legend(
            color: const Color(0xFFFB923C),
            label: 'Lowest: $lowest bpm',
          ),
        ],
      ),
    );
  }
}

class _EcgWavePainter extends StatelessWidget {
  final List<double> bpmReadings;
  final double phase;
  final bool animate;
  const _EcgWavePainter({
    this.bpmReadings = const [],
    this.phase = 0,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 68),
      painter: _EcgPainter(bpmReadings, phase: phase, animate: animate),
    );
  }
}

class _EcgPainter extends CustomPainter {
  final List<double> readings;
  final double phase;
  final bool animate;
  const _EcgPainter(
    this.readings, {
    this.phase = 0,
    this.animate = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    if (readings.isEmpty) {
      final y = size.height * 0.55;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      return;
    }

    final source = readings;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final mid = h * 0.55;
    final minBpm = source.reduce((a, b) => a < b ? a : b);
    final maxBpm = source.reduce((a, b) => a > b ? a : b);
    final range = (maxBpm - minBpm).clamp(1.0, double.infinity);

    path.moveTo(0, mid);
    final segW = w / source.length;
    final offset = animate ? -phase * segW : 0.0;
    for (int i = -1; i <= source.length; i++) {
      final sourceIndex = i % source.length;
      final x = segW * i + offset;
      // normalize bpm to wave amplitude
      final norm = (source[sourceIndex] - minBpm) / range; // 0..1
      final peakH = h * 0.6 * norm + h * 0.15;
      path.lineTo(x + segW * 0.1, mid);
      path.lineTo(x + segW * 0.2, mid - h * 0.1);
      path.lineTo(x + segW * 0.3, mid + h * 0.15);
      path.lineTo(x + segW * 0.4, mid - peakH); // peak driven by data
      path.lineTo(x + segW * 0.5, mid + h * 0.1);
      path.lineTo(x + segW * 0.6, mid - h * 0.05);
      path.lineTo(x + segW * 0.75, mid + h * 0.12);
      path.lineTo(x + segW * 0.9, mid);
    }
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_EcgPainter old) =>
      old.readings != readings || old.phase != phase || old.animate != animate;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFDBDEE4)
      ..strokeWidth = 0.8;

    final axisPaint = Paint()
      ..color = const Color(0xFF54555A)
      ..strokeWidth = 1.2;

    // horizontal grid lines (5 lines, leave bottom 15px for X axis visibility)
    for (int i = 0; i < 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Y axis
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), axisPaint);

    // X axis
    canvas.drawLine(
        Offset(0, size.height), Offset(size.width, size.height), axisPaint);
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}

class _ChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final double minVal;
  final double maxVal;
  final double phase;
  final bool animate;

  _ChartPainter({
    this.dataPoints = const [],
    this.minVal = 0,
    this.maxVal = 120,
    this.phase = 0,
    this.animate = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;
    final source = dataPoints;

    final paint = Paint()
      ..color = const Color(0xFFFB923C)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFFFB923C)
      ..style = PaintingStyle.fill;

    final range = (maxVal - minVal).clamp(1.0, double.infinity);

    // Convert data to canvas points
    final shifted = animate
        ? List<double>.generate(source.length, (i) {
            final index = (i + (phase * source.length).floor()) % source.length;
            return source[index];
          })
        : source;
    final scaledPoints = List.generate(shifted.length, (i) {
      final x = shifted.length == 1
          ? size.width / 2
          : size.width * i / (shifted.length - 1);
      final availableH = size.height - 8; // 8px bottom padding for X axis
      final y = availableH * (1 - (shifted[i] - minVal) / range);
      return Offset(x, y);
    });

    // Line path
    final linePath = Path();
    linePath.moveTo(scaledPoints.first.dx, scaledPoints.first.dy);
    for (int i = 1; i < scaledPoints.length; i++) {
      final cp = Offset(
        (scaledPoints[i - 1].dx + scaledPoints[i].dx) / 2,
        (scaledPoints[i - 1].dy + scaledPoints[i].dy) / 2,
      );
      linePath.quadraticBezierTo(
        scaledPoints[i - 1].dx,
        scaledPoints[i - 1].dy,
        cp.dx,
        cp.dy,
      );
    }
    // close to last point
    linePath.lineTo(scaledPoints.last.dx, scaledPoints.last.dy);
    canvas.drawPath(linePath, paint);

    // Dots - clipped within bounds
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    for (final pt in scaledPoints) {
      canvas.drawCircle(pt, 3.5, dotPaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.dataPoints != dataPoints ||
      old.phase != phase ||
      old.animate != animate;
}
