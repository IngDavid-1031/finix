import 'package:flutter/material.dart';

import '../data/finance_data.dart';
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
  int _period = 0;

  static const _labels = [
    ['Jul', 'Ago', 'Sep', 'Oct', 'Nov'],
    ['T1', 'T2', 'T3', 'T4'],
    ['2022', '2023', '2024', '2025', '2026'],
  ];
  static const _values = [
    [1.2, 1.9, 1.4, 1.8, 1.3, 1.6, 2.4],
    [1.0, 1.6, 1.3, 2.2],
    [0.8, 1.2, 1.1, 1.7, 2.3],
  ];
  static const _totals = ['\$ 1.750.000', '\$ 4.980.000', '\$ 18.400.000'];
  static const _deltas = ['+18%', '+9%', '+24%'];

  static const _top = [
    (Categories.comida, 0.32),
    (Categories.transporte, 0.28),
    (Categories.compras, 0.20),
    (Categories.hogar, 0.12),
    (Categories.salud, 0.08),
  ];

  @override
  Widget build(BuildContext context) => ListView(
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
            const Text(
              'Resumen financiero',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  _totals[_period],
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_upward_rounded,
                  size: 16,
                  color: AppColors.green,
                ),
                Text(
                  _deltas[_period],
                  style: const TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 160,
              child: SmoothLineChart(
                series: [
                  LineSeries(
                    _values[_period],
                    color: AppColors.green,
                    endDot: true,
                  ),
                ],
                xLabels: _labels[_period],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      const SoftCard(
        child: Row(
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: DonutChart(
                thickness: 22,
                segments: [
                  (32, Color(0xFFF59E0B)),
                  (28, Color(0xFFA855F7)),
                  (40, AppColors.green),
                ],
              ),
            ),
            SizedBox(width: 24),
            Expanded(
              child: Column(
                children: [
                  _Legend(
                    color: Color(0xFFF97316),
                    label: 'Gastos',
                    value: '60%',
                  ),
                  SizedBox(height: 12),
                  _Legend(
                    color: AppColors.green,
                    label: 'Ingresos',
                    value: '40%',
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
      SoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            for (final (cat, pct) in _top)
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
                            value: pct / 0.4,
                            color: cat.color,
                            height: 5,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${(pct * 100).round()}%',
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
