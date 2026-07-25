import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/shifts/presentation/screens/history/history_screen.dart';
import '../../features/shifts/presentation/screens/home/home_screen.dart';
import '../../features/shifts/presentation/screens/participants/participants_screen.dart';
import '../../features/shifts/presentation/screens/stats/stats_screen.dart';
import '../../features/shifts/presentation/screens/week/week_screen.dart';
import '../../shared/widgets/app_scaffold.dart';

/// Contexto del Navigator raíz para código fuera del árbol de rutas (ej.
/// `IdentityGate`, que vive en el `builder` de `MaterialApp.router` y por
/// lo tanto no tiene un Navigator como ancestro).
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Router como provider: cada ProviderScope (app o test) recibe su propia
/// instancia y no se filtra estado de navegación entre árboles de widgets.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/week',
                name: 'week',
                builder: (context, state) => const WeekScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/people',
                name: 'people',
                builder: (context, state) => const ParticipantsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                name: 'stats',
                builder: (context, state) => const StatsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                name: 'history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
