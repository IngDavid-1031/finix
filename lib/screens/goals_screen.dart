import 'package:flutter/material.dart';

import '../data/finance_data.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<List<Goal>>(
    valueListenable: AppState.goals,
    builder: (context, goals, _) => ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        Row(
          children: [
            const Icon(Icons.track_changes_rounded, color: AppColors.text),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Mis metas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => showCreateGoalDialog(context),
              icon: const Icon(Icons.add_rounded, color: AppColors.green),
              label: const Text(
                'Nueva meta',
                style: TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (goals.isEmpty)
          EmptyHint(
            icon: Icons.flag_rounded,
            text:
                'Aún no tienes metas de ahorro.\nCrea una para empezar a ahorrar con un objetivo.',
            actionLabel: 'Crear mi primera meta',
            onAction: () => showCreateGoalDialog(context),
          )
        else ...[
          _MainGoalCard(goal: goals.first),
          if (goals.length > 1) ...[
            const SizedBox(height: 22),
            const SectionHeader(title: 'Tus otras metas'),
            const SizedBox(height: 12),
            for (final g in goals.skip(1)) ...[
              GoalTile(goal: g, onTap: () => showAddToGoalDialog(context, g)),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ],
    ),
  );
}

class _MainGoalCard extends StatelessWidget {
  final Goal goal;
  const _MainGoalCard({required this.goal});

  @override
  Widget build(BuildContext context) => SoftCard(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white, Color(0xFFEAF4FF)],
    ),
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: RingProgress(
                    value: goal.progress,
                    thickness: 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(goal.progress * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        const Text(
                          'Completado',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 10,
                child: Text(goal.emoji, style: const TextStyle(fontSize: 64)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Text(
                goal.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Eliminar meta',
              onPressed: () => confirmDeleteGoal(context, goal),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
        Text(
          '${formatMoney(goal.saved)} / ${formatMoney(goal.target)}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: 'Abonar a la meta',
          arrow: false,
          height: 50,
          onPressed: () => showAddToGoalDialog(context, goal),
        ),
      ],
    ),
  );
}

class GoalTile extends StatelessWidget {
  final Goal goal;
  final VoidCallback? onTap;
  const GoalTile({super.key, required this.goal, this.onTap});

  @override
  Widget build(BuildContext context) => SoftCard(
    onTap: onTap,
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${formatMoney(goal.saved)} / ${formatMoney(goal.target)}',
                style: const TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              ProgressBar(value: goal.progress, color: goal.color),
              const SizedBox(height: 6),
              Text(
                '${(goal.progress * 100).round()}%',
                style: TextStyle(
                  color: goal.color,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFFEAF4FF), Color(0xFFF4ECFF)],
            ),
          ),
          alignment: Alignment.center,
          child: Text(goal.emoji, style: const TextStyle(fontSize: 40)),
        ),
      ],
    ),
  );
}

int _digits(String s) => int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

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

Future<void> showAddToGoalDialog(BuildContext context, Goal goal) async {
  final ctrl = TextEditingController();
  final added = await showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text('Abonar a "${goal.title}"'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${formatMoney(goal.saved)} de ${formatMoney(goal.target)}',
            style: const TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          FinixField(
            hint: 'Monto a abonar',
            icon: Icons.attach_money_rounded,
            controller: ctrl,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () => Navigator.pop(ctx, _digits(ctrl.text)),
          child: const Text('Abonar'),
        ),
      ],
    ),
  );
  if (added == null || added <= 0 || !context.mounted) return;
  try {
    await DatabaseService.addToGoal(goal, added);
  } catch (e) {
    if (context.mounted) {
      _toast(context, AuthService.errorMessage(e), error: true);
    }
  }
}

const _emojis = ['✈️', '📱', '🏠', '🚗', '🎓', '💻', '🏖️', '💍', '🎁', '🐷'];

Future<void> showCreateGoalDialog(BuildContext context) async {
  final title = TextEditingController();
  final target = TextEditingController();
  var emoji = _emojis.first;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setLocal) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Nueva meta'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FinixField(
                hint: 'Nombre (ej: Viaje a Japón)',
                icon: Icons.flag_outlined,
                controller: title,
              ),
              const SizedBox(height: 12),
              FinixField(
                hint: 'Monto objetivo',
                icon: Icons.attach_money_rounded,
                controller: target,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in _emojis)
                    GestureDetector(
                      onTap: () => setLocal(() => emoji = e),
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: e == emoji
                              ? AppColors.greenSoft
                              : AppColors.field,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: e == emoji
                                ? AppColors.green
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                ],
              ),
            ],
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
            child: const Text('Crear'),
          ),
        ],
      ),
    ),
  );
  if (ok != true || !context.mounted) return;
  final amount = _digits(target.text);
  if (title.text.trim().isEmpty || amount <= 0) {
    _toast(context, 'Escribe un nombre y un monto objetivo', error: true);
    return;
  }
  try {
    await DatabaseService.addGoal(
      Goal(title: title.text.trim(), saved: 0, target: amount, emoji: emoji),
    );
    if (context.mounted) _toast(context, 'Meta creada');
  } catch (e) {
    if (context.mounted) {
      _toast(context, AuthService.errorMessage(e), error: true);
    }
  }
}

Future<void> confirmDeleteGoal(BuildContext context, Goal goal) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Eliminar meta'),
      content: Text('¿Seguro que quieres eliminar "${goal.title}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Eliminar', style: TextStyle(color: AppColors.red)),
        ),
      ],
    ),
  );
  if (ok == true) await DatabaseService.deleteGoal(goal);
}
