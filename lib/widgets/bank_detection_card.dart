import 'package:flutter/material.dart';

import '../services/bank_detector.dart';
import '../theme/app_colors.dart';
import 'common.dart';

/// Configuración de la detección automática de movimientos del banco (solo Android).
class BankDetectionCard extends StatefulWidget {
  const BankDetectionCard({super.key});

  @override
  State<BankDetectionCard> createState() => _BankDetectionCardState();
}

class _BankDetectionCardState extends State<BankDetectionCard> {
  BankStatus _s = const BankStatus();

  @override
  void initState() {
    super.initState();
    BankDetector.changes.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    BankDetector.changes.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final s = await BankDetector.status();
    if (mounted) setState(() => _s = s);
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Detección automática',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: AppColors.text,
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        'Finix lee los mensajes de tu banco (Bancolombia, Nequi…) y agrega '
        'tus compras, pagos y transferencias como gastos o ingresos.',
        style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.35),
      ),
      const SizedBox(height: 10),
      SoftCard(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Column(
          children: [
            MenuTile(
              icon: Icons.account_balance_rounded,
              title: 'Detectar movimientos del banco',
              trailing: FinixSwitch(
                value: _s.enabled,
                onChanged: (v) async {
                  await BankDetector.setEnabled(v);
                  _load();
                },
              ),
            ),
            if (_s.enabled) ...[
              _PermissionTile(
                icon: Icons.notifications_active_outlined,
                title: 'Leer notificaciones',
                ok: _s.notifications,
                onTap: BankDetector.openNotificationAccess,
              ),
              _PermissionTile(
                icon: Icons.sms_outlined,
                title: 'Leer SMS del banco',
                ok: _s.sms,
                onTap: BankDetector.requestPermissions,
              ),
              _PermissionTile(
                icon: Icons.picture_in_picture_alt_outlined,
                title: 'Mostrar sobre otras apps',
                ok: _s.overlay,
                onTap: BankDetector.openOverlay,
              ),
              if (_s.xiaomi)
                _PermissionTile(
                  icon: Icons.open_in_new_rounded,
                  title: 'Ventanas emergentes en segundo plano',
                  ok: _s.popups ?? false,
                  unknown: _s.popups == null,
                  onTap: BankDetector.openMiuiPermissions,
                ),
              MenuTile(
                icon: Icons.battery_saver_outlined,
                title: 'Segundo plano y autoinicio',
                onTap: BankDetector.openAppSettings,
              ),
              MenuTile(
                icon: Icons.play_circle_outline_rounded,
                title: 'Probar el banner',
                color: AppColors.green,
                onTap: () {
                  if (!_s.overlay) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Primero activa “Mostrar sobre otras apps”.',
                        ),
                      ),
                    );
                    return;
                  }
                  BankDetector.test();
                },
              ),
            ],
          ],
        ),
      ),
      if (_s.enabled && !_s.ready)
        const Padding(
          padding: EdgeInsets.fromLTRB(6, 8, 6, 0),
          child: Text(
            'Toca cada opción en rojo para darle el permiso a Finix. En Xiaomi, '
            'en “Ventanas emergentes en segundo plano” activa “Mostrar ventanas '
            'emergentes mientras se ejecuta en segundo plano”, y en “Segundo '
            'plano y autoinicio” activa Autoinicio y pon el ahorro de batería '
            'en “Sin restricciones”.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.muted,
              height: 1.35,
            ),
          ),
        ),
    ],
  );
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool ok;
  final bool unknown;
  final VoidCallback onTap;
  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.ok,
    required this.onTap,
    this.unknown = false,
  });

  @override
  Widget build(BuildContext context) => MenuTile(
    icon: icon,
    title: title,
    onTap: onTap,
    trailing: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: ok
            ? AppColors.greenSoft
            : unknown
            ? AppColors.bg
            : AppColors.redSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        ok
            ? 'Activo'
            : unknown
            ? 'Revisar'
            : 'Activar',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: ok
              ? AppColors.green
              : unknown
              ? AppColors.muted
              : AppColors.red,
        ),
      ),
    ),
  );
}
