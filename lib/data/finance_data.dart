import 'package:flutter/material.dart';

/* ───────────────────────────── Categorías ───────────────────────────── */

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

  static const _all = [
    comida, transporte, compras, hogar, salud, otros, //
    servicios, salario, ahorro, ventas, regalos, inversiones,
  ];

  static Category byName(String? name) =>
      _all.firstWhere((c) => c.name == name, orElse: () => otros);
}

/* ───────────────────────────── Modelos ───────────────────────────── */

class Txn {
  final String? id;
  final String title;
  final Category category;
  final int amount; // negativo = gasto, positivo = ingreso
  final DateTime date;
  final String? note;

  const Txn({
    this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.note,
  });

  bool get isIncome => amount > 0;

  factory Txn.fromMap(Map<String, dynamic> m) => Txn(
    id: m['id'] as String?,
    title: m['title'] as String? ?? '',
    category: Categories.byName(m['category'] as String?),
    amount: (m['amount'] as num?)?.toInt() ?? 0,
    date:
        DateTime.tryParse(m['date'] as String? ?? '')?.toLocal() ??
        DateTime.now(),
    note: m['note'] as String?,
  );

  Map<String, dynamic> toInsert() => {
    'title': title,
    'category': category.name,
    'amount': amount,
    'date': date.toUtc().toIso8601String(),
    'note': note,
  };
}

class Goal {
  final String? id;
  final String title;
  final int saved;
  final int target;
  final String emoji;

  const Goal({
    this.id,
    required this.title,
    required this.saved,
    required this.target,
    required this.emoji,
  });

  Color get color => const Color(0xFF1FB86A);
  double get progress =>
      target == 0 ? 0 : (saved / target).clamp(0, 1).toDouble();

  Goal copyWith({int? saved}) => Goal(
    id: id,
    title: title,
    saved: saved ?? this.saved,
    target: target,
    emoji: emoji,
  );

  factory Goal.fromMap(Map<String, dynamic> m) => Goal(
    id: m['id'] as String?,
    title: m['title'] as String? ?? '',
    saved: (m['saved'] as num?)?.toInt() ?? 0,
    target: (m['target'] as num?)?.toInt() ?? 1,
    emoji: m['emoji'] as String? ?? '🎯',
  );

  Map<String, dynamic> toInsert() => {
    'title': title,
    'saved': saved,
    'target': target,
    'emoji': emoji,
  };
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  String get firstName =>
      name.trim().isEmpty ? '' : name.trim().split(RegExp(r'\s+')).first;

  String get initials {
    final parts = (name.trim().isEmpty ? email : name).trim().split(
      RegExp(r'\s+'),
    );
    return parts.take(2).map((p) => p.isEmpty ? '' : p[0].toUpperCase()).join();
  }
}

/* ───────────────────────────── Estado global ───────────────────────────── */

/// Estado de la app. Cuando hay sesión, `DatabaseService` lo llena con los
/// datos de Supabase en tiempo real; sin sesión queda vacío.
class AppState {
  AppState._();

  /// true si Supabase se inicializó correctamente.
  static bool backendReady = false;

  static final user = ValueNotifier<AppUser?>(null);
  static final transactions = ValueNotifier<List<Txn>>([]);
  static final goals = ValueNotifier<List<Goal>>([]);

  static final notifications = ValueNotifier<bool>(true);
  static final reminders = ValueNotifier<bool>(true);
  static final cloudSync = ValueNotifier<bool>(true);
  static final darkMode = ValueNotifier<bool>(false);

  /// 0 = Claro, 1 = Oscuro, 2 = Automático
  static final appearance = ValueNotifier<int>(2);

  /// Datos de ejemplo solo para desarrollo (--dart-define=START=...).
  static void loadDemoData() {
    DateTime ago(int d) {
      final n = DateTime.now();
      return DateTime(n.year, n.month, n.day).subtract(Duration(days: d));
    }

    user.value = const AppUser(
      id: 'demo',
      name: 'Usuario Demo',
      email: 'demo@finix.app',
    );
    transactions.value = [
      Txn(
        title: 'Comida',
        category: Categories.comida,
        amount: -45000,
        date: ago(0),
      ),
      Txn(
        title: 'Salario',
        category: Categories.salario,
        amount: 3200000,
        date: ago(1),
      ),
      Txn(
        title: 'Transporte',
        category: Categories.transporte,
        amount: -20000,
        date: ago(1),
      ),
      Txn(
        title: 'Compras',
        category: Categories.compras,
        amount: -120000,
        date: ago(3),
      ),
      Txn(
        title: 'Servicios',
        category: Categories.servicios,
        amount: -90000,
        date: ago(5),
      ),
      Txn(
        title: 'Salario',
        category: Categories.salario,
        amount: 3000000,
        date: ago(32),
      ),
      Txn(
        title: 'Hogar',
        category: Categories.hogar,
        amount: -900000,
        date: ago(40),
      ),
      Txn(
        title: 'Salario',
        category: Categories.salario,
        amount: 2800000,
        date: ago(62),
      ),
      Txn(
        title: 'Compras',
        category: Categories.compras,
        amount: -1500000,
        date: ago(70),
      ),
    ];
    goals.value = const [
      Goal(
        title: 'Viaje a Japón',
        saved: 1400000,
        target: 2000000,
        emoji: '✈️',
      ),
      Goal(title: 'Nuevo celular', saved: 600000, target: 1200000, emoji: '📱'),
    ];
  }
}

/* ───────────────────────────── Formatos ───────────────────────────── */

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

/// Formato corto para ejes: 1,2M · 850K · 0
String compactMoney(num v) {
  final a = v.abs();
  String trim(double x) => x
      .toStringAsFixed(x >= 10 || x == x.roundToDouble() ? 0 : 1)
      .replaceAll('.', ',');
  if (a >= 1000000) return '${v < 0 ? '-' : ''}${trim(a / 1000000)}M';
  if (a >= 1000) return '${v < 0 ? '-' : ''}${trim(a / 1000)}K';
  return v.round().toString();
}

const monthNames = [
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
  final md = '${d.day.toString().padLeft(2, '0')} ${monthNames[d.month - 1]}';
  if (diff == 0) return 'Hoy, $md';
  if (diff == 1) return 'Ayer, $md';
  return '${_days[d.weekday - 1]}, $md';
}

String dateLabelWithYear(DateTime d) =>
    '${dateLabel(d).split(',').first}, ${d.day} ${monthNames[d.month - 1]} ${d.year}';
