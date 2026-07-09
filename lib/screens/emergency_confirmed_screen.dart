import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/localization/app_localizations.dart';
import '../shared/widgets/app_widgets.dart';

class EmergencyConfirmedScreen extends StatelessWidget {
  const EmergencyConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // ── Status Bar ───────────────────────────────────────────────
          const SizedBox(height: 16),
          const AppStatusBar(),
          const SizedBox(height: 16),

          // ── Back Button ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                ),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: AppColors.greyBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.textDark,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),

          const Spacer(),

          // ── Confirm Icon ─────────────────────────────────────────────
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: AppColors.emergencyDark,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CustomPaint(
                size: Size(52, 40),
                painter: _CheckPainter(),
              ),
            ),
          ),

          const SizedBox(height: 56),

          // ── Message ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 72),
            child: Text(
              context.tr(
                  'We will contact the nearest hospital, police station to your current location'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                height: 1.5,
                letterSpacing: 0.02 * 16,
                color: Color(0xFF575555),
              ),
            ),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.12, size.height * 0.48)
      ..lineTo(size.width * 0.40, size.height * 0.76)
      ..lineTo(size.width * 0.88, size.height * 0.18);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) => false;
}

