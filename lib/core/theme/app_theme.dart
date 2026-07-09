import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorSchemeSeed: AppColors.purple,
        scaffoldBackgroundColor: AppColors.white,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            height: 1.16,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            height: 1.18,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            height: 1.2,
          ),
          titleMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
            height: 1.25,
          ),
          bodyLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
            height: 1.35,
          ),
          bodyMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
            height: 1.35,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textDark),
          titleTextStyle: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.purple,
            foregroundColor: AppColors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      );
}

