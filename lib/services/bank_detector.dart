import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../data/finance_data.dart';
import 'database_service.dart';

/// Estado de los permisos que necesita la detección automática.
class BankStatus {
  final bool enabled;
  final bool notifications;
  final bool sms;
  final bool overlay;
  const BankStatus({
    this.enabled = false,
    this.notifications = false,
    this.sms = false,
    this.overlay = false,
  });

  /// Lista para funcionar: puede leer el banco (notificación o SMS) y mostrar el banner.
  bool get ready => enabled && (notifications || sms) && overlay;
}

/// Puente con el código nativo de Android que lee los SMS/notificaciones del
/// banco y muestra el banner. Aquí solo se suben a Supabase los movimientos
/// que ya tienen nombre.
class BankDetector {
  BankDetector._();

  static const _ch = MethodChannel('finix/bank');

  /// Solo en la app de Android (no en web ni iOS).
  static bool get supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Se incrementa cuando cambian permisos o llegan movimientos.
  static final changes = ValueNotifier<int>(0);

  static bool _syncing = false;
  // ignore: unused_field
  static AppLifecycleListener? _lifecycle;

  static void init() {
    if (!supported) return;
    _ch.setMethodCallHandler((call) async {
      if (call.method == 'changed') {
        changes.value++;
        await sync();
      }
    });
    _lifecycle = AppLifecycleListener(
      onResume: () {
        changes.value++;
        sync();
      },
    );
  }

  static Future<BankStatus> status() async {
    if (!supported) return const BankStatus();
    final m = await _ch.invokeMapMethod<String, bool>('status') ?? {};
    return BankStatus(
      enabled: m['enabled'] ?? false,
      notifications: m['notifications'] ?? false,
      sms: m['sms'] ?? false,
      overlay: m['overlay'] ?? false,
    );
  }

  static Future<void> setEnabled(bool v) => _ch.invokeMethod('setEnabled', v);
  static Future<void> openNotificationAccess() =>
      _ch.invokeMethod('openNotificationAccess');
  static Future<void> openOverlay() => _ch.invokeMethod('openOverlay');
  static Future<void> openAppSettings() => _ch.invokeMethod('openAppSettings');
  static Future<void> requestPermissions() =>
      _ch.invokeMethod('requestPermissions');
  static Future<void> test() => _ch.invokeMethod('test');

  /// Sube los movimientos detectados que ya tienen nombre.
  static Future<void> sync() async {
    if (!supported || _syncing || AppState.user.value == null) return;
    _syncing = true;
    try {
      final raw = await _ch.invokeMethod<String>('takeReady') ?? '[]';
      final items = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      final done = <String>[];
      for (final it in items) {
        try {
          await DatabaseService.addTransaction(
            Txn(
              title: it['title'] as String,
              category: Categories.otros,
              amount: (it['amount'] as num).toInt(),
              date: DateTime.fromMillisecondsSinceEpoch(
                (it['date'] as num).toInt(),
              ),
              note: 'Detectado automáticamente · ${it['bank']}',
            ),
          );
          done.add(it['id'] as String);
        } catch (e) {
          debugPrint('No se pudo guardar el movimiento detectado: $e');
        }
      }
      if (done.isNotEmpty) await _ch.invokeMethod('ack', done);
    } catch (e) {
      debugPrint('BankDetector.sync: $e');
    } finally {
      _syncing = false;
    }
  }
}
