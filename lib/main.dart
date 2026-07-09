import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/constants/app_routes.dart';
import 'core/localization/app_localizations.dart';
import 'core/services/call_push_service.dart';
import 'core/services/medication_notification_service.dart';
import 'core/services/sensor_alert_monitor.dart';
import 'core/theme/app_theme.dart';
import 'screens/blood_pressure_screen.dart';
import 'screens/blood_sugar_screen.dart';
import 'screens/call_screen.dart';
import 'screens/care_notes_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/emergency_report_screen.dart';
import 'screens/emergency_confirmed_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/health_result_screen.dart';
import 'screens/heart_screen.dart';
import 'screens/home_screen.dart';
import 'screens/location_screen.dart';
import 'screens/login_form_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/patient_info_screen.dart';
import 'screens/register_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/routine_screen.dart';
import 'screens/sensors_screen.dart';
import 'screens/sleep_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/steps_screen.dart';
import 'screens/verify_phone_screen.dart';
import 'screens/video_call_screen.dart';
import 'screens/water_screen.dart';
import 'shared/widgets/call_invite_listener.dart';

final appLanguage = AppLanguageController();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(_startBackgroundServices());
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    AppLanguageScope(controller: appLanguage, child: const BrMemoryApp()),
  );
}

Future<void> _startBackgroundServices() async {
  try {
    await CallPushService.initializeFirebase();
    await CallPushService.instance.start();
  } catch (_) {}

  try {
    await MedicationNotificationService.instance.start();
  } catch (_) {}

  try {
    await SensorAlertMonitor.instance.start();
  } catch (_) {}
}

class BrMemoryApp extends StatelessWidget {
  const BrMemoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: context.language,
      builder: (context, _) {
        final language = AppLanguageScope.of(context);
        return MaterialApp(
          title: context.tr('Br. Memory'),
          debugShowCheckedModeBanner: false,
          navigatorKey: appNavigatorKey,
          theme: AppTheme.light,
          locale: language.locale,
          initialRoute: AppRoutes.splash,
          builder: (context, child) {
            return CallInviteListener(
              child: ColoredBox(
                color: Colors.white,
                child: Directionality(
                  textDirection:
                      language.isArabic ? TextDirection.rtl : TextDirection.ltr,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: child!,
                    ),
                  ),
                ),
              ),
            );
          },
          routes: {
            AppRoutes.splash: (_) => const SplashScreen(),
            AppRoutes.onboarding: (_) => const OnboardingScreen(),
            AppRoutes.login: (_) => const LoginScreen(),
            AppRoutes.loginForm: (_) => const LoginFormScreen(),
            AppRoutes.register: (_) => const RegisterScreen(),
            AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
            AppRoutes.verifyPhone: (_) => const VerifyPhoneScreen(),
            AppRoutes.resetPassword: (_) => const ResetPasswordScreen(),
            AppRoutes.home: (_) => const HomeScreen(),
            AppRoutes.careNotes: (_) => const CareNotesScreen(),
            AppRoutes.contact: (_) => const ContactScreen(),
            AppRoutes.call: (_) => const CallScreen(),
            AppRoutes.videoCall: (_) => const VideoCallScreen(),
            AppRoutes.heart: (_) => const HeartScreen(),
            AppRoutes.patientInfo: (_) => const PatientInfoScreen(),
            AppRoutes.routine: (_) => const RoutineScreen(),
            AppRoutes.sensors: (_) => const SensorsScreen(),
            AppRoutes.bloodSugar: (_) => const BloodSugarScreen(),
            AppRoutes.bloodPressure: (_) => const BloodPressureScreen(),
            AppRoutes.steps: (_) => const StepsScreen(),
            AppRoutes.sleepDetail: (_) => const SleepScreen(),
            AppRoutes.waterReminder: (_) => const WaterScreen(),
            AppRoutes.healthResult: (_) => const HealthResultScreen(),
            AppRoutes.locationDetail: (_) => const LocationScreen(),
            AppRoutes.emergencyReport: (_) => const EmergencyReportScreen(),
            AppRoutes.emergencyConfirmed: (_) =>
                const EmergencyConfirmedScreen(),
          },
        );
      },
    );
  }
}
