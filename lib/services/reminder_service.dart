import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/finance_data.dart';

/// Envía los pagos fijos a Android, que avisa con una notificación los días
/// antes del vencimiento (aunque la app esté cerrada).
class ReminderService {
  ReminderService._();

  static const _ch = MethodChannel('finix/bank');

  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// true cuando hay que abrir la pantalla de pagos (al tocar la notificación).
  static final openBills = ValueNotifier<bool>(false);

  static void init() {
    if (!supported) return;
    AppState.bills.addListener(_sync);
    AppState.reminders.addListener(_sync);
    _ch
        .invokeMethod<String>('takeOpen')
        .then((v) {
          if (v == 'bills') openBills.value = true;
        })
        .catchError((_) {});
  }

  /// Lo llama el manejador del canal cuando llega una notificación con la app abierta.
  static void handleOpen(Object? what) {
    if (what == 'bills') openBills.value = true;
  }

  static Future<void> _sync() async {
    // Sin sesión (p. ej. al cerrar sesión) no se borran: se actualizan al volver.
    if (AppState.user.value == null) return;
    try {
      await _ch.invokeMethod('syncBills', {
        'enabled': AppState.reminders.value,
        'bills': [
          for (final b in AppState.bills.value)
            {
              'id': b.id ?? b.title,
              'title': b.title,
              'emoji': b.emoji,
              'amount': b.amount,
              'dueDay': b.dueDay,
              'remindDays': b.remindDays,
              'paidMonth': b.paidMonth ?? '',
            },
        ],
      });
    } catch (e) {
      debugPrint('ReminderService: $e');
    }
  }

  /// Pide el permiso de notificaciones (Android 13+).
  static Future<void> askPermission() async {
    if (!supported) return;
    try {
      await _ch.invokeMethod('requestNotifications');
    } catch (_) {}
  }
}
