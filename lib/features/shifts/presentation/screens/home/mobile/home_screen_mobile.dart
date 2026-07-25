import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/utils/app_date_utils.dart';
import '../../../../../../shared/widgets/soda_header.dart';
import '../../../providers/shifts_providers.dart';
import '../../../widgets/today_hero_card.dart';
import '../../../widgets/upcoming_days_strip.dart';
import '../../../widgets/cups_week_card.dart';
import '../../../widgets/week_progress_card.dart';

/// Home mobile: columna única con header de marca y FAB de generar.
/// Siempre muestra la semana "activa" (la actual, o la entrante en finde).
class HomeScreenMobile extends ConsumerWidget {
  const HomeScreenMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final ui = ref.watch(turnosViewModelProvider);
    final vm = ref.read(turnosViewModelProvider.notifier);
    final mondayIso = AppDateUtils.activeMondayIso(DateTime.now());

    if (ui.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-home',
        onPressed: () {
          vm.goCurrentWeek();
          vm.generateToday();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Turnos generados hasta hoy 🥤')),
          );
        },
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Generar hasta hoy'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            const SodaHeader(),
            const SizedBox(height: 24),
            Text(
              '¡Hola, Equipo!',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '¿Listos para la rotación de hoy?',
              style: textTheme.bodyLarge?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            TodayHeroCard(data: ui.data),
            const SizedBox(height: 12),
            CupsWeekCard(data: ui.data, mondayIso: mondayIso),
            const SizedBox(height: 24),
            Text(
              'Próximos días',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            UpcomingDaysStrip(data: ui.data, mondayIso: mondayIso),
            const SizedBox(height: 12),
            WeekProgressCard(data: ui.data, mondayIso: mondayIso),
          ],
        ),
      ),
    );
  }
}
