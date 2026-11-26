import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/bottom_nav.dart';
import 'add_movement_screen.dart';
import 'categories_screen.dart';
import 'desktop/desktop_shell.dart';
import 'goals_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

/// A partir de este ancho se muestra el panel de escritorio.
const kDesktopBreakpoint = 1100.0;

/// Elige la interfaz según el ancho: escritorio (web en PC) o móvil (app y web en celular).
class HomeShell extends StatelessWidget {
  final int initialTab;
  const HomeShell({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => c.maxWidth >= kDesktopBreakpoint
        ? const DesktopShell()
        : MobileShell(initialTab: initialTab),
  );
}

class MobileShell extends StatefulWidget {
  final int initialTab;
  const MobileShell({super.key, this.initialTab = 0});

  @override
  State<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends State<MobileShell> {
  late int _index = widget.initialTab;

  void _push(Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    body: SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: IndexedStack(
            index: _index,
            children: [
              HomeScreen(
                onOpenHistory: (f) =>
                    _push(HistoryScreen(standalone: true, initialFilter: f)),
              ),
              StatsScreen(
                onSeeCategories: () =>
                    _push(const CategoriesScreen(standalone: true)),
              ),
              const GoalsScreen(),
              ProfileScreen(
                onOpenSettings: () =>
                    _push(const SettingsScreen(standalone: true)),
              ),
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: FinixBottomNav(
      index: _index,
      onTap: (i) => setState(() => _index = i),
      onAdd: () => _push(const AddMovementScreen()),
    ),
  );
}
