import 'package:flutter/material.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/localization/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  static const _pages = [
    _PageData(
      image: AppAssets.onboarding1,
      title: 'A digital solution',
      subtitle:
          "That supports Alzheimer's families and makes care-giving easier and more humane",
      progress: 1,
    ),
    _PageData(
      image: AppAssets.onboarding2,
      title: 'patient Day Mgmt',
      subtitle: 'medication, meal, and check-ups all in one smart system',
      progress: 2,
    ),
    _PageData(
      image: AppAssets.onboarding3,
      title: 'Instant alerts',
      subtitle:
          "continuous connection because the patient's comfort starts with their family's peace of mind",
      progress: 3,
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _previous() {
    if (_page == 0) return;
    _ctrl.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: PageView.builder(
        controller: _ctrl,
        onPageChanged: (i) => setState(() => _page = i),
        itemCount: _pages.length,
        itemBuilder: (_, i) => _OnboardingPage(
          data: _pages[i],
          onNext: _next,
          onSkip: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.login),
          onBack: _previous,
          total: _pages.length,
        ),
      ),
    );
  }
}

class _PageData {
  final String image, title, subtitle;
  final int progress;
  const _PageData({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.progress,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _PageData data;
  final VoidCallback onNext, onSkip, onBack;
  final int total;

  const _OnboardingPage({
    required this.data,
    required this.onNext,
    required this.onSkip,
    required this.onBack,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final canGoBack = data.progress > 1;

    return Stack(
      children: [
        Positioned(
          left: 24,
          right: 24,
          top: MediaQuery.paddingOf(context).top + 32,
          bottom: 32,
          child: ClipPath(
            clipper: const _OnboardingCardClipper(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  data.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: Colors.grey[800]),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x22000000),
                        Color(0x33000000),
                        Color(0x99000000),
                        Color(0xF2000000),
                      ],
                      stops: [0.0, 0.48, 0.78, 1.0],
                    ),
                  ),
                ),
                if (canGoBack)
                  Positioned(
                    top: 28,
                    left: 24,
                    child: GestureDetector(
                      onTap: onBack,
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ),
                  ),
                Positioned(
                  top: 28,
                  right: 24,
                  child: data.progress == 3
                      ? const SizedBox.shrink()
                      : GestureDetector(
                          onTap: onSkip,
                          child: Text(
                            context.tr('Skip'),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  left: 26,
                  right: 70,
                  bottom: 130,
                  child: DefaultTextStyle(
                    style: const TextStyle(color: AppColors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.tr(data.title),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          context.tr(data.subtitle),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontFamily: 'Afacad',
                            height: 1.35,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 39,
                  bottom: 28,
                  child: GestureDetector(
                    onTap: onNext,
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 24,
          bottom: 62,
          child: Stack(
            children: [
              Container(
                width: 93,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEAEA),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                width: 93 * data.progress / total,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFC69DCF),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnboardingCardClipper extends CustomClipper<Path> {
  const _OnboardingCardClipper();

  @override
  Path getClip(Size size) {
    const radius = 48.0;
    const leftLift = 70.0;
    final w = size.width;
    final h = size.height;
    final liftedBottom = h - leftLift;
    final tailStart = w * 0.58;

    return Path()
      ..moveTo(radius, 0)
      ..lineTo(w - radius, 0)
      ..quadraticBezierTo(w, 0, w, radius)
      ..lineTo(w, h - radius)
      ..quadraticBezierTo(w, h, w - radius, h)
      ..lineTo(tailStart + 46, h)
      ..cubicTo(
        tailStart + 20,
        h,
        tailStart + 18,
        liftedBottom,
        tailStart,
        liftedBottom,
      )
      ..lineTo(radius, liftedBottom)
      ..quadraticBezierTo(0, liftedBottom, 0, liftedBottom - radius)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
