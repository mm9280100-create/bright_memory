import 'package:flutter/material.dart';

import '../core/localization/app_localizations.dart';
import '../core/services/content_action_service.dart';
import '../core/services/imilab_w12_service.dart';

class HealthResultScreen extends StatefulWidget {
  const HealthResultScreen({super.key});

  @override
  State<HealthResultScreen> createState() => _HealthResultScreenState();
}

class _HealthResultScreenState extends State<HealthResultScreen> {
  static const _green = Color(0xFFCFE9BC);
  static const _orange = Color(0xFFC77817);

  final _watchService = ImilabW12Service.instance;

  @override
  void initState() {
    super.initState();
    _watchService.addListener(_refresh);
    _watchService.refreshMeasurements();
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
    final report = _HealthReport.fromWatch(_watchService);
    final now = DateTime.now();
    final dateText = _dateText(now);
    final timeText = _timeText(now);
    final shareText = report.shareText(dateText: dateText, timeText: timeText);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _TopBar(text: shareText),
              const SizedBox(height: 16),
              Text(
                context.tr('Average Daily Health'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('Result'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReportLine(label: 'Date', value: dateText),
                    _ReportLine(label: 'Time', value: timeText),
                    const _Divider(),
                    _SectionTitle(text: context.tr('Average Vital Signs')),
                    const SizedBox(height: 4),
                    _ReportLine(
                      label: 'Heart Rate',
                      value: report.heartRateText,
                    ),
                    _ReportLine(
                      label: 'Blood Pressure',
                      value: report.bloodPressureText,
                    ),
                    _ReportLine(
                      label: 'Blood Sugar',
                      value: report.bloodSugarText,
                    ),
                    _ReportLine(
                      label: 'Temperature',
                      value: report.temperatureText,
                    ),
                    _ReportLine(label: 'SpO2', value: report.spo2Text),
                    const _Divider(),
                    _SectionTitle(text: context.tr('Average Daily Activity')),
                    const SizedBox(height: 4),
                    _ReportLine(label: 'Steps', value: report.stepsText),
                    _ReportLine(label: 'Water Intake', value: '2 L'),
                    const _Divider(),
                    _SectionTitle(text: context.tr('Sleep')),
                    const SizedBox(height: 4),
                    _ReportLine(label: 'Total Sleep', value: report.sleepText),
                    const _Divider(),
                    _SectionTitle(text: context.tr('Status')),
                    const SizedBox(height: 4),
                    _ReportLine(
                      label: 'Overall Status',
                      value: report.overallStatus,
                    ),
                    const _Divider(),
                    _SectionTitle(text: context.tr('Notes:')),
                    const SizedBox(height: 4),
                    Text(
                      context.tr(report.note),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212121),
                      ),
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

  String _dateText(DateTime value) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${value.day} ${months[value.month - 1]} ${value.year}';
  }

  String _timeText(DateTime value) {
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

class _HealthReport {
  final String heartRateText;
  final String bloodPressureText;
  final String bloodSugarText;
  final String temperatureText;
  final String spo2Text;
  final String stepsText;
  final String sleepText;
  final String overallStatus;
  final String note;

  const _HealthReport({
    required this.heartRateText,
    required this.bloodPressureText,
    required this.bloodSugarText,
    required this.temperatureText,
    required this.spo2Text,
    required this.stepsText,
    required this.sleepText,
    required this.overallStatus,
    required this.note,
  });

  factory _HealthReport.fromWatch(ImilabW12Service watch) {
    final heartRate = watch.averageHeartRate;
    final bloodSugar = watch.averageBloodSugar;
    final bloodPressure = watch.averageBloodPressure;
    final temperature = watch.averageTemperature;
    final spo2 = watch.averageSpo2;
    final steps = watch.averageSteps;
    final sleepMinutes = watch.averageSleepMinutes;

    final abnormal = _hasAbnormalReading(
      heartRate: heartRate,
      bloodSugar: bloodSugar,
      bloodPressure: bloodPressure,
      temperature: temperature,
      spo2: spo2,
    );
    final hasAnyReading = [
      heartRate,
      bloodSugar,
      bloodPressure,
      temperature,
      spo2,
      steps,
      sleepMinutes,
    ].any((value) => value != null);

    return _HealthReport(
      heartRateText: heartRate == null ? 'Not available' : '$heartRate bpm',
      bloodPressureText:
          bloodPressure == null ? 'Not available' : '$bloodPressure mmHg',
      bloodSugarText:
          bloodSugar == null ? 'Not available' : '${bloodSugar.toStringAsFixed(1)} mmol/L',
      temperatureText:
          temperature == null ? 'Not available' : '${temperature.toStringAsFixed(1)} C',
      spo2Text: spo2 == null ? 'Not available' : '$spo2%',
      stepsText: steps == null ? 'Not available' : '$steps steps',
      sleepText: sleepMinutes == null
          ? 'Not available'
          : '${sleepMinutes ~/ 60}h ${sleepMinutes % 60}m',
      overallStatus: !hasAnyReading
          ? 'Waiting for watch readings'
          : abnormal
              ? 'Needs attention'
              : 'Stable',
      note: !hasAnyReading
          ? 'Connect the watch and refresh readings'
          : abnormal
              ? 'Some averages are outside the normal range'
              : 'No abnormal activity detected',
    );
  }

  String shareText({required String dateText, required String timeText}) {
    return [
      'Average Daily Health report',
      'Date: $dateText',
      'Time: $timeText',
      'Heart Rate: $heartRateText',
      'Blood Pressure: $bloodPressureText',
      'Blood Sugar: $bloodSugarText',
      'Temperature: $temperatureText',
      'SpO2: $spo2Text',
      'Steps: $stepsText',
      'Total Sleep: $sleepText',
      'Overall Status: $overallStatus',
      'Notes: $note',
    ].join('\n');
  }

  static bool _hasAbnormalReading({
    required int? heartRate,
    required double? bloodSugar,
    required String? bloodPressure,
    required double? temperature,
    required int? spo2,
  }) {
    if (heartRate != null && (heartRate < 50 || heartRate > 120)) return true;
    if (bloodSugar != null && (bloodSugar < 3.9 || bloodSugar > 10.0)) {
      return true;
    }
    final pressure = _parseBloodPressure(bloodPressure);
    if (pressure != null &&
        (pressure.$1 < 90 ||
            pressure.$1 > 140 ||
            pressure.$2 < 60 ||
            pressure.$2 > 90)) {
      return true;
    }
    if (temperature != null && (temperature < 35.0 || temperature > 38.0)) {
      return true;
    }
    if (spo2 != null && spo2 < 92) return true;
    return false;
  }

  static (int, int)? _parseBloodPressure(String? value) {
    if (value == null) return null;
    final parts = value.split('/');
    if (parts.length < 2) return null;
    final systolic = int.tryParse(parts[0].trim());
    final diastolic = int.tryParse(parts[1].replaceAll(RegExp(r'[^0-9]'), ''));
    if (systolic == null || diastolic == null) return null;
    return (systolic, diastolic);
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _HealthResultScreenState._orange,
      ),
    );
  }
}

class _ReportLine extends StatelessWidget {
  final String label;
  final String value;

  const _ReportLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      '${context.tr(label)}: ${context.tr(value)}',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF212121),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: DottedLine(),
      );
}

class DottedLine extends StatelessWidget {
  const DottedLine({super.key});

  @override
  Widget build(BuildContext context) =>
      SizedBox(height: 1, child: CustomPaint(painter: _DottedPainter()));
}

class _DottedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF464646).withValues(alpha: 0.72)
      ..strokeWidth = 1;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + 5, 0), paint);
      x += 10;
    }
  }

  @override
  bool shouldRepaint(_) => false;
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
