import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/backgrounds.dart';
import '../widgets/common.dart';
import 'home_shell.dart';
import 'register_screen.dart';

void logout(BuildContext context) => Navigator.of(
  context,
  rootNavigator: true,
).pushAndRemoveUntil(fadeRoute(const LoginScreen()), (_) => false);

void enterApp(BuildContext context) => Navigator.of(
  context,
  rootNavigator: true,
).pushAndRemoveUntil(fadeRoute(const HomeShell()), (_) => false);

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

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => AuthLayout(
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
        const FinixField(
          hint: 'Correo electrónico',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        const FinixField(
          hint: 'Contraseña',
          icon: Icons.lock_outline_rounded,
          obscure: true,
        ),
        const SizedBox(height: 26),
        PrimaryButton(
          label: 'Iniciar sesión',
          onPressed: () => enterApp(context),
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
        SizedBox(
          height: 54,
          child: OutlinedButton(
            onPressed: () => enterApp(context),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _GoogleG(),
                SizedBox(width: 10),
                Text(
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
        ),
        const SizedBox(height: 36),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¿No tienes cuenta? ',
              style: TextStyle(color: AppColors.muted),
            ),
            GestureDetector(
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
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
  );
}

class _GoogleG extends StatelessWidget {
  const _GoogleG();

  @override
  Widget build(BuildContext context) => ShaderMask(
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
  );
}
