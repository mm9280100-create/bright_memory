import 'package:flutter/material.dart';
import '../core/constants/app_assets.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/content_action_service.dart';

class WaterScreen extends StatelessWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const _TopBar(
                  text: 'Water reminder: Please drink 2 glass of water now.'),
              const SizedBox(height: 16),

              // Reminder card (purple)
              Text(
                context.tr('Water reminder'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1ADFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Image.asset(
                              AppAssets.cupIcon,
                              width: 24,
                              height: 24,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.local_drink, size: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            context.tr('Please drink 2 glass of water now.'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF212121),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7E5987),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          context.tr('Send'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Goal card (yellow)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CF),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          context.tr('Goal : '),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const Text(
                          '3L',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF575555),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      children: List.generate(
                        12,
                        (i) => Image.asset(
                          AppAssets.drinkIcon,
                          width: 16,
                          height: 16,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.local_drink,
                            size: 16,
                            color: Color(0xFF7E5987),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          '8/12',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          context.tr('Cups'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF575555),
                          ),
                        ),
                      ],
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
