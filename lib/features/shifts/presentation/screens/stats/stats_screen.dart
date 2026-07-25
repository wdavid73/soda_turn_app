import 'package:flutter/material.dart';

import '../../../../../shared/layout/app_breakpoints.dart';
import 'mobile/stats_screen_mobile.dart';
import 'web/stats_screen_web.dart';

/// Estadísticas: ranking de aportes, totales y gasto por persona.
/// Despacha al diseño de cada plataforma: mobile por defecto, web (mockups
/// de design/web) solo en plataforma web con ventana ancha.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) => context.useWebLayout
      ? const StatsScreenWeb()
      : const StatsScreenMobile();
}
