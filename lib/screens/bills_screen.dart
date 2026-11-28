import 'package:flutter/material.dart';

import '../data/finance_data.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/reminder_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';

/// Pagos fijos mensuales: arriendo, planes, servicios… con cuenta regresiva
/// de los días que faltan para que se venzan.
class BillsScreen extends StatelessWidget {
  final bool standalone;
  const BillsScreen({super.key, this.standalone = false});

  @override
  Widget build(BuildContext context) {
    final body = ValueListenableBuilder<List<Bill>>(
      valueListenable: AppState.bills,
      builder: (context, bills, _) {
        final pending = bills.where((b) => !b.paidThisMonth).toList()
          ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
        final paid = bills.where((b) => b.paidThisMonth).toList()
          ..sort((a, b) => a.dueDay.compareTo(b.dueDay));

        return ListView(
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
                const Expanded(
                  child: Text(
                    'Pagos fijos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => showBillDialog(context),
                  icon: const Icon(Icons.add_rounded, color: AppColors.green),
                  label: const Text(
                    'Nuevo',
                    style: TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Arriendo, planes, servicios y todo lo que pagas cada mes.',
              style: TextStyle(color: AppColors.muted, fontSize: 13.5),
            ),
            const SizedBox(height: 16),
            if (bills.isEmpty)
              EmptyHint(
                icon: Icons.event_repeat_rounded,
                text:
                    'Aún no tienes pagos fijos.\nAgrega tu arriendo, plan de celular o internet y te avisamos antes de que se venzan.',
                actionLabel: 'Agregar mi primer pago',
                onAction: () => showBillDialog(context),
              )
            else ...[
              _BillsSummary(bills: bills, next: pending.firstOrNull),
              if (pending.isNotEmpty) ...[
                const SizedBox(height: 22),
                const SectionHeader(title: 'Por pagar'),
                const SizedBox(height: 10),
                for (final b in pending) ...[
                  BillTile(bill: b),
                  const SizedBox(height: 10),
                ],
              ],
              if (paid.isNotEmpty) ...[
                const SizedBox(height: 14),
                const SectionHeader(title: 'Pagados este mes'),
                const SizedBox(height: 10),
                for (final b in paid) ...[
                  BillTile(bill: b),
                  const SizedBox(height: 10),
                ],
              ],
            ],
          ],
        );
      },
    );
    return standalone ? StandalonePage(child: body) : body;
  }
}

/* ───────────── Resumen del mes ───────────── */

class _BillsSummary extends StatelessWidget {
  final List<Bill> bills;
  final Bill? next;
  const _BillsSummary({required this.bills, required this.next});

