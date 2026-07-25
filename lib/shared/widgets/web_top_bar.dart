import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../features/identity/presentation/providers/identity_providers.dart';
import '../../features/shifts/presentation/providers/shifts_providers.dart';
import 'initials_avatar.dart';

/// Barra superior de las pages web, según los mockups de design/web:
/// search pill, campana, settings y avatar del participante identificado.
/// Search/campana/settings son decorativos por ahora (muestran un snackbar);
/// solo existe en la versión web, no tiene variante mobile.
class WebTopBar extends ConsumerWidget {
  const WebTopBar({super.key});

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Próximamente...')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final myId = ref.watch(myParticipantIdProvider);
    final ui = ref.watch(turnosViewModelProvider);
    final myName = myId != null && !ui.loading ? ui.data.nameOf(myId) : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 384),
              child: Material(
                color: AppTheme.surfaceContainerHigh,
                shape: const StadiumBorder(),
                child: InkWell(
                  onTap: () => _comingSoon(context),
                  customBorder: const StadiumBorder(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          size: 20,
                          color: AppTheme.outline,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Buscar…',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          IconButton(
            onPressed: () => _comingSoon(context),
            tooltip: 'Notificaciones',
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            onPressed: () => _comingSoon(context),
            tooltip: 'Configuración',
            icon: const Icon(Icons.settings_outlined),
          ),
          if (myName != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(width: 1, height: 24, color: AppTheme.outlineVariant),
            ),
            InitialsAvatar(name: myName, size: 40, ringColor: AppTheme.primaryContainer),
            const SizedBox(width: 10),
            Text(
              myName,
              style: textTheme.titleSmall?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
