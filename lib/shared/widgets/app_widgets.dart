import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';

// ─── Status Bar ──────────────────────────────────────────────────────────────
class AppStatusBar extends StatelessWidget {
  final bool light;
  const AppStatusBar({super.key, this.light = false});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

// ─── Back Button ─────────────────────────────────────────────────────────────
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: AppColors.lightPurple,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: AppColors.purple,
          size: 20,
        ),
      ),
    );
  }
}

// ─── Text Field ──────────────────────────────────────────────────────────────
class AppTextField extends StatelessWidget {
  final String hint;
  final IconData suffixIcon;
  final bool obscure;
  final TextEditingController? controller;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    required this.hint,
    required this.suffixIcon,
    this.obscure = false,
    this.controller,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.lightPurple,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  decoration: InputDecoration(
                    hintText: context.tr(hint),
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                      fontFamily: 'Roboto',
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(suffixIcon, size: 20, color: AppColors.textGrey),
              ),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            context.tr(errorText!),
            style: const TextStyle(fontSize: 10, color: Color(0xFFE74C3C)),
          ),
        ],
      ],
    );
  }
}

// ─── Primary Button ───────────────────────────────────────────────────────────
class AppPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double? width;

  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? double.infinity,
        height: 51,
        decoration: BoxDecoration(
          color: AppColors.purple,
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: Text(
          context.tr(label),
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// ─── Social Button ────────────────────────────────────────────────────────────
class SocialButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;

  const SocialButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 152,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.textGrey),
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: icon,
      ),
    );
  }
}

// ─── Next Button ──────────────────────────────────────────────────────────────
class AppNextButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const AppNextButton({super.key, required this.onTap, this.label = 'Next'});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 222,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.purple,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.tr(label),
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────
class AppAvatar extends StatelessWidget {
  final String assetPath;
  final double size;

  const AppAvatar({super.key, required this.assetPath, this.size = 60});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: Colors.grey[300],
          child: Icon(Icons.person, size: size * 0.5, color: Colors.grey),
        ),
      ),
    );
  }
}
