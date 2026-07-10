import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/iot_sensor_service.dart';
import '../core/services/imilab_w12_service.dart';
import '../shared/widgets/app_widgets.dart';
import 'bottom_nav.dart';

class SensorsScreen extends StatefulWidget {
  const SensorsScreen({super.key});

  @override
  State<SensorsScreen> createState() => _SensorsScreenState();
}

class _SensorsScreenState extends State<SensorsScreen> {
  final _watchService = ImilabW12Service.instance;
  final _iotService = IotSensorService.instance;
  String? _lastAlertMessage;

  @override
  void initState() {
    super.initState();
    _watchService.addListener(_refresh);
    _iotService.addListener(_refresh);
    _iotService.start();
  }

  @override
  void dispose() {
    _watchService.removeListener(_refresh);
    _iotService.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {});
    final alertMessage = _iotAlertMessage();
    if (alertMessage != null && alertMessage != _lastAlertMessage) {
      _lastAlertMessage = alertMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(alertMessage),
          backgroundColor: AppColors.emergency,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (alertMessage == null) {
      _lastAlertMessage = null;
    }
  }

  String? _iotAlertMessage() {
    final snapshot = _iotService.snapshot;
    if (snapshot == null) return null;
    if (snapshot.fallDetected == true) {
      final position = snapshot.fallPositionLabel;
      final message = context.tr('Alert: fall detected by model');
      return position == null ? message : '$message - $position';
    }
    if (snapshot.flameDetected == true) {
      return context.tr('Alert: flame detected');
    }
    if (snapshot.gasAlert == true) {
      return context.tr('Alert: gas detected');
    }
    if (snapshot.waterDetected == true) {
      return context.tr('Alert: water detected');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final watchConnected = _watchService.isConnected ? 1 : 0;
    const hardwareSensorCount = 8;
    final hardwareConnected = _iotService.isOnline ? hardwareSensorCount : 0;
    final connectedTotal = watchConnected + hardwareConnected;
    const totalSensors = hardwareSensorCount + 1;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: AppStatusBar(),
            ),
            const SizedBox(height: 8),

            // â”€â”€ Back button + Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEDEDED),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      context.tr('Sensors'),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF059669),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            context.isArabic
                                ? '$connectedTotal ${context.tr('Active')}'
                                : '$connectedTotal Active',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF059669),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // â”€â”€ Summary card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightPurple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SummaryItem(
                      label: 'Total',
                      value: '$totalSensors',
                      icon: Icons.memory,
                      color: AppColors.purple,
                    ),
                    _SummaryItem(
                      label: 'Connected',
                      value: '$connectedTotal',
                      icon: Icons.wifi,
                      color: const Color(0xFF059669),
                    ),
                    _SummaryItem(
                      label: 'Offline',
                      value: '${totalSensors - connectedTotal}',
                      icon: Icons.wifi_off,
                      color: AppColors.emergency,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                children: [
                  _WatchConnectorCard(service: _watchService),
                  const SizedBox(height: 12),
                  _HardwareSensorsCard(service: _iotService),
                ],
              ),
            ),

            // â”€â”€ Sensor list â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 4),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          context.tr(label),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
        ),
      ],
    );
  }
}

class _WatchConnectorCard extends StatelessWidget {
  final ImilabW12Service service;

