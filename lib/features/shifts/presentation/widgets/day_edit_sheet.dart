import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../shared/widgets/assignment_confirmation_check.dart';
import '../../../../shared/widgets/show_adaptive_modal.dart';
import '../../domain/entities/assignment_entity.dart';
import '../providers/shifts_providers.dart';

/// Edición de un día: gaseosa, presentes y bloqueo. Bottom sheet en mobile,
/// diálogo centrado en web.
/// Regla 8: todo se puede forzar; las reglas rotas solo advierten.
Future<void> showDayEditSheet(BuildContext context, String dateIso) {
  return showAdaptiveModal(
    context,
    builder: (_) => DayEditSheet(dateIso: dateIso),
  );
}

class DayEditSheet extends ConsumerStatefulWidget {
  final String dateIso;

  const DayEditSheet({super.key, required this.dateIso});

  @override
  ConsumerState<DayEditSheet> createState() => _DayEditSheetState();
}

class _DayEditSheetState extends ConsumerState<DayEditSheet> {
  final _confirmationKey = GlobalKey<AssignmentConfirmationCheckState>();

  /// Guarda la selección manual y, si no hubo error, dispara el checkmark.
  Future<void> _selectParticipant(String? participanteId) async {
    final vm = ref.read(turnosViewModelProvider.notifier);
    final hadError = ref.read(turnosViewModelProvider).error != null;
    await vm.setProducto('gaseosa', widget.dateIso, participanteId);
    final nowHasError = ref.read(turnosViewModelProvider).error != null;
    if (!hadError && !nowHasError) {
      _confirmationKey.currentState?.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateIso = widget.dateIso;
    final textTheme = Theme.of(context).textTheme;
    final vm = ref.read(turnosViewModelProvider.notifier);
    final data = ref.watch(turnosViewModelProvider.select((s) => s.data));
    final day = data.asignacionDe('gaseosa', dateIso) ?? const AssignmentEntity();
    final hasRecord = data.presenciaPorDia.containsKey(dateIso);
    final present = hasRecord ? data.presentesEn(dateIso) : data.activeIds;
    final mondayIso = AppDateUtils.toIso(
      AppDateUtils.mondayOf(AppDateUtils.parseIso(dateIso)),
    );
    final vasosId = data.asignacionDe('vasos', mondayIso)?.participanteId;

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
                      AppDateUtils.dayLabel(dateIso),
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => vm.toggleLock('gaseosa', dateIso),
                    tooltip: day.locked ? 'Desbloquear' : 'Bloquear',
                    icon: Icon(
                      day.locked ? Icons.lock : Icons.lock_open_outlined,
                      color: day.locked
                          ? AppTheme.primary
                          : AppTheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (day.warning != null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AppTheme.onErrorContainer,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          day.warning!,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppTheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Gaseosa del día',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AssignmentConfirmationCheck(
                    key: _confirmationKey,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final id in present)
                    ChoiceChip(
                      label: Text(
                        id == vasosId
                            ? '🥤 ${data.nameOf(id)}'
                            : data.nameOf(id),
                      ),
                      selected: day.participanteId == id,
                      selectedColor: AppTheme.mint,
                      onSelected: (selected) =>
                          _selectParticipant(selected ? id : null),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  FilledButton.tonalIcon(
                    onPressed: day.locked
                        ? null
                        : () => vm.autoAssignProducto('gaseosa', dateIso),
                    icon: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('Auto-asignar'),
                  ),
                  const SizedBox(width: 8),
                  if (day.participanteId != null)
                    TextButton(
                      onPressed: () => vm.setProducto('gaseosa', dateIso, null),
                      child: const Text('Quitar asignación'),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Presentes (${present.length})',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in data.participants)
                    FilterChip(
                      label: Text(p.name),
                      selected: present.contains(p.id),
                      selectedColor: AppTheme.mint,
                      onSelected: (selected) {
                        final next = selected
                            ? [...present, p.id]
                            : present.where((id) => id != p.id).toList();
                        vm.setPresence(dateIso, next);
                      },
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
