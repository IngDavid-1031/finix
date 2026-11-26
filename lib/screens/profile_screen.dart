import 'package:flutter/material.dart';

import '../data/finance_data.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onOpenSettings;
  const ProfileScreen({super.key, required this.onOpenSettings});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
    children: [
      const Center(child: UserAvatar(size: 100)),
      const SizedBox(height: 12),
      const Text(
        'Noaj David',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w800,
          color: AppColors.text,
        ),
      ),
      const SizedBox(height: 2),
      const Text(
        'noajdavid@gmail.com',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.muted, fontSize: 13),
      ),
      const SizedBox(height: 10),
      Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.greenSoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_rounded, size: 15, color: AppColors.green),
              SizedBox(width: 4),
              Text(
                'Usuario Premium',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      const PremiumBanner(),
      const SizedBox(height: 16),
      SoftCard(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          children: [
            MenuTile(
              icon: Icons.settings_outlined,
              title: 'Configuración',
              onTap: onOpenSettings,
            ),
            MenuTile(
              icon: Icons.notifications_none_rounded,
              title: 'Notificaciones',
              trailing: NotifierSwitch(AppState.notifications),
            ),
            MenuTile(
              icon: Icons.shield_outlined,
              title: 'Seguridad',
              onTap: () => showSoon(context, 'Seguridad'),
            ),
            MenuTile(
              icon: Icons.help_outline_rounded,
              title: 'Ayuda y soporte',
              onTap: () => showSoon(context, 'Ayuda y soporte'),
            ),
            MenuTile(
              icon: Icons.info_outline_rounded,
              title: 'Acerca de Finix',
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'Finix',
                applicationVersion: '1.0.0',
                applicationIcon: const FinixLogoMark(size: 40),
                applicationLegalese: 'Tu dinero, en tus manos.',
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      SoftCard(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: MenuTile(
          icon: Icons.logout_rounded,
          title: 'Cerrar sesión',
          color: AppColors.red,
          trailing: const SizedBox.shrink(),
          onTap: () => logout(context),
        ),
      ),
    ],
  );
}

class PremiumBanner extends StatelessWidget {
  const PremiumBanner({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: AppColors.darkGradient,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      children: [
        const Text('👑', style: TextStyle(fontSize: 30)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tu plan Premium',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Disfruta de todas las ventajas',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: Colors.white),
      ],
    ),
  );
}
