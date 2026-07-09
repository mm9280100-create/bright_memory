import 'package:flutter/material.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/services/external_call_service.dart';
import '../core/localization/app_localizations.dart';
import '../shared/widgets/app_widgets.dart';

class EmergencyReportScreen extends StatefulWidget {
  const EmergencyReportScreen({super.key});

  @override
  State<EmergencyReportScreen> createState() => _EmergencyReportScreenState();
}

class _EmergencyReportScreenState extends State<EmergencyReportScreen> {
  int _selected = 0; // 0=Fall, 1=Fire, 2=Flood

  static const _types = [
    {
      'label': 'Fall',
      'asset': AppAssets.emergencySlip,
      'color': AppColors.emergencyDark,
      'phone': '123',
    },
    {
      'label': 'Fire',
      'asset': AppAssets.emergencyFire,
      'color': AppColors.greyBg,
      'phone': '180',
    },
    {
      'label': 'Flood',
      'asset': AppAssets.emergencyFlood,
      'color': AppColors.greyBg,
      'phone': '125',
    },
  ];

  Future<void> _callSelectedEmergency() async {
    final phoneNumber = _types[_selected]['phone'] as String;
    final opened = await ExternalCallService.openPhoneCall(
      phoneNumber: phoneNumber,
    );
    if (!mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${context.tr('Call')} $phoneNumber'),
      ),
    );
  }

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
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _BackCircle(),
                ),
                Text(
                  context.tr('REPORT'),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 90),

          // ── What kind ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.tr('What kind of emergency ?'),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Type Buttons ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_types.length, (i) {
                final isSelected = _selected == i;
                final bgColor =
                    isSelected ? AppColors.emergencyDark : AppColors.greyBg;
                final labelColor = isSelected
                    ? AppColors.emergencyDark
                    : const Color(0xFF575555);

                return GestureDetector(
                  onTap: () => setState(() => _selected = i),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: bgColor,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(9),
                        child: Image.asset(
                          _types[i]['asset'] as String,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.warning,
                            color: isSelected ? Colors.white : Colors.grey,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 50,
                        child: Text(
                          context.tr(_types[i]['label'] as String),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: labelColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 70),

          // ── Location Bar ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 42,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0x8292180B), width: 0.5),
                  bottom: BorderSide(color: Color(0x8292180B), width: 1),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  // Location icon
                  Image.asset(
                    AppAssets.emergencyPin,
                    width: 24,
                    height: 24,
                    color: AppColors.emergencyDark,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.emergencyDark,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('Where is the emergency?'),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColors.emergencyDark,
                      ),
                    ),
                  ),
                  // MY LOCATION button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.emergencyDark,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      context.tr('MY LOCATION'),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 8,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Map Preview ──────────────────────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 0),
              child: Image.asset(
                AppAssets.emergencyMap,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFE8F5E9),
                  child: const Center(
                    child: Icon(Icons.map, size: 80, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),

          // ── Call Button ───────────────────────────────────────────────
          GestureDetector(
            onTap: _callSelectedEmergency,
            child: Container(
              width: double.infinity,
              height: 62,
              color: AppColors.emergencyDark,
              alignment: Alignment.center,
              child: Text(
                context.tr('Call'),
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
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
