import 'package:flutter/material.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/fall_detection_service.dart';
import '../core/services/iot_sensor_service.dart';

class LocationCard extends StatefulWidget {
  const LocationCard({super.key});

  @override
  State<LocationCard> createState() => _LocationCardState();
}

class _LocationCardState extends State<LocationCard> {
  static const double _mapHeight = 241;

  final _fallService = FallDetectionService.instance;
  final _iotService = IotSensorService.instance;

  @override
  void initState() {
    super.initState();
    _fallService.addListener(_refresh);
    _iotService.addListener(_refresh);
    _fallService.start();
    _iotService.start();
  }

  @override
  void dispose() {
    _fallService.removeListener(_refresh);
    _iotService.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _showLargeMap({
    required bool fallDetected,
    required String currentRoom,
    required IotSensorSnapshot? fallSnapshot,
  }) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) => _LargeMapDialog(
        fallDetected: fallDetected,
        currentRoom: currentRoom,
        fallSnapshot: fallSnapshot,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fallSnapshot = _fallService.snapshot;
    final sensorSnapshot = _iotService.snapshot;
    final fallDetected = fallSnapshot?.fallDetected == true;
    final detectedRoom =
        sensorSnapshot?.detectedRoomLabel ?? _iotService.lastDetectedRoomLabel;
    final currentRoom = fallDetected
        ? _roomLabel(fallSnapshot?.fallLocation ?? fallSnapshot?.fallZone)
        : detectedRoom ?? 'Bedroom';
    final statusColor =
        fallDetected ? AppColors.emergency : AppColors.safeGreen;
    final statusText = fallDetected ? 'Fall detected' : 'Safe';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF6F6F6F), width: 1),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showLargeMap(
              fallDetected: fallDetected,
              currentRoom: currentRoom,
              fallSnapshot: fallSnapshot,
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: Stack(
                children: [
                  Image.asset(
                    AppAssets.floorPlan,
                    width: double.infinity,
                    height: _mapHeight,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    errorBuilder: (_, __, ___) => Container(
                      height: _mapHeight,
                      color: Colors.grey[200],
                      child:
                          const Icon(Icons.map, size: 60, color: Colors.grey),
                    ),
                  ),
                  Container(
                    height: _mapHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFF151414).withValues(alpha: 0.46),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                  ),
                  if (fallDetected)
                    Positioned.fill(
                      child: _FallMapMarkerPosition(
                        snapshot: fallSnapshot,
                        room: currentRoom,
                      ),
                    )
                  else if (detectedRoom != null)
                    Positioned.fill(
                      child: _RoomMapMarkerPosition(room: currentRoom),
                    )
                  else
                    const Positioned(
                      right: 47,
                      bottom: 7,
                      child: _SafeMapMarker(),
                    ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.zoom_out_map,
                        size: 18,
                        color: Color(0xFF212121),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: fallDetected ? 12 : null,
                    top: 12,
                    child: fallDetected
                        ? _FallAlertBanner(
                            confidence: fallSnapshot?.fallConfidence,
                            location: fallSnapshot?.fallPositionLabel,
                          )
                        : _SensorStatusChip(isOnline: _iotService.isOnline),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 70,
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
            decoration: const BoxDecoration(
              color: AppColors.locationBar,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              context.tr('Current Location : '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 12,
                                height: 15 / 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              width: 60,
                              height: 23,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                context.tr(currentRoom),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 12,
                                  height: 15 / 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0,
                                  color: Color(0xFF575555),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            context.tr('Statue : '),
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 12,
                              height: 15 / 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0,
                              color: AppColors.textDark,
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
                          const SizedBox(width: 4),
                          Text(
                            context.tr(statusText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 12,
                              height: 15 / 12,
                              fontWeight: fallDetected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              letterSpacing: 0,
                              color: fallDetected
                                  ? AppColors.emergency
                                  : const Color(0xFF575555),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.locationDetail),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ),
                    width: 75,
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        children: [
                          Text(
                            context.tr('See details'),
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 8,
                              height: 10 / 8,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios, size: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _roomLabel(String? value) {
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

class _RoomMapMarkerPosition extends StatelessWidget {
  final String room;

  const _RoomMapMarkerPosition({required this.room});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const markerSize = 16.0;
        final point = _mapPointForRoom(room);
        final left = (constraints.maxWidth * point.dx - markerSize / 2)
            .clamp(0.0, constraints.maxWidth - markerSize);
        final top = (constraints.maxHeight * point.dy - markerSize / 2)
            .clamp(0.0, constraints.maxHeight - markerSize);

        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              child: const _SafeMapMarker(),
            ),
          ],
        );
      },
    );
  }

}

class _LargeMapDialog extends StatelessWidget {
  final bool fallDetected;
  final String currentRoom;
  final IotSensorSnapshot? fallSnapshot;

  const _LargeMapDialog({
    required this.fallDetected,
    required this.currentRoom,
    required this.fallSnapshot,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 5,
                boundaryMargin: const EdgeInsets.all(120),
                child: AspectRatio(
                  aspectRatio: 1600 / 1196,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        AppAssets.floorPlan,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.map,
                            size: 72,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.black.withValues(alpha: 0.18),
                      ),
                      if (fallDetected)
                        _FallMapMarkerPosition(
                          snapshot: fallSnapshot,
                          room: currentRoom,
                        )
                      else
                        _RoomMapMarkerPosition(room: currentRoom),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF212121),
                ),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafeMapMarker extends StatelessWidget {
  const _SafeMapMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: const Color(0xFFEE3535),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB8B8).withValues(alpha: 0.7),
            blurRadius: 8,
            spreadRadius: 4,
          ),
        ],
      ),
    );
  }
}

