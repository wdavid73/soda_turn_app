import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turn_soda/features/shifts/presentation/providers/shifts_providers.dart';
import 'package:turn_soda/main.dart';

void main() {
  testWidgets('la app arranca y navega entre las 4 pestañas', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const SodaTurnApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Home
    expect(find.text('¡Hola, Equipo!'), findsOneWidget);
    expect(find.text('Generar hasta hoy'), findsOneWidget);

    // Semana
    await tester.tap(find.text('Semana'));
    await tester.pumpAndSettle();
    expect(find.text('Esta Semana'), findsOneWidget);
    expect(find.text('Vasos de la semana'), findsOneWidget);

    // Equipo: los 8 participantes sembrados
    await tester.tap(find.text('Equipo'));
    await tester.pumpAndSettle();
    expect(find.text('Participantes'), findsOneWidget);
    expect(find.text('Brayan Díaz'), findsOneWidget);

    // Stats: sin historial todavía
    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('Estadísticas'), findsOneWidget);
    expect(find.textContaining('Aún no hay historial'), findsOneWidget);
  });

  testWidgets('generar turno de hoy no falla y navega a Semana', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const SodaTurnApp(),
      ),
    );
    await tester.pumpAndSettle();

    // "Generar hasta hoy" solo calcula los periodos pendientes hasta hoy
    // (nunca una semana completa por adelantado, ver docs/02-reglas-negocio.md).
    // Este smoke test solo verifica que el flujo no falle y la pantalla
    // "Semana" siga funcionando; el comportamiento exacto de qué se asigna
    // está cubierto por test/features/shifts/domain/shifts_engine_test.dart.
    await tester.tap(find.text('Generar hasta hoy'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Semana'));
    await tester.pumpAndSettle();
    expect(find.text('Esta Semana'), findsOneWidget);
    expect(find.text('Vasos de la semana'), findsOneWidget);
  });
}
