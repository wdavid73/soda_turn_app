import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../../../../shared/widgets/soda_header.dart';
import '../../../../shared/widgets/stat_tile.dart';
import '../../domain/entities/participant_entity.dart';
import '../providers/turnos_providers.dart';

/// Participantes: buscar, agregar, renombrar, activar/inactivar y eliminar.
class ParticipantsScreen extends ConsumerStatefulWidget {
  const ParticipantsScreen({super.key});

  @override
  ConsumerState<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends ConsumerState<ParticipantsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ui = ref.watch(turnosViewModelProvider);
    final stats = ref.watch(turnosStatsProvider);

    if (ui.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    bool matches(ParticipantEntity p) =>
        _query.isEmpty || p.name.toLowerCase().contains(_query.toLowerCase());

    final actives = ui.data.participants
        .where((p) => p.active && matches(p))
        .toList();
    final inactives = ui.data.participants
        .where((p) => !p.active && matches(p))
        .toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab-people',
        tooltip: 'Agregar participante',
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            const SodaHeader(),
            const SizedBox(height: 24),
            Text(
              'Participantes',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre…',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Total Activos',
                    value: '${ui.data.activeParticipants.length}',
                    background: AppTheme.primaryContainer,
                    foreground: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    label: 'Turnos repartidos',
                    value: '${stats.totalGaseosaDays + stats.totalVasosWeeks}',
                    background: AppTheme.mint,
                    foreground: AppTheme.onMint,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (actives.isNotEmpty) ...[
              Text(
                'Activos',
                style: textTheme.titleMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              for (final p in actives) ...[
                _ParticipantTile(participant: p),
                const SizedBox(height: 8),
              ],
            ],
            if (inactives.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Inactivos',
                style: textTheme.titleMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              for (final p in inactives) ...[
                _ParticipantTile(participant: p),
                const SizedBox(height: 8),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
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
}

class _ParticipantTile extends ConsumerWidget {
  final ParticipantEntity participant;

  const _ParticipantTile({required this.participant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final vm = ref.read(turnosViewModelProvider.notifier);
    final stats = ref.watch(turnosStatsProvider);

    return Opacity(
      opacity: participant.active ? 1 : 0.55,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              InitialsAvatar(name: participant.name, size: 44),
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
                      '${stats.gaseosaOf(participant.id)} gaseosas · '
                      '${stats.vasosOf(participant.id)} vasos',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showEditDialog(context, ref),
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

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
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
}
