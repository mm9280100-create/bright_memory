import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/localization/app_localizations.dart';
import '../shared/widgets/app_widgets.dart';

class VerifyPhoneScreen extends StatefulWidget {
  const VerifyPhoneScreen({super.key});

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final List<String> _digits = ['', '', '', ''];

  void _addDigit(String d) {
    setState(() {
      final idx = _digits.indexWhere((e) => e.isEmpty);
      if (idx != -1) _digits[idx] = d;
    });
  }

  void _clear() {
    setState(() {
      final idx = _digits.lastIndexWhere((e) => e.isNotEmpty);
      if (idx != -1) _digits[idx] = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 650;
            final sidePadding = compact ? 20.0 : 24.0;
            final otpSize = compact ? 52.0 : 60.0;
            final numSize = compact ? 50.0 : 60.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(0, compact ? 8 : 16, 0, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: AppStatusBar(),
                  ),
                  SizedBox(height: compact ? 12 : 32),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: AppBackButton(),
                  ),
                  SizedBox(height: compact ? 16 : 32),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sidePadding),
                    child: Text(
                      context.tr('Verify Phone'),
                      style: const TextStyle(
                        color: AppColors.purple,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sidePadding),
                    child: Text(
                      context.tr(
                        'Enter the verification code sent to your phone number',
                      ),
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 20 : 32),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sidePadding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        4,
                        (i) => Container(
                          width: otpSize,
                          height: otpSize,
                          decoration: BoxDecoration(
                            color: AppColors.lightPurple,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _digits[i],
                            style: const TextStyle(
                              color: AppColors.purple,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sidePadding),
                    child: GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.resetPassword),
                      child: Container(
                        height: 35,
                        decoration: BoxDecoration(
                          color: AppColors.lightPurple,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          context.tr('Verify and Continue'),
                          style: const TextStyle(
                            color: AppColors.purple,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 18 : 24),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 50 : 42,
                    ),
                    child: Column(
                      children: [
                        _NumRow(
                          digits: const ['7', '8', '9'],
                          onTap: _addDigit,
                          size: numSize,
                        ),
                        SizedBox(height: compact ? 10 : 16),
                        _NumRow(
                          digits: const ['4', '5', '6'],
                          onTap: _addDigit,
                          size: numSize,
                        ),
                        SizedBox(height: compact ? 10 : 16),
                        _NumRow(
                          digits: const ['1', '2', '3'],
                          onTap: _addDigit,
                          size: numSize,
                        ),
                        SizedBox(height: compact ? 10 : 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _NumBtn(
                              label: '0',
                              onTap: () => _addDigit('0'),
                              size: numSize,
                            ),
                            SizedBox(width: compact ? 36 : 48),
                            _NumBtn(
                              label: '<',
                              onTap: _clear,
                              size: numSize,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NumRow extends StatelessWidget {
  final List<String> digits;
  final void Function(String) onTap;
  final double size;

  const _NumRow({
    required this.digits,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: digits
            .map((d) => _NumBtn(label: d, onTap: () => onTap(d), size: size))
            .toList(),
      );
}

class _NumBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double size;

  const _NumBtn({
    required this.label,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.purple,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
