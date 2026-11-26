import 'dart:async';

import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2500), _go);
  }

  void _go() {
    _timer?.cancel();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(fadeRoute(const LoginScreen()));
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
