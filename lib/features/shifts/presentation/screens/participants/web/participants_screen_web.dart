import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../shared/widgets/stat_tile.dart';
import '../../../../../../shared/widgets/web_top_bar.dart';
import '../../../../domain/entities/participant_entity.dart';
import '../../../providers/shifts_providers.dart';
import '../../../widgets/participant_tile.dart';

/// Equipo web: "gobernanza del equipo" del mockup de design/web — métricas
/// bento, búsqueda y grid de cards de participante con card de agregar.
class ParticipantsScreenWeb extends ConsumerStatefulWidget {
  const ParticipantsScreenWeb({super.key});

  @override
  ConsumerState<ParticipantsScreenWeb> createState() =>
      _ParticipantsScreenWebState();
}

class _ParticipantsScreenWebState
    extends ConsumerState<ParticipantsScreenWeb> {
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            const WebTopBar(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Equipo',
                        style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Participantes, presencia y rotación justa.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => showParticipantAddDialog(context, ref),
                  icon: const Icon(Icons.person_add_alt),
                  label: const Text('Agregar participante'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: StatTile.web(
                    label: 'Miembros activos',
                    value: '${ui.data.activeParticipants.length}',
                    background: const Color(0xFFDEE0FF),
                    foreground: AppTheme.primary,
                    icon: Icons.groups_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatTile.web(
                    label: 'Turnos repartidos',
                    value:
                        '${stats.totalDe('gaseosa') + stats.totalDe('vasos')}',
                    background: const Color(0xFFDFF3E4),
                    foreground: AppTheme.secondary,
                    icon: Icons.local_drink_outlined,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StatTile.web(
                    label: 'Semanas de vasos',
                    value: '${stats.totalDe('vasos')}',
                    background: const Color(0xFFD8F3FA),
                    foreground: AppTheme.tertiary,
                    icon: Icons.coffee_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 384),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre…',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
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
              const SizedBox(height: 12),
              _ParticipantGrid(
                participants: actives,
                trailing: _AddMemberCard(
                  onTap: () => showParticipantAddDialog(context, ref),
                ),
              ),
            ],
            if (inactives.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Inactivos',
                style: textTheme.titleMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              _ParticipantGrid(participants: inactives),
            ],
          ],
        ),
      ),
    );
  }
}

/// Grid de cards de participante (3-4 columnas según el ancho disponible).
class _ParticipantGrid extends StatelessWidget {
  final List<ParticipantEntity> participants;
  final Widget? trailing;

  const _ParticipantGrid({required this.participants, this.trailing});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;
        final columns = (constraints.maxWidth / 300).floor().clamp(2, 4);
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final p in participants)
              SizedBox(
                width: itemWidth,
                child: ParticipantTile.web(participant: p),
              ),
            if (trailing != null)
              SizedBox(width: itemWidth, child: trailing),
          ],
        );
      },
    );
  }
}

/// Card "Agregar nuevo miembro" del mockup (borde punteado aproximado).
class _AddMemberCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddMemberCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: AppTheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Container(
          constraints: const BoxConstraints(minHeight: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            border: Border.all(color: AppTheme.outlineVariant, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: AppTheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              Text(
                'Agregar nuevo miembro',
                style: textTheme.titleSmall?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
