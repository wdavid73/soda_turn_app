import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../../domain/entities/day_assignment_entity.dart';
import '../../domain/entities/turnos_state_entity.dart';

/// Ticket de un día hábil: asignado de gaseosa + presentes + lock/warning.
/// El día de hoy se resalta en mint con el badge "TURNO" (como en el mockup).
class DayCard extends StatelessWidget {
  final TurnosStateEntity data;
  final String dayIso;
  final String? vasosId;
  final VoidCallback? onTap;
  final VoidCallback? onToggleLock;

  const DayCard({
    super.key,
    required this.data,
    required this.dayIso,
    this.vasosId,
    this.onTap,
    this.onToggleLock,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isToday = AppDateUtils.isToday(dayIso);
    final day = data.assignments[dayIso] ?? const DayAssignmentEntity();
    final present =
        day.present.isNotEmpty || data.assignments.containsKey(dayIso)
        ? day.present
        : data.activeIds;
    final buyerName = day.gaseosa != null ? data.nameOf(day.gaseosa) : null;

    final onCard = isToday ? AppTheme.onMint : AppTheme.onSurface;

    return Material(
      color: isToday ? AppTheme.mint : AppTheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      elevation: isToday ? 2 : 1,
      shadowColor: AppTheme.primary.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  buyerName != null
                      ? InitialsAvatar(
                          name: buyerName,
                          size: 48,
                          ringColor: isToday ? AppTheme.onMint : AppTheme.mint,
                        )
                      : Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isToday
                                ? Colors.white.withValues(alpha: 0.5)
                                : AppTheme.surfaceContainerHigh,
                          ),
                          child: const Icon(
                            Icons.person_search_outlined,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              AppDateUtils.dayLabel(dayIso),
                              style: textTheme.labelLarge?.copyWith(
                                color: isToday
                                    ? AppTheme.onMint
                                    : AppTheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (isToday) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'TURNO',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: AppTheme.onMint,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          buyerName ?? 'Sin asignar',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: buyerName != null
                                ? onCard
                                : AppTheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (day.warning != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Tooltip(
                        message: day.warning!,
                        triggerMode: TooltipTriggerMode.tap,
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: AppTheme.error,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: onToggleLock,
                    tooltip: day.locked ? 'Desbloquear' : 'Bloquear',
                    icon: Icon(
                      day.locked ? Icons.lock : Icons.lock_open_outlined,
                      color: day.locked
                          ? (isToday ? AppTheme.onMint : AppTheme.primary)
                          : AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'PRESENTES',
                style: textTheme.labelSmall?.copyWith(
                  color: isToday
                      ? AppTheme.onMint.withValues(alpha: 0.8)
                      : AppTheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final id in present)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isToday
                            ? Colors.white.withValues(alpha: 0.6)
                            : AppTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        // 🥤 marca a quien lleva los vasos esta semana.
                        id == vasosId
                            ? '🥤 ${data.nameOf(id)}'
                            : data.nameOf(id),
                        style: textTheme.labelMedium?.copyWith(
                          color: AppTheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (present.isEmpty)
                    Text(
                      'Nadie marcado aún',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
