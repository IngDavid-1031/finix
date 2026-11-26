import 'package:flutter/material.dart';

import '../data/finance_data.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';

class HistoryScreen extends StatefulWidget {
  final bool standalone;
  final int initialFilter; // 0 todos, 1 gastos, 2 ingresos
  const HistoryScreen({
    super.key,
    this.standalone = false,
    this.initialFilter = 0,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late int _filter = widget.initialFilter;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Column(
            children: [
              Row(
                children: [
                  if (widget.standalone)
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.text,
                      ),
                    ),
                  const FinixLogoMark(size: 22),
                  const SizedBox(width: 6),
                  const Text(
                    'Historial',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              FinixField(
                hint: 'Buscar movimientos...',
                icon: Icons.search_rounded,
                fillColor: Colors.white,
                onChanged: (v) =>
                    setState(() => _query = v.trim().toLowerCase()),
              ),
              const SizedBox(height: 12),
              PillTabs(
                labels: const ['Todos', 'Gastos', 'Ingresos'],
                index: _filter,
                height: 36,
                onChanged: (i) => setState(() => _filter = i),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<List<Txn>>(
            valueListenable: AppState.transactions,
            builder: (context, all, _) {
              final list = all.where((t) {
                if (_filter == 1 && t.isIncome) return false;
                if (_filter == 2 && !t.isIncome) return false;
                if (_query.isEmpty) return true;
                return t.title.toLowerCase().contains(_query) ||
                    (t.note?.toLowerCase().contains(_query) ?? false);
              }).toList();
              if (list.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay movimientos',
                    style: TextStyle(color: AppColors.muted),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                itemCount: list.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, i) {
                  final t = list[i];
                  return Dismissible(
                    key: ValueKey(t.id ?? identityHashCode(t)),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: AppColors.redSoft,
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.red,
                      ),
                    ),
                    confirmDismiss: (_) => showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: Colors.white,
                        title: const Text('Eliminar movimiento'),
                        content: Text(
                          '¿Eliminar "${t.title}" por ${formatMoney(t.amount)}?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text(
                              'Eliminar',
                              style: TextStyle(color: AppColors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onDismissed: (_) => DatabaseService.deleteTransaction(t),
                    child: TransactionTile(txn: t),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
    return widget.standalone ? StandalonePage(child: body) : body;
  }
}
