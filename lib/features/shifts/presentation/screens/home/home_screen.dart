import 'package:flutter/material.dart';

import '../../../../../shared/layout/app_breakpoints.dart';
import 'mobile/home_screen_mobile.dart';
import 'web/home_screen_web.dart';

/// Home: quién compra hoy, vasos de la semana, próximos días y progreso.
/// Despacha al diseño de cada plataforma: mobile por defecto, web (mockups
/// de design/web) solo en plataforma web con ventana ancha.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => context.useWebLayout
      ? const HomeScreenWeb()
      : const HomeScreenMobile();
}
