import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../../domain/entities/shifts_state_entity.dart';

/// Card principal del Home: quién compra la gaseosa hoy.
class TodayHeroCard extends StatelessWidget {
  final ShiftsStateEntity data;

  const TodayHeroCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final todayIso = AppDateUtils.toIso(DateTime.now());
    final isWeekend = AppDateUtils.weekdayIndex(todayIso) < 0;
    final day = data.asignacionDe('gaseosa', todayIso);
    final buyerId = isWeekend ? null : day?.participanteId;
    final buyerName = buyerId != null ? data.nameOf(buyerId) : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: const BoxDecoration(
              color: AppTheme.mint,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            child: Text(
              isWeekend
                  ? 'Fin de semana'
                  : buyerName != null
                  ? 'Hoy le toca a…'
                  : 'Hoy sin asignar',
              style: textTheme.labelLarge?.copyWith(
                color: AppTheme.onMint,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isWeekend
                ? '¡Nos vemos el lunes!'
                : buyerName ?? 'Genera la semana ✨',
            style: textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (buyerName != null) ...[
                InitialsAvatar(
                  name: buyerName,
                  size: 52,
                  ringColor: Colors.white.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: const BoxDecoration(
                    color: AppTheme.mint,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                  child: Text(
                    'Gaseosa',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppTheme.onMint,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ] else
                Text(
                  isWeekend
                      ? 'La rotación descansa sábado y domingo.'
                      : 'Usa "Generar Semana" para repartir los turnos.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
            ],
          ),
          if (!isWeekend && day?.warning != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.mint,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    day!.warning!,
                    style: textTheme.bodySmall?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
