import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/auth_service.dart';
import '../shared/widgets/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  Future<void> _continueWithProvider(String provider) async {
    if (_loading) return;
    final email = await _askForProviderEmail(provider);
    if (email == null || email.trim().isEmpty) return;
    if (!mounted) return;
    setState(() => _loading = true);
    final result = await AuthService.instance.continueWithProvider(
      provider: provider,
      email: email,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.isSuccess) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.error ?? 'Login failed.')),
    );
  }

  Future<String?> _askForProviderEmail(String provider) {
    final controller = TextEditingController();
    final label = provider == 'google' ? 'Gmail' : 'iCloud';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Continue with $label'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: provider == 'google'
                ? 'example@gmail.com'
                : 'example@icloud.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Continue'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const AppStatusBar(),
              const SizedBox(height: 32),

              // Photo card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: SizedBox(
                    height: 514,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          AppAssets.loginPhoto,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: Colors.grey[900]),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black54, Colors.transparent],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 24,
                          bottom: 32,
                          right: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('Create an Account'),
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                context.tr(
                                  'Support your loved one with a connected experience',
                                ),
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 12,
                                  fontFamily: 'Afacad',
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AppPrimaryButton(
                  label: 'Register',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.register),
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: SocialButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.google,
                          size: 22,
                          color: Color(0xFFDB4437),
                        ),
                        onTap: () => _continueWithProvider('google'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SocialButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.apple,
                          size: 22,
                          color: Color(0xFF212121),
                        ),
                        onTap: () => _continueWithProvider('icloud'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.loginForm),
                child: RichText(
                  text: TextSpan(
                    text: context.tr('Have an account? '),
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 12,
                      fontFamily: 'Afacad',
                    ),
                    children: [
                      TextSpan(
                        text: context.tr('Login'),
                        style: const TextStyle(
                          color: AppColors.purple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
