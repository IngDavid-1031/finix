import 'package:flutter/material.dart';

import '../data/finance_data.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'bills_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onOpenSettings;
  final VoidCallback? onOpenBills;
  const ProfileScreen({
    super.key,
    required this.onOpenSettings,
    this.onOpenBills,
  });

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
    children: [
      const Center(child: UserAvatar(size: 100)),
      const SizedBox(height: 12),
      ValueListenableBuilder<AppUser?>(
        valueListenable: AppState.user,
        builder: (_, u, _) => Column(
          children: [
            Text(
              u == null || u.name.isEmpty ? 'Mi cuenta' : u.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              u?.email ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ],
        ),
      ),
      const SizedBox(height: 22),
      SoftCard(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          children: [
            MenuTile(
              icon: Icons.event_repeat_rounded,
              title: 'Pagos fijos',
              onTap:
                  onOpenBills ??
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BillsScreen(standalone: true),
                    ),
                  ),
            ),
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
