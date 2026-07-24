import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turn_soda/features/shifts/data/datasources/shifts_local_datasource.dart';
import 'package:turn_soda/features/shifts/data/repositories/shifts_repository_impl.dart';
import 'package:turn_soda/features/shifts/presentation/providers/shifts_providers.dart';
import 'package:turn_soda/main.dart';

/// Arranca la app en modo local: el repositorio se fuerza a la
/// implementación con SharedPreferences (los tests no inicializan Supabase)
/// y el dispositivo ya tiene identidad para que `IdentityGate` no abra el
/// bottom sheet de "¿Quién sos?" encima de la navegación.
Future<void> pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({
    'sodaturn_my_participant_id': 'wilson',
  });
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        turnosRepositoryProvider.overrideWithValue(
          ShiftsRepositoryImpl(ShiftsLocalDatasourceImpl(prefs)),
        ),
      ],
      child: const SodaTurnApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('la app arranca y navega entre las 5 pestañas', (tester) async {
    await pumpApp(tester);

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

    // Historial: sin semanas completadas todavía. 'Historial' aparece en la
    // barra y como título de la pantalla, así que el tap apunta a la barra.
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Historial'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Revisa los turnos pasados de bebidas y snacks.'),
        findsOneWidget);
    expect(
      find.textContaining('Aún no hay semanas completadas'),
      findsOneWidget,
    );
  });

  testWidgets('generar turno de hoy no falla y navega a Semana', (
    tester,
  ) async {
    await pumpApp(tester);

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
