import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../../domain/entities/assignment_entity.dart';
import '../../domain/entities/shifts_state_entity.dart';

enum _Variant { mobile, web }

/// Card del comprador de vasos de la semana (regla 3).
/// Default = mobile (fila); `.web` = card "MVP de la semana" en columna,
/// como la columna derecha del Home del mockup de design/web.
class CupsWeekCard extends StatelessWidget {
  final ShiftsStateEntity data;
  final String mondayIso;
  final VoidCallback? onTap;
  final VoidCallback? onToggleLock;
  final _Variant _variant;

  const CupsWeekCard({
    super.key,
    required this.data,
    required this.mondayIso,
    this.onTap,
    this.onToggleLock,
  }) : _variant = _Variant.mobile;

  const CupsWeekCard.web({
    super.key,
    required this.data,
    required this.mondayIso,
    this.onTap,
    this.onToggleLock,
  }) : _variant = _Variant.web;

  @override
  Widget build(BuildContext context) {
    final rec =
        data.asignacionDe('vasos', mondayIso) ?? const AssignmentEntity();
    final name =
        rec.participanteId != null ? data.nameOf(rec.participanteId) : null;

    return switch (_variant) {
      _Variant.mobile => _buildMobile(context, rec: rec, name: name),
      _Variant.web => _buildWeb(context, rec: rec, name: name),
    };
  }

  Widget _buildMobile(
    BuildContext context, {
    required AssignmentEntity rec,
    required String? name,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              name != null
                  ? InitialsAvatar(name: name, size: 48)
                  : const CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.surfaceContainerHigh,
                      child: Icon(
                        Icons.local_drink_outlined,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name ?? 'Sin asignar',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: name != null
                            ? AppTheme.onSurface
                            : AppTheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_drink_outlined,
                          size: 16,
                          color: AppTheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Vasos de la semana',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (rec.warning != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        rec.warning!,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppTheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _LockControl(rec: rec, onToggleLock: onToggleLock),
            ],
          ),
        ),
      ),
    );
  }

  /// Card columna del mockup: label uppercase + chip de la semana, avatar
  /// centrado con ring primary y nombre en headline.
  Widget _buildWeb(
    BuildContext context, {
    required AssignmentEntity rec,
    required String? name,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'VASOS DE LA SEMANA',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: const BoxDecoration(
                      color: AppTheme.mint,
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                    ),
                    child: Text(
                      AppDateUtils.weekRangeLabel(mondayIso),
                      style: textTheme.labelSmall?.copyWith(
                        color: AppTheme.onMint,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _LockControl(rec: rec, onToggleLock: onToggleLock),
                ],
              ),
              const SizedBox(height: 20),
              name != null
                  ? InitialsAvatar(
                      name: name,
                      size: 88,
                      ringColor: AppTheme.primaryContainer,
                    )
                  : const CircleAvatar(
                      radius: 44,
                      backgroundColor: AppTheme.surfaceContainerHigh,
                      child: Icon(
                        Icons.local_drink_outlined,
                        size: 32,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
              const SizedBox(height: 12),
              Text(
                name ?? 'Sin asignar',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: name != null
                      ? AppTheme.onSurface
                      : AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Lleva los vasos toda la semana',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              if (rec.warning != null) ...[
                const SizedBox(height: 8),
                Text(
                  rec.warning!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(color: AppTheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LockControl extends StatelessWidget {
  final AssignmentEntity rec;
  final VoidCallback? onToggleLock;

  const _LockControl({required this.rec, required this.onToggleLock});

  @override
  Widget build(BuildContext context) {
    if (onToggleLock != null) {
      return IconButton(
        onPressed: onToggleLock,
        tooltip: rec.locked ? 'Desbloquear' : 'Bloquear',
        icon: Icon(
          rec.locked ? Icons.lock : Icons.lock_open_outlined,
          color: rec.locked ? AppTheme.primary : AppTheme.onSurfaceVariant,
        ),
      );
    }
    if (rec.locked) {
      return const Icon(Icons.lock, color: AppTheme.primary, size: 20);
    }
    return const SizedBox.shrink();
  }
}
