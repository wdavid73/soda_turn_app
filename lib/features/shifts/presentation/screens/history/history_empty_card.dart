import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

/// Estado vacío del historial (sin semanas completadas). Compartido por las
/// versiones mobile y web.
class HistoryEmptyCard extends StatelessWidget {
  const HistoryEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.history_rounded,
              size: 40,
              color: AppTheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'Aún no hay semanas completadas. Cuando termine la '
              'primera semana aparecerá aquí.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