class _FallMapMarkerPosition extends StatelessWidget {
  final IotSensorSnapshot? snapshot;
  final String? room;

  const _FallMapMarkerPosition({required this.snapshot, this.room});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const markerSize = 76.0;
        final roomText = room?.trim();
        final roomPoint = roomText == null || roomText.isEmpty
            ? null
            : _mapPointForRoom(roomText);
        final x = (roomPoint?.dx ?? snapshot?.fallX ?? 0.82).clamp(0.0, 1.0);
        final y = (roomPoint?.dy ?? snapshot?.fallY ?? 0.92).clamp(0.0, 1.0);
        final left = (constraints.maxWidth * x - markerSize / 2)
            .clamp(0.0, constraints.maxWidth - markerSize);
        final top = (constraints.maxHeight * y - markerSize / 2)
            .clamp(0.0, constraints.maxHeight - markerSize);

        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              child: const _FallMapMarker(),
            ),
          ],
        );
      },
    );
  }
}

Offset _mapPointForRoom(String room) {
  final text = room.toLowerCase();
  if (text.contains('bath')) return const Offset(0.64, 0.29);
  if (text.contains('kid') || text.contains('child')) {
    return const Offset(0.40, 0.25);
  }
  if (text.contains('kitchen')) return const Offset(0.86, 0.86);
  if (text.contains('dining')) return const Offset(0.80, 0.61);
  if (text.contains('living')) return const Offset(0.36, 0.62);
  return const Offset(0.80, 0.25);
}

class _FallMapMarker extends StatelessWidget {
  const _FallMapMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: AppColors.emergency.withValues(alpha: 0.22),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.emergency,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.emergency.withValues(alpha: 0.45),
                blurRadius: 14,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.personal_injury_outlined,
            color: Colors.white,
            size: 30,
          ),
        ),
      ],
    );
  }
}

class _FallAlertBanner extends StatelessWidget {
  final double? confidence;
  final String? location;

  const _FallAlertBanner({this.confidence, this.location});

  @override
  Widget build(BuildContext context) {
    final confidencePercent = confidence == null
        ? null
        : confidence! <= 1
            ? confidence! * 100
            : confidence!;
    final confidenceText = confidence == null
        ? null
        : '${context.tr('Confidence')} ${confidencePercent!.clamp(0, 100).toStringAsFixed(0)}%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.emergency,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.4),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('Fall detected by model'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (location != null)
                  Text(
                    location!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          if (confidenceText != null)
            Text(
              confidenceText,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

class _SensorStatusChip extends StatelessWidget {
  final bool isOnline;

  const _SensorStatusChip({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: isOnline
            ? AppColors.safeGreen.withValues(alpha: 0.92)
            : AppColors.emergency.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.sensors_outlined : Icons.sensors_off_outlined,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 5),
          Text(
            context.tr(
              isOnline
                  ? 'Connected to ESP32'
                  : 'ESP32 not connected',
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
