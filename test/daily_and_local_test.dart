import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finix/data/finance_data.dart';
import 'package:finix/screens/home_shell.dart';
import 'package:finix/services/local/local_store.dart';
import 'package:finix/services/local/local_store_web.dart' as web;

void main() {
  testWidgets('Diario muestra ingresos y gastos del día', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    AppState.loadDemoData();
    await tester.pumpWidget(const MaterialApp(home: HomeShell()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Diario'));
    await tester.pumpAndSettle();
    expect(find.text('Ingresos'), findsWidgets);
    expect(find.textContaining('Hoy,'), findsWidgets);
    expect(find.text('- \$ 45.000'), findsWidgets); // gasto de hoy en el demo

    // Ayer: salario y transporte.
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();
    expect(find.textContaining('Ayer,'), findsWidgets);
    expect(find.text('+ \$ 3.200.000'), findsWidgets);
  });

  test('base interna guarda, marca pendientes y borra', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await web.openLocalStore();
    final id = newId();
    expect(id, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-')));

    await store.putAll([
      LocalRecord(
        kind: 'transactions',
        id: id,
        userId: 'u1',
        data: {'id': id, 'title': 'Café', 'amount': -5000},
        dirty: true,
      ),
    ]);
    var recs = await store.load('transactions', 'u1');
    expect(recs.single.dirty, isTrue);
    expect(recs.single.data['title'], 'Café');
    expect(await store.load('transactions', 'otro'), isEmpty);

    await store.removeAll('transactions', [id]);
    recs = await store.load('transactions', 'u1');
    expect(recs, isEmpty);
  });
}
