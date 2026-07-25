import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../../domain/entities/shifts_state_entity.dart';
import '../../domain/usecases/compute_history_usecase.dart';
import '../providers/shifts_providers.dart';

enum _Variant { mobile, web }

/// Sección de un mes del historial: encabezado, panel resumen y acordeones
/// por semana. Default = mobile (filas por día); `.web` = el acordeón
/// expandido muestra un grid Lun–Vie como el mockup de design/web.
class HistoryMonthSection extends StatelessWidget {
  final HistoryMonthGroup group;
  final ShiftsStateEntity data;
  final _Variant _variant;

  const HistoryMonthSection({
    super.key,
    required this.group,
    required this.data,
  }) : _variant = _Variant.mobile;

  const HistoryMonthSection.web({
    super.key,
    required this.group,
    required this.data,
  }) : _variant = _Variant.web;

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
            webGrid: _variant == _Variant.web,
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
/// asignaciones (filas en mobile, grid Lun–Vie en web) y "Ver semana".
class _WeekAccordionCard extends ConsumerWidget {
  final HistoryWeekItem week;
  final ShiftsStateEntity data;

  /// La semana más reciente del mes lleva el tile en mint, como el mockup.
  final bool highlighted;

  /// `true` en la variante web: el contenido expandido es el grid Lun–Vie.
  final bool webGrid;

  const _WeekAccordionCard({
    required this.week,
    required this.data,
    required this.highlighted,
    required this.webGrid,
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
            if (webGrid)
              _WeekDaysGrid(week: week, data: data)
            else
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

/// Grid Lun–Vie del acordeón expandido (mockup web): chip del día, avatar,
/// nombre y chip "GASEOSA".
class _WeekDaysGrid extends StatelessWidget {
  final HistoryWeekItem week;
  final ShiftsStateEntity data;

  const _WeekDaysGrid({required this.week, required this.data});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < week.dias.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(
              child: _WebDayCell(
                dayIso: week.dias[i].dayIso,
                participantName: week.dias[i].participanteId == null
                    ? null
                    : data.nameOf(week.dias[i].participanteId),
                textTheme: textTheme,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WebDayCell extends StatelessWidget {
  final String dayIso;
  final String? participantName;
  final TextTheme textTheme;

  const _WebDayCell({
    required this.dayIso,
    required this.participantName,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    final idx = AppDateUtils.weekdayIndex(dayIso);
    final dayLabel = idx >= 0
        ? AppDateUtils.dayNamesShort[idx].toUpperCase()
        : '??';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            dayLabel,
            style: textTheme.labelSmall?.copyWith(
              color: AppTheme.onSurfaceVariant,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (participantName == null)
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceContainerHigh,
              ),
              child: const Icon(
                Icons.person_outline,
                size: 20,
                color: AppTheme.onSurfaceVariant,
              ),
            )
          else
            InitialsAvatar(name: participantName!, size: 40),
          const SizedBox(height: 8),
          Text(
            participantName ?? 'Sin asignar',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: participantName != null
                  ? AppTheme.onSurface
                  : AppTheme.onSurfaceVariant,
            ),
          ),
          if (participantName != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.mint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'GASEOSA',
                style: textTheme.labelSmall?.copyWith(
                  color: AppTheme.onMint,
                  fontWeight: FontWeight.w800,
                  fontSize: 9,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ],
      ),
    );
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

/// Fila de un día (mobile): chip del día (LU/MA/...), avatar, nombre e icono
/// del producto diario.
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
