import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Tile de métrica destacada (Total Activos, Total Gaseosas, etc.).
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color background;
  final Color foreground;
  final IconData? icon;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.background,
    required this.foreground,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: foreground, size: 22),
            const SizedBox(height: 8),
          ],
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: foreground.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
