import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../shared/widgets/soda_header.dart';
import '../../../../../../shared/widgets/stat_tile.dart';
import '../../../providers/shifts_providers.dart';
import '../../../widgets/stats_cards.dart';
import '../stats_empty_card.dart';

/// Estadísticas mobile: columna única con ranking, totales y detalle.
class StatsScreenMobile extends ConsumerWidget {
  const StatsScreenMobile({super.key});

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
              const StatsEmptyCard()
            else ...[
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
                    for (var i = 1; i < ranked.length && i < 3; i++) ...[
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
              TotalSpendCard(totalCop: stats.totalGastoCop(condiciones)),
              const SizedBox(height: 20),
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
