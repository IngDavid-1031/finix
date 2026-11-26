import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/backgrounds.dart';
import '../widgets/common.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2200), _go);
  }

  void _go() {
    _timer?.cancel();
    if (!mounted || _done) return;
    _done = true;
    // Si ya hay una sesión guardada (o se acaba de volver de Google), entra directo.
    final user = AuthService.currentUser;
    if (user != null) {
      enterApp(context, user);
    } else {
      Navigator.of(context).pushReplacement(fadeRoute(const LoginScreen()));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: GestureDetector(
      onTap: _go,
      child: WavesBackground(
        dark: true,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FinixLogoMark(size: 120),
              const SizedBox(height: 28),
              const Text(
                'Finix',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Controla tus finanzas,\nconstruye tus sueños',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 17,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
