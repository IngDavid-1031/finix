import 'package:flutter/material.dart';

import '../data/finance_data.dart';
import '../data/summary.dart';
import '../theme/app_colors.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';

class StatsScreen extends StatefulWidget {
  final VoidCallback? onSeeCategories;
  const StatsScreen({super.key, this.onSeeCategories});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _period = 0; // 0 mes, 1 trimestre, 2 año

  List<Bucket> _buckets(FinanceSummary s) => switch (_period) {
    0 => s.lastMonths(5),
    1 => s.lastQuarters(4),
    _ => s.lastYears(5),
  };

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<List<Txn>>(
    valueListenable: AppState.transactions,
    builder: (context, txns, _) {
      final s = FinanceSummary(txns);
      final buckets = _buckets(s);
      final net = s.netBy(buckets);
      final current = buckets.last;
      final income = s.income(current.start, current.end);
      final expense = s.expense(current.start, current.end);
      final change = FinanceSummary.change(net.last, net[net.length - 2]);
      final top = s.expenseByCategory(current.start, current.end);
      final topTotal = top.fold<int>(0, (a, e) => a + e.$2);

      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Estadísticas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
              IconCircleButton(
                icon: Icons.calendar_month_outlined,
                onTap: () => showSoon(context, 'El filtro por fechas'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PillTabs(
            labels: const ['Mes', 'Trimestre', 'Año'],
            index: _period,
            onChanged: (i) => setState(() => _period = i),
          ),
          const SizedBox(height: 18),
          SoftCard(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ahorro neto · ${current.label}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          formatMoney(net.last),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ),
                    if (change != null) ChangeLabel(change),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 160,
                  child: SmoothLineChart(
                    series: [
                      LineSeries(
                        [for (final v in net) v.toDouble()],
                        color: AppColors.green,
                        endDot: true,
                      ),
                    ],
                    xLabels: [for (final b in buckets) b.label],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SoftCard(
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  height: 110,
                  child: DonutChart(
                    thickness: 22,
                    segments: income + expense == 0
                        ? const [(1, AppColors.border)]
                        : [
                            (expense.toDouble(), const Color(0xFFF97316)),
                            (income.toDouble(), AppColors.green),
                          ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      _Legend(
                        color: const Color(0xFFF97316),
                        label: 'Gastos',
                        value: _pct(expense, income + expense),
                      ),
                      const SizedBox(height: 12),
                      _Legend(
                        color: AppColors.green,
                        label: 'Ingresos',
                        value: _pct(income, income + expense),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SectionHeader(
            title: 'Categorías principales',
            action: 'Ver todo',
            onAction: widget.onSeeCategories,
          ),
          const SizedBox(height: 10),
          if (top.isEmpty)
            const EmptyHint(
              icon: Icons.pie_chart_outline_rounded,
              text: 'No hay gastos en este periodo.',
            )
          else
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  for (final (cat, value) in top.take(5))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          CategoryBubble(category: cat, size: 34),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ProgressBar(
                                  value: value / top.first.$2,
                                  color: cat.color,
                                  height: 5,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            _pct(value, topTotal),
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
  );

  static String _pct(int part, int total) =>
      total == 0 ? '0%' : '${(part * 100 / total).round()}%';
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _Legend({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      LegendDot(color: color, label: label),
      const Spacer(),
      Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
    ],
  );
}
