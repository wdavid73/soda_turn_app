import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turn_soda/features/shifts/data/datasources/shifts_local_datasource.dart';
import 'package:turn_soda/features/shifts/data/repositories/shifts_repository_impl.dart';
import 'package:turn_soda/features/shifts/presentation/providers/shifts_providers.dart';
import 'package:turn_soda/main.dart';
import 'package:turn_soda/shared/layout/app_breakpoints.dart';
import 'package:turn_soda/shared/widgets/web_top_bar.dart';

/// Arranca la app en modo local: el repositorio se fuerza a la
/// implementación con SharedPreferences (los tests no inicializan Supabase)
/// y el dispositivo ya tiene identidad para que `IdentityGate` no abra el
/// bottom sheet de "¿Quién sos?" encima de la navegación.
/// El viewport arranca en tamaño teléfono; `isWeb` simula la plataforma web
/// (los widget tests no corren en web, ver `AppPlatform.debugIsWebOverride`).
Future<void> pumpApp(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  bool isWeb = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  AppPlatform.debugIsWebOverride = isWeb;
  addTearDown(() => AppPlatform.debugIsWebOverride = null);

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

  testWidgets('en web con ventana ancha muestra el diseño web', (
    tester,
  ) async {
    await pumpApp(tester, size: const Size(1280, 800), isWeb: true);

    // Shell web: sin barra inferior; sidebar con branding y botón de
    // generar; top bar decorativa; Home web con su saludo.
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Rotación de oficina'), findsOneWidget);
    expect(find.text('Generar hasta hoy'), findsOneWidget);
    expect(find.byType(WebTopBar), findsOneWidget);
    expect(find.text('¡Hola, Equipo! 👋'), findsOneWidget);

    // Navegación desde el sidebar hacia la page web de Semana.
    await tester.tap(find.text('Semana'));
    await tester.pumpAndSettle();
    expect(find.text('Planeación semanal'), findsOneWidget);
    // El card de vasos queda debajo del grid Lun–Vie; hay que scrollear.
    await tester.scrollUntilVisible(
      find.text('VASOS DE LA SEMANA'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('VASOS DE LA SEMANA'), findsOneWidget);

    // Equipo web: métricas bento y grid de cards.
    await tester.tap(find.text('Equipo'));
    await tester.pumpAndSettle();
    expect(find.text('MIEMBROS ACTIVOS'), findsOneWidget);
    expect(find.text('Brayan Díaz'), findsOneWidget);

    // Stats web: sin historial todavía.
    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Aún no hay historial'), findsOneWidget);

    // Historial web: sin semanas completadas todavía.
    await tester.tap(find.text('Historial'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Aún no hay semanas completadas'),
      findsOneWidget,
    );
  });

  testWidgets('ventana ancha fuera de web conserva el diseño mobile', (
    tester,
  ) async {
    // Simula una tablet Android / escritorio no-web: la regla es
    // kIsWeb && ancho, así que sin plataforma web sigue el shell mobile.
    await pumpApp(tester, size: const Size(1280, 800));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Rotación de oficina'), findsNothing);
    expect(find.byType(WebTopBar), findsNothing);
    expect(find.text('¡Hola, Equipo!'), findsOneWidget);
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
