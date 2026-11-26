import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'data/finance_data.dart';
import 'screens/home_shell.dart';
import 'screens/splash_screen.dart';
import 'theme/app_colors.dart';

/// Para desarrollo: --dart-define=START=home|stats|goals|profile abre esa
/// pestaña directamente con datos de ejemplo (sin iniciar sesión).
const _start = String.fromEnvironment('START');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_start.isEmpty) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        publishableKey: SupabaseConfig.publishableKey,
      );
      AppState.backendReady = true;
    } catch (e) {
      debugPrint('No se pudo inicializar Supabase: $e');
    }
  } else {
    AppState.loadDemoData();
  }
  runApp(const FinixApp());
}

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
    home: switch (_start) {
      'home' => const HomeShell(),
      'stats' => const HomeShell(initialTab: 1),
      'goals' => const HomeShell(initialTab: 2),
      'profile' => const HomeShell(initialTab: 3),
      _ => const SplashScreen(),
    },
  );
}
