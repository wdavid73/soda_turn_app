import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../../domain/entities/participant_entity.dart';
import '../../domain/entities/product_condition_entity.dart';
import '../../domain/entities/shifts_stats.dart';

/// Cards de Estadísticas compartidas por las versiones mobile y web (se ven
/// igual en ambas plataformas, así que no llevan variante `.web`).

/// Card del #1 del ranking de aportes.
class TopContributorCard extends StatelessWidget {
  final String name;
  final int total;

  const TopContributorCard({super.key, required this.name, required this.total});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Row(
        children: [
          InitialsAvatar(name: name, size: 52, ringColor: AppTheme.mint),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#1 · Más aportes',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppTheme.mint,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  name,
                  style: textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                '$total',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppTheme.mint,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'turnos',
                style: textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card de los puestos #2 y #3 del ranking.
class RunnerUpCard extends StatelessWidget {
  final int position;
  final String name;
  final int total;

  const RunnerUpCard({
    super.key,
    required this.position,
    required this.name,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        children: [
          InitialsAvatar(name: name, size: 40),
          const SizedBox(height: 8),
          Text(
            '#$position $name',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            '$total turnos',
            style: textTheme.titleMedium?.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card del gasto total aproximado.
class TotalSpendCard extends StatelessWidget {
  final int totalCop;

  const TotalSpendCard({super.key, required this.totalCop});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gasto total aproximado',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatCop(totalCop),
              style: textTheme.displaySmall?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$7.000 por día de gaseosa asignado. '
              'Los vasos se cuentan por frecuencia, no en dinero.',
              style: textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card "Detalle por persona": conteos y gasto de cada participante.
class StatsBreakdownCard extends StatelessWidget {
  final List<ParticipantEntity> ranked;
  final ShiftsStats stats;
  final Map<String, ProductConditionEntity> condiciones;

  const StatsBreakdownCard({
    super.key,
    required this.ranked,
    required this.stats,
    required this.condiciones,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            for (final p in ranked)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    InitialsAvatar(name: p.name, size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${stats.countOf('gaseosa', p.id)} días de '
                            'gaseosa · ${stats.countOf('vasos', p.id)} '
                            'semanas de vasos',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatCop(stats.gastoCopOf(p.id, condiciones)),
                      style: textTheme.titleSmall?.copyWith(
                        color: AppTheme.secondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
