import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthChangeEvent, AuthState, User;

import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';
import '../widgets/backgrounds.dart';
import '../widgets/common.dart';
import 'home_shell.dart';
import 'register_screen.dart';

Future<void> logout(BuildContext context) async {
  final nav = Navigator.of(context, rootNavigator: true);
  await AuthService.signOut();
  nav.pushAndRemoveUntil(fadeRoute(const LoginScreen()), (_) => false);
}

/// Conecta los datos del usuario y abre la app.
void enterApp(BuildContext context, User user) {
  DatabaseService.bind(user);
  Navigator.of(
    context,
    rootNavigator: true,
  ).pushAndRemoveUntil(fadeRoute(const HomeShell()), (_) => false);
}

void showError(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.red,
        ),
      );

/// Contenedor común para login y registro.
class AuthLayout extends StatelessWidget {
  final Widget child;
  const AuthLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: WavesBackground(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  StreamSubscription<AuthState>? _sub;
  bool _loading = false;
  bool _entered = false;

  @override
  void initState() {
    super.initState();
    // La vuelta desde Google llega por aquí (Android: deep link; web: recarga).
    _sub = AuthService.changes.listen((s) {
      if (s.event == AuthChangeEvent.signedIn && s.session != null) {
        _enter(s.session!.user);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _enter(User user) {
    if (_entered || !mounted) return;
    _entered = true;
    enterApp(context, user);
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
    } catch (e) {
      if (mounted) showError(context, AuthService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _loginEmail() {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      showError(context, 'Escribe tu correo y contraseña');
      return;
    }
    _run(
      () async => _enter(
        await AuthService.signInWithEmail(_email.text, _password.text),
      ),
    );
  }

  void _loginGoogle() => _run(AuthService.signInWithGoogle);

  @override
  Widget build(BuildContext context) => AuthLayout(
    child: AbsorbPointer(
      absorbing: _loading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Center(child: FinixLogoMark(size: 68)),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Finix',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Bienvenido de nuevo',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Inicia sesión para continuar',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 15),
          ),
          const SizedBox(height: 32),
          FinixField(
            hint: 'Correo electrónico',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            controller: _email,
          ),
          const SizedBox(height: 14),
          FinixField(
            hint: 'Contraseña',
            icon: Icons.lock_outline_rounded,
            obscure: true,
            controller: _password,
          ),
          const SizedBox(height: 26),
          PrimaryButton(
            label: _loading ? 'Ingresando…' : 'Iniciar sesión',
            onPressed: _loginEmail,
          ),
          const SizedBox(height: 22),
          const Row(
            children: [
              Expanded(child: Divider(color: AppColors.border)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'o continúa con',
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
              ),
              Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 18),
          GoogleButton(onPressed: _loginGoogle),
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¿No tienes cuenta? ',
                style: TextStyle(color: AppColors.muted),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: const Text(
                  'Regístrate',
                  style: TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    ),
  );
}

class GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;
  const GoogleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 54,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (r) => const SweepGradient(
              colors: [
                Color(0xFFEA4335),
                Color(0xFFFBBC05),
                Color(0xFF34A853),
                Color(0xFF4285F4),
                Color(0xFFEA4335),
              ],
              stops: [0.0, 0.25, 0.5, 0.75, 1.0],
            ).createShader(r),
            child: const Text(
              'G',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Continuar con Google',
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    ),
  );
}
