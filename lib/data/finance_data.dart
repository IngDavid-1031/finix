import 'package:flutter/material.dart';

class Category {
  final String name;
  final IconData icon;
  final Color color;
  const Category(this.name, this.icon, this.color);
}

class Categories {
  Categories._();

  static const comida = Category(
    'Comida',
    Icons.restaurant_rounded,
    Color(0xFFF59E0B),
  );
  static const transporte = Category(
    'Transporte',
    Icons.directions_car_rounded,
    Color(0xFF3B82F6),
  );
  static const compras = Category(
    'Compras',
    Icons.shopping_bag_rounded,
    Color(0xFFA855F7),
  );
  static const hogar = Category('Hogar', Icons.home_rounded, Color(0xFFF97316));
  static const salud = Category(
    'Salud',
    Icons.favorite_rounded,
    Color(0xFFEF4444),
  );
  static const otros = Category(
    'Otros',
    Icons.more_horiz_rounded,
    Color(0xFF64748B),
  );
  static const servicios = Category(
    'Servicios',
    Icons.house_rounded,
    Color(0xFFF97316),
  );
  static const salario = Category(
    'Salario',
    Icons.south_rounded,
    Color(0xFF16A34A),
  );
  static const ahorro = Category(
    'Ahorro',
    Icons.savings_rounded,
    Color(0xFF22C55E),
  );
  static const ventas = Category(
    'Ventas',
    Icons.storefront_rounded,
    Color(0xFF0EA5E9),
  );
  static const regalos = Category(
    'Regalos',
    Icons.card_giftcard_rounded,
    Color(0xFFEC4899),
  );
  static const inversiones = Category(
    'Inversiones',
    Icons.trending_up_rounded,
    Color(0xFF14B8A6),
  );

  static const expense = [comida, transporte, compras, hogar, salud, otros];
  static const income = [salario, ahorro, ventas, regalos, inversiones, otros];
}

class Txn {
  final String title;
  final Category category;
  final int amount; // negativo = gasto, positivo = ingreso
  final DateTime date;
  final String? note;

  const Txn({
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.note,
  });

  bool get isIncome => amount > 0;
}

class Goal {
  final String title;
  final int saved;
  final int target;
  final String emoji;
  final Color color;

  const Goal({
    required this.title,
    required this.saved,
    required this.target,
    required this.emoji,
    required this.color,
  });

  double get progress =>
      target == 0 ? 0 : (saved / target).clamp(0, 1).toDouble();

  Goal copyWith({int? saved}) => Goal(
    title: title,
    saved: saved ?? this.saved,
    target: target,
    emoji: emoji,
    color: color,
  );
}

/// Estado en memoria de la app (datos de ejemplo hasta conectar el backend).
class AppState {
  AppState._();

  static DateTime _daysAgo(int d) {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day).subtract(Duration(days: d));
  }

  static final transactions = ValueNotifier<List<Txn>>([
    Txn(
      title: 'Comida',
      category: Categories.comida,
      amount: -45000,
      date: _daysAgo(0),
    ),
    Txn(
      title: 'Salario',
      category: Categories.salario,
      amount: 1500000,
      date: _daysAgo(1),
    ),
    Txn(
      title: 'Transporte',
      category: Categories.transporte,
      amount: -20000,
      date: _daysAgo(1),
    ),
    Txn(
      title: 'Compras',
      category: Categories.compras,
      amount: -120000,
      date: _daysAgo(3),
    ),
    Txn(
      title: 'Servicios',
      category: Categories.servicios,
      amount: -90000,
      date: _daysAgo(5),
    ),
    Txn(
      title: 'Ahorro',
      category: Categories.ahorro,
      amount: 200000,
      date: _daysAgo(6),
    ),
  ]);

  static final goals = ValueNotifier<List<Goal>>(const [
    Goal(
      title: 'Viaje a Japón',
      saved: 1400000,
      target: 2000000,
      emoji: '✈️',
      color: Color(0xFF1FB86A),
    ),
    Goal(
      title: 'Nuevo celular',
      saved: 600000,
      target: 1200000,
      emoji: '📱',
      color: Color(0xFF1FB86A),
    ),
    Goal(
      title: 'Casa propia',
      saved: 10000000,
      target: 50000000,
      emoji: '🏠',
      color: Color(0xFF1FB86A),
    ),
  ]);

  static final notifications = ValueNotifier<bool>(true);
  static final reminders = ValueNotifier<bool>(true);
  static final cloudSync = ValueNotifier<bool>(true);
  static final darkMode = ValueNotifier<bool>(false);

  /// 0 = Claro, 1 = Oscuro, 2 = Automático
  static final appearance = ValueNotifier<int>(2);

  static void addTransaction(Txn t) =>
      transactions.value = [t, ...transactions.value];

  static void addToGoal(int index, int amount) {
    final list = [...goals.value];
    list[index] = list[index].copyWith(saved: list[index].saved + amount);
    goals.value = list;
  }
}

/// Formato de moneda colombiano: $ 2.750.000
String formatMoney(num value, {bool withSign = false}) {
  final s = value.round().abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  final sign = value < 0 ? '- ' : (withSign && value > 0 ? '+ ' : '');
  return '$sign\$ $b';
}

const _months = [
  'Ene',
  'Feb',
  'Mar',
  'Abr',
  'May',
  'Jun',
  'Jul',
  'Ago',
  'Sep',
  'Oct',
  'Nov',
  'Dic',
];
const _days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

String dateLabel(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(DateTime(d.year, d.month, d.day)).inDays;
  final md = '${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]}';
  if (diff == 0) return 'Hoy, $md';
  if (diff == 1) return 'Ayer, $md';
  return '${_days[d.weekday - 1]}, $md';
}

String dateLabelWithYear(DateTime d) =>
    '${dateLabel(d).split(',').first}, ${d.day} ${_months[d.month - 1]} ${d.year}';
