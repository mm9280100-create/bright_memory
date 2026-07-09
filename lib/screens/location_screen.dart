import 'package:flutter/material.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/content_action_service.dart';
import '../core/services/fall_detection_service.dart';
import '../core/services/iot_sensor_service.dart';
import '../shared/widgets/app_widgets.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool _expanded = false;
  final FallDetectionService _fallService = FallDetectionService.instance;
  final IotSensorService _iotService = IotSensorService.instance;

  static const _timeline = [
    _RoomEntry(AppAssets.roomBedroom, 'Bedroom', '7:00 - 9:00 AM', true),
    _RoomEntry(AppAssets.roomBathroom, 'Bathroom', '9:30 - 10:00 AM', true),
    _RoomEntry(AppAssets.roomKids, "Kid's room", '9:00 - 9:30 AM', true),
    _RoomEntry(AppAssets.roomKitchen, 'Kitchen', '10:00 - 10:30 AM', true),
    _RoomEntry(AppAssets.roomDining, 'Dining room', '11:00 - 11:55 AM', true),
    _RoomEntry(AppAssets.roomLiving, 'Living room', '12:30 - 4:00 PM', true),
  ];

  @override
  void initState() {
    super.initState();
    _fallService.addListener(_handleFallUpdate);
    _iotService.addListener(_handleFallUpdate);
    _fallService.start();
    _iotService.start();
  }

  @override
  void dispose() {
    _fallService.removeListener(_handleFallUpdate);
    _iotService.removeListener(_handleFallUpdate);
    super.dispose();
  }

  void _handleFallUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _fallService.snapshot;
    final sensorSnapshot = _iotService.snapshot;
    final fallDetected = snapshot?.fallDetected == true;
    final currentRoom = fallDetected
        ? _roomLabelFromModel(snapshot?.fallLocation ?? snapshot?.fallZone)
        : sensorSnapshot?.detectedRoomLabel ??
            _iotService.lastDetectedRoomLabel ??
            'Bedroom';
    final statusKey = fallDetected ? 'Fall detected' : 'Safe';
    final statusColor =
        fallDetected ? const Color(0xFFE84135) : const Color(0xFF00A17B);
    final shareText = [
      'Home Status: $statusKey',
      'Location: $currentRoom',
    ].join('\n');

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const AppStatusBar(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.maybePop(context),
                  ),
                  Row(
                    children: [
                      _CircleButton(
                        icon: Icons.copy_outlined,
                        onTap: () =>
                            ContentActionService.copyText(context, shareText),
                      ),
                      const SizedBox(width: 8),
                      _CircleButton(
                        icon: Icons.ios_share_outlined,
                        onTap: () =>
                            ContentActionService.shareText(context, shareText),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 82),
              Text(
                context.tr('Home Status'),
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF212121),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      context.tr('Current Location : '),
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF212121),
                      ),
                    ),
                    Container(
                      height: 25,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFECA8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        context.tr(currentRoom),
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF575555),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    context.tr('Status : '),
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF212121),
                    ),
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    context.tr(statusKey),
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF575555),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _ActivityCard(
                expanded: _expanded,
                onToggle: () => setState(() => _expanded = !_expanded),
                timeline: _timeline,
                currentRoom: currentRoom,
                fallDetected: fallDetected,
                statusColor: statusColor,
                statusKey: statusKey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _roomLabelFromModel(String? value) {
    final text = value?.trim().toLowerCase();
    if (text == null || text.isEmpty) return 'Bedroom';
    if (text.contains('bath')) return 'Bathroom';
    if (text.contains('kid') || text.contains('child')) return "Kid's room";
    if (text.contains('kitchen')) return 'Kitchen';
    if (text.contains('dining') || text.contains('dinging')) {
      return 'Dining room';
    }
    if (text.contains('living')) return 'Living room';
    if (text.contains('bed')) return 'Bedroom';
    return value!.trim();
  }
}

class _ActivityCard extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final List<_RoomEntry> timeline;
  final String currentRoom;
  final bool fallDetected;
  final Color statusColor;
  final String statusKey;

  const _ActivityCard({
    required this.expanded,
    required this.onToggle,
    required this.timeline,
    required this.currentRoom,
    required this.fallDetected,
    required this.statusColor,
    required this.statusKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 304,
      margin: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFECA8),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bed_outlined,
                  size: 20,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr('Patient Activity'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MiniStatusLine(
                      icon: Icons.location_on,
                      text: context.tr(currentRoom),
                    ),
                    const SizedBox(height: 3),
                    _MiniStatusLine(
                      dotColor: statusColor,
                      text: context.tr(statusKey),
                    ),
                    const SizedBox(height: 3),
                    _MiniStatusLine(
                      icon: Icons.access_time_filled,
                      text: context.tr('Last update: 2 min ago'),
                      small: true,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 104,
                  height: 33,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF212121)),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.tr('View Timeline'),
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (expanded) ...[
            const SizedBox(height: 12),
            ...timeline.map(
              (entry) => _TimelineRow(
                entry: entry,
                isCurrent: entry.room == currentRoom,
                isAlert: fallDetected && entry.room == currentRoom,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStatusLine extends StatelessWidget {
  final IconData? icon;
  final Color? dotColor;
  final String text;
  final bool small;

  const _MiniStatusLine({
    this.icon,
    this.dotColor,
    required this.text,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (dotColor != null)
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          )
        else
          Icon(icon, size: small ? 12 : 16, color: const Color(0xFF575555)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: small ? 9 : 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF575555),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final _RoomEntry entry;
  final bool isCurrent;
  final bool isAlert;

  const _TimelineRow({
    required this.entry,
    required this.isCurrent,
    required this.isAlert,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Image.asset(entry.icon, fit: BoxFit.contain),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(entry.room),
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF212121),
                  ),
                ),
                Text(
                  entry.time,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 8,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF7B7A7A),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isAlert
                  ? const Color(0xFFE84135)
                  : isCurrent || entry.safe
                      ? const Color(0xFF00A17B)
                      : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Color(0xFFEDEDED),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF212121)),
      ),
    );
  }
}

class _RoomEntry {
  final String icon;
  final String room;
  final String time;
  final bool safe;

  const _RoomEntry(this.icon, this.room, this.time, this.safe);
}
