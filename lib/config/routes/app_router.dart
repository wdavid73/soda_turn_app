import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/shifts/presentation/screens/home_screen.dart';
import '../../features/shifts/presentation/screens/participants_screen.dart';
import '../../features/shifts/presentation/screens/stats_screen.dart';
import '../../features/shifts/presentation/screens/week_screen.dart';
import '../../shared/widgets/app_scaffold.dart';

/// Router como provider: cada ProviderScope (app o test) recibe su propia
/// instancia y no se filtra estado de navegación entre árboles de widgets.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
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
        ],
      ),
    ],
  );
});
