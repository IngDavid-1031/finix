import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/finance_data.dart';
import '../../data/summary.dart';
import '../../theme/app_colors.dart';
import '../../widgets/backgrounds.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';
import '../add_movement_screen.dart';
import '../bills_screen.dart';
import '../goals_screen.dart';
import '../home_screen.dart' show GreetingText;

class DesktopDashboard extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const DesktopDashboard({super.key, required this.onNavigate});

  static void openAdd(BuildContext context, bool income) =>
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AddMovementScreen(initialIncome: income),
        ),
      );

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(width: 20, height: 20);
    return ValueListenableBuilder<List<Txn>>(
      valueListenable: AppState.transactions,
      builder: (context, txns, _) {
        final s = FinanceSummary(txns);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
          child: Column(
            children: [
              SizedBox(
                height: 220,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 7,
                      child: _HeroBanner(onStats: () => onNavigate(1)),
                    ),
                    gap,
                    Expanded(flex: 3, child: _BalancePanel(summary: s)),
                  ],
                ),
              ),
              gap,
              Row(
                children: [
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.account_balance_wallet_rounded,
                      color: AppColors.red,
                      title: 'Agregar Gasto',
                      subtitle: 'Registra un gasto',
                      onTap: () => openAdd(context, false),
                    ),
                  ),
                  gap,
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.south_rounded,
                      color: AppColors.green,
                      title: 'Agregar Ingreso',
                      subtitle: 'Registra un ingreso',
                      onTap: () => openAdd(context, true),
                    ),
                  ),
                  gap,
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.mic_rounded,
                      color: AppColors.purple,
                      title: 'Registrar con Voz',
                      subtitle: 'Usa el micrófono con IA',
                      onTap: () =>
                          showSoon(context, 'El registro por voz con IA'),
                    ),
                  ),
                  gap,
                  Expanded(
                    child: _QuickAction(
                      icon: Icons.track_changes_rounded,
                      color: AppColors.blue,
                      title: 'Crear Meta',
                      subtitle: 'Establece un objetivo',
                      onTap: () => showCreateGoalDialog(context),
                    ),
                  ),
                ],
              ),
              gap,
              SizedBox(
                height: 300,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 5, child: _SummaryChartCard(summary: s)),
                    gap,
                    Expanded(
                      flex: 4,
                      child: _CategoryDonutCard(
                        summary: s,
                        onDetail: () => onNavigate(5),
                      ),
                    ),
                    gap,
                    Expanded(
                      flex: 3,
                      child: _GoalsCard(onSeeAll: () => onNavigate(3)),
                    ),
                  ],
                ),
              ),
              gap,
              SizedBox(
                height: 240,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 4,
                      child: _LatestMovements(
                        txns: txns,
                        onSeeAll: () => onNavigate(2),
                      ),
                    ),
                    gap,
                    Expanded(flex: 5, child: _MonthCard(summary: s)),
                    gap,
                    Expanded(
                      flex: 3,
                      child: _BillsCard(onSeeAll: () => onNavigate(4)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/* ───────────────────────── Banner principal ───────────────────────── */

class _HeroBanner extends StatelessWidget {
  final VoidCallback onStats;
  const _HeroBanner({required this.onStats});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(26),
    child: CustomPaint(
      painter: WavesPainter(dark: true),
      child: LayoutBuilder(
        builder: (context, c) => Stack(
          children: [
            if (c.maxWidth > 620)
              const Positioned(
                right: 24,
                top: 0,
                bottom: 0,
                child: Center(child: _WalletIllustration()),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: c.maxWidth > 620 ? c.maxWidth - 380 : null,
                    child: const GreetingText(
                      fontSize: 34,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Gestiona tus finanzas de forma inteligente\ny alcanza tus metas.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 17,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  WhitePillButton(
                    label: 'Ver estadísticas',
                    onPressed: onStats,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _WalletIllustration extends StatelessWidget {
  const _WalletIllustration();

  Widget _coin(double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        colors: [Color(0xFFFFE08A), AppColors.gold],
      ),
      border: Border.all(color: const Color(0xFFE59400), width: 2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x55000000),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    alignment: Alignment.center,
    child: Text(
      '\$',
      style: TextStyle(
        color: const Color(0xFFB86E00),
        fontWeight: FontWeight.w900,
        fontSize: size * 0.5,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 300,
    height: 200,
    child: Stack(
      children: [
        Positioned(
          right: 20,
          top: 0,
          child: Icon(
            Icons.trending_up_rounded,
            size: 110,
            color: AppColors.mint.withValues(alpha: 0.9),
          ),
        ),
        Positioned(
          left: 80,
          top: 50,
          child: Transform.rotate(
            angle: -0.08,
            child: Container(
              width: 150,
              height: 125,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1C8A58), Color(0xFF07402A)],
                ),
                border: Border.all(
                  color: AppColors.mint.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const FinixLogoMark(size: 56),
            ),
          ),
        ),
        Positioned(left: 30, top: 30, child: _coin(46)),
        Positioned(left: 40, bottom: 10, child: _coin(40)),
        Positioned(right: 20, bottom: 20, child: _coin(44)),
        Positioned(left: 150, top: 0, child: _coin(30)),
      ],
    ),
  );
}

/* ───────────────────────── Saldo ───────────────────────── */

class _BalancePanel extends StatelessWidget {
  final FinanceSummary summary;
  const _BalancePanel({required this.summary});

  @override
  Widget build(BuildContext context) {
    final change = summary.balanceChange;
    return SoftCard(
      padding: const EdgeInsets.all(22),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.greenSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: AppColors.green,
                size: 28,
              ),
            ),
          ),
          if (summary.txns.isNotEmpty)
            Positioned(
              right: 0,
              bottom: 0,
              width: 150,
              height: 70,
              child: SmoothLineChart(
                series: [
                  LineSeries(
                    summary.balanceSeries(days: 180),
                    color: AppColors.green,
                    endDot: true,
                  ),
                ],
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    'Saldo Actual',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.text,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  formatMoney(summary.balance),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (change != null)
                ChangeLabel(change, suffix: ' vs. mes anterior'),
            ],
          ),
        ],
      ),
    );
  }
}

/* ───────────────────────── Accesos rápidos ───────────────────────── */

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => SoftCard(
    onTap: onTap,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: AppColors.text),
      ],
    ),
  );
}

