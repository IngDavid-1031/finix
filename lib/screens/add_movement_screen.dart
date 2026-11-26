import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/finance_data.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';

class AddMovementScreen extends StatefulWidget {
  final bool initialIncome;
  const AddMovementScreen({super.key, this.initialIncome = false});

  @override
  State<AddMovementScreen> createState() => _AddMovementScreenState();
}

class _AddMovementScreenState extends State<AddMovementScreen> {
  late int _type = widget.initialIncome ? 1 : 0; // 0 gasto, 1 ingreso
  int _category = 0;
  DateTime _date = DateTime.now();
  final _amount = TextEditingController();
  final _note = TextEditingController();

  List<Category> get _cats =>
      _type == 0 ? Categories.expense : Categories.income;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _date = d);
  }

  bool _saving = false;

  Future<void> _save() async {
    final digits = _amount.text.replaceAll(RegExp(r'[^0-9]'), '');
    final value = int.tryParse(digits) ?? 0;
    final messenger = ScaffoldMessenger.of(context);
    void toast(String msg, Color color) => messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          backgroundColor: color,
        ),
      );
    if (value == 0) {
      toast('Ingresa un monto', AppColors.red);
      return;
    }
    final cat = _cats[_category];
    setState(() => _saving = true);
    try {
      await DatabaseService.addTransaction(
        Txn(
          title: cat.name,
          category: cat,
          amount: _type == 0 ? -value : value,
          date: _date,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      toast(
        '${_type == 0 ? 'Gasto' : 'Ingreso'} guardado: ${formatMoney(value)}',
        AppColors.primaryDark,
      );
    } catch (e) {
      toast(AuthService.errorMessage(e), AppColors.red);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => StandalonePage(
    background: Colors.white,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text),
            ),
            const Expanded(
              child: Text(
                'Agregar movimiento',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 16),
        PillTabs(
          labels: const ['Gasto', 'Ingreso'],
          index: _type,
          boxed: true,
          height: 44,
          onChanged: (i) => setState(() {
            _type = i;
            _category = 0;
          }),
        ),
        const SizedBox(height: 28),
        TextField(
          controller: _amount,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [_MoneyFormatter()],
          style: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: '\$ 0.00',
            hintStyle: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
        ),
        const Text(
          'Ingresa un monto',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 14),
        ),
        const SizedBox(height: 26),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.92,
          children: [
            for (var i = 0; i < _cats.length; i++)
              GestureDetector(
                onTap: () => setState(() => _category = i),
                child: Column(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _cats[i].color.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: i == _category
                                ? _cats[i].color
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _cats[i].icon,
                          color: _cats[i].color,
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _cats[i].name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: i == _category
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Text(
                'Fecha',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: AppColors.text,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateLabelWithYear(_date),
                        style: const TextStyle(color: AppColors.text),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Descripción (opcional)',
          style: TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 8),
        FinixField(hint: 'Ej: Almuerzo en la ciudad', controller: _note),
        const SizedBox(height: 26),
        PrimaryButton(
          label: _saving ? 'Guardando…' : 'Guardar',
          onPressed: _saving ? null : _save,
        ),
      ],
    ),
  );
}

class _MoneyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    if (digits.length > 12) digits = digits.substring(0, 12);
    final text = formatMoney(int.parse(digits));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
