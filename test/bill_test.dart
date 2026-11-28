import 'package:flutter_test/flutter_test.dart';

import 'package:finix/data/finance_data.dart';

void main() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final thisMonth = Bill.monthKey(today);
  final lastMonth = Bill.monthKey(DateTime(now.year, now.month - 1));

  Bill bill(int day, String? paid) =>
      Bill(title: 'Arriendo', amount: 900000, dueDay: day, paidMonth: paid);

  test('sin pagar este mes: vence este mes', () {
    final b = bill(today.day, lastMonth);
    expect(b.paidThisMonth, isFalse);
    expect(b.daysLeft, 0);
    expect(b.nextDue.month, today.month);
  });

  test('pagado este mes: el próximo vencimiento es el mes siguiente', () {
    final b = bill(today.day, thisMonth);
    expect(b.paidThisMonth, isTrue);
    expect(b.daysLeft, greaterThan(26));
    expect(b.nextDue.month, DateTime(now.year, now.month + 1).month);
  });

  test('si la fecha ya pasó y no se pagó queda vencido', () {
    if (today.day == 1) return; // no hay días anteriores este mes
    final b = bill(1, lastMonth);
    expect(b.daysLeft, lessThan(0));
    expect(b.overdue, isTrue);
  });

  test('día 31 en meses cortos vence el último día del mes', () {
    final b = bill(31, lastMonth);
    final last = DateTime(now.year, now.month + 1, 0).day;
    expect(b.nextDue.day, last);
  });
}
