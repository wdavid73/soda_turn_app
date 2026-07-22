import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../domain/entities/shifts_state_entity.dart';

/// Progreso de la semana: días de gaseosa ya asignados sobre 5.
class WeekProgressCard extends StatelessWidget {
  final ShiftsStateEntity data;
  final String mondayIso;

  const WeekProgressCard({
    super.key,
    required this.data,
    required this.mondayIso,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final days = AppDateUtils.weekDays(mondayIso);
    final assigned = days
        .where((d) => data.asignacionDe('gaseosa', d)?.participanteId != null)
        .length;
    final progress = assigned / days.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progreso semanal',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: AppTheme.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation(AppTheme.mint),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$assigned de ${days.length} días asignados',
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
