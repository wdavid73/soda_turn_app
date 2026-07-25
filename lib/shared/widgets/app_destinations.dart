import 'package:flutter/material.dart';

/// Destino de navegación compartido entre la `NavigationBar` (móvil), el
/// `NavigationRail` (tablet) y el `SideNav` (desktop), para que las tres
/// variantes muestren siempre los mismos 5 tabs.
class AppDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const AppDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// Home, Semana, Equipo, Stats, Historial — mismo orden que los branches del
/// `StatefulShellRoute` en `app_router.dart`.
const List<AppDestination> appDestinations = [
  AppDestination(
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
    label: 'Home',
  ),
  AppDestination(
    icon: Icons.calendar_view_week_outlined,
    selectedIcon: Icons.calendar_view_week,
    label: 'Semana',
  ),
  AppDestination(
    icon: Icons.people_outline,
    selectedIcon: Icons.people,
    label: 'Equipo',
  ),
  AppDestination(
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart,
    label: 'Stats',
  ),
  AppDestination(
    icon: Icons.history_outlined,
    selectedIcon: Icons.history,
    label: 'Historial',
  ),
];
