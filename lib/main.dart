import 'package:flutter/material.dart';
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
      title: 'جابینجا',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90D9),
          primary: const Color(0xFF4A90D9),
          surface: Colors.white,
        ),
        fontFamily: 'Vazir',
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF212529),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Vazir',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212529),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A90D9),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8F9FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4A90D9), width: 2),
          ),
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
        '/how-to': (context) => const HowToScreen(),
      },
    );
  }
}
