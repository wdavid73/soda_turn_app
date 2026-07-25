import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

/// Estado vacío de Estadísticas (sin historial todavía). Compartido por las
/// versiones mobile y web.
class StatsEmptyCard extends StatelessWidget {
  const StatsEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.bar_chart_rounded,
              size: 40,
              color: AppTheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              'Aún no hay historial. Genera tu primera semana '
              'para ver el reparto.',
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
