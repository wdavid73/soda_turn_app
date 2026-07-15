import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turn_soda/features/turnos/presentation/providers/turnos_providers.dart';
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
    expect(find.text('Generar Semana'), findsOneWidget);

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

  testWidgets('generar semana asigna gaseosa y vasos', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const SodaTurnApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Generar Semana'));
    await tester.pumpAndSettle();

    // En Semana deben quedar los 5 días asignados (nadie "Sin asignar").
    await tester.tap(find.text('Semana'));
    await tester.pumpAndSettle();
    expect(find.text('Sin asignar'), findsNothing);
  });
}
