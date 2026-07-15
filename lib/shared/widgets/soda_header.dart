import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Cabecera de marca "SodaTurn" con el logo de burbujas.
class SodaHeader extends StatelessWidget {
  const SodaHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.bubble_chart_rounded,
          color: AppTheme.primary,
          size: 30,
        ),
        const SizedBox(width: 8),
        Text(
          'SodaTurn',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
