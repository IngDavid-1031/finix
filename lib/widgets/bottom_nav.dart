import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class FinixBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final VoidCallback onAdd;

  const FinixBottomNav({
    super.key,
    required this.index,
    required this.onTap,
    required this.onAdd,
  });

  static const _items = [
    (Icons.home_rounded, 'Inicio'),
    (Icons.bar_chart_rounded, 'Estadísticas'),
    (Icons.track_changes_rounded, 'Metas'),
    (Icons.person_rounded, 'Perfil'),
  ];

  Widget _item(int i) {
    final selected = i == index;
    final color = selected ? AppColors.primary : AppColors.muted;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(i),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_items[i].$1, color: color, size: 25),
              const SizedBox(height: 3),
              Text(
                _items[i].$2,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      boxShadow: [
        BoxShadow(
          color: Color(0x140B5A3A),
          blurRadius: 24,
          offset: Offset(0, -6),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            child: Row(
              children: [
                _item(0),
                _item(1),
                Expanded(
                  child: Center(
                    heightFactor: 1,
                    child: GestureDetector(
                      onTap: onAdd,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.buttonGradient,
                          border: Border.all(
                            color: AppColors.greenSoft,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
                _item(2),
                _item(3),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
