import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../../domain/entities/assignment_entity.dart';
import '../../domain/entities/shifts_state_entity.dart';

/// Card del comprador de vasos de la semana (regla 3).
class CupsWeekCard extends StatelessWidget {
  final ShiftsStateEntity data;
  final String mondayIso;
  final VoidCallback? onTap;
  final VoidCallback? onToggleLock;

  const CupsWeekCard({
    super.key,
    required this.data,
    required this.mondayIso,
    this.onTap,
    this.onToggleLock,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final rec = data.asignacionDe('vasos', mondayIso) ?? const AssignmentEntity();
    final name = rec.participanteId != null ? data.nameOf(rec.participanteId) : null;

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
                        Text(
                          'Vasos de la semana',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppTheme.onSurfaceVariant,
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
              if (onToggleLock != null)
                IconButton(
                  onPressed: onToggleLock,
                  tooltip: rec.locked ? 'Desbloquear' : 'Bloquear',
                  icon: Icon(
                    rec.locked ? Icons.lock : Icons.lock_open_outlined,
                    color: rec.locked
                        ? AppTheme.primary
                        : AppTheme.onSurfaceVariant,
                  ),
                )
              else if (rec.locked)
                const Icon(Icons.lock, color: AppTheme.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
