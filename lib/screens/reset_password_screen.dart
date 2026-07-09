import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/auth_service.dart';
import '../shared/widgets/app_widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_loading) return;
    final email = ModalRoute.of(context)?.settings.arguments?.toString() ?? '';
    setState(() {
      _loading = true;
      _errorText = null;
    });
    final result = await AuthService.instance.resetPassword(
      email: email,
      newPassword: _passwordController.text,
      confirmPassword: _confirmController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.isSuccess) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (_) => false,
      );
      return;
    }
    setState(() => _errorText = result.error);
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
              const AppBackButton(),
              const SizedBox(height: 120),
              Text(
                context.tr('Reset\nPassword'),
                style: const TextStyle(
                  color: AppColors.purple,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('Please enter your new password'),
                style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
              const SizedBox(height: 40),
              AppTextField(
                hint: 'Enter Your Password',
                suffixIcon: Icons.visibility_off_outlined,
                obscure: true,
                controller: _passwordController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              AppTextField(
                hint: 'Confirm Password',
                suffixIcon: Icons.visibility_off_outlined,
                obscure: true,
                controller: _confirmController,
                textInputAction: TextInputAction.done,
                errorText: _errorText,
              ),
              const SizedBox(height: 8),
              const Text(
                'Use 8+ chars with uppercase, lowercase, number, and symbol.',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 300),
              Align(
                alignment: Alignment.centerRight,
                child: AppNextButton(
                  label: _loading ? 'Loading...' : 'Next',
                  onTap: _resetPassword,
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
