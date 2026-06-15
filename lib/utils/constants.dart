import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1ABC9C);
  static const Color primaryDark = Color(0xFF16A085);
  static const Color primaryLight = Color(0xFFD4F5EF);
  static const Color accent = Color(0xFF4A90D9);
  static const Color accentLight = Color(0xFFE8F0FE);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF0F0F0);
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color star = Color(0xFFF5A623);
  static const Color chipBackground = Color(0xFFEEF2FF);
  static const Color premiumGold = Color(0xFFB8860B);
  static const Color premiumLight = Color(0xFFFFF3CD);
  static const Color purple = Color(0xFFB3A0FF);
  static const Color amber = Color(0xFFF9A60B);
  static const Color lightBlue = Color(0xFF3AB0E4);
  static const Color shadow = Color(0x0D000000);
  static const Color shadowMd = Color(0x1A000000);
}

class AppTypography {
  static const String fontFamily = 'Vazir';

  static const TextStyle display = TextStyle(fontFamily: fontFamily, fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary);
  static const TextStyle h1 = TextStyle(fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary);
  static const TextStyle h2 = TextStyle(fontFamily: fontFamily, fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary);
  static const TextStyle h3 = TextStyle(fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary);
  static const TextStyle h4 = TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary);
  static const TextStyle body = TextStyle(fontFamily: fontFamily, fontSize: 14, color: AppColors.textPrimary);
  static const TextStyle bodySmall = TextStyle(fontFamily: fontFamily, fontSize: 12, color: AppColors.textSecondary);
  static const TextStyle caption = TextStyle(fontFamily: fontFamily, fontSize: 11, color: AppColors.textMuted);
  static const TextStyle button = TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.surface);
  static const TextStyle link = TextStyle(fontFamily: fontFamily, fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w500);
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 48;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 999;
}

class Constants {
  static const String appName = 'جابینجا';
  static const String baseUrl = 'http://localhost:3000';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}