  @override
  Widget build(BuildContext context) {
    final total = bills.fold<int>(0, (a, b) => a + b.amount);
    final paid = bills
        .where((b) => b.paidThisMonth)
        .fold<int>(0, (a, b) => a + b.amount);
    final pending = total - paid;
    final progress = total == 0 ? 0.0 : paid / total;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.darkGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pendiente de ${monthNames[DateTime.now().month - 1].toLowerCase()}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatMoney(pending),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(AppColors.mint),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Pagado ${formatMoney(paid)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                'Total ${formatMoney(total)}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (next != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(next!.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Próximo: ${next!.title}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    dueText(next!),
                    style: const TextStyle(
                      color: AppColors.mint,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/* ───────────── Estado del vencimiento ───────────── */

/// "Vence hoy", "Faltan 5 días", "Vencido hace 2 días", "Pagado".
String dueText(Bill b) {
  if (b.paidThisMonth) return 'Pagado';
  final d = b.daysLeft;
  if (d < 0) return 'Vencido hace ${-d} ${-d == 1 ? 'día' : 'días'}';
  if (d == 0) return 'Vence hoy';
  if (d == 1) return 'Vence mañana';
  return 'Faltan $d días';
}

Color dueColor(Bill b) {
  if (b.paidThisMonth) return AppColors.muted;
  if (b.daysLeft <= 0) return AppColors.red;
  if (b.daysLeft <= b.remindDays) return const Color(0xFFF97316);
  return AppColors.green;
}

class DueChip extends StatelessWidget {
  final Bill bill;
  const DueChip({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    final c = dueColor(bill);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            bill.paidThisMonth
                ? Icons.check_circle_rounded
                : bill.daysLeft < 0
                ? Icons.error_rounded
                : Icons.schedule_rounded,
            size: 14,
            color: c,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              dueText(bill),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: c,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Emoji dentro de un anillo que se va llenando a medida que se acerca el día.
class _CountdownBubble extends StatelessWidget {
  final Bill bill;
  final double size;
  const _CountdownBubble({required this.bill, this.size = 52});

  @override
  Widget build(BuildContext context) {
    final c = dueColor(bill);
    final v = bill.paidThisMonth
        ? 1.0
        : (1 - bill.daysLeft.clamp(0, 30) / 30).toDouble();
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: v,
              strokeWidth: 3.5,
              strokeCap: StrokeCap.round,
              backgroundColor: c.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(c),
            ),
          ),
          Text(bill.emoji, style: TextStyle(fontSize: size * 0.42)),
        ],
      ),
    );
  }
}

class BillTile extends StatelessWidget {
  final Bill bill;
  final bool compact;
  const BillTile({super.key, required this.bill, this.compact = false});

  @override
  Widget build(BuildContext context) => SoftCard(
    onTap: () => showBillActions(context, bill),
    padding: EdgeInsets.all(compact ? 12 : 14),
    child: Row(
      children: [
        _CountdownBubble(bill: bill, size: compact ? 44 : 52),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bill.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Vence el ${bill.nextDue.day} de ${monthNames[bill.nextDue.month - 1].toLowerCase()}',
                style: const TextStyle(color: AppColors.muted, fontSize: 12.5),
              ),
              const SizedBox(height: 6),
              DueChip(bill: bill),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formatMoney(bill.amount),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: bill.paidThisMonth ? AppColors.muted : AppColors.text,
            decoration: bill.paidThisMonth ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    ),
  );
}

/// Tarjeta "Próximos pagos" para Inicio (móvil y escritorio).
class UpcomingBillsCard extends StatelessWidget {
  final VoidCallback onSeeAll;
  final int max;
  const UpcomingBillsCard({super.key, required this.onSeeAll, this.max = 3});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<List<Bill>>(
    valueListenable: AppState.bills,
    builder: (context, bills, _) {
      final pending = bills.where((b) => !b.paidThisMonth).toList()
        ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: 'Próximos pagos',
            action: bills.isEmpty ? null : 'Ver todos',
            onAction: onSeeAll,
          ),
          const SizedBox(height: 10),
          if (bills.isEmpty)
            SoftCard(
              onTap: () => showBillDialog(context),
              child: const Row(
                children: [
                  Text('🧾', style: TextStyle(fontSize: 30)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Agrega tus pagos fijos (arriendo, planes…) y te avisamos antes de que se venzan.',
                      style: TextStyle(color: AppColors.muted, height: 1.35),
                    ),
                  ),
                  Icon(Icons.add_circle_rounded, color: AppColors.green),
                ],
              ),
            )
          else if (pending.isEmpty)
            const SoftCard(
              child: Row(
                children: [
                  Text('🎉', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '¡Todo pagado este mes!',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            for (final b in pending.take(max)) ...[
              BillTile(bill: b, compact: true),
              const SizedBox(height: 10),
            ],
        ],
      );
    },
  );
}

/* ───────────── Acciones ───────────── */

void _toast(BuildContext context, String msg, {bool error = false}) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? AppColors.red : AppColors.primaryDark,
        ),
      );

Future<void> showBillActions(BuildContext context, Bill bill) async {
  final action = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(bill.emoji, style: const TextStyle(fontSize: 34)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bill.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        '${formatMoney(bill.amount)} · día ${bill.dueDay} de cada mes',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                DueChip(bill: bill),
              ],
            ),
            const SizedBox(height: 18),
            if (!bill.paidThisMonth || bill.daysLeft <= bill.remindDays)
              PrimaryButton(
                label: bill.paidThisMonth
                    ? 'Pagar el próximo mes'
                    : 'Marcar como pagado',
                arrow: false,
                height: 52,
                onPressed: () => Navigator.pop(ctx, 'pay'),
              ),
            if (bill.paidThisMonth)
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'unpay'),
                child: const Text(
                  'Marcar como no pagado',
                  style: TextStyle(color: AppColors.text),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(ctx, 'edit'),
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.text,
                    ),
                    label: const Text(
                      'Editar',
                      style: TextStyle(color: AppColors.text),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(ctx, 'delete'),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.red,
                    ),
                    label: const Text(
                      'Eliminar',
                      style: TextStyle(color: AppColors.red),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  if (!context.mounted || action == null) return;
  try {
    switch (action) {
      case 'pay':
        await DatabaseService.payBill(bill);
        if (context.mounted) {
          _toast(context, '${bill.title} pagado · se registró como gasto');
        }
      case 'unpay':
        await DatabaseService.unpayBill(bill);
      case 'edit':
        await showBillDialog(context, existing: bill);
      case 'delete':
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Eliminar pago fijo'),
            content: Text('¿Seguro que quieres eliminar "${bill.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: AppColors.red),
                ),
              ),
            ],
          ),
        );
        if (ok == true) await DatabaseService.deleteBill(bill);
    }
  } catch (e) {
    if (context.mounted) {
      _toast(context, AuthService.errorMessage(e), error: true);
    }
  }
}

