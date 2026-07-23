import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/initials_avatar.dart';
import '../../../shifts/domain/entities/participant_entity.dart';
import '../providers/identity_providers.dart';

/// Bottom sheet que pregunta "¿Quién sos?" para poder mandarle push
/// notifications a la persona correcta. Descartable: si no elige, se
/// vuelve a preguntar la próxima vez que abra la app (no bloquea el uso).
Future<void> showWhoAreYouSheet(
  BuildContext context,
  List<ParticipantEntity> participants,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => WhoAreYouSheet(participants: participants),
  );
}

class WhoAreYouSheet extends ConsumerWidget {
  final List<ParticipantEntity> participants;

  const WhoAreYouSheet({super.key, required this.participants});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Quién sos?',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Así te avisamos por notificación cuando te toque comprar.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final p in participants)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: InitialsAvatar(name: p.name, size: 40),
                        title: Text(
                          p.name,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        onTap: () async {
                          await ref
                              .read(myParticipantIdProvider.notifier)
                              .set(p.id);
                          if (context.mounted) Navigator.of(context).pop();
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Preguntarme después'),
            ),
          ],
        ),
      ),
    );
  }
}
