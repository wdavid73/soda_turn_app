import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../layout/app_breakpoints.dart';
import 'app_destinations.dart';
import 'side_nav.dart';

/// Shell de navegación (Home, Semana, Equipo, Stats, Historial) con una
/// versión por plataforma:
/// - Mobile (default, y web con ventana angosta): barra de navegación
///   inferior; el contenido se centra si la ventana supera 600 px.
/// - Web (plataforma web + ventana >= 1024 px): sidebar de 280px según los
///   mockups de design/web.
class AppScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return context.useWebLayout
        ? _WebShell(navigationShell: navigationShell)
        : _MobileShell(navigationShell: navigationShell);
  }
}

void _goBranch(StatefulNavigationShell shell, int index) => shell.goBranch(
  index,
  initialLocation: index == shell.currentIndex,
);

class _MobileShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _MobileShell({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      body: width > AppBreakpoints.tablet
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppBreakpoints.tablet,
                ),
                child: navigationShell,
              ),
            )
          : navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) => _goBranch(navigationShell, i),
        destinations: [
          for (final d in appDestinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: d.label,
            ),
        ],
      ),
    );
  }
}

class _WebShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _WebShell({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideNav(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (i) => _goBranch(navigationShell, i),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppBreakpoints.contentMaxWidth,
                ),
                child: navigationShell,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
