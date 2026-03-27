import 'package:flutter/material.dart';

class AppColors {
  static const Color navy = Color(0xFF0A2540);
  static const Color navyLight = Color(0xFF1A3A5C);
  static const Color gold = Color(0xFFE8A838);
  static const Color goldLight = Color(0xFFFFC85C);
  static const Color background = Color(0xFFF0F4F8);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF00B37E);
  static const Color successBg = Color(0xFFE6F9F3);
  static const Color warning = Color(0xFFE8A838);
  static const Color warningBg = Color(0xFFFFF7E6);
  static const Color danger = Color(0xFFE53E3E);
  static const Color dangerBg = Color(0xFFFFF0F0);
  static const Color info = Color(0xFF3182CE);
  static const Color infoBg = Color(0xFFEBF8FF);
  static const Color textPrimary = Color(0xFF0A2540);
  static const Color textSecondary = Color(0xFF5A6A7E);
  static const Color textMuted = Color(0xFF9EB0C5);
  static const Color divider = Color(0xFFE2EAF2);
}

class AppTextStyles {
  static const TextStyle displayLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.5,
  );
}
