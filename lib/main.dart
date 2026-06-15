import 'package:flutter/material.dart';
import 'utils/constants.dart';
import 'views/splash_screen.dart';
import 'views/login_screen.dart';
import 'views/signup_screen.dart';
import 'views/home_screen.dart';
import 'views/profile_screen.dart';
import 'views/job_detail_screen.dart';
import 'views/company_screen.dart';
import 'views/favorites_screen.dart';
import 'views/applied_jobs_screen.dart';
import 'views/top_companies_screen.dart';
import 'views/resume_builder_screen.dart';
import 'views/job_alert_screen.dart';
import 'views/contact_screen.dart';
import 'views/about_screen.dart';
import 'views/how_to_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JobinjaApp());
}

class JobinjaApp extends StatelessWidget {
  const JobinjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
        ),
        fontFamily: AppTypography.fontFamily,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: AppTypography.button,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: AppColors.textSecondary,
          ),
          hintStyle: const TextStyle(
            fontFamily: AppTypography.fontFamily,
            color: AppColors.textMuted,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: const BorderSide(color: AppColors.border, width: 0.5),
          ),
          color: AppColors.surface,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: AppColors.primaryLight,
          backgroundColor: AppColors.surface,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontFamily: AppTypography.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              );
            }
            return const TextStyle(
              fontFamily: AppTypography.fontFamily,
              fontSize: 12,
              color: AppColors.textMuted,
            );
          }),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/job-detail': (context) => const JobDetailScreen(),
        '/company': (context) => const CompanyScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/applied-jobs': (context) => const AppliedJobsScreen(),
        '/top-companies': (context) => const TopCompaniesScreen(),
        '/resume-builder': (context) => const ResumeBuilderScreen(),
        '/job-alert': (context) => const JobAlertScreen(),
        '/contact': (context) => const ContactScreen(),
        '/about': (context) => const AboutScreen(),
        '/how-to': (context) => const HowToScreen(),
      },
    );
  }
}
