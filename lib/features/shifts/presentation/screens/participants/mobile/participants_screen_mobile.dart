import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../shared/widgets/soda_header.dart';
import '../../../../../../shared/widgets/stat_tile.dart';
import '../../../../domain/entities/participant_entity.dart';
import '../../../providers/shifts_providers.dart';
import '../../../widgets/participant_tile.dart';

/// Equipo mobile: lista vertical de participantes con búsqueda y FAB.
class ParticipantsScreenMobile extends ConsumerStatefulWidget {
  const ParticipantsScreenMobile({super.key});

  @override
  ConsumerState<ParticipantsScreenMobile> createState() =>
      _ParticipantsScreenMobileState();
}

class _ParticipantsScreenMobileState
    extends ConsumerState<ParticipantsScreenMobile> {
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
        onPressed: () => showParticipantAddDialog(context, ref),
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
                    value: '${stats.totalDe('gaseosa') + stats.totalDe('vasos')}',
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
                ParticipantTile(participant: p),
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
                ParticipantTile(participant: p),
                const SizedBox(height: 8),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
