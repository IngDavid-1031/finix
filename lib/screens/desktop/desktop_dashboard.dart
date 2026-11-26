import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/finance_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/backgrounds.dart';
import '../../widgets/charts.dart';
import '../../widgets/common.dart';
import '../add_movement_screen.dart';

class DesktopDashboard extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const DesktopDashboard({super.key, required this.onNavigate});

  void _openAdd(BuildContext context, bool income) =>
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AddMovementScreen(initialIncome: income),
        ),
      );

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(width: 20, height: 20);
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
                const Expanded(flex: 3, child: _BalancePanel()),
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
                  onTap: () => _openAdd(context, false),
                ),
              ),
              gap,
              Expanded(
                child: _QuickAction(
                  icon: Icons.south_rounded,
                  color: AppColors.green,
                  title: 'Agregar Ingreso',
                  subtitle: 'Registra un ingreso',
                  onTap: () => _openAdd(context, true),
                ),
              ),
              gap,
              Expanded(
                child: _QuickAction(
                  icon: Icons.mic_rounded,
                  color: AppColors.purple,
                  title: 'Registrar con Voz',
                  subtitle: 'Usa el micrófono con IA',
                  onTap: () => showSoon(context, 'El registro por voz con IA'),
                ),
              ),
              gap,
              Expanded(
                child: _QuickAction(
                  icon: Icons.track_changes_rounded,
                  color: AppColors.blue,
                  title: 'Crear Meta',
                  subtitle: 'Establece un objetivo',
                  onTap: () => onNavigate(3),
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
                const Expanded(flex: 5, child: _SummaryChartCard()),
                gap,
                Expanded(
                  flex: 4,
                  child: _CategoryDonutCard(onDetail: () => onNavigate(4)),
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
                  child: _LatestMovements(onSeeAll: () => onNavigate(2)),
                ),
                gap,
                const Expanded(flex: 5, child: _ProCard()),
                gap,
                Expanded(
                  flex: 3,
                  child: _QuickSettings(onEdit: () => onNavigate(6)),
                ),
              ],
            ),
          ),
        ],
      ),
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
                  const Text(
                    'Hola, Noaj 👋',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
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
  const _BalancePanel();

  @override
  Widget build(BuildContext context) => SoftCard(
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
        Positioned(
          right: 0,
          bottom: 0,
          width: 150,
          height: 70,
          child: SmoothLineChart(
            series: [
              LineSeries(
                const [1.0, 1.3, 1.1, 1.8, 1.6, 2.6, 3.1],
                color: AppColors.green,
                endDot: true,
              ),
            ],
          ),
        ),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
            SizedBox(height: 18),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '\$ 2.750.000',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ),
            SizedBox(height: 14),
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: AppColors.greenSoft,
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    size: 13,
                    color: AppColors.green,
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '+12% vs. mes anterior',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.text, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
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
  const _SummaryChartCard();

  @override
  Widget build(BuildContext context) => SoftCard(
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.field,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Text(
                    'Últimos 6 meses',
                    style: TextStyle(fontSize: 13, color: AppColors.text),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.text,
                  ),
                ],
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
        const Expanded(
          child: SmoothLineChart(
            minY: 0,
            maxY: 4,
            yLabels: ['4M', '3M', '2M', '1M', '0'],
            xLabels: ['May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct'],
            tooltip: '\$ 3.2M',
            series: [
              LineSeries(
                [1.3, 2.2, 3.05, 2.6, 2.75, 3.2],
                color: AppColors.green,
                endDot: true,
              ),
              LineSeries(
                [0.6, 1.7, 2.05, 1.6, 2.0, 1.65],
                color: Color(0xFF8A958F),
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

/* ───────────────────────── Gastos por categoría ───────────────────────── */

class _CategoryDonutCard extends StatelessWidget {
  final VoidCallback onDetail;
  const _CategoryDonutCard({required this.onDetail});

  static const _items = [
    (Categories.comida, 35.0, Color(0xFF22C55E)),
    (Categories.transporte, 28.0, Color(0xFF6D8BF5)),
    (Categories.compras, 22.0, Color(0xFFF59E0B)),
    (Categories.hogar, 15.0, Color(0xFF14A85E)),
  ];

  @override
  Widget build(BuildContext context) => SoftCard(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
    child: Column(
      children: [
        SectionHeader(
          title: 'Gastos por Categoría',
          action: 'Ver detalle',
          onAction: onDetail,
          fontSize: 17,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: LayoutBuilder(
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
                        for (final (_, v, color) in _items) (v, color),
                      ],
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            child: Text(
                              '\$ 1.250.000',
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
                        for (final (cat, v, _) in _items)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Icon(cat.icon, color: cat.color, size: 20),
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
                                  '${v.round()}%',
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
            builder: (_, goals, _) => Column(
              children: [
                Expanded(
                  child: _GoalMini(
                    goal: goals[0],
                    leading: '🌱',
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _GoalMini(
                    goal: const Goal(
                      title: 'Comprar un iPhone',
                      saved: 800000,
                      target: 2000000,
                      emoji: '📱',
                      color: AppColors.purple,
                    ),
                    leading: '🎁',
                    color: AppColors.purple,
                  ),
                ),
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
  final String leading;
  final Color color;
  const _GoalMini({
    required this.goal,
    required this.leading,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      gradient: const LinearGradient(
        colors: [Color(0xFFF4F9FF), Color(0xFFEAF3FF)],
      ),
    ),
    child: Row(
      children: [
        Text(leading, style: const TextStyle(fontSize: 28)),
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
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(goal.emoji, style: const TextStyle(fontSize: 30)),
      ],
    ),
  );
}

/* ───────────────────────── Últimos movimientos ───────────────────────── */

class _LatestMovements extends StatelessWidget {
  final VoidCallback onSeeAll;
  const _LatestMovements({required this.onSeeAll});

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
          child: ValueListenableBuilder<List<Txn>>(
            valueListenable: AppState.transactions,
            builder: (_, list, _) => ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final t in list.take(3))
                  TransactionTile(txn: t, dense: true),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

/* ───────────────────────── Finix Pro ───────────────────────── */

class _ProCard extends StatelessWidget {
  const _ProCard();

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(26),
    child: CustomPaint(
      painter: WavesPainter(dark: true),
      child: LayoutBuilder(
        builder: (context, c) => Stack(
          children: [
            if (c.maxWidth > 380)
              Positioned(
                right: 30,
                top: 18,
                bottom: -30,
                child: Transform.rotate(
                  angle: 0.22,
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF155C3E), Color(0xFF041C12)],
                      ),
                      border: Border.all(
                        color: AppColors.mint.withValues(alpha: 0.6),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mint.withValues(alpha: 0.25),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const FinixLogoMark(size: 50),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Finix Pro',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Más control, más beneficios.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final f in const [
                    'Reportes avanzados',
                    'Sin anuncios',
                    'Soporte prioritario',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.mint,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            f,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  WhitePillButton(
                    label: 'Actualizar Ahora',
                    onPressed: () => showSoon(context, 'Finix Pro'),
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

/* ───────────────────────── Configuración rápida ───────────────────────── */

class _QuickSettings extends StatelessWidget {
  final VoidCallback onEdit;
  const _QuickSettings({required this.onEdit});

  Widget _row(IconData icon, String label, Widget trailing) => Expanded(
    child: Row(
      children: [
        Icon(icon, size: 21, color: AppColors.text),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.text, fontSize: 14),
          ),
        ),
        trailing,
      ],
    ),
  );

  Widget _switch(ValueNotifier<bool> n) =>
      SizedBox(height: 30, child: FittedBox(child: NotifierSwitch(n)));

  @override
  Widget build(BuildContext context) => SoftCard(
    padding: const EdgeInsets.fromLTRB(18, 16, 14, 10),
    child: Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.settings_outlined,
              size: 22,
              color: AppColors.text,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Configuración Rápida',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.text,
                ),
              ),
            ),
            InkWell(
              onTap: onEdit,
              child: const Text(
                'Editar',
                style: TextStyle(
                  color: AppColors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _row(
          Icons.dark_mode_outlined,
          'Modo Oscuro',
          _switch(AppState.darkMode),
        ),
        _row(
          Icons.notifications_none_rounded,
          'Notificaciones',
          _switch(AppState.notifications),
        ),
        _row(
          Icons.calendar_today_outlined,
          'Recordatorios de gasto',
          _switch(AppState.reminders),
        ),
        _row(
          Icons.language_rounded,
          'Idioma: Español',
          const Icon(Icons.chevron_right_rounded, color: AppColors.text),
        ),
      ],
    ),
  );
}