  const _WatchConnectorCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final isBusy = service.status == SmartWatchStatus.scanning ||
        service.status == SmartWatchStatus.connecting;
    final isConnected = service.isConnected;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFCBBF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.watch_outlined,
                  size: 24,
                  color: AppColors.purple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConnected
                          ? service.connectedDeviceName ?? 'Smart Watch'
                          : context.tr('Smart Watch'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _statusText(context),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              _WatchActionButton(
                label: isConnected
                    ? context.tr('Disconnect')
                    : isBusy
                        ? context.tr('Scanning...')
                        : context.tr('Search Watch'),
                onTap: isBusy
                    ? null
                    : isConnected
                        ? service.disconnect
                        : service.startScan,
              ),
            ],
          ),
          if (isConnected) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _WatchMetric(
                  label: 'Battery',
                  value: service.batteryLevel == null
                      ? context.tr('N/A - Proprietary protocol')
                      : '${service.batteryLevel}%',
                  icon: Icons.battery_full,
                ),
                const SizedBox(width: 8),
                _WatchMetric(
                  label: 'Heart Rate',
                  value: service.heartRate == null
                      ? context.tr('Not available')
                      : '${service.heartRate} ${context.tr('bpm')}',
                  icon: Icons.favorite_border,
                ),
              ],
            ),
            if (service.heartRate == null &&
                service.heartRateMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                context.tr(service.heartRateMessage!),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (service.serviceCount > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Bluetooth profile: ${service.serviceCount} services, '
                '${service.notifiableCharacteristicCount} live channels',
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: _WatchActionButton(
                label: service.isReadingMeasurements
                    ? context.tr('Reading...')
                    : context.tr('Refresh readings'),
                onTap: service.isReadingMeasurements
                    ? null
                    : () => service.refreshMeasurements(),
              ),
            ),
          ],
          if (!isConnected && service.devices.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              context.tr('Found devices'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            ...service.devices.map(
              (device) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _FoundWatchRow(device: device, service: service),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _statusText(BuildContext context) {
    switch (service.status) {
      case SmartWatchStatus.scanning:
        return context.tr('Searching for Bluetooth watches/devices...');
      case SmartWatchStatus.connecting:
        return context.tr('Connecting...');
      case SmartWatchStatus.connected:
        return context.tr('Connected');
      case SmartWatchStatus.bluetoothOff:
        return context.tr('Bluetooth is off');
      case SmartWatchStatus.permissionDenied:
        return context.tr('Bluetooth permission needed');
      case SmartWatchStatus.error:
        return service.errorMessage ?? context.tr('Connection error');
      case SmartWatchStatus.disconnected:
        return context.tr('No Bluetooth watch/device found');
      case SmartWatchStatus.idle:
        return context.tr('Tap scan to find any Bluetooth watch');
    }
  }
}

class _HardwareSensorsCard extends StatelessWidget {
  final IotSensorService service;

  const _HardwareSensorsCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final snapshot = service.snapshot;
    final servoAngle = (snapshot?.servoAngle ?? 90).clamp(0, 90).toInt();
    final statusText = service.isOnline
        ? context.tr('Connected to ESP32')
        : context.tr(service.errorMessage ?? 'Connect phone to ESP32 Wi-Fi');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFD6F6E7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.developer_board_outlined,
                  size: 24,
                  color: Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('Hardware Sensors'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statusText,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service.endpoint,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF059669),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _WatchActionButton(
                label: service.isPolling
                    ? context.tr('Reading...')
                    : context.tr('Refresh'),
                onTap: service.isPolling ? null : service.refresh,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_alertText(context, snapshot) != null) ...[
            _HardwareAlertBanner(
              message: _alertText(context, snapshot)!,
              actionLabel: snapshot?.gasAlert == true ? 'OK' : null,
              onAction: snapshot?.gasAlert == true
                  ? service.acknowledgeGasAlert
                  : null,
            ),
            const SizedBox(height: 8),
          ],
          _HardwareMetric(
            label: 'Flame',
            value: _boolValue(
              context,
              snapshot?.flameDetected,
              trueText: 'Fire detected',
              falseText: 'Safe',
            ),
            icon: Icons.local_fire_department_outlined,
            color: const Color(0xFFFFD6CC),
            iconColor: const Color(0xFFD8482F),
            alert: snapshot?.flameDetected == true,
          ),
          const SizedBox(height: 8),
          _HardwareMetric(
            label: 'Water',
            value: snapshot?.waterLevel == null
                ? _boolValue(
                    context,
                    snapshot?.waterDetected,
                    trueText: 'Water found',
                    falseText: 'Dry',
                  )
                : '${snapshot!.waterLevel!.toStringAsFixed(0)}%',
            icon: Icons.water_drop_outlined,
            color: const Color(0xFFCDEBFF),
            iconColor: const Color(0xFF1D7CC1),
            alert: snapshot?.waterDetected == true,
          ),
          const SizedBox(height: 8),
          _HardwareMetric(
            label: 'Gas',
            value: snapshot?.gasLevel == null
                ? context.tr('Not available')
                : snapshot?.gasAcknowledged == true
                    ? '${snapshot!.gasLevel} - ${context.tr('OK')}'
                    : '${snapshot!.gasLevel}',
            icon: Icons.air,
            color: const Color(0xFFE5DCFF),
            iconColor: const Color(0xFF6A43B8),
            alert: snapshot?.gasAlert == true,
            trailing: _GasBuzzerSwitch(
              enabled: snapshot?.gasBuzzerEnabled ?? true,
              onChanged: service.setGasBuzzerEnabled,
            ),
          ),
          const SizedBox(height: 8),
          _HardwareMetric(
            label: 'Buzzer',
            value: snapshot?.buzzerActive == true
                ? context.tr('On')
                : context.tr('Off'),
            icon: Icons.notifications_active_outlined,
            color: const Color(0xFFFFE7B8),
            iconColor: const Color(0xFFB36B00),
            alert: snapshot?.buzzerActive == true,
          ),
          const SizedBox(height: 8),
          _HardwareMetric(
            label: 'Temperature',
            value: snapshot?.temperatureC == null
                ? context.tr('Not available')
                : '${snapshot!.temperatureC!.toStringAsFixed(1)} C',
            icon: Icons.thermostat,
            color: const Color(0xFFFFD9EA),
            iconColor: const Color(0xFFB92366),
          ),
          const SizedBox(height: 8),
          _HardwareMetric(
            label: 'Ultrasonic',
            value: _distanceValue(context, snapshot),
            icon: Icons.sensors_outlined,
            color: const Color(0xFFD8F6D2),
            iconColor: const Color(0xFF248A35),
            alert: snapshot?.obstacleDetected == true,
          ),
          const SizedBox(height: 8),
          _HardwareMetric(
            label: 'LDR Sensor',
            value: _lightValue(context, snapshot),
            icon: Icons.light_mode_outlined,
            color: const Color(0xFFFFF0B8),
            iconColor: const Color(0xFFC47A00),
            alert: snapshot?.lightDetected == true,
          ),
          const SizedBox(height: 8),
          _ServoAngleSwitch(
            angle: servoAngle,
            onChanged: service.setServoAngle,
          ),
        ],
      ),
    );
  }

  String _boolValue(
    BuildContext context,
    bool? value, {
    required String trueText,
    required String falseText,
  }) {
    if (value == null) return context.tr('Not available');
    return context.tr(value ? trueText : falseText);
  }

  String _lightValue(BuildContext context, IotSensorSnapshot? snapshot) {
    if (snapshot?.lightLevel == null) {
      return context.tr('Not available');
    }
    final state = snapshot!.lightDetected == true
        ? context.tr('Light detected')
        : context.tr('Dark');
    return '${snapshot.lightLevel}% - $state';
  }

  String _distanceValue(BuildContext context, IotSensorSnapshot? snapshot) {
    if (snapshot?.ultrasonicDistanceCm == null) {
      return context.tr('Not available');
    }
    final distance = snapshot!.ultrasonicDistanceCm!.toStringAsFixed(1);
    final room = snapshot.detectedRoomLabel;
    final state = snapshot.obstacleDetected == true
        ? context.tr('Obstacle')
        : context.tr('Clear');
    if (room != null && room.isNotEmpty) {
      return '$distance ${context.tr('cm')} - ${context.tr(room)}';
    }
    return '$distance ${context.tr('cm')} - $state';
  }

  String? _alertText(BuildContext context, IotSensorSnapshot? snapshot) {
    if (snapshot == null) return null;
    if (snapshot.flameDetected == true) {
      return context.tr('Alert: flame detected');
    }
    if (snapshot.gasAlert == true) {
      return context.tr('Alert: gas detected');
    }
    if (snapshot.waterDetected == true) {
      return context.tr('Alert: water detected');
    }
    if (snapshot.fallDetected == true) {
      final position = snapshot.fallPositionLabel;
      final message = context.tr('Alert: fall detected by model');
      return position == null ? message : '$message - $position';
    }
    return null;
  }
}

