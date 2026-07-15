import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../domain/entities/weekly_vasos_entity.dart';
import '../providers/turnos_providers.dart';

/// Bottom sheet para elegir quién lleva los vasos de la semana visible.
Future<void> showVasosEditSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const VasosEditSheet(),
  );
}

class VasosEditSheet extends ConsumerWidget {
  const VasosEditSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final vm = ref.read(turnosViewModelProvider.notifier);
    final ui = ref.watch(turnosViewModelProvider);
    final data = ui.data;
    final rec =
        data.weeklyVasos[ui.selectedMonday] ?? const WeeklyVasosEntity();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Vasos de la semana',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: vm.toggleVasosLock,
                    tooltip: rec.locked ? 'Desbloquear' : 'Bloquear',
                    icon: Icon(
                      rec.locked ? Icons.lock : Icons.lock_open_outlined,
                      color: rec.locked
                          ? AppTheme.primary
                          : AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Text(
                AppDateUtils.weekRangeLabel(ui.selectedMonday),
                style: textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              if (rec.warning != null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rec.warning!,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppTheme.onErrorContainer,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'Quien lleve los vasos no compra gaseosa esta semana.',
                style: textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in data.activeParticipants)
                    ChoiceChip(
                      label: Text(p.name),
                      selected: rec.personId == p.id,
                      selectedColor: AppTheme.mint,
                      onSelected: (selected) =>
                          vm.setVasos(selected ? p.id : null),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  FilledButton.tonalIcon(
                    onPressed: rec.locked ? null : vm.autoAssignVasos,
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('Auto-asignar'),
                  ),
                  const SizedBox(width: 8),
                  if (rec.personId != null)
                    TextButton(
                      onPressed: () => vm.setVasos(null),
                      child: const Text('Quitar asignación'),
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
