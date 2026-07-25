import 'package:flutter/material.dart';

import '../../../../../shared/layout/app_breakpoints.dart';
import 'mobile/history_screen_mobile.dart';
import 'web/history_screen_web.dart';

/// Historial: semanas completadas agrupadas por mes.
/// Despacha al diseño de cada plataforma: mobile por defecto, web (mockups
/// de design/web) solo en plataforma web con ventana ancha.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) => context.useWebLayout
      ? const HistoryScreenWeb()
      : const HistoryScreenMobile();
}
