import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../../../../shared/widgets/soda_header.dart';
import '../../../../shared/widgets/stat_tile.dart';
import '../providers/shifts_providers.dart';

/// Estadísticas: ranking de aportes, totales y gasto aproximado por persona.
/// El donut "por sabor" del mockup no existe en el dominio (solo se trackea
/// el costo de la gaseosa), así que se muestra el gasto real.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final ui = ref.watch(turnosViewModelProvider);
    final stats = ref.watch(turnosStatsProvider);

    if (ui.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final ranked = [...ui.data.participants]
      ..sort((a, b) => stats.totalOf(b.id).compareTo(stats.totalOf(a.id)));
    final condiciones = ui.data.condiciones;
    final hasHistory = stats.totalDe('gaseosa') + stats.totalDe('vasos') > 0;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            const SodaHeader(),
            const SizedBox(height: 24),
            Text(
              'Estadísticas',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Reparto acumulado de todo el historial.',
              style: textTheme.bodyLarge?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            if (!hasHistory)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.bar_chart_rounded,
                        size: 40,
                        color: AppTheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aún no hay historial. Genera tu primera semana '
                        'para ver el reparto.',
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
              Text(
                'Ranking de aportes',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              if (ranked.isNotEmpty)
                _TopCard(
                  name: ranked.first.name,
                  total: stats.totalOf(ranked.first.id),
                ),
              const SizedBox(height: 12),
              if (ranked.length > 1)
                Row(
                  children: [
                    for (var i = 1; i < ranked.length && i < 3; i++) ...[
                      if (i > 1) const SizedBox(width: 12),
                      Expanded(
                        child: _RunnerUpCard(
                          position: i + 1,
                          name: ranked[i].name,
                          total: stats.totalOf(ranked[i].id),
                        ),
                      ),
                    ],
                  ],
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: 'Total Gaseosas',
                      value: '${stats.totalDe('gaseosa')}',
                      background: const Color(0xFFDFF3E4),
                      foreground: AppTheme.secondary,
                      icon: Icons.local_drink_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                      label: 'Total Vasos',
                      value: '${stats.totalDe('vasos')}',
                      background: const Color(0xFFD8F3FA),
                      foreground: AppTheme.tertiary,
                      icon: Icons.coffee_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
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
                        formatCop(stats.totalGastoCop(condiciones)),
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
              ),
              const SizedBox(height: 20),
              Text(
                'Detalle por persona',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TopCard extends StatelessWidget {
  final String name;
  final int total;

  const _TopCard({required this.name, required this.total});

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

class _RunnerUpCard extends StatelessWidget {
  final int position;
  final String name;
  final int total;

  const _RunnerUpCard({
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
