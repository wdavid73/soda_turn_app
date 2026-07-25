import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/currency_utils.dart';
import '../../../../../../shared/widgets/initials_avatar.dart';
import '../../../../../../shared/widgets/web_top_bar.dart';
import '../../../../domain/entities/shifts_state_entity.dart';
import '../../../../domain/entities/shifts_stats.dart';
import '../../../../domain/usecases/compute_history_usecase.dart';
import '../../../providers/shifts_providers.dart';
import '../../../widgets/history_month_section.dart';
import '../history_empty_card.dart';

/// Historial web: layout de dos columnas del mockup de design/web —
/// secciones por mes a la izquierda y panel lateral con resumen y
/// tendencias (con datos reales) a la derecha.
class HistoryScreenWeb extends ConsumerWidget {
  const HistoryScreenWeb({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final ui = ref.watch(turnosViewModelProvider);
    final groups = ref.watch(turnosHistoryProvider);
    final stats = ref.watch(turnosStatsProvider);

    if (ui.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            const WebTopBar(),
            Text(
              'Historial de rotación',
              style: textTheme.headlineLarge?.copyWith(
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
            const SizedBox(height: 24),
            if (groups.isEmpty)
              const HistoryEmptyCard()
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final group in groups) ...[
                          HistoryMonthSection.web(
                            group: group,
                            data: ui.data,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        _TotalsCard(groups: groups),
                        const SizedBox(height: 16),
                        _TrendsCard(data: ui.data, stats: stats),
                        const SizedBox(height: 16),
                        const _InfoCard(),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Card indigo del panel lateral: total de semanas registradas y gasto
/// acumulado de todo el historial (reemplaza el "fairness score" ficticio
/// del mockup con datos reales).
class _TotalsCard extends StatelessWidget {
  final List<HistoryMonthGroup> groups;

  const _TotalsCard({required this.groups});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    var weeks = 0;
    var gasto = 0;
    for (final g in groups) {
      weeks += g.weeks.length;
      gasto += g.gastoCop;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rotación acumulada',
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'La rotación justa reparte gaseosa y vasos sin repetir de más.',
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            weeks == 1 ? '1 semana' : '$weeks semanas',
            style: textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            'registradas · ${formatCop(gasto)} en gaseosas',
            style: textTheme.bodyMedium?.copyWith(
              color: AppTheme.mint,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tendencias de aportes: top 3 del ranking real.
class _TrendsCard extends StatelessWidget {
  final ShiftsStateEntity data;
  final ShiftsStats stats;

  const _TrendsCard({required this.data, required this.stats});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ranked = [...data.participants]
      ..sort((a, b) => stats.totalOf(b.id).compareTo(stats.totalOf(a.id)));
    final top = ranked.take(3).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tendencias de aportes',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          for (final p in top)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  InitialsAvatar(name: p.name, size: 36),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${stats.countOf('gaseosa', p.id)} gaseosas · '
                          '${stats.countOf('vasos', p.id)} vasos',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${stats.totalOf(p.id)}',
                    style: textTheme.titleMedium?.copyWith(
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Info-card gris del mockup, con el cierre real del historial.
class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 20,
            color: AppTheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Fin del historial disponible. Las semanas se archivan '
              'automáticamente al terminar y conservan sus asignaciones.',
              style: textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
