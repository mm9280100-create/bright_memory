import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/localization/app_localizations.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  const BottomNav({super.key, required this.currentIndex});

  static const _items = [
    _NavItem('Home', Icons.home),
    _NavItem('Routine', Icons.list_alt),
    _NavItem('Contact', Icons.chat_bubble_outline),
    _NavItem('Patient', Icons.person_outline),
    _NavItem('Sensors', Icons.memory),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_items.length, (i) {
          final item = _items[i];
          final active = i == currentIndex;
          final color = active ? AppColors.textDark : AppColors.textGrey;
          return GestureDetector(
            onTap: () {
              if (active) return;
              switch (i) {
                case 0:
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                  break;
                case 1:
                  Navigator.pushNamed(context, AppRoutes.routine);
                  break;
                case 2:
                  Navigator.pushNamed(context, AppRoutes.contact);
                  break;
                case 3:
                  Navigator.pushNamed(context, AppRoutes.patientInfo);
                  break;
                case 4:
                  Navigator.pushNamed(context, AppRoutes.sensors);
                  break;
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 24, color: color),
                const SizedBox(height: 4),
                Text(
                  context.tr(item.label),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem(this.label, this.icon);
}

