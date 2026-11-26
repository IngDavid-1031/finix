import 'package:flutter/material.dart';

import '../data/finance_data.dart';
import '../theme/app_colors.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int filter) onOpenHistory;
  const HomeScreen({super.key, required this.onOpenHistory});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
    children: [
      Row(
        children: [
          const FinixLogo(size: 28),
          const Spacer(),
          IconCircleButton(
            icon: Icons.notifications_none_rounded,
            badge: true,
            onTap: () => showSoon(context, 'El centro de notificaciones'),
          ),
          const SizedBox(width: 10),
          const UserAvatar(size: 44),
        ],
      ),
      const SizedBox(height: 22),
      const Text(
        'Hola, Noaj 👋',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppColors.text,
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        'Aquí tienes un resumen\nde tus finanzas',
        style: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.35),
      ),
      const SizedBox(height: 18),
      const BalanceCard(),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: _MiniStat(
              label: 'Ingresos',
              amount: 3200000,
              color: AppColors.green,
              up: true,
              onTap: () => onOpenHistory(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MiniStat(
              label: 'Gastos',
              amount: 1450000,
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
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu ahorro',
                    style: TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '\$ 750.000',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_upward_rounded,
                        size: 15,
                        color: AppColors.green,
                      ),
                      Text(
                        '+20%',
                        style: TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
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
        title: 'Categorías de gastos',
        action: 'Ver todo',
        onAction: () => onOpenHistory(0),
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final c in const [
            Categories.compras,
            Categories.comida,
            Categories.salud,
            Categories.transporte,
            Categories.hogar,
          ])
            Tooltip(
              message: c.name,
              child: CategoryBubble(category: c, size: 52),
            ),
        ],
      ),
    ],
  );
}

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _hidden = false;
  int _period = 0;

  static const _periods = ['1M', '3M', '6M', '1A'];
  static const _data = [
    [1.0, 1.4, 1.2, 1.9, 1.7, 2.4, 2.2, 3.1],
    [1.0, 1.6, 1.3, 1.5, 2.2, 2.0, 2.8, 3.0],
    [1.2, 1.1, 1.8, 1.6, 2.1, 2.6, 2.4, 3.2],
    [0.8, 1.3, 1.1, 1.9, 2.3, 2.0, 2.9, 3.4],
  ];

  @override
  Widget build(BuildContext context) => Container(
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
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 150,
                child: SmoothLineChart(
                  series: [
                    LineSeries(
                      _data[_period],
                      color: AppColors.mint,
                      endDot: true,
                    ),
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
                    _hidden ? '\$ •••••••' : '\$ 2.750.000',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          size: 11,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '+12% vs. mes anterior',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
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
            Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
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
