import 'package:geolocator/geolocator.dart';

enum PatientLocationStatus {
  loading,
  ready,
  permissionDenied,
  permissionDeniedForever,
  servicesDisabled,
  error,
}

class PatientLocationResult {
  final PatientLocationStatus status;
  final Position? position;
  final String? message;

  const PatientLocationResult({
    required this.status,
    this.position,
    this.message,
  });

  bool get hasPosition => position != null;
}

class PatientLocationService {
  const PatientLocationService();

  Future<PatientLocationResult> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const PatientLocationResult(
        status: PatientLocationStatus.servicesDisabled,
        message: 'Turn on location services',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return const PatientLocationResult(
        status: PatientLocationStatus.permissionDenied,
        message: 'Location permission required',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      return const PatientLocationResult(
        status: PatientLocationStatus.permissionDeniedForever,
        message: 'Location permission permanently denied',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return PatientLocationResult(
        status: PatientLocationStatus.ready,
        position: position,
      );
    } catch (error) {
      return const PatientLocationResult(
        status: PatientLocationStatus.error,
        message: 'Could not get current location',
      );
    }
  }

  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}

