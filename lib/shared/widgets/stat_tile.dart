import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

enum _Variant { mobile, web }

/// Tile de métrica destacada (Total Activos, Total Gaseosas, etc.).
/// Default = mobile (columna); `.web` = bento horizontal del mockup de
/// design/web (icono en cuadrado tintado + label uppercase + valor grande).
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final _Variant _variant;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.background,
    required this.foreground,
    this.icon,
  }) : _variant = _Variant.mobile;

  const StatTile.web({
    super.key,
    required this.label,
    required this.value,
    required this.background,
    required this.foreground,
    this.icon,
  }) : _variant = _Variant.web;

  @override
  Widget build(BuildContext context) => switch (_variant) {
    _Variant.mobile => _buildMobile(context),
    _Variant.web => _buildWeb(context),
  };

  Widget _buildMobile(BuildContext context) {
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

  /// Bento horizontal del mockup: icono 56 en cuadrado redondeado tintado,
  /// label uppercase pequeño y valor en headline. El fondo del tile es
  /// neutro; `background`/`foreground` tintan el cuadrado del icono.
  Widget _buildWeb(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon ?? Icons.bubble_chart_outlined,
              color: foreground,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
