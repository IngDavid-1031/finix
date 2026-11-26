import 'package:flutter/material.dart';

import '../data/finance_data.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';

class CategoriesScreen extends StatelessWidget {
  final bool standalone;
  const CategoriesScreen({super.key, this.standalone = false});

  static const _spent = {
    'Comida': 400000,
    'Transporte': 350000,
    'Compras': 275000,
    'Hogar': 187500,
    'Salud': 37500,
    'Otros': 0,
  };

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      children: [
        Row(
          children: [
            if (standalone)
              IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.text,
                ),
              ),
            const Text(
              'Categorías',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.35,
          children: [
            for (final c in Categories.expense)
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CategoryBubble(category: c, size: 44, radius: 14),
                    Text(
                      c.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      formatMoney(_spent[c.name] ?? 0),
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
    return standalone ? StandalonePage(child: body) : body;
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faq = [
    (
      '¿Cómo registro un gasto?',
      'Toca el botón + o "Agregar Gasto", escribe el monto, elige una categoría y guarda.',
    ),
    (
      '¿Cómo creo una meta de ahorro?',
      'Ve a "Mis metas" y toca una meta para abonarle dinero.',
    ),
    (
      '¿Mis datos están seguros?',
      'Tus datos se guardan de forma privada. Nunca compartimos tu información.',
    ),
    (
      '¿Qué incluye Finix Pro?',
      'Reportes avanzados, sin anuncios y soporte prioritario.',
    ),
  ];

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
    children: [
      const Text(
        'Ayuda',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.text,
        ),
      ),
      const SizedBox(height: 16),
      for (final (q, a) in _faq) ...[
        SoftCard(
          padding: EdgeInsets.zero,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text(
                q,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedAlignment: Alignment.centerLeft,
              children: [
                Text(
                  a,
                  style: const TextStyle(color: AppColors.muted, height: 1.4),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    ],
  );
}
