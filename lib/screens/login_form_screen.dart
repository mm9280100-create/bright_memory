import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/auth_service.dart';
import '../shared/widgets/app_widgets.dart';

class LoginFormScreen extends StatefulWidget {
  const LoginFormScreen({super.key});

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _errorText = null;
    });
    final result = await AuthService.instance.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.isSuccess) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
      return;
    }
    setState(() => _errorText = result.error ?? 'Invalid email or password.');
  }

  Future<void> _continueWithProvider(String provider) async {
    final email = await _askForProviderEmail(provider);
    if (email == null || email.trim().isEmpty) return;
    if (!mounted) return;
    setState(() {
      _loading = true;
      _errorText = null;
    });
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
    setState(() => _errorText = result.error);
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const AppStatusBar(),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppBackButton(),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.register),
                    child: Text(
                      context.tr('Register'),
                      style: const TextStyle(
                        color: AppColors.purple,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 148),
              Text(
                context.tr('Login'),
                style: const TextStyle(
                  color: AppColors.purple,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('Welcome! Please login'),
                style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
              const SizedBox(height: 64),
              AppTextField(
                hint: 'Enter Your Email',
                suffixIcon: Icons.email_outlined,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              AppTextField(
                hint: 'Enter Your Password',
                suffixIcon: Icons.visibility_off_outlined,
                obscure: true,
                controller: _passwordController,
                textInputAction: TextInputAction.done,
                errorText: _errorText,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.forgotPassword),
                  child: Text(
                    context.tr('Forget Password?'),
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 160),
              AppPrimaryButton(
                label: _loading ? 'Loading...' : 'Login',
                onTap: _login,
              ),
              const SizedBox(height: 12),
              Row(
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
