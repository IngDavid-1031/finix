import 'package:flutter/material.dart';

import '../data/finance_data.dart';
import '../data/summary.dart';
import '../theme/app_colors.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int filter) onOpenHistory;
  const HomeScreen({super.key, required this.onOpenHistory});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<List<Txn>>(
    valueListenable: AppState.transactions,
    builder: (context, txns, _) {
      final s = FinanceSummary(txns);
      final savingsChange = FinanceSummary.change(
        s.monthSavings,
        s.prevMonthSavings,
      );
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        children: [
          Row(
            children: [
              const FinixLogo(size: 28),
              const Spacer(),
              IconCircleButton(
                icon: Icons.notifications_none_rounded,
                onTap: () => showSoon(context, 'El centro de notificaciones'),
              ),
              const SizedBox(width: 10),
              const UserAvatar(size: 44),
            ],
          ),
          const SizedBox(height: 22),
          const GreetingText(fontSize: 26),
          const SizedBox(height: 4),
          const Text(
            'Aquí tienes un resumen\nde tus finanzas',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          BalanceCard(summary: s),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Ingresos del mes',
                  amount: s.monthIncome,
                  color: AppColors.green,
                  up: true,
                  onTap: () => onOpenHistory(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStat(
                  label: 'Gastos del mes',
                  amount: s.monthExpense,
                  color: AppColors.red,
                  up: false,
                  onTap: () => onOpenHistory(1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SoftCard(
            gradient: const LinearGradient(
              colors: [Color(0xFFF1F8FF), Color(0xFFE3F1FF)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tu ahorro del mes',
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatMoney(s.monthSavings),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      if (savingsChange != null) ...[
                        const SizedBox(height: 4),
                        ChangeLabel(savingsChange),
                      ],
                    ],
                  ),
                ),
                Text(
                  '🐷',
                  style: TextStyle(
                    fontSize: 54,
                    shadows: [
                      Shadow(
                        color: AppColors.blue.withValues(alpha: 0.25),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SectionHeader(
            title: 'Últimos movimientos',
            action: 'Ver todo',
            onAction: () => onOpenHistory(0),
          ),
          const SizedBox(height: 4),
          if (txns.isEmpty)
            const EmptyHint(
              icon: Icons.receipt_long_rounded,
              text:
                  'Aún no tienes movimientos.\nToca el botón + para registrar el primero.',
            )
          else
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Column(
                children: [
                  for (final t in txns.take(4)) TransactionTile(txn: t),
                ],
              ),
            ),
        ],
      );
    },
  );
}

/// "Hola, Nombre 👋" con el nombre del usuario conectado.
class GreetingText extends StatelessWidget {
  final double fontSize;
  final Color color;
  const GreetingText({
    super.key,
    this.fontSize = 26,
    this.color = AppColors.text,
  });

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<AppUser?>(
    valueListenable: AppState.user,
    builder: (_, u, _) => Text(
      u == null || u.firstName.isEmpty ? 'Hola 👋' : 'Hola, ${u.firstName} 👋',
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: color,
      ),
    ),
  );
}

class BalanceCard extends StatefulWidget {
  final FinanceSummary summary;
  const BalanceCard({super.key, required this.summary});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _hidden = false;
  int _period = 0;

  static const _periods = ['1M', '3M', '6M', '1A'];
  static const _days = [30, 90, 180, 365];

  @override
  Widget build(BuildContext context) {
    final s = widget.summary;
    final change = s.balanceChange;
    final series = s.balanceSeries(days: _days[_period]);
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.darkGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 96),
            child: Stack(
              children: [
                if (s.txns.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 140,
                    child: SmoothLineChart(
                      series: [
                        LineSeries(series, color: AppColors.mint, endDot: true),
                      ],
                    ),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Saldo actual',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => setState(() => _hidden = !_hidden),
                          child: Icon(
                            _hidden
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _hidden ? '\$ •••••••' : formatMoney(s.balance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (change != null)
                      ChangeLabel(
                        change,
                        onDark: true,
                        suffix: ' vs. mes anterior',
                      )
                    else
                      Text(
                        'Registra movimientos para ver tu evolución',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                for (var i = 0; i < _periods.length; i++)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _period = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: i == _period
                              ? AppColors.brightGradient
                              : null,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _periods[i],
                          style: TextStyle(
                            color: i == _period
                                ? AppColors.primaryDark
                                : Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  final bool up;
  final VoidCallback onTap;

  const _MiniStat({
    required this.label,
    required this.amount,
    required this.color,
    required this.up,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => SoftCard(
    onTap: onTap,
    color: up ? Colors.white : const Color(0xFFFFF6F6),
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(
                up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 12,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(
              up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatMoney(amount),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
