import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/localization/app_localizations.dart';
import '../core/services/auth_service.dart';
import '../shared/widgets/app_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorText;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _errorText = null;
    });
    final result = await AuthService.instance.register(
      fullName: _fullNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.isSuccess) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const AppBackButton(),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.loginForm,
                    ),
                    child: Text(
                      context.tr('Login'),
                      style: const TextStyle(
                        color: AppColors.purple,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 88),
              Text(
                context.tr('Register'),
                style: const TextStyle(
                  color: AppColors.purple,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('Create your account to get started'),
                style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
              const SizedBox(height: 48),
              AppTextField(
                hint: 'Full Name',
                suffixIcon: Icons.person_outline,
                controller: _fullNameController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              AppTextField(
                hint: 'Email',
                suffixIcon: Icons.email_outlined,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              // Phone field with country code
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightPurple,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text('🇪🇬', style: TextStyle(fontSize: 18)),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.textGrey,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: context.tr('Phone Number'),
                          hintStyle: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                            fontFamily: 'Roboto',
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.phone_outlined,
                      size: 20,
                      color: AppColors.textGrey,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              AppTextField(
                hint: 'Password',
                suffixIcon: Icons.visibility_off_outlined,
                obscure: true,
                controller: _passwordController,
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
              const SizedBox(height: 160),
              Center(
                child: Text(
                  context.tr(
                    'By registering you agree to our\nTerms and Conditions',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppPrimaryButton(
                label: _loading ? 'Loading...' : 'Register',
                onTap: _register,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
