import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../shared/widgets/stat_tile.dart';
import '../../../../../../shared/widgets/web_top_bar.dart';
import '../../../providers/shifts_providers.dart';
import '../../../widgets/stats_cards.dart';
import '../stats_empty_card.dart';

/// Estadísticas web: dashboard de dos columnas del mockup de design/web —
/// ranking a la izquierda, totales y gasto a la derecha, detalle abajo.
class StatsScreenWeb extends ConsumerWidget {
  const StatsScreenWeb({super.key});

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
          padding: const EdgeInsets.all(32),
          children: [
            const WebTopBar(),
            Text(
              'Estadísticas',
              style: textTheme.headlineLarge?.copyWith(
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
            const SizedBox(height: 24),
            if (!hasHistory)
              const StatsEmptyCard()
            else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ranking de aportes',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (ranked.isNotEmpty)
                          TopContributorCard(
                            name: ranked.first.name,
                            total: stats.totalOf(ranked.first.id),
                          ),
                        const SizedBox(height: 12),
                        if (ranked.length > 1)
                          Row(
                            children: [
                              for (
                                var i = 1;
                                i < ranked.length && i < 3;
                                i++
                              ) ...[
                                if (i > 1) const SizedBox(width: 12),
                                Expanded(
                                  child: RunnerUpCard(
                                    position: i + 1,
                                    name: ranked[i].name,
                                    total: stats.totalOf(ranked[i].id),
                                  ),
                                ),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        StatTile.web(
                          label: 'Total Gaseosas',
                          value: '${stats.totalDe('gaseosa')}',
                          background: const Color(0xFFDFF3E4),
                          foreground: AppTheme.secondary,
                          icon: Icons.local_drink_outlined,
                        ),
                        const SizedBox(height: 12),
                        StatTile.web(
                          label: 'Total Vasos',
                          value: '${stats.totalDe('vasos')}',
                          background: const Color(0xFFD8F3FA),
                          foreground: AppTheme.tertiary,
                          icon: Icons.coffee_outlined,
                        ),
                        const SizedBox(height: 12),
                        TotalSpendCard(
                          totalCop: stats.totalGastoCop(condiciones),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Detalle por persona',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              StatsBreakdownCard(
                ranked: ranked,
                stats: stats,
                condiciones: condiciones,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
