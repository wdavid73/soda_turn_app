import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/app_date_utils.dart';
import '../../../../../../shared/widgets/soda_header.dart';
import '../../../providers/shifts_providers.dart';
import '../../../widgets/day_card.dart';
import '../../../widgets/day_edit_sheet.dart';
import '../../../widgets/cups_edit_sheet.dart';
import '../../../widgets/cups_week_card.dart';
import '../week_nav_label.dart';

/// Semana mobile: lista vertical de tickets diarios con FAB de generar.
class WeekScreenMobile extends ConsumerWidget {
  const WeekScreenMobile({super.key});

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
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab-week',
        tooltip: 'Generar hasta hoy',
        onPressed: () {
          vm.generateToday();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Turnos generados hasta hoy 🥤')),
          );
        },
        child: const Icon(Icons.refresh),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            const SodaHeader(),
            const SizedBox(height: 24),
            Text(
              'Esta Semana',
              style: textTheme.headlineMedium?.copyWith(
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
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  onPressed: vm.goPreviousWeek,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: WeekNavLabel(
                    mondayIso: mondayIso,
                    isCurrentWeek: isCurrentWeek,
                    onBackToCurrent: vm.goCurrentWeek,
                  ),
                ),
                IconButton(
                  onPressed: vm.goNextWeek,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CupsWeekCard(
              data: ui.data,
              mondayIso: mondayIso,
              onTap: () => showCupsEditSheet(context),
              onToggleLock: () => vm.toggleLock('vasos', mondayIso),
            ),
            const SizedBox(height: 12),
            for (final dayIso in AppDateUtils.weekDays(mondayIso)) ...[
              DayCard(
                data: ui.data,
                dayIso: dayIso,
                vasosId: vasosId,
                onTap: () => showDayEditSheet(context, dayIso),
                onToggleLock: () => vm.toggleLock('gaseosa', dayIso),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
