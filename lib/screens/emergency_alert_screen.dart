import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/localization/app_localizations.dart';
import '../shared/widgets/app_widgets.dart';

class EmergencyAlertScreen extends StatelessWidget {
  const EmergencyAlertScreen({super.key});

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

          // ── Header ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _BackCircle(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.tr('Emergency Alert!'),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 50),
              ],
            ),
          ),

          const Spacer(),

          // ── SOS Circle ───────────────────────────────────────────────
          SizedBox(
            width: 195,
            height: 195,
            child: Stack(
              children: [
                // Outer pink ring
                Container(
                  width: 195,
                  height: 195,
                  decoration: const BoxDecoration(
                    color: AppColors.emergencyLight,
                    shape: BoxShape.circle,
                  ),
                ),
                // Inner dark red circle
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    width: 175,
                    height: 175,
                    decoration: const BoxDecoration(
                      color: AppColors.emergencyDark,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'SOS',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                        fontSize: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // ── Details ──────────────────────────────────────────────────
          SizedBox(
            width: 208,
            child: Column(
              children: [
                _DetailRow(label: 'Type : ', value: 'Fall Detected'),
                const SizedBox(height: 10),
                _DetailRow(label: 'Location: ', value: '30.123, 31.456'),
                const SizedBox(height: 10),
                _DetailRow(label: 'Building: ', value: 'Al Nour Residence'),
                const SizedBox(height: 10),
                _DetailRow(label: 'Floor: ', value: '3, Apartment: 12B'),
              ],
            ),
          ),

          const Spacer(),

          // ── SEND / CANCEL Buttons ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // CANCEL
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 62,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: AppColors.emergencyDark,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        context.tr('CANCEL'),
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF575555),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // SEND & Call
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.emergencyConfirmed,
                    ),
                    child: Container(
                      height: 62,
                      decoration: BoxDecoration(
                        color: AppColors.emergencyDark,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        context.tr('SEND & Call'),
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Detail Row ────────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.tr(label),
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Color(0xFF575555),
            ),
          ),
          Text(
            context.tr(value),
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: AppColors.emergencyDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Back Circle Helper ────────────────────────────────────────────────────────
class _BackCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
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
    );
  }
}

