import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../../domain/entities/shifts_state_entity.dart';

enum _Variant { mobile, web }

/// Franja Lun–Vie con el asignado de gaseosa de cada día.
/// Default = mobile (franja compacta); `.web` = card "Próximos días" del
/// mockup de design/web con 5 tiles de día.
class UpcomingDaysStrip extends StatelessWidget {
  final ShiftsStateEntity data;
  final String mondayIso;
  final _Variant _variant;

  const UpcomingDaysStrip({
    super.key,
    required this.data,
    required this.mondayIso,
  }) : _variant = _Variant.mobile;

  const UpcomingDaysStrip.web({
    super.key,
    required this.data,
    required this.mondayIso,
  }) : _variant = _Variant.web;

  @override
  Widget build(BuildContext context) => switch (_variant) {
    _Variant.mobile => _buildMobile(context),
    _Variant.web => _buildWeb(context),
  };

  Widget _buildMobile(BuildContext context) {
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
                  _dayAvatar(days[i], compact: true),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Card blanca del mockup: título + 5 tiles de día con nombre.
  Widget _buildWeb(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final days = AppDateUtils.weekDays(mondayIso);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Próximos días',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < days.length; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  Expanded(child: _webDayTile(context, i, days[i])),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _webDayTile(BuildContext context, int index, String dayIso) {
    final textTheme = Theme.of(context).textTheme;
    final isToday = AppDateUtils.isToday(dayIso);
    final buyerId = data.asignacionDe('gaseosa', dayIso)?.participanteId;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isToday
            ? AppTheme.mint.withValues(alpha: 0.25)
            : AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            AppDateUtils.dayNamesShort[index].toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: isToday ? AppTheme.onMint : AppTheme.onSurfaceVariant,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _dayAvatar(dayIso, compact: false),
          const SizedBox(height: 8),
          Text(
            buyerId != null ? data.nameOf(buyerId) : 'Sin asignar',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: buyerId != null
                  ? AppTheme.onSurface
                  : AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayAvatar(String dayIso, {required bool compact}) {
    final buyerId = data.asignacionDe('gaseosa', dayIso)?.participanteId;
    final isToday = AppDateUtils.isToday(dayIso);
    final size = compact ? 44.0 : 48.0;
    if (buyerId == null) {
      return Container(
        width: size,
        height: size,
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
      size: compact && isToday ? 38 : size,
      ringColor: isToday ? AppTheme.primary : null,
    );
  }
}