/* ───────────────────────── Resumen financiero ───────────────────────── */

class _SummaryChartCard extends StatelessWidget {
  final FinanceSummary summary;
  const _SummaryChartCard({required this.summary});

  /// Redondea el máximo del eje Y hacia arriba (1, 2, 2.5, 5 × 10^n).
  static double _niceMax(double v) {
    if (v <= 0) return 1000000;
    final p = math.pow(10, (math.log(v) / math.ln10).floor()).toDouble();
    for (final m in [1.0, 2.0, 2.5, 5.0, 10.0]) {
      if (v <= m * p) return m * p;
    }
    return 10 * p;
  }

  @override
  Widget build(BuildContext context) {
    final buckets = summary.lastMonths(6);
    final income = summary.incomeBy(buckets);
    final expense = summary.expenseBy(buckets);
    final maxY = _niceMax(
      [...income, ...expense].fold<int>(0, math.max).toDouble(),
    );
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 14),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, color: AppColors.green),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Resumen Financiero',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    color: AppColors.text,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.field,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Últimos 6 meses',
                  style: TextStyle(fontSize: 13, color: AppColors.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LegendDot(color: AppColors.green, label: 'Ingresos'),
              SizedBox(width: 18),
              LegendDot(color: Color(0xFF8A958F), label: 'Gastos'),
            ],
          ),
          const SizedBox(height: 4),
          Expanded(
            child: SmoothLineChart(
              minY: 0,
              maxY: maxY,
              yLabels: [
                for (var i = 4; i >= 0; i--) compactMoney(maxY * i / 4),
              ],
              xLabels: [for (final b in buckets) b.label],
              tooltip: income.last > 0
                  ? '\$ ${compactMoney(income.last)}'
                  : null,
              series: [
                LineSeries(
                  [for (final v in income) v.toDouble()],
                  color: AppColors.green,
                  endDot: true,
                ),
                LineSeries(
                  [for (final v in expense) v.toDouble()],
                  color: const Color(0xFF8A958F),
                  fill: false,
                  width: 2.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ───────────────────────── Gastos por categoría ───────────────────────── */

class _CategoryDonutCard extends StatelessWidget {
  final FinanceSummary summary;
  final VoidCallback onDetail;
  const _CategoryDonutCard({required this.summary, required this.onDetail});

  static const _palette = [
    Color(0xFF22C55E),
    Color(0xFF6D8BF5),
    Color(0xFFF59E0B),
    Color(0xFF14A85E),
    Color(0xFFA855F7),
  ];

  @override
  Widget build(BuildContext context) {
    final all = summary.expenseByCategory(summary.monthStart, DateTime(9999));
    final total = all.fold<int>(0, (a, e) => a + e.$2);
    final items = all.take(4).toList();
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        children: [
          SectionHeader(
            title: 'Gastos del mes',
            action: 'Ver detalle',
            onAction: onDetail,
            fontSize: 17,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'Sin gastos este mes',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, c) {
                      final d = math.min(
                        180.0,
                        math.min(c.maxHeight, c.maxWidth * 0.48),
                      );
                      return Row(
                        children: [
                          SizedBox(
                            width: d,
                            height: d,
                            child: DonutChart(
                              thickness: d * 0.17,
                              segments: [
                                for (var i = 0; i < items.length; i++)
                                  (items[i].$2.toDouble(), _palette[i]),
                                if (total >
                                    items.fold<int>(0, (a, e) => a + e.$2))
                                  (
                                    (total -
                                            items.fold<int>(
                                              0,
                                              (a, e) => a + e.$2,
                                            ))
                                        .toDouble(),
                                    AppColors.border,
                                  ),
                              ],
                              center: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FittedBox(
                                    child: Text(
                                      formatMoney(total),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: d * 0.095,
                                        color: AppColors.text,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    'Total',
                                    style: TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (final (cat, v) in items)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          cat.icon,
                                          color: cat.color,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            cat.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: AppColors.text,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${(v * 100 / total).round()}%',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.text,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/* ───────────────────────── Metas ───────────────────────── */

class _GoalsCard extends StatelessWidget {
  final VoidCallback onSeeAll;
  const _GoalsCard({required this.onSeeAll});

  @override
  Widget build(BuildContext context) => SoftCard(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
    child: Column(
      children: [
        SectionHeader(
          title: 'Tus Metas',
          action: 'Ver todas',
          onAction: onSeeAll,
          fontSize: 17,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ValueListenableBuilder<List<Goal>>(
            valueListenable: AppState.goals,
            builder: (context, goals, _) => goals.isEmpty
                ? Center(
                    child: TextButton.icon(
                      onPressed: () => showCreateGoalDialog(context),
                      icon: const Icon(
                        Icons.add_rounded,
                        color: AppColors.green,
                      ),
                      label: const Text(
                        'Crear una meta',
                        style: TextStyle(color: AppColors.green),
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < math.min(2, goals.length); i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        Expanded(
                          child: _GoalMini(
                            goal: goals[i],
                            color: i == 0 ? AppColors.green : AppColors.purple,
                            onTap: () => showAddToGoalDialog(context, goals[i]),
                          ),
                        ),
                      ],
                      if (goals.length == 1) const Spacer(),
                    ],
                  ),
          ),
        ),
      ],
    ),
  );
}

class _GoalMini extends StatelessWidget {
  final Goal goal;
  final Color color;
  final VoidCallback onTap;
  const _GoalMini({
    required this.goal,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFF4F9FF), Color(0xFFEAF3FF)],
          ),
        ),
        child: Row(
          children: [
            Text(goal.emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    goal.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    '${(goal.progress * 100).round()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ProgressBar(value: goal.progress, color: color, height: 5),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${formatMoney(goal.saved)} / ${formatMoney(goal.target)}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/* ───────────────────────── Últimos movimientos ───────────────────────── */

class _LatestMovements extends StatelessWidget {
  final List<Txn> txns;
  final VoidCallback onSeeAll;
  const _LatestMovements({required this.txns, required this.onSeeAll});

  @override
  Widget build(BuildContext context) => SoftCard(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
    child: Column(
      children: [
        SectionHeader(
          title: 'Últimos Movimientos',
          icon: Icons.format_list_bulleted_rounded,
          action: 'Ver todos',
          onAction: onSeeAll,
          fontSize: 17,
        ),
        const SizedBox(height: 4),
        Expanded(
          child: txns.isEmpty
              ? const Center(
                  child: Text(
                    'Aún no hay movimientos',
                    style: TextStyle(color: AppColors.muted),
                  ),
                )
              : ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final t in txns.take(3))
                      TransactionTile(txn: t, dense: true),
                  ],
                ),
        ),
      ],
    ),
  );
}

/* ───────────────────────── Resumen del mes ───────────────────────── */

class _MonthCard extends StatelessWidget {
  final FinanceSummary summary;
  const _MonthCard({required this.summary});

  Widget _line(String label, int value, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          formatMoney(value),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(26),
    child: CustomPaint(
      painter: WavesPainter(dark: true),
      child: LayoutBuilder(
        builder: (context, c) => Stack(
          children: [
            if (c.maxWidth > 400)
              const Positioned(
                right: 26,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Text('🐷', style: TextStyle(fontSize: 90)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen de ${monthNames[summary.now.month - 1]}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _line('Ingresos', summary.monthIncome, AppColors.mint),
                  _line(
                    'Gastos',
                    summary.monthExpense,
                    const Color(0xFFF97316),
                  ),
                  _line(
                    'Ahorro',
                    summary.monthSavings,
                    const Color(0xFF6D8BF5),
                  ),
                  const Spacer(),
                  WhitePillButton(
                    label: 'Agregar movimiento',
                    onPressed: () => DesktopDashboard.openAdd(context, false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/* ───────────────────────── Próximos pagos ───────────────────────── */

class _BillsCard extends StatelessWidget {
  final VoidCallback onSeeAll;
  const _BillsCard({required this.onSeeAll});

  @override
  Widget build(BuildContext context) => SoftCard(
    padding: const EdgeInsets.fromLTRB(18, 16, 16, 12),
    child: ValueListenableBuilder<List<Bill>>(
      valueListenable: AppState.bills,
      builder: (context, bills, _) {
        final pending = bills.where((b) => !b.paidThisMonth).toList()
          ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Próximos pagos',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.text,
                    ),
                  ),
                ),
                InkWell(
                  onTap: bills.isEmpty
                      ? () => showBillDialog(context)
                      : onSeeAll,
                  child: Text(
                    bills.isEmpty ? 'Agregar' : 'Ver todos',
                    style: const TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: bills.isEmpty
                  ? const Center(
                      child: Text(
                        '🧾\nAgrega tu arriendo, planes o servicios y te avisamos antes de que se venzan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted, height: 1.4),
                      ),
                    )
                  : pending.isEmpty
                  ? const Center(
                      child: Text(
                        '🎉\n¡Todo pagado este mes!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        for (final b in pending.take(4))
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => showBillActions(context, b),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Text(
                                    b.emoji,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          b.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.text,
                                          ),
                                        ),
                                        Text(
                                          dueText(b),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: dueColor(b),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    compactMoney(b.amount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        );
      },
    ),
  );
}
