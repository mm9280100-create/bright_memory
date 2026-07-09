import 'package:flutter/material.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/imilab_w12_service.dart';

class VitalsGrid extends StatefulWidget {
  const VitalsGrid({super.key});

  @override
  State<VitalsGrid> createState() => _VitalsGridState();
}

class _VitalsGridState extends State<VitalsGrid> {
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

  void _handleHeartTap() {
    Navigator.pushNamed(context, AppRoutes.heart);
  }

  @override
  Widget build(BuildContext context) {
    final heartRate = _watchService.heartRate;
    final bloodSugar = _watchService.bloodSugar;
    final bloodPressure = _watchService.bloodPressure;
    final steps = _watchService.steps;
    final sleepMinutes = _watchService.sleepMinutes;

    final vitals = [
      _VitalItem(
        label: 'Heart',
        icon: AppAssets.vitalHeart,
        value: heartRate == null ? '--' : '$heartRate',
        unit: heartRate == null ? '' : 'bpm',
        color: AppColors.vitalHeart,
        route: AppRoutes.heart,
        onTap: _handleHeartTap,
      ),
      _VitalItem(
        label: 'Blood-S',
        icon: AppAssets.vitalBloodSugar,
        value: bloodSugar == null ? '--' : bloodSugar.toStringAsFixed(1),
        unit: bloodSugar == null ? '' : 'mmol/L',
        color: AppColors.vitalBloodS,
        route: AppRoutes.bloodSugar,
      ),
      _VitalItem(
        label: 'Blood-P',
        icon: AppAssets.vitalArm,
        value: bloodPressure ?? '--',
        unit: bloodPressure == null ? '' : 'mmHg',
        color: AppColors.vitalBloodP,
        route: AppRoutes.bloodPressure,
      ),
      _VitalItem(
        label: 'Steps',
        icon: AppAssets.vitalStep,
        value: steps == null ? '--' : '$steps',
        unit: steps == null ? '' : 'St',
        color: AppColors.vitalSteps,
        route: AppRoutes.steps,
      ),
      _VitalItem(
        label: 'Sleep',
        icon: AppAssets.vitalSleep,
        value: sleepMinutes == null ? '--' : '${sleepMinutes ~/ 60}',
        unit: sleepMinutes == null ? '' : 'H ${sleepMinutes % 60} Min',
        color: AppColors.vitalSleep,
        route: AppRoutes.sleepDetail,
      ),
      _VitalItem(
        label: 'Water',
        icon: AppAssets.vitalBottle,
        value: '--',
        unit: '',
        color: AppColors.vitalWater,
        route: AppRoutes.waterReminder,
      ),
    ];

    return SizedBox(
      height: 240,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    for (final item in vitals.take(3)) ...[
                      _VitalCard(item: item),
                      if (item != vitals[2]) const SizedBox(width: 8),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (final item in vitals.skip(3)) ...[
                      _VitalCard(item: item),
                      if (item != vitals[5]) const SizedBox(width: 8),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 104,
              height: 240,
              child: _HealthReportCard(),
            ),
          ],
        ),
      ),
    );
  }
}

class _VitalCard extends StatelessWidget {
  final _VitalItem item;
  const _VitalCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap ?? () => Navigator.pushNamed(context, item.route),
      child: Container(
        width: 104,
        height: 116,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: item.color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              item.icon,
              width: 32,
              height: 32,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.favorite,
                size: 32,
                color: Colors.red,
              ),
            ),
            Text(
              context.tr(item.label),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: Text(
                      context.tr(item.unit),
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF575555),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthReportCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.healthResult),
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: AppColors.reportBg,
          border: Border.all(color: AppColors.reportAccent, width: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
              child: Text(
                context.tr('Health Report'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.reportAccent,
                ),
              ),
            ),
            Expanded(
              child: Image.asset(
                AppAssets.dataResearch,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.bar_chart,
                  size: 54,
                  color: AppColors.reportAccent,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(8, 6, 8, 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.reportAccent, width: 0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.tr('View Report'),
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: AppColors.reportAccent,
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 8,
                      color: AppColors.reportAccent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VitalItem {
  final String label;
  final String icon;
  final String value;
  final String unit;
  final Color color;
  final String route;
  final VoidCallback? onTap;

  const _VitalItem({
    required this.label,
    required this.icon,
    required this.value,
    required this.unit,
    required this.color,
    required this.route,
    this.onTap,
  });
}
