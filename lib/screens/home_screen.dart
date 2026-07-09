import 'package:flutter/material.dart';

import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/localization/app_localizations.dart';
import '../shared/widgets/app_widgets.dart';
import 'bottom_nav.dart';
import 'care_note_preview.dart';
import 'emergency_row.dart';
import 'location_card.dart';
import 'vitals_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showLangMenu = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_showLangMenu) setState(() => _showLangMenu = false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 40),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Header(
                              onLanguageTap: () => setState(
                                () => _showLangMenu = !_showLangMenu,
                              ),
                            ),
                            const SizedBox(height: 64),
                            const _LocationSection(),
                            const SizedBox(height: 38),
                            const _VitalsSection(),
                            const SizedBox(height: 38),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: EmergencyRow(),
                            ),
                            const SizedBox(height: 24),
                            _CareNotesSection(
                              onAllTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.careNotes,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (_showLangMenu)
                  Positioned(
                    top: 110,
                    right: 16,
                    child: _LanguageMenu(
                      onSelected: (locale) {
                        AppLanguageScope.of(context).setLocale(locale);
                        setState(() => _showLangMenu = false);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 390),
            child: BottomNav(currentIndex: 0),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onLanguageTap;

  const _Header({
    required this.onLanguageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AppAvatar(
                assetPath: AppAssets.profileAli,
                size: 60,
              ),
              const SizedBox(width: 8),
              Text(
                context.tr('Hello, Ali'),
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onLanguageTap,
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: AppColors.greyBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                context.isArabic ? 'AR' : 'EN',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationSection extends StatelessWidget {
  const _LocationSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: 328,
        height: 354,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 328,
              height: 29,
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 22,
                    height: 29 / 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                    color: AppColors.textDark,
                  ),
                  children: [
                    TextSpan(text: context.tr('Location ')),
                    TextSpan(
                      text: context.tr('(Live)'),
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 15,
                        height: 19 / 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                        color: Color(0xFFE31E24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(
              width: 328,
              height: 313,
              child: LocationCard(),
            ),
          ],
        ),
      ),
    );
  }
}

class _VitalsSection extends StatelessWidget {
  const _VitalsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            context.tr('Vitals & Result'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const VitalsGrid(),
      ],
    );
  }
}

class _CareNotesSection extends StatelessWidget {
  final VoidCallback onAllTap;

  const _CareNotesSection({required this.onAllTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('Care Notes'),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          CareNotePreview(onAllTap: onAllTap),
        ],
      ),
    );
  }
}

class _LanguageMenu extends StatelessWidget {
  final ValueChanged<Locale> onSelected;

  const _LanguageMenu({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 88,
        decoration: BoxDecoration(
          color: const Color(0xFF2F2E2E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageMenuItem(
              label: 'English',
              selected: !context.isArabic,
              isFirst: true,
              onTap: () => onSelected(const Locale('en')),
            ),
            _LanguageMenuItem(
              label: 'Arabic',
              selected: context.isArabic,
              isLast: true,
              onTap: () => onSelected(const Locale('ar')),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageMenuItem extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const _LanguageMenuItem({
    required this.label,
    required this.selected,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF908F8F) : const Color(0xFF2F2E2E),
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(8) : Radius.zero,
            bottom: isLast ? const Radius.circular(8) : Radius.zero,
          ),
          border: isFirst
              ? const Border(
                  bottom: BorderSide(color: Color(0x74FFFFFF), width: 0.7),
                )
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
