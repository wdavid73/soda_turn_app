import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../features/shifts/presentation/providers/shifts_providers.dart';
import '../layout/app_breakpoints.dart';
import 'app_destinations.dart';

/// Sidebar desktop según los mockups de design/web: logo arriba, los 5
/// destinos con píldora mint en el activo, y el botón "Generar hasta hoy"
/// (equivalente al FAB de Home en móvil) anclado abajo.
class SideNav extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const SideNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: AppBreakpoints.sideNavWidth,
      color: AppTheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.bubble_chart_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SodaTurn',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleLarge?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Rotación de oficina',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          for (var i = 0; i < appDestinations.length; i++)
            _SideNavItem(
              destination: appDestinations[i],
              selected: i == selectedIndex,
              onTap: () => onDestinationSelected(i),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.mint,
                foregroundColor: AppTheme.onMint,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                final vm = ref.read(turnosViewModelProvider.notifier);
                vm.goCurrentWeek();
                vm.generateToday();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Turnos generados hasta hoy 🥤'),
                  ),
                );
              },
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generar hasta hoy'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ítem del sidebar: píldora mint redondeada solo a la derecha en el activo,
/// como el `rounded-r-full` del mockup.
class _SideNavItem extends StatelessWidget {
  final AppDestination destination;
  final bool selected;
  final VoidCallback onTap;

  const _SideNavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const rightPill = BorderRadius.horizontal(right: Radius.circular(999));

    return Padding(
      padding: const EdgeInsets.only(right: 20, bottom: 4),
      child: Material(
        color: selected ? AppTheme.mint : Colors.transparent,
        borderRadius: rightPill,
        child: InkWell(
          onTap: onTap,
          borderRadius: rightPill,
          hoverColor: AppTheme.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  color: selected ? AppTheme.onMint : AppTheme.onSurfaceVariant,
                ),
                const SizedBox(width: 16),
                Text(
                  destination.label,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? AppTheme.onMint
                        : AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
