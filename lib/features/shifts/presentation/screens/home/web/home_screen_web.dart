import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/app_date_utils.dart';
import '../../../../../../core/utils/currency_utils.dart';
import '../../../../../../shared/widgets/stat_tile.dart';
import '../../../../../../shared/widgets/web_top_bar.dart';
import '../../../providers/shifts_providers.dart';
import '../../../widgets/today_hero_card.dart';
import '../../../widgets/upcoming_days_strip.dart';
import '../../../widgets/cups_week_card.dart';
import '../../../widgets/week_progress_card.dart';

/// Home web: bento grid del mockup de design/web — hero del turno de hoy,
/// MVP de vasos, próximos días, progreso y fila de métricas.
class HomeScreenWeb extends ConsumerWidget {
  const HomeScreenWeb({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final ui = ref.watch(turnosViewModelProvider);
    final stats = ref.watch(turnosStatsProvider);
    final mondayIso = AppDateUtils.activeMondayIso(DateTime.now());

    if (ui.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final ranked = [...ui.data.participants]
      ..sort((a, b) => stats.totalOf(b.id).compareTo(stats.totalOf(a.id)));
    final top = ranked.isNotEmpty ? ranked.first : null;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            const WebTopBar(),
            Text(
              '¡Hola, Equipo! 👋',
              style: textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '¿Listos para la rotación de hoy? Esta es la logística del día.',
              style: textTheme.bodyLarge?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 8,
                  child: TodayHeroCard.web(data: ui.data),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 4,
                  child: CupsWeekCard.web(data: ui.data, mondayIso: mondayIso),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 8,
                  child: UpcomingDaysStrip.web(
                    data: ui.data,
                    mondayIso: mondayIso,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 4,
                  child: WeekProgressCard.web(
                    data: ui.data,
                    mondayIso: mondayIso,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: StatTile.web(
                    label: 'Top aportador',
                    value: top != null && stats.totalOf(top.id) > 0
                        ? top.name
                        : '—',
                    background: const Color(0xFFDEE0FF),
                    foreground: AppTheme.primary,
                    icon: Icons.emoji_events_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatTile.web(
                    label: 'Activos',
                    value: '${ui.data.activeParticipants.length}',
                    background: const Color(0xFFDFF3E4),
                    foreground: AppTheme.secondary,
                    icon: Icons.people_outline,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatTile.web(
                    label: 'Turnos totales',
                    value:
                        '${stats.totalDe('gaseosa') + stats.totalDe('vasos')}',
                    background: const Color(0xFFD8F3FA),
                    foreground: AppTheme.tertiary,
                    icon: Icons.local_drink_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatTile.web(
                    label: 'Gasto total',
                    value: formatCop(stats.totalGastoCop(ui.data.condiciones)),
                    background: const Color(0xFFFFE9DC),
                    foreground: AppTheme.tertiaryContainer,
                    icon: Icons.payments_outlined,
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
