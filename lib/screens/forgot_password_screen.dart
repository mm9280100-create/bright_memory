import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/auth_service.dart';
import '../shared/widgets/app_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 0; // 0=choose method, 1=email, 2=phone
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_loading) return;
    if (_step == 2) {
      setState(() => _errorText = 'Use email reset for this account.');
      return;
    }
    setState(() {
      _loading = true;
      _errorText = null;
    });
    final result = await AuthService.instance.sendPasswordResetEmail(
      _emailController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.isSuccess) {
      Navigator.pushNamed(
        context,
        AppRoutes.resetPassword,
        arguments: result.user?.email ?? _emailController.text.trim(),
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
              const SizedBox(height: 48),
              Text(
                context.tr('Forgot\nPassword'),
                style: const TextStyle(
                  color: AppColors.purple,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr(
                  'We will send you a message to set or reset your new password',
                ),
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 48),
              if (_step == 0) ...[
                Text(
                  context.tr('Verification Method'),
                  style: const TextStyle(
                    color: AppColors.purple,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('Choose your preferred verification method'),
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _VerificationCard(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        onTap: () => setState(() => _step = 1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _VerificationCard(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        onTap: () => setState(() => _step = 2),
                      ),
                    ),
                  ],
                ),
              ] else if (_step == 1) ...[
                AppTextField(
                  hint: 'Enter Your Email',
                  suffixIcon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  errorText: _errorText,
                ),
              ] else ...[
                AppTextField(
                  hint: 'Enter Your Phone',
                  suffixIcon: Icons.phone_outlined,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  errorText: _errorText,
                ),
              ],
              const SizedBox(height: 280),
              if (_step != 0)
                Align(
                  alignment: Alignment.centerRight,
                  child: AppNextButton(
                    label: _loading ? 'Loading...' : 'Next',
                    onTap: _continue,
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

class _VerificationCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _VerificationCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 162,
        decoration: BoxDecoration(
          color: AppColors.lightPurple,
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.purple,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, color: AppColors.white, size: 20),
            ),
            const Spacer(),
            Text(
              context.tr(label),
              style: const TextStyle(
                color: AppColors.purple,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.tr('Press here'),
              style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