class _ServoAngleSwitch extends StatelessWidget {
  final int angle;
  final ValueChanged<int> onChanged;

  const _ServoAngleSwitch({
    required this.angle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = angle >= 45;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFECD9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.settings_input_component_outlined,
                size: 26,
                color: Color(0xFF7B3FB2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.tr('Servo angle control'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$angle ${context.tr('deg')}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('Close'),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Switch(
                value: isOpen,
                activeThumbColor: AppColors.purple,
                onChanged: (value) => onChanged(value ? 90 : 0),
              ),
              Text(
                context.tr('Open'),
                style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HardwareAlertBanner extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _HardwareAlertBanner({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE4E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.emergency.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.emergency,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.emergency,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAction,
              child: Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    color: AppColors.emergency,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HardwareMetric extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color, iconColor;
  final bool alert;
  final Widget? trailing;

  const _HardwareMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.iconColor,
    this.alert = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = alert ? const Color(0xFFFFE4E0) : color;
    final effectiveIconColor = alert ? AppColors.emergency : iconColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.86),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 25, color: effectiveIconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(label),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: alert ? AppColors.emergency : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _GasBuzzerSwitch extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _GasBuzzerSwitch({
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          enabled ? context.tr('On') : context.tr('Off'),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: enabled ? const Color(0xFF059669) : AppColors.textMuted,
          ),
        ),
        SizedBox(
          width: 46,
          height: 30,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Switch(
              value: enabled,
              activeThumbColor: const Color(0xFF059669),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _FoundWatchRow extends StatelessWidget {
  final ImilabW12Device device;
  final ImilabW12Service service;

  const _FoundWatchRow({required this.device, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${context.tr('ID: ')}${device.id} | RSSI: ${device.rssi} dBm',
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _WatchActionButton(
            label: context.tr('Connect'),
            onTap: () => service.connect(device),
          ),
        ],
      ),
    );
  }
}

class _WatchMetric extends StatelessWidget {
  final String label, value;
  final IconData icon;

  const _WatchMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.purple),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(label),
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
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

class _WatchActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _WatchActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: onTap == null ? AppColors.textMuted : AppColors.purple,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

