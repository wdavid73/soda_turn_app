import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

const _visibleDuration = Duration(milliseconds: 900);
const _popDuration = Duration(milliseconds: 220);

/// Checkmark animado (100% Flutter, sin dependencias nativas) que confirma
/// visualmente que una asignación manual quedó guardada, ver
/// `day_edit_sheet.dart`. Oculto hasta que se llama a [play].
class AssignmentConfirmationCheck extends StatefulWidget {
  final double size;

  const AssignmentConfirmationCheck({super.key, this.size = 22});

  @override
  State<AssignmentConfirmationCheck> createState() =>
      AssignmentConfirmationCheckState();
}

class AssignmentConfirmationCheckState
    extends State<AssignmentConfirmationCheck> {
  bool _visible = false;
  Timer? _hideTimer;

  void play() {
    _hideTimer?.cancel();
    setState(() => _visible = true);
    _hideTimer = Timer(_visibleDuration, () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: _visible ? 1 : 0),
        duration: _popDuration,
        curve: Curves.easeOutBack,
        builder: (context, t, child) =>
            Opacity(opacity: t.clamp(0, 1), child: Transform.scale(scale: t, child: child)),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: const BoxDecoration(
            color: AppTheme.mint,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            size: widget.size * 0.65,
            color: AppTheme.onMint,
          ),
        ),
      ),
    );
  }
}
