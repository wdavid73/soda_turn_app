import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../../../identity/presentation/providers/identity_providers.dart';
import '../../domain/entities/participant_entity.dart';
import '../providers/shifts_providers.dart';

enum _Variant { mobile, web }

/// Tile de un participante (Equipo): renombrar, activar/inactivar, eliminar
/// y "marcar como yo". Default = mobile (fila); `.web` = card vertical del
/// grid de participantes del mockup de design/web.
class ParticipantTile extends ConsumerWidget {
  final ParticipantEntity participant;
  final _Variant _variant;

  const ParticipantTile({super.key, required this.participant})
    : _variant = _Variant.mobile;

  const ParticipantTile.web({super.key, required this.participant})
    : _variant = _Variant.web;

  @override
  Widget build(BuildContext context, WidgetRef ref) => switch (_variant) {
    _Variant.mobile => _buildMobile(context, ref),
    _Variant.web => _buildWeb(context, ref),
  };

  Widget _buildMobile(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final vm = ref.read(turnosViewModelProvider.notifier);
    final stats = ref.watch(turnosStatsProvider);
    final isMe = ref.watch(myParticipantIdProvider) == participant.id;

    return Opacity(
      opacity: participant.active ? 1 : 0.55,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              InitialsAvatar(
                name: participant.name,
                size: 44,
                ringColor: isMe ? AppTheme.mint : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      participant.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${stats.countOf('gaseosa', participant.id)} gaseosas · '
                      '${stats.countOf('vasos', participant.id)} vasos',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => ref
                    .read(myParticipantIdProvider.notifier)
                    .set(participant.id),
                tooltip: isMe ? 'Sos vos' : 'Marcar como yo',
                icon: Icon(
                  isMe ? Icons.person : Icons.person_outline,
                  color: isMe ? AppTheme.mint : AppTheme.onSurfaceVariant,
                ),
              ),
              IconButton(
                onPressed: () => showParticipantEditDialog(
                  context,
                  ref,
                  participant,
                ),
                tooltip: 'Editar',
                icon: const Icon(
                  Icons.edit_outlined,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              Switch(
                value: participant.active,
                onChanged: (_) => vm.toggleParticipantActive(participant.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Card vertical del mockup: avatar con ring, toggle arriba a la derecha,
  /// nombre + subtítulo, footer con chip de turnos y menú de acciones.
  Widget _buildWeb(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final vm = ref.read(turnosViewModelProvider.notifier);
    final stats = ref.watch(turnosStatsProvider);
    final isMe = ref.watch(myParticipantIdProvider) == participant.id;
    final total = stats.totalOf(participant.id);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: participant.active ? 1 : 0.55,
                  child: InitialsAvatar(
                    name: participant.name,
                    size: 64,
                    ringColor: isMe
                        ? AppTheme.mint
                        : (participant.active
                              ? AppTheme.mint.withValues(alpha: 0.5)
                              : null),
                  ),
                ),
                const Spacer(),
                Switch(
                  value: participant.active,
                  onChanged: (_) => vm.toggleParticipantActive(participant.id),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              participant.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: participant.active
                    ? AppTheme.onSurface
                    : AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              participant.active
                  ? '${stats.countOf('gaseosa', participant.id)} gaseosas · '
                        '${stats.countOf('vasos', participant.id)} vasos'
                  : 'Inactivo (vacaciones)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceVariant,
                fontStyle: participant.active
                    ? FontStyle.normal
                    : FontStyle.italic,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppTheme.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: participant.active
                          ? AppTheme.mint
                          : AppTheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      total == 1 ? '1 turno' : '$total turnos',
                      style: textTheme.labelSmall?.copyWith(
                        color: participant.active
                            ? AppTheme.onMint
                            : AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    tooltip: 'Acciones',
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppTheme.onSurfaceVariant,
                    ),
                    onSelected: (action) => switch (action) {
                      'me' => ref
                          .read(myParticipantIdProvider.notifier)
                          .set(participant.id),
                      'edit' => showParticipantEditDialog(
                        context,
                        ref,
                        participant,
                      ),
                      _ => null,
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'me',
                        child: Text(isMe ? 'Sos vos ✓' : 'Marcar como yo'),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Editar / Eliminar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Diálogo de edición (renombrar / eliminar) compartido por ambas variantes.
Future<void> showParticipantEditDialog(
  BuildContext context,
  WidgetRef ref,
  ParticipantEntity participant,
) async {
  final vm = ref.read(turnosViewModelProvider.notifier);
  final controller = TextEditingController(text: participant.name);
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Editar participante'),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Nombre'),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppTheme.error),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: dialogContext,
              builder: (confirmContext) => AlertDialog(
                title: Text('¿Eliminar a ${participant.name}?'),
                content: const Text(
                  'Su historial de turnos se conserva en las semanas '
                  'pasadas, pero ya no aparecerá en la lista.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(confirmContext).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.error,
                    ),
                    onPressed: () => Navigator.of(confirmContext).pop(true),
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
            );
            if (confirmed == true && dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
              await vm.removeParticipant(participant.id);
            }
          },
          child: const Text('Eliminar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            vm.renameParticipant(participant.id, controller.text);
          },
          child: const Text('Guardar'),
        ),
      ],
    ),
  );
}

/// Diálogo para agregar un participante nuevo (usado por el FAB mobile y el
/// botón del header web).
Future<void> showParticipantAddDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final controller = TextEditingController();
  final name = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Nuevo participante'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Nombre'),
        onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(controller.text),
          child: const Text('Agregar'),
        ),
      ],
    ),
  );
  if (name != null && name.trim().isNotEmpty) {
    await ref.read(turnosViewModelProvider.notifier).addParticipant(name);
  }
}
