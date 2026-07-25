import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../../domain/entities/shifts_state_entity.dart';

enum _Variant { mobile, web }

/// Card principal del Home: quién compra la gaseosa hoy.
/// Default = mobile; `.web` = hero grande con gradiente indigo del mockup
/// de design/web (badge "TURNO DE HOY", avatar 128 con ring mint, nombre en
/// display).
class TodayHeroCard extends StatelessWidget {
  final ShiftsStateEntity data;
  final _Variant _variant;

  const TodayHeroCard({super.key, required this.data})
    : _variant = _Variant.mobile;

  const TodayHeroCard.web({super.key, required this.data})
    : _variant = _Variant.web;

  @override
  Widget build(BuildContext context) {
    final todayIso = AppDateUtils.toIso(DateTime.now());
    final isWeekend = AppDateUtils.weekdayIndex(todayIso) < 0;
    final day = data.asignacionDe('gaseosa', todayIso);
    final buyerId = isWeekend ? null : day?.participanteId;
    final buyerName = buyerId != null ? data.nameOf(buyerId) : null;

    return switch (_variant) {
      _Variant.mobile => _buildMobile(
        context,
        todayIso: todayIso,
        isWeekend: isWeekend,
        buyerName: buyerName,
        warning: isWeekend ? null : day?.warning,
      ),
      _Variant.web => _buildWeb(
        context,
        todayIso: todayIso,
        isWeekend: isWeekend,
        buyerName: buyerName,
        warning: isWeekend ? null : day?.warning,
      ),
    };
  }

  Widget _buildMobile(
    BuildContext context, {
    required String todayIso,
    required bool isWeekend,
    required String? buyerName,
    required String? warning,
  }) {
    final textTheme = Theme.of(context).textTheme;
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
          _MintBadge(
            text: isWeekend
                ? 'Fin de semana'
                : buyerName != null
                ? 'Hoy le toca a…'
                : 'Hoy sin asignar',
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
                const _MintBadge(text: 'Gaseosa'),
              ] else
                Expanded(
                  child: Text(
                    isWeekend
                        ? 'La rotación descansa sábado y domingo.'
                        : 'Usa "Generar Semana" para repartir los turnos.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
            ],
          ),
          if (warning != null) _WarningRow(warning: warning),
        ],
      ),
    );
  }

  /// Hero del mockup web: gradiente indigo, avatar 128 con ring mint y
  /// nombre en display. El CTA real ("Generar hasta hoy") vive en el sidebar.
  Widget _buildWeb(
    BuildContext context, {
    required String todayIso,
    required bool isWeekend,
    required String? buyerName,
    required String? warning,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          if (buyerName != null) ...[
            Stack(
              clipBehavior: Clip.none,
              children: [
                InitialsAvatar(
                  name: buyerName,
                  size: 128,
                  ringColor: AppTheme.mint,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppTheme.mint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_drink,
                      size: 18,
                      color: AppTheme.onMint,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 32),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MintBadge(
                  text: isWeekend ? 'FIN DE SEMANA' : 'TURNO DE HOY',
                  uppercase: true,
                ),
                const SizedBox(height: 16),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isWeekend
                        ? '¡Nos vemos el lunes!'
                        : buyerName ?? 'Genera la semana ✨',
                    style: textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        buyerName != null
                            ? '${AppDateUtils.dayLabel(todayIso)} · le toca la gaseosa'
                            : isWeekend
                            ? 'La rotación descansa sábado y domingo.'
                            : 'Usa "Generar hasta hoy" en el panel lateral.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ],
                ),
                if (warning != null) _WarningRow(warning: warning),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MintBadge extends StatelessWidget {
  final String text;
  final bool uppercase;

  const _MintBadge({required this.text, this.uppercase = false});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: const BoxDecoration(
        color: AppTheme.mint,
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Text(
        text,
        style: textTheme.labelLarge?.copyWith(
          color: AppTheme.onMint,
          fontWeight: FontWeight.w700,
          letterSpacing: uppercase ? 1.2 : null,
        ),
      ),
    );
  }
}

class _WarningRow extends StatelessWidget {
  final String warning;

  const _WarningRow({required this.warning});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.mint,
            size: 18,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              warning,
              style: textTheme.bodySmall?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
