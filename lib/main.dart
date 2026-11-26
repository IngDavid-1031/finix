import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/home_shell.dart';
import 'screens/splash_screen.dart';
import 'theme/app_colors.dart';

void main() => runApp(const FinixApp());

class FinixApp extends StatelessWidget {
  const FinixApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Finix',
    debugShowCheckedModeBanner: false,
    locale: const Locale('es'),
    supportedLocales: const [Locale('es'), Locale('en')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
      ),
      scaffoldBackgroundColor: AppColors.bg,
      splashFactory: InkRipple.splashFactory,
    ),
    // Para desarrollo: --dart-define=START=home|stats|goals|profile abre esa pestaña directamente.
    home: switch (const String.fromEnvironment('START')) {
      'home' => const HomeShell(),
      'stats' => const HomeShell(initialTab: 1),
      'goals' => const HomeShell(initialTab: 2),
      'profile' => const HomeShell(initialTab: 3),
      _ => const SplashScreen(),
    },
  );
}
