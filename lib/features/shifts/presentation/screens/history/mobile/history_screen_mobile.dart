import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../shared/widgets/soda_header.dart';
import '../../../../domain/usecases/compute_history_usecase.dart';
import '../../../providers/shifts_providers.dart';
import '../../../widgets/history_month_section.dart';
import '../history_empty_card.dart';

/// Historial mobile: columna única con filtro por mes y acordeones de
/// semanas. La búsqueda del mockup no existe todavía en el dominio, así que
/// el botón solo avisa "Próximamente...".
class HistoryScreenMobile extends ConsumerStatefulWidget {
  const HistoryScreenMobile({super.key});

  @override
  ConsumerState<HistoryScreenMobile> createState() =>
      _HistoryScreenMobileState();
}

class _HistoryScreenMobileState extends ConsumerState<HistoryScreenMobile> {
  /// Mes seleccionado en los chips ("2025-10"); null = "Todo el tiempo".
  String? _selectedMonthKey;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ui = ref.watch(turnosViewModelProvider);
    final groups = ref.watch(turnosHistoryProvider);

    if (ui.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final visibles = _selectedMonthKey == null
        ? groups
        : groups.where((g) => g.monthKey == _selectedMonthKey).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Row(
              children: [
                const SodaHeader(),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.search,
                    color: AppTheme.onSurfaceVariant,
                  ),
                  tooltip: 'Buscar',
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Próximamente...')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Historial',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Revisa los turnos pasados de bebidas y snacks.',
              style: textTheme.bodyLarge?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            if (groups.isEmpty)
              const HistoryEmptyCard()
            else ...[
              _MonthFilterChips(
                groups: groups,
                selectedKey: _selectedMonthKey,
                onSelected: (key) => setState(() => _selectedMonthKey = key),
              ),
              const SizedBox(height: 20),
              for (final group in visibles) ...[
                HistoryMonthSection(group: group, data: ui.data),
                const SizedBox(height: 24),
              ],
              const _HistoryFooter(),
            ],
          ],
        ),
      ),
    );
  }
}

/// Chips horizontales de filtro por mes ("Todo el tiempo" + un chip por mes).
class _MonthFilterChips extends StatelessWidget {
  final List<HistoryMonthGroup> groups;
  final String? selectedKey;
  final ValueChanged<String?> onSelected;

  const _MonthFilterChips({
    required this.groups,
    required this.selectedKey,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _FilterPill(
            label: 'Todo el tiempo',
            selected: selectedKey == null,
            onTap: () => onSelected(null),
          ),
          for (final group in groups) ...[
            const SizedBox(width: 8),
            _FilterPill(
              label: group.label,
              selected: selectedKey == group.monthKey,
              onTap: () => onSelected(group.monthKey),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: selected ? AppTheme.primary : AppTheme.surfaceContainerHigh,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: selected ? Colors.white : AppTheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Cierre decorativo del historial (burbujas del mockup).
class _HistoryFooter extends StatelessWidget {
  const _HistoryFooter();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Opacity(
            opacity: 0.2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.bubble_chart_outlined),
                SizedBox(width: 4),
                Icon(Icons.bubble_chart_rounded),
                SizedBox(width: 4),
                Icon(Icons.bubble_chart_outlined),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fin del historial disponible',
            style: textTheme.labelMedium?.copyWith(
              color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
