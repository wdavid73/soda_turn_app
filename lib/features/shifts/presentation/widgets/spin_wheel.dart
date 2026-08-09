import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Rueda de selección aleatoria dibujada a mano: la cantidad de segmentos
/// sigue a [labels], así que crece o se achica con los presentes del día
/// sin depender de un asset (Lottie/Rive) con un número fijo de casillas.
///
/// El giro se controla desde afuera vía [SpinWheelState]:
/// - [SpinWheelState.spinIndefinitely] gira sin destino mientras se resuelve
///   la asignación real (que puede tardar por la persistencia remota).
/// - [SpinWheelState.landOn] frena y aterriza exactamente sobre el ganador.
class SpinWheel extends StatefulWidget {
  final List<String> labels;
  final double size;

  const SpinWheel({super.key, required this.labels, this.size = 220});

  @override
  State<SpinWheel> createState() => SpinWheelState();
}

class SpinWheelState extends State<SpinWheel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _rotation = 0;

  static const _fastSpinChunk = Duration(milliseconds: 450);
  static const _landingDuration = Duration(milliseconds: 1600);
  static const _extraTurns = 3;

  static const _palette = [
    AppTheme.primary,
    AppTheme.primaryContainer,
    AppTheme.tertiary,
    AppTheme.tertiaryContainer,
    AppTheme.secondary,
    AppTheme.onSurfaceVariant,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Gira a velocidad constante en pequeños tramos hasta que [keepSpinning]
  /// deje de ser true. Cada tramo avanza una vuelta completa, así que el
  /// corte entre tramos nunca se nota como un salto.
  Future<void> spinIndefinitely(bool Function() keepSpinning) async {
    while (keepSpinning() && mounted) {
      await _animateTo(
        _rotation + 2 * math.pi,
        _fastSpinChunk,
        Curves.linear,
      );
      if (!mounted) return;
    }
  }

  /// Desacelera y aterriza exactamente sobre [winnerIndex] de un total de
  /// [count] segmentos, dando un par de vueltas extra para que se note.
  Future<void> landOn(int winnerIndex, int count) async {
    if (count <= 0) return;
    final sliceAngle = 2 * math.pi / count;
    final normalizedTarget = -winnerIndex * sliceAngle;
    var target = normalizedTarget + 2 * math.pi * _extraTurns;
    while (target < _rotation) {
      target += 2 * math.pi;
    }
    await _animateTo(target, _landingDuration, Curves.easeOutCubic);
  }

  Future<void> _animateTo(
    double end,
    Duration duration,
    Curve curve,
  ) async {
    final tween = Tween<double>(begin: _rotation, end: end);
    _controller
      ..duration = duration
      ..reset();
    final animation = tween.animate(
      CurvedAnimation(parent: _controller, curve: curve),
    );
    void listener() => setState(() => _rotation = animation.value);
    animation.addListener(listener);
    await _controller.forward();
    animation.removeListener(listener);
    if (mounted) setState(() => _rotation = end);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size + 20,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 20,
            child: CustomPaint(
              size: Size.square(widget.size),
              painter: _WheelPainter(
                labels: widget.labels,
                rotation: _rotation,
                palette: _palette,
              ),
            ),
          ),
          const Icon(
            Icons.arrow_drop_down_rounded,
            size: 36,
            color: AppTheme.onSurface,
          ),
        ],
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<String> labels;
  final double rotation;
  final List<Color> palette;

  _WheelPainter({
    required this.labels,
    required this.rotation,
    required this.palette,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final n = labels.length;
    if (n == 0) return;

    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 4;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sliceAngle = 2 * math.pi / n;

    for (var i = 0; i < n; i++) {
      final startAngle = -math.pi / 2 + rotation + i * sliceAngle - sliceAngle / 2;
      canvas.drawArc(
        rect,
        startAngle,
        sliceAngle,
        true,
        Paint()..color = palette[i % palette.length],
      );
      canvas.drawArc(
        rect,
        startAngle,
        sliceAngle,
        true,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      _paintLabel(canvas, center, radius, startAngle + sliceAngle / 2, labels[i]);
    }

    canvas.drawCircle(center, radius * 0.14, Paint()..color = Colors.white);
    canvas.drawCircle(
      center,
      radius * 0.14,
      Paint()
        ..color = AppTheme.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  /// Dibuja el nombre en orientación radial (de adentro hacia el borde) en
  /// vez de tangencial: al no depender del ancho del arco, no se come
  /// letras de nombres largos aunque haya muchos segmentos angostos.
  void _paintLabel(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    String label,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: _shorten(label),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: radius * 0.62);

    // En la mitad izquierda de la rueda el texto radial queda cabeza
    // abajo; se corrige rotando 180° y espejando la posición.
    final flip = math.cos(angle) < 0;
    final rotation = flip ? angle + math.pi : angle;
    final sign = flip ? -1.0 : 1.0;
    final labelRadius = radius * 0.6;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    painter.paint(
      canvas,
      Offset(sign * labelRadius - painter.width / 2, -painter.height / 2),
    );
    canvas.restore();
  }

  String _shorten(String name) {
    final trimmed = name.trim();
    if (trimmed.length <= 14) return trimmed;
    return '${trimmed.substring(0, 13)}…';
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.labels != labels;
  }
}
