import 'package:flutter/material.dart';

import '../data/finance_data.dart';
import '../theme/app_colors.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<List<Goal>>(
    valueListenable: AppState.goals,
    builder: (context, goals, _) {
      final main = goals.first;
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        children: [
          const Row(
            children: [
              Icon(Icons.track_changes_rounded, color: AppColors.text),
              SizedBox(width: 8),
              Text(
                'Mis metas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SoftCard(
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
                            value: main.progress,
                            thickness: 16,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(main.progress * 100).round()}%',
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
                        child: Text(
                          main.emoji,
                          style: const TextStyle(fontSize: 64),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  main.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatMoney(main.saved)} / ${formatMoney(main.target)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Editar meta',
                  arrow: false,
                  height: 50,
                  onPressed: () => showAddToGoalDialog(context, 0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SectionHeader(
            title: 'Tus otras metas',
            action: 'Ver todo',
            onAction: () => showSoon(context, 'La lista completa de metas'),
          ),
          const SizedBox(height: 12),
          for (var i = 1; i < goals.length; i++) ...[
            GoalTile(
              goal: goals[i],
              onTap: () => showAddToGoalDialog(context, i),
            ),
            const SizedBox(height: 12),
          ],
        ],
      );
    },
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
                formatMoney(goal.saved),
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

Future<void> showAddToGoalDialog(BuildContext context, int index) async {
  final goal = AppState.goals.value[index];
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
          onPressed: () => Navigator.pop(
            ctx,
            int.tryParse(ctrl.text.replaceAll(RegExp(r'[^0-9]'), '')),
          ),
          child: const Text('Abonar'),
        ),
      ],
    ),
  );
  if (added != null && added > 0) AppState.addToGoal(index, added);
}
