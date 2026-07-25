import 'package:flutter/material.dart';

import '../../../../../core/utils/app_date_utils.dart';

/// Rango de la semana visible + acceso rápido a "volver a la actual".
/// Compartido por las versiones mobile y web de la page Semana.
class WeekNavLabel extends StatelessWidget {
  final String mondayIso;
  final bool isCurrentWeek;
  final VoidCallback onBackToCurrent;

  const WeekNavLabel({
    super.key,
    required this.mondayIso,
    required this.isCurrentWeek,
    required this.onBackToCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppDateUtils.weekRangeLabel(mondayIso),
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        if (!isCurrentWeek)
          TextButton(
            onPressed: onBackToCurrent,
            child: const Text('Volver a la semana actual'),
          ),
      ],
    );
  }
}
