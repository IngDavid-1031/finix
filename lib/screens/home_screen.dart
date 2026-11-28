import 'package:flutter/material.dart';

import '../data/finance_data.dart';
import '../data/summary.dart';
import '../theme/app_colors.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import 'bills_screen.dart';

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
          UpcomingBillsCard(
            max: 2,
            onSeeAll: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const BillsScreen(standalone: true),
              ),
            ),
          ),
          const SizedBox(height: 12),
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
  int _period = 1;

  /// Día que se ve en "Diario" (0 = hoy, 1 = ayer…).
  int _dayOffset = 0;

  static const _periods = ['Diario', '1M', '3M', '6M', '1A'];
  static const _days = [1, 30, 90, 180, 365];

  bool get _daily => _period == 0;

  DateTime get _day {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day - _dayOffset);
  }

  /// Saldo al empezar el día y después de cada movimiento de ese día.
  List<double> _daySeries(FinanceSummary s, List<Txn> dayTxns) {
    var acc = s.balanceAt(_day.subtract(const Duration(microseconds: 1)));
    final pts = [acc.toDouble()];
    for (final t in dayTxns.reversed) {
      acc += t.amount;
      pts.add(acc.toDouble());
    }
    if (pts.length == 1) pts.add(pts.first);
    return pts;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.summary;
    final change = s.balanceChange;
    final day = _day;
    final next = DateTime(day.year, day.month, day.day + 1);
    final dayTxns = [
      for (final t in s.txns)
        if (!t.date.isBefore(day) && t.date.isBefore(next)) t,
    ]..sort((a, b) => b.date.compareTo(a.date));
    final series = _daily
        ? _daySeries(s, dayTxns)
        : s.balanceSeries(days: _days[_period]);
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
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _daily
                ? _DayPanel(
                    day: day,
                    txns: dayTxns,
                    hidden: _hidden,
                    canGoForward: _dayOffset > 0,
                    onPrev: () => setState(() => _dayOffset++),
                    onNext: () => setState(() => _dayOffset--),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// "Diario": lo que entró y salió en un día, con flechas para ver otros días.
class _DayPanel extends StatelessWidget {
  final DateTime day;
  final List<Txn> txns;
  final bool hidden;
  final bool canGoForward;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _DayPanel({
    required this.day,
    required this.txns,
    required this.hidden,
    required this.canGoForward,
    required this.onPrev,
    required this.onNext,
  });

  static const _max = 5;
  static const _red = Color(0xFFFF8A8A);

  String _money(int v, {bool sign = false}) =>
      hidden ? '\$ •••' : formatMoney(v, withSign: sign);

  @override
  Widget build(BuildContext context) {
    final income = txns
        .where((t) => t.isIncome)
        .fold(0, (a, t) => a + t.amount);
    final expense = txns
        .where((t) => !t.isIncome)
        .fold(0, (a, t) => a - t.amount);
    final white70 = Colors.white.withValues(alpha: 0.7);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Row(
            children: [
              _ArrowButton(icon: Icons.chevron_left_rounded, onTap: onPrev),
              Expanded(
                child: Text(
                  dateLabel(day),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              _ArrowButton(
                icon: Icons.chevron_right_rounded,
                onTap: canGoForward ? onNext : null,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DayTotal(
                  label: 'Ingresos',
                  value: _money(income, sign: true),
                  color: AppColors.mint,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DayTotal(
                  label: 'Gastos',
                  value: _money(-expense),
                  color: _red,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (txns.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Sin movimientos este día',
                style: TextStyle(color: white70, fontSize: 13),
              ),
            )
          else ...[
            for (final t in txns.take(_max))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        t.category.icon,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        t.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${t.date.hour.toString().padLeft(2, '0')}:'
                      '${t.date.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(color: white70, fontSize: 11),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _money(t.amount, sign: true),
                      style: TextStyle(
                        color: t.isIncome ? AppColors.mint : _red,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            if (txns.length > _max)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'y ${txns.length - _max} movimientos más',
                  style: TextStyle(color: white70, fontSize: 12),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _DayTotal extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _DayTotal({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _ArrowButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: onTap == null ? 0.05 : 0.14),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 20,
        color: Colors.white.withValues(alpha: onTap == null ? 0.3 : 1),
      ),
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
