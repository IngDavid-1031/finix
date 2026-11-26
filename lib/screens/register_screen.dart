import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/backgrounds.dart';
import '../widgets/common.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_name.text.trim().isEmpty ||
        _email.text.trim().isEmpty ||
        _password.text.isEmpty) {
      showError(context, 'Completa todos los campos');
      return;
    }
    setState(() => _loading = true);
    try {
      final user = await AuthService.register(
        _name.text,
        _email.text,
        _password.text,
      );
      if (!mounted) return;
      if (user != null) {
        enterApp(context, user);
      } else {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Revisa tu correo'),
            content: Text(
              'Te enviamos un enlace a ${_email.text.trim()} para confirmar tu cuenta. '
              'Después vuelve e inicia sesión.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
        if (mounted) Navigator.of(context).maybePop();
      }
    } catch (e) {
      if (mounted) showError(context, AuthService.errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: WavesBackground(
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Stack(
              children: [
                const Positioned(
                  top: 8,
                  right: 0,
                  child: _GrowthIllustration(),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      const SizedBox(height: 70),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: FinixLogoMark(size: 50),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Crear cuenta',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Empieza tu viaje financiero',
                        style: TextStyle(color: AppColors.muted, fontSize: 15),
                      ),
                      const SizedBox(height: 30),
                      FinixField(
                        hint: 'Nombre completo',
                        icon: Icons.person_outline_rounded,
                        controller: _name,
                      ),
                      const SizedBox(height: 14),
                      FinixField(
                        hint: 'Correo electrónico',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        controller: _email,
                      ),
                      const SizedBox(height: 14),
                      FinixField(
                        hint: 'Contraseña (mínimo 6 caracteres)',
                        icon: Icons.lock_outline_rounded,
                        obscure: true,
                        controller: _password,
                      ),
                      const SizedBox(height: 26),
                      PrimaryButton(
                        label: _loading ? 'Creando cuenta…' : 'Crear cuenta',
                        onPressed: _loading ? null : _register,
                      ),
                      const SizedBox(height: 22),
                      const Text.rich(
                        TextSpan(
                          text: 'Al registrarte, aceptas nuestros\n',
                          children: [
                            TextSpan(
                              text: 'Términos y Condiciones',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _GrowthIllustration extends StatelessWidget {
  const _GrowthIllustration();

  @override
  Widget build(BuildContext context) {
    const heights = [42.0, 62.0, 84.0, 108.0, 132.0];
    return SizedBox(
      width: 190,
      height: 175,
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -10,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.mint.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            right: 14,
            bottom: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final h in heights)
                  Container(
                    width: 20,
                    height: h,
                    margin: const EdgeInsets.only(left: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.mint, Color(0xFF0B6B41)],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x330B5A3A),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const Positioned(
            right: 0,
            top: 0,
            child: Icon(
              Icons.trending_up_rounded,
              size: 96,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}
