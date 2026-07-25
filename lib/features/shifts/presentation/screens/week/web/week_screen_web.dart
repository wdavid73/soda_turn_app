import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/app_date_utils.dart';
import '../../../../../../shared/widgets/web_top_bar.dart';
import '../../../providers/shifts_providers.dart';
import '../../../widgets/day_card.dart';
import '../../../widgets/day_edit_sheet.dart';
import '../../../widgets/cups_edit_sheet.dart';
import '../../../widgets/cups_week_card.dart';
import '../week_nav_label.dart';

/// Semana web: planeación semanal del mockup de design/web — header con la
/// navegación de semanas, card de vasos y grid Lun–Vie de 5 columnas.
class WeekScreenWeb extends ConsumerWidget {
  const WeekScreenWeb({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final ui = ref.watch(turnosViewModelProvider);
    final vm = ref.read(turnosViewModelProvider.notifier);
    final mondayIso = ui.selectedMonday;
    final isCurrentWeek =
        mondayIso == AppDateUtils.activeMondayIso(DateTime.now());
    final vasosId = ui.data.asignacionDe('vasos', mondayIso)?.participanteId;

    if (ui.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            const WebTopBar(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Planeación semanal',
                        style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gestión de turnos y presencia del equipo.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: vm.goPreviousWeek,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    WeekNavLabel(
                      mondayIso: mondayIso,
                      isCurrentWeek: isCurrentWeek,
                      onBackToCurrent: vm.goCurrentWeek,
                    ),
                    IconButton(
                      onPressed: vm.goNextWeek,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, dayIso)
                    in AppDateUtils.weekDays(mondayIso).indexed) ...[
                  if (i > 0) const SizedBox(width: 16),
                  Expanded(
                    child: DayCard.web(
                      data: ui.data,
                      dayIso: dayIso,
                      vasosId: vasosId,
                      onTap: () => showDayEditSheet(context, dayIso),
                      onToggleLock: () => vm.toggleLock('gaseosa', dayIso),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            CupsWeekCard.web(
              data: ui.data,
              mondayIso: mondayIso,
              onTap: () => showCupsEditSheet(context),
              onToggleLock: () => vm.toggleLock('vasos', mondayIso),
            ),
          ],
        ),
      ),
    );
  }
}
