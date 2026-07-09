import 'package:flutter/material.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/imilab_w12_service.dart';

class EmergencyRow extends StatefulWidget {
  const EmergencyRow({super.key});
  @override
  State<EmergencyRow> createState() => _EmergencyRowState();
}

class _EmergencyRowState extends State<EmergencyRow> {
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

  @override
  Widget build(BuildContext context) {
    final batteryPct = _watchService.batteryLevel;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 328;
        final emergencyCard = SizedBox(
          width: compact ? constraints.maxWidth : 241,
          child: _EmergencyCallCard(),
        );
        final battery = SizedBox(
          width: 71,
          height: 122,
          child: _WatchBatteryImage(
            label: batteryPct == null ? '--' : '$batteryPct%',
          ),
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              emergencyCard,
              const SizedBox(height: 12),
              battery,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            emergencyCard,
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(top: 42),
              child: battery,
            ),
          ],
        );
      },
    );
  }
}

class _EmergencyCallCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.tr('Emergency Call'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.emergencyReport),
          child: Container(
            height: 132,
            decoration: BoxDecoration(
              color: AppColors.emergency,
              border: Border.all(color: const Color(0xFFAC1E0F)),
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    right: 0,
                    child: SizedBox(
                      height: 96,
                      child: Image.asset(
                        AppAssets.ambulancePhoto,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: const Color(0xFFFFBAB3)),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 96,
                    bottom: 0,
                    child: Container(color: AppColors.emergency),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 102,
                    height: 24,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            context.tr('Call for Help'),
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WatchBatteryImage extends StatelessWidget {
  final String label;

  const _WatchBatteryImage({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 71,
      height: 122,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            AppAssets.watchBattery,
            width: 71,
            height: 122,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.battery_charging_full_rounded,
              size: 60,
              color: Color(0xFF8A8989),
            ),
          ),
          Positioned(
            top: 45,
            child: Container(
              width: 54,
              height: 30,
              alignment: Alignment.center,
              color: const Color(0xFFD7D7D7),
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
