import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/localization/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _waveCtrl;
  late final Animation<double> _waveAnim;
  late final AnimationController _logoCtrl;
  late final Animation<double> _logoAnim;

  @override
  void initState() {
    super.initState();

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _waveAnim = CurvedAnimation(parent: _waveCtrl, curve: Curves.easeInOut);

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoAnim = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn);

    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 400), _waveCtrl.forward);
    Future.delayed(const Duration(milliseconds: 3800), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    });
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _logoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _waveAnim,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _WavePainter(progress: _waveAnim.value),
            ),
          ),
          FadeTransition(
            opacity: _logoAnim,
            child: const Center(child: _SplashLogo()),
          ),
        ],
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/splash/logo.png',
              width: 90,
              height: 100,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.psychology, size: 90, color: AppColors.gold),
            ),
            const SizedBox(height: 6),
            Text(
              context.tr('Br. memory'),
              style: const TextStyle(
                fontFamily: 'PoiretOne',
                fontSize: 24,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        Positioned(
          top: -8,
          right: -28,
          child: Image.asset(
            'assets/images/splash/sparkles.png',
            width: 39,
            height: 46,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),
        ),
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  const _WavePainter({required this.progress});

  static const _tops = [0.90, 0.84, 0.79, 0.73];
  static const _colors = [
    Color(0xFFEEBDF9),
    Color(0xFFD28CE3),
    Color(0xFF9A61A8),
    Color(0xFF805A89),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = _colors.length - 1; i >= 0; i--) {
      final top = _lerp(size.height, _tops[i] * size.height, progress);
      final amp = 18.0 + i * 4;
      final paint = Paint()
        ..color = _colors[i]
        ..style = PaintingStyle.fill;
      final path = Path()..moveTo(0, top);
      for (double x = 0; x <= size.width; x++) {
        path.lineTo(x, top + sin(x / size.width * 2 * pi) * amp);
      }
      path
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(_WavePainter old) => old.progress != progress;
}