/* ───────────── Crear / editar ───────────── */

const _presets = [
  ('🏠', 'Arriendo', Categories.hogar),
  ('📱', 'Plan celular', Categories.servicios),
  ('🌐', 'Internet', Categories.servicios),
  ('💡', 'Luz', Categories.servicios),
  ('💧', 'Agua', Categories.servicios),
  ('🔥', 'Gas', Categories.servicios),
  ('🎬', 'Streaming', Categories.servicios),
  ('🏋️', 'Gimnasio', Categories.salud),
  ('🚗', 'Carro / Moto', Categories.transporte),
  ('💳', 'Tarjeta / Crédito', Categories.otros),
  ('📚', 'Estudio', Categories.otros),
  ('🧾', 'Otro', Categories.otros),
];

Future<void> showBillDialog(BuildContext context, {Bill? existing}) async {
  final title = TextEditingController(text: existing?.title ?? '');
  final amount = TextEditingController(
    text: existing == null ? '' : existing.amount.toString(),
  );
  var preset = _presets.indexWhere((p) => p.$1 == existing?.emoji);
  if (preset < 0) preset = existing == null ? 0 : _presets.length - 1;
  var day = existing?.dueDay ?? DateTime.now().day;
  var remind = existing?.remindDays ?? 3;

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(existing == null ? 'Nuevo pago fijo' : 'Editar pago fijo'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < _presets.length; i++)
                      Tooltip(
                        message: _presets[i].$2,
                        child: GestureDetector(
                          onTap: () => setLocal(() {
                            // Si el nombre era el de otro preset, lo cambia.
                            final t = title.text.trim();
                            if (t.isEmpty ||
                                _presets.any(
                                  (p) => p.$2 == t && p.$2 != 'Otro',
                                )) {
                              title.text = i == _presets.length - 1
                                  ? ''
                                  : _presets[i].$2;
                            }
                            preset = i;
                          }),
                          child: Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: i == preset
                                  ? AppColors.greenSoft
                                  : AppColors.field,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: i == preset
                                    ? AppColors.green
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              _presets[i].$1,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                FinixField(
                  hint: 'Nombre (ej: Arriendo)',
                  icon: Icons.edit_outlined,
                  controller: title,
                ),
                const SizedBox(height: 12),
                FinixField(
                  hint: 'Valor mensual',
                  icon: Icons.attach_money_rounded,
                  controller: amount,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Día del mes en que vence',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: AppColors.field,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            setLocal(() => day = day <= 1 ? 31 : day - 1),
                        icon: const Icon(Icons.remove_rounded),
                      ),
                      Expanded(
                        child: Text(
                          'Día $day',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            setLocal(() => day = day >= 31 ? 1 : day + 1),
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                ),
                if (day > 28)
                  const Padding(
                    padding: EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      'En meses más cortos vencerá el último día.',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Recordarme antes',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final d in const [1, 3, 5, 7])
                      ChoiceChip(
                        label: Text('$d ${d == 1 ? 'día' : 'días'}'),
                        selected: remind == d,
                        selectedColor: AppColors.greenSoft,
                        backgroundColor: AppColors.field,
                        side: BorderSide.none,
                        labelStyle: TextStyle(
                          color: remind == d
                              ? AppColors.primary
                              : AppColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) => setLocal(() => remind = d),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(existing == null ? 'Guardar' : 'Actualizar'),
          ),
        ],
      ),
    ),
  );
  if (ok != true || !context.mounted) return;

  final value =
      int.tryParse(amount.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  final p = _presets[preset];
  final name = title.text.trim().isEmpty ? p.$2 : title.text.trim();
  if (value <= 0) {
    _toast(context, 'Escribe el valor mensual', error: true);
    return;
  }
  try {
    if (existing == null) {
      final now = DateTime.now();
      // Si el día de este mes ya pasó, se asume que este mes ya está pagado.
      final passed = day < now.day;
      await DatabaseService.addBill(
        Bill(
          title: name,
          amount: value,
          dueDay: day,
          emoji: p.$1,
          category: p.$3,
          remindDays: remind,
          paidMonth: passed
              ? Bill.monthKey(now)
              : Bill.monthKey(DateTime(now.year, now.month - 1)),
        ),
      );
      await ReminderService.askPermission();
      if (context.mounted) _toast(context, 'Pago fijo agregado');
    } else {
      await DatabaseService.updateBill(
        existing,
        existing.copyWith(
          title: name,
          amount: value,
          dueDay: day,
          emoji: p.$1,
          category: p.$3,
          remindDays: remind,
        ),
      );
      if (context.mounted) _toast(context, 'Pago fijo actualizado');
    }
  } catch (e) {
    if (context.mounted) {
      _toast(context, AuthService.errorMessage(e), error: true);
    }
  }
}
