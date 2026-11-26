import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finix/data/finance_data.dart';
import 'package:finix/main.dart';
import 'package:finix/screens/home_shell.dart';
import 'package:finix/widgets/bottom_nav.dart';

void main() {
  testWidgets('Splash muestra Finix y luego el login', (tester) async {
    await tester.pumpWidget(const FinixApp());
    expect(find.text('Finix'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);
  });

  for (final (name, size) in [
    ('móvil', Size(400, 860)),
    ('escritorio', Size(1440, 1000)),
  ]) {
    testWidgets('Inicio se renderiza sin errores en $name', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      AppState.loadDemoData();
      await tester.pumpWidget(const MaterialApp(home: HomeShell()));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Hola, Usuario', skipOffstage: false),
        findsOneWidget,
      );

      // La barra inferior (solo móvil) no debe ocupar toda la pantalla.
      final nav = find.byType(FinixBottomNav);
      if (nav.evaluate().isNotEmpty) {
        expect(tester.getSize(nav).height, lessThan(140));
      }
    });
  }
}
