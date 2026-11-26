import 'package:flutter/material.dart';

import '../data/finance_data.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  final bool standalone;
  const SettingsScreen({super.key, this.standalone = false});

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        Row(
          children: [
            if (standalone)
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.text,
                ),
              ),
            const Text(
              'Configuración',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'Apariencia',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 10),
        SoftCard(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: ValueListenableBuilder<int>(
            valueListenable: AppState.appearance,
            builder: (_, sel, _) => Row(
              children: [
                for (final (i, label) in const [
                  (0, 'Claro'),
                  (1, 'Oscuro'),
                  (2, 'Automático'),
                ])
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => AppState.appearance.value = i,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _RadioDot(selected: sel == i),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                label,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        SoftCard(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: MenuTile(
            icon: Icons.language_rounded,
            title: 'Idioma',
            onTap: () => showSoon(context, 'El cambio de idioma'),
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🇪🇸 Español', style: TextStyle(color: AppColors.text)),
                Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        SoftCard(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Column(
            children: [
              MenuTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notificaciones',
                trailing: NotifierSwitch(AppState.notifications),
              ),
              MenuTile(
                icon: Icons.alarm_rounded,
                title: 'Recordatorios de gasto',
                trailing: NotifierSwitch(AppState.reminders),
              ),
              MenuTile(
                icon: Icons.cloud_sync_outlined,
                title: 'Sincronización en la nube',
                trailing: NotifierSwitch(AppState.cloudSync),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SoftCard(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Column(
            children: [
              MenuTile(
                icon: Icons.lock_outline_rounded,
                title: 'Privacidad y seguridad',
                onTap: () => showSoon(context, 'Privacidad y seguridad'),
              ),
              MenuTile(
                icon: Icons.description_outlined,
                title: 'Términos y condiciones',
                onTap: () => showSoon(context, 'Términos y condiciones'),
              ),
              MenuTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Política de privacidad',
                onTap: () => showSoon(context, 'Política de privacidad'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Material(
          color: AppColors.redSoft,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => logout(context),
            child: const SizedBox(
              height: 54,
              child: Center(
                child: Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
    return standalone ? StandalonePage(child: body) : body;
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;
  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) => Container(
    width: 18,
    height: 18,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: selected ? AppColors.green : AppColors.muted,
        width: 2,
      ),
    ),
    padding: const EdgeInsets.all(3),
    child: selected
        ? Container(
            decoration: const BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
            ),
          )
        : null,
  );
}
