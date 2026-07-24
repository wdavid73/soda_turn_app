import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../../../../shared/widgets/soda_header.dart';
import '../../domain/entities/shifts_state_entity.dart';
import '../../domain/usecases/compute_history_usecase.dart';
import '../providers/shifts_providers.dart';

/// Historial: semanas completadas agrupadas por mes, con las asignaciones de
/// cada día y el resumen del mes. La búsqueda del mockup no existe todavía en
/// el dominio, así que el botón solo avisa "Próximamente...".
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.history_rounded,
                        size: 40,
                        color: AppTheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aún no hay semanas completadas. Cuando termine la '
                        'primera semana aparecerá aquí.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              _MonthFilterChips(
                groups: groups,
                selectedKey: _selectedMonthKey,
                onSelected: (key) => setState(() => _selectedMonthKey = key),
              ),
              const SizedBox(height: 20),
              for (final group in visibles) ...[
                _MonthSection(group: group, data: ui.data),
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

/// Sección de un mes: encabezado, panel resumen y acordeones por semana.
class _MonthSection extends StatelessWidget {
  final HistoryMonthGroup group;
  final ShiftsStateEntity data;

  const _MonthSection({required this.group, required this.data});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final n = group.weeks.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  group.label.toUpperCase(),
                  style: textTheme.labelLarge?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Text(
                n == 1 ? '1 semana registrada' : '$n semanas registradas',
                style: textTheme.labelMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _MonthSummaryPanel(group: group),
        const SizedBox(height: 12),
        for (var i = 0; i < group.weeks.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _WeekAccordionCard(
            week: group.weeks[i],
            data: data,
            highlighted: i == 0,
          ),
        ],
      ],
    );
  }
}

/// Resumen del mes: gaseosas, vasos y gasto (el mockup muestra "deuda", que
/// no existe en el dominio; el gasto sí es computable con `costoCop`).
class _MonthSummaryPanel extends StatelessWidget {
  final HistoryMonthGroup group;

  const _MonthSummaryPanel({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.mint.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          _SummaryItem(
            value: '${group.conteoDe('gaseosa')}',
            label: 'Refrescos',
            color: AppTheme.primary,
          ),
          Container(width: 1, height: 40, color: AppTheme.outlineVariant),
          _SummaryItem(
            value: '${group.conteoDe('vasos')}',
            label: 'Vasos',
            color: AppTheme.secondary,
          ),
          Container(width: 1, height: 40, color: AppTheme.outlineVariant),
          _SummaryItem(
            value: formatCop(group.gastoCop),
            label: 'Gasto',
            color: AppTheme.onSurface,
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _SummaryItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: AppTheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Acordeón de una semana: encabezado con número/rango y, expandido, las
/// asignaciones diarias, el producto semanal y el botón "Ver semana".
class _WeekAccordionCard extends ConsumerWidget {
  final HistoryWeekItem week;
  final ShiftsStateEntity data;

  /// La semana más reciente del mes lleva el tile en mint, como el mockup.
  final bool highlighted;

  const _WeekAccordionCard({
    required this.week,
    required this.data,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // Sin divisores arriba/abajo del ExpansionTile.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: highlighted
                  ? AppTheme.mint
                  : AppTheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_month,
              color: highlighted ? AppTheme.onMint : AppTheme.onSurfaceVariant,
            ),
          ),
          title: Text(
            'Semana ${week.weekNumber}',
            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            AppDateUtils.weekRangeLabel(week.monday),
            style: textTheme.labelMedium?.copyWith(
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          children: [
            for (final entry in week.semanales.entries)
              if (entry.value != null)
                _WeeklyProductRow(
                  productoNombre: _productoNombre(entry.key),
                  participantName: data.nameOf(entry.value),
                ),
            for (final dia in week.dias)
              _DayEntryRow(
                dayIso: dia.dayIso,
                participantName: dia.participanteId == null
                    ? null
                    : data.nameOf(dia.participanteId),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  ref
                      .read(turnosViewModelProvider.notifier)
                      .selectMonday(week.monday);
                  context.go('/week');
                },
                icon: const Text('Ver semana'),
                label: const Icon(Icons.arrow_forward, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _productoNombre(String productoId) {
    for (final p in data.productos) {
      if (p.id == productoId) return p.nombre;
    }
    return productoId;
  }
}

/// Fila del producto semanal (ej. "Vasos de la semana").
class _WeeklyProductRow extends StatelessWidget {
  final String productoNombre;
  final String participantName;

  const _WeeklyProductRow({
    required this.productoNombre,
    required this.participantName,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFD8F3FA),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.coffee_outlined,
              size: 18,
              color: AppTheme.tertiary,
            ),
          ),
          const SizedBox(width: 8),
          InitialsAvatar(name: participantName, size: 32),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              participantName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '$productoNombre de la semana',
            style: textTheme.labelSmall?.copyWith(
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila de un día: chip del día (LU/MA/...), avatar, nombre e icono del
/// producto diario.
class _DayEntryRow extends StatelessWidget {
  final String dayIso;
  final String? participantName;

  const _DayEntryRow({required this.dayIso, required this.participantName});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final idx = AppDateUtils.weekdayIndex(dayIso);
    final dayChip = idx >= 0
        ? AppDateUtils.dayNamesShort[idx].substring(0, 2).toUpperCase()
        : '??';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFDEE0FF), // primary-fixed del design system
              shape: BoxShape.circle,
            ),
            child: Text(
              dayChip,
              style: textTheme.labelSmall?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (participantName == null)
            Expanded(
              child: Text(
                'Sin asignación',
                style: textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else ...[
            InitialsAvatar(name: participantName!, size: 32),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                participantName!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.local_drink_outlined,
              size: 20,
              color: AppTheme.primary,
            ),
          ],
        ],
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
