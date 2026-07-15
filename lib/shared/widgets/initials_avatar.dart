import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Avatar circular con iniciales (los mockups usan fotos; en la app real no
/// hay fotos, así que usamos iniciales con fondo derivado del nombre).
class InitialsAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? background;
  final Color? foreground;
  final Color? ringColor;

  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.background,
    this.foreground,
    this.ringColor,
  });

  static const _palette = [
    AppTheme.primaryContainer,
    AppTheme.tertiaryContainer,
    AppTheme.secondary,
    Color(0xFF6750A4),
    Color(0xFF7D5260),
    Color(0xFF4355B9),
  ];

  String get _initials {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      return words.first.substring(0, 1).toUpperCase();
    }
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bg = background ?? _palette[name.hashCode.abs() % _palette.length];
    final avatar = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(
        _initials,
        style: TextStyle(
          color: foreground ?? Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.38,
        ),
      ),
    );
    if (ringColor == null) return avatar;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor!, width: 2),
      ),
      child: avatar,
    );
  }
}
