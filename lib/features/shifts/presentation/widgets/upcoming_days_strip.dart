import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../../domain/entities/shifts_state_entity.dart';

/// Franja Lun–Vie con el asignado de gaseosa de cada día.
class UpcomingDaysStrip extends StatelessWidget {
  final ShiftsStateEntity data;
  final String mondayIso;

  const UpcomingDaysStrip({
    super.key,
    required this.data,
    required this.mondayIso,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final days = AppDateUtils.weekDays(mondayIso);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Row(
        children: [
          for (var i = 0; i < days.length; i++)
            Expanded(
              child: Column(
                children: [
                  Text(
                    AppDateUtils.dayNamesShort[i],
                    style: textTheme.labelLarge?.copyWith(
                      color: AppDateUtils.isToday(days[i])
                          ? AppTheme.primary
                          : AppTheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _dayAvatar(days[i]),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _dayAvatar(String dayIso) {
    final buyerId = data.asignacionDe('gaseosa', dayIso)?.participanteId;
    final isToday = AppDateUtils.isToday(dayIso);
    if (buyerId == null) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.surfaceContainerHigh,
          border: isToday
              ? Border.all(color: AppTheme.primary, width: 2)
              : null,
        ),
        child: const Icon(
          Icons.person_search_outlined,
          size: 20,
          color: AppTheme.onSurfaceVariant,
        ),
      );
    }
    return InitialsAvatar(
      name: data.nameOf(buyerId),
      size: isToday ? 38 : 44,
      ringColor: isToday ? AppTheme.primary : null,
    );
  }
}
