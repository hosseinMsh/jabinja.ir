import 'package:flutter/material.dart';

import '../services/session_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    _routeBySession();
  }

  Future<void> _routeBySession() async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final isLoggedIn = await _sessionManager.isLoggedIn();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, isLoggedIn ? '/home' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.work_rounded, size: 64, color: Color(0xFF4A90D9)),
            SizedBox(height: 18),
            Text(
              'جابینجا',
              style: TextStyle(
                fontFamily: 'Vazir',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212529),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}
