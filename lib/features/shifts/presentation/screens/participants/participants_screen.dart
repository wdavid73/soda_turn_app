import 'package:flutter/material.dart';

import '../../../../../shared/layout/app_breakpoints.dart';
import 'mobile/participants_screen_mobile.dart';
import 'web/participants_screen_web.dart';

/// Equipo: buscar, agregar, renombrar, activar/inactivar y eliminar
/// participantes. Despacha al diseño de cada plataforma: mobile por defecto,
/// web (mockups de design/web) solo en plataforma web con ventana ancha.
class ParticipantsScreen extends StatelessWidget {
  const ParticipantsScreen({super.key});

  @override
  Widget build(BuildContext context) => context.useWebLayout
      ? const ParticipantsScreenWeb()
      : const ParticipantsScreenMobile();
}
