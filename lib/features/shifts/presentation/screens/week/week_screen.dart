import 'package:flutter/material.dart';

import '../../../../../shared/layout/app_breakpoints.dart';
import 'mobile/week_screen_mobile.dart';
import 'web/week_screen_web.dart';

/// Semana: navegación entre semanas, vasos semanal y los 5 tickets diarios.
/// Despacha al diseño de cada plataforma: mobile por defecto, web (mockups
/// de design/web) solo en plataforma web con ventana ancha.
class WeekScreen extends StatelessWidget {
  const WeekScreen({super.key});

  @override
  Widget build(BuildContext context) => context.useWebLayout
      ? const WeekScreenWeb()
      : const WeekScreenMobile();
}
