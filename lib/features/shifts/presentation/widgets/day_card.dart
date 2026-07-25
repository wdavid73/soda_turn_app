import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/utils/colombian_holidays.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../../domain/entities/assignment_entity.dart';
import '../../domain/entities/shifts_state_entity.dart';

enum _Variant { mobile, web }

/// Ticket de un día hábil: asignado de gaseosa + presentes + lock/warning.
/// El día de hoy se resalta en mint con el badge "TURNO".
/// Default = mobile (ticket horizontal); `.web` = columna vertical del grid
/// Lun–Vie del mockup de design/web.
class DayCard extends StatelessWidget {
  final ShiftsStateEntity data;
  final String dayIso;
  final String? vasosId;
  final VoidCallback? onTap;
  final VoidCallback? onToggleLock;
  final _Variant _variant;

  const DayCard({
    super.key,
    required this.data,
    required this.dayIso,
    this.vasosId,
    this.onTap,
    this.onToggleLock,
  }) : _variant = _Variant.mobile;

  const DayCard.web({
    super.key,
    required this.data,
    required this.dayIso,
    this.vasosId,
    this.onTap,
    this.onToggleLock,
  }) : _variant = _Variant.web;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isToday = AppDateUtils.isToday(dayIso);
    final isHoliday = ColombianHolidays.esFestivo(AppDateUtils.parseIso(dayIso));
    final day = data.asignacionDe('gaseosa', dayIso) ?? const AssignmentEntity();
    final present = data.presenciaPorDia.containsKey(dayIso)
        ? data.presentesEn(dayIso)
        : data.activeIds;
    final buyerName =
        day.participanteId != null ? data.nameOf(day.participanteId) : null;

    final onCard = isToday ? AppTheme.onMint : AppTheme.onSurface;

    return Material(
      color: isToday ? AppTheme.mint : AppTheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      elevation: isToday ? 2 : 1,
      shadowColor: AppTheme.primary.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: switch (_variant) {
          _Variant.mobile => _buildMobile(
            textTheme: textTheme,
            isToday: isToday,
            isHoliday: isHoliday,
            day: day,
            present: present,
            buyerName: buyerName,
            onCard: onCard,
          ),
          _Variant.web => _buildWeb(
            textTheme: textTheme,
            isToday: isToday,
            isHoliday: isHoliday,
            day: day,
            present: present,
            buyerName: buyerName,
            onCard: onCard,
          ),
        },
      ),
    );
  }

  /// Ticket horizontal (mobile).
  Widget _buildMobile({
    required TextTheme textTheme,
    required bool isToday,
    required bool isHoliday,
    required AssignmentEntity day,
    required List<String> present,
    required String? buyerName,
    required Color onCard,
  }) {
    return Padding(
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
                          isHoliday
                              ? '🎉 ${AppDateUtils.dayLabel(dayIso)}'
                              : AppDateUtils.dayLabel(dayIso),
                          style: textTheme.labelLarge?.copyWith(
                            color: isToday
                                ? AppTheme.onMint
                                : AppTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 8),
                          _TurnoBadge(textTheme: textTheme),
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
          _PresentesLabel(textTheme: textTheme, isToday: isToday),
          const SizedBox(height: 8),
          _PresentesWrap(
            data: data,
            present: present,
            vasosId: vasosId,
            isToday: isToday,
            textTheme: textTheme,
            centered: false,
          ),
        ],
      ),
    );
  }

  /// Columna vertical del grid Lun–Vie (web).
  Widget _buildWeb({
    required TextTheme textTheme,
    required bool isToday,
    required bool isHoliday,
    required AssignmentEntity day,
    required List<String> present,
    required String? buyerName,
    required Color onCard,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            isHoliday
                ? '🎉 ${AppDateUtils.dayLabel(dayIso)}'
                : AppDateUtils.dayLabel(dayIso),
            textAlign: TextAlign.center,
            style: textTheme.labelLarge?.copyWith(
              color: isToday ? AppTheme.onMint : AppTheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isToday)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: _TurnoBadge(textTheme: textTheme),
            ),
          const SizedBox(height: 12),
          buyerName != null
              ? InitialsAvatar(
                  name: buyerName,
                  size: 72,
                  ringColor: isToday ? AppTheme.onMint : AppTheme.mint,
                )
              : Container(
                  width: 72,
                  height: 72,
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
          const SizedBox(height: 10),
          Text(
            buyerName ?? 'Sin asignar',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: buyerName != null ? onCard : AppTheme.onSurfaceVariant,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (day.warning != null)
                Tooltip(
                  message: day.warning!,
                  triggerMode: TooltipTriggerMode.tap,
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.error,
                    size: 20,
                  ),
                ),
              IconButton(
                onPressed: onToggleLock,
                tooltip: day.locked ? 'Desbloquear' : 'Bloquear',
                iconSize: 20,
                icon: Icon(
                  day.locked ? Icons.lock : Icons.lock_open_outlined,
                  color: day.locked
                      ? (isToday ? AppTheme.onMint : AppTheme.primary)
                      : AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          _PresentesLabel(textTheme: textTheme, isToday: isToday),
          const SizedBox(height: 8),
          _PresentesWrap(
            data: data,
            present: present,
            vasosId: vasosId,
            isToday: isToday,
            textTheme: textTheme,
            centered: true,
          ),
        ],
      ),
    );
  }
}

class _TurnoBadge extends StatelessWidget {
  final TextTheme textTheme;

  const _TurnoBadge({required this.textTheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
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
    );
  }
}

class _PresentesLabel extends StatelessWidget {
  final TextTheme textTheme;
  final bool isToday;

  const _PresentesLabel({required this.textTheme, required this.isToday});

  @override
  Widget build(BuildContext context) {
    return Text(
      'PRESENTES',
      style: textTheme.labelSmall?.copyWith(
        color: isToday
            ? AppTheme.onMint.withValues(alpha: 0.8)
            : AppTheme.onSurfaceVariant,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _PresentesWrap extends StatelessWidget {
  final ShiftsStateEntity data;
  final List<String> present;
  final String? vasosId;
  final bool isToday;
  final TextTheme textTheme;
  final bool centered;

  const _PresentesWrap({
    required this.data,
    required this.present,
    required this.vasosId,
    required this.isToday,
    required this.textTheme,
    required this.centered,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: centered ? 6 : 8,
      runSpacing: centered ? 6 : 8,
      alignment: centered ? WrapAlignment.center : WrapAlignment.start,
      children: [
        for (final id in present)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: centered ? 10 : 12,
              vertical: centered ? 4 : 6,
            ),
            decoration: BoxDecoration(
              color: isToday
                  ? Colors.white.withValues(alpha: 0.6)
                  : AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              // 🥤 marca a quien lleva los vasos esta semana.
              id == vasosId ? '🥤 ${data.nameOf(id)}' : data.nameOf(id),
              style: (centered ? textTheme.labelSmall : textTheme.labelMedium)
                  ?.copyWith(
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
    );
  }
}
