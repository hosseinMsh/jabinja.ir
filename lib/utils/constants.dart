import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4A90D9);
  static const Color primaryDark = Color(0xFF357ABD);
  static const Color background = Color(0xFFF8F9FA);
  static const Color white = Colors.white;
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textMuted = Color(0xFFADB5BD);
  static const Color border = Color(0xFFDEE2E6);
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFE74C3C);
  static const Color star = Color(0xFFF5A623);
  static const Color chipBackground = Color(0xFFE8F0FE);
  static const Color premiumGold = Color(0xFFB8860B);
  static const Color premiumLight = Color(0xFFFFD700);
}

class AppTypography {
  static const String fontFamily = 'Vazir';

  static const TextStyle h1 = TextStyle(fontFamily: fontFamily, fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary);
  static const TextStyle h2 = TextStyle(fontFamily: fontFamily, fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary);
  static const TextStyle h3 = TextStyle(fontFamily: fontFamily, fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary);
  static const TextStyle h4 = TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary);
  static const TextStyle body = TextStyle(fontFamily: fontFamily, fontSize: 14, color: AppColors.textPrimary);
  static const TextStyle bodySmall = TextStyle(fontFamily: fontFamily, fontSize: 12, color: AppColors.textSecondary);
  static const TextStyle caption = TextStyle(fontFamily: fontFamily, fontSize: 11, color: AppColors.textMuted);
  static const TextStyle button = TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white);
  static const TextStyle link = TextStyle(fontFamily: fontFamily, fontSize: 14, color: AppColors.primary);
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

class Constants {
  static const String appName = 'جابینجا';
  static const String baseUrl = 'http://localhost:3000/api';

  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
}
