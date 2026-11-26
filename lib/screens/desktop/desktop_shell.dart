import 'package:flutter/material.dart';

import '../../data/finance_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/backgrounds.dart';
import '../../widgets/common.dart';
import '../categories_screen.dart';
import '../goals_screen.dart';
import '../history_screen.dart';
import '../login_screen.dart';
import '../profile_screen.dart';
import '../settings_screen.dart';
import '../stats_screen.dart';
import 'desktop_dashboard.dart';

class DesktopShell extends StatefulWidget {
  const DesktopShell({super.key});

  @override
  State<DesktopShell> createState() => _DesktopShellState();
}

class _DesktopShellState extends State<DesktopShell> {
  int _index = 0;

  static const _nav = [
    (Icons.home_rounded, 'Inicio'),
    (Icons.bar_chart_rounded, 'Estadísticas'),
    (Icons.swap_vert_rounded, 'Movimientos'),
    (Icons.favorite_border_rounded, 'Mis metas'),
    (Icons.calendar_today_outlined, 'Categorías'),
    (Icons.person_outline_rounded, 'Perfil'),
    (Icons.settings_outlined, 'Configuración'),
    (Icons.help_outline_rounded, 'Ayuda'),
  ];

  void _go(int i) => setState(() => _index = i);

  Widget _content() {
    if (_index == 0) return DesktopDashboard(onNavigate: _go);
    final page = switch (_index) {
      1 => StatsScreen(onSeeCategories: () => _go(4)),
      2 => const HistoryScreen(),
      3 => const GoalsScreen(),
      4 => const CategoriesScreen(),
      5 => ProfileScreen(onOpenSettings: () => _go(6)),
      6 => const SettingsScreen(),
      _ => const HelpScreen(),
    };
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    body: Row(
      children: [
        _Sidebar(items: _nav, selected: _index, onSelect: _go),
        Expanded(
          child: Column(
            children: [
              _TopBar(onProfile: () => _go(5)),
              Expanded(
                child: KeyedSubtree(key: ValueKey(_index), child: _content()),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Sidebar extends StatelessWidget {
  final List<(IconData, String)> items;
  final int selected;
  final ValueChanged<int> onSelect;

  const _Sidebar({
    required this.items,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 250,
    child: ClipRRect(
      borderRadius: const BorderRadius.horizontal(right: Radius.circular(28)),
      child: CustomPaint(
        painter: WavesPainter(dark: true),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: FinixLogo(size: 40, textColor: Colors.white),
              ),
              const SizedBox(height: 34),
              Expanded(
                child: ListView(
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _NavItem(
                          icon: items[i].$1,
                          label: items[i].$2,
                          selected: i == selected,
                          onTap: () => onSelect(i),
                        ),
                      ),
                  ],
                ),
              ),
              _NavItem(
                icon: Icons.logout_rounded,
                label: 'Cerrar sesión',
                selected: false,
                onTap: () => logout(context),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.brightGradient : null,
          borderRadius: BorderRadius.circular(26),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.mint.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 23),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: selected ? 1 : 0.88),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _TopBar extends StatelessWidget {
  final VoidCallback onProfile;
  const _TopBar({required this.onProfile});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(28, 20, 28, 12),
    child: Row(
      children: [
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar movimientos, categorías...',
                hintStyle: const TextStyle(color: AppColors.muted),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.text,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        IconCircleButton(
          icon: Icons.notifications_none_rounded,
          size: 50,
          onTap: () => showSoon(context, 'El centro de notificaciones'),
        ),
        const SizedBox(width: 18),
        InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onProfile,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                const UserAvatar(size: 50, online: true),
                const SizedBox(width: 12),
                ValueListenableBuilder<AppUser?>(
                  valueListenable: AppState.user,
                  builder: (_, u, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        u == null || u.name.isEmpty ? 'Mi cuenta' : u.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        u?.email ?? '',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.text,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
