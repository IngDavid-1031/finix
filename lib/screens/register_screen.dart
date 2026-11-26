import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/backgrounds.dart';
import '../widgets/common.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
                      const FinixField(
                        hint: 'Nombre completo',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 14),
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
                        label: 'Crear cuenta',
                        onPressed: () => enterApp(context),
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
