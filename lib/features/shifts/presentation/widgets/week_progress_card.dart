import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../domain/entities/shifts_state_entity.dart';

enum _Variant { mobile, web }

/// Progreso de la semana: días de gaseosa ya asignados sobre 5.
/// Default = mobile; `.web` = card "Progreso semanal" del mockup con chip
/// mint, barra gruesa y filas de métricas reales.
class WeekProgressCard extends StatelessWidget {
  final ShiftsStateEntity data;
  final String mondayIso;
  final _Variant _variant;

  const WeekProgressCard({
    super.key,
    required this.data,
    required this.mondayIso,
  }) : _variant = _Variant.mobile;

  const WeekProgressCard.web({
    super.key,
    required this.data,
    required this.mondayIso,
  }) : _variant = _Variant.web;

  @override
  Widget build(BuildContext context) {
    final days = AppDateUtils.weekDays(mondayIso);
    final assigned = days
        .where((d) => data.asignacionDe('gaseosa', d)?.participanteId != null)
        .length;
    final progress = assigned / days.length;

    return switch (_variant) {
      _Variant.mobile => _buildMobile(context, assigned, days.length, progress),
      _Variant.web => _buildWeb(context, assigned, days.length, progress),
    };
  }

  Widget _buildMobile(
    BuildContext context,
    int assigned,
    int total,
    double progress,
  ) {
    final textTheme = Theme.of(context).textTheme;
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
            _ProgressBar(progress: progress, height: 10),
            const SizedBox(height: 8),
            Text(
              '$assigned de $total días asignados',
              style: textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card del mockup: chip mint de estado + % grande, barra gruesa y filas
  /// de métricas con icono (datos reales de la semana).
  Widget _buildWeb(
    BuildContext context,
    int assigned,
    int total,
    double progress,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final vasosId = data.asignacionDe('vasos', mondayIso)?.participanteId;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progreso semanal',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(
                    color: AppTheme.mint,
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                  child: Text(
                    progress >= 1 ? 'COMPLETA' : 'EN CURSO',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppTheme.onMint,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: textTheme.titleLarge?.copyWith(
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _ProgressBar(progress: progress, height: 16),
            const SizedBox(height: 16),
            _MetricRow(
              icon: Icons.local_drink_outlined,
              label: 'Días asignados',
              value: '$assigned/$total',
            ),
            const SizedBox(height: 8),
            _MetricRow(
              icon: Icons.coffee_outlined,
              label: 'Vasos',
              value: vasosId != null ? data.nameOf(vasosId) : 'Sin asignar',
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final double height;

  const _ProgressBar({required this.progress, required this.height});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: progress,
        minHeight: height,
        backgroundColor: AppTheme.surfaceContainerHighest,
        valueColor: const AlwaysStoppedAnimation(AppTheme.mint),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFDEE0FF), // primary-fixed del design system
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
