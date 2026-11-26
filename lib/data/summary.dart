import 'finance_data.dart';

/// Rango de fechas [start, end) con su etiqueta para gráficas.
class Bucket {
  final DateTime start;
  final DateTime end;
  final String label;
  const Bucket(this.start, this.end, this.label);
}

/// Cálculos sobre la lista de movimientos (saldo, totales del mes, categorías…).
class FinanceSummary {
  final List<Txn> txns;
  final DateTime now;

  FinanceSummary(this.txns, {DateTime? now}) : now = now ?? DateTime.now();

  DateTime get monthStart => DateTime(now.year, now.month);
  DateTime get prevMonthStart => DateTime(now.year, now.month - 1);

  int get balance => txns.fold(0, (a, t) => a + t.amount);

  int balanceAt(DateTime t) =>
      txns.where((x) => !x.date.isAfter(t)).fold(0, (a, x) => a + x.amount);

  int income(DateTime from, DateTime to) =>
      _in(from, to).where((t) => t.isIncome).fold(0, (a, t) => a + t.amount);

  int expense(DateTime from, DateTime to) =>
      _in(from, to).where((t) => !t.isIncome).fold(0, (a, t) => a - t.amount);

  Iterable<Txn> _in(DateTime from, DateTime to) =>
      txns.where((t) => !t.date.isBefore(from) && t.date.isBefore(to));

  int get monthIncome => income(monthStart, _farFuture);
  int get monthExpense => expense(monthStart, _farFuture);
  int get monthSavings => monthIncome - monthExpense;
  int get prevMonthIncome => income(prevMonthStart, monthStart);
  int get prevMonthExpense => expense(prevMonthStart, monthStart);
  int get prevMonthSavings => prevMonthIncome - prevMonthExpense;

  static final _farFuture = DateTime(9999);

  /// Variación porcentual; null si no hay base de comparación.
  static double? change(num current, num previous) =>
      previous == 0 ? null : (current - previous) / previous.abs() * 100;

  /// % de cambio del saldo frente al cierre del mes anterior.
  double? get balanceChange => change(
    balance,
    balanceAt(monthStart.subtract(const Duration(microseconds: 1))),
  );

  /// Saldo acumulado en [points] momentos repartidos en los últimos [days] días.
  List<double> balanceSeries({required int days, int points = 8}) {
    final start = now.subtract(Duration(days: days));
    return [
      for (var i = 0; i < points; i++)
        balanceAt(
          start.add(
            Duration(
              milliseconds: (days * 86400000 * i / (points - 1)).round(),
            ),
          ),
        ).toDouble(),
    ];
  }

  /// Gastos agrupados por categoría (de mayor a menor) en el rango.
  List<(Category, int)> expenseByCategory(DateTime from, DateTime to) {
    final m = <String, int>{};
    for (final t in _in(from, to).where((t) => !t.isIncome)) {
      m[t.category.name] = (m[t.category.name] ?? 0) - t.amount;
    }
    final list = [
      for (final e in m.entries) (Categories.byName(e.key), e.value),
    ];
    list.sort((a, b) => b.$2.compareTo(a.$2));
    return list;
  }

  List<int> incomeBy(List<Bucket> b) => [
    for (final x in b) income(x.start, x.end),
  ];
  List<int> expenseBy(List<Bucket> b) => [
    for (final x in b) expense(x.start, x.end),
  ];
  List<int> netBy(List<Bucket> b) => [
    for (final x in b) income(x.start, x.end) - expense(x.start, x.end),
  ];

  /* ── Generadores de rangos ── */

  List<Bucket> lastMonths(int n) => [
    for (var i = n - 1; i >= 0; i--)
      Bucket(
        DateTime(now.year, now.month - i),
        DateTime(now.year, now.month - i + 1),
        monthNames[DateTime(now.year, now.month - i).month - 1],
      ),
  ];

  List<Bucket> lastQuarters(int n) {
    final q = (now.month - 1) ~/ 3; // trimestre actual 0..3
    return [
      for (var i = n - 1; i >= 0; i--)
        () {
          final s = DateTime(now.year, (q - i) * 3 + 1);
          return Bucket(
            s,
            DateTime(s.year, s.month + 3),
            'T${(s.month - 1) ~/ 3 + 1}',
          );
        }(),
    ];
  }

  List<Bucket> lastYears(int n) => [
    for (var i = n - 1; i >= 0; i--)
      Bucket(
        DateTime(now.year - i),
        DateTime(now.year - i + 1),
        '${now.year - i}',
      ),
  ];
}
