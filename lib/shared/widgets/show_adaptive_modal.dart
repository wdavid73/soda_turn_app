import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../layout/app_breakpoints.dart';

/// Muestra el mismo contenido como bottom sheet (mobile, default) o como
/// diálogo centrado (web con ventana ancha), sin que el contenido tenga que
/// saber en qué plataforma corre.
Future<T?> showAdaptiveModal<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  if (context.useWebLayout) {
    return showDialog<T>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppBreakpoints.sheetMaxWidth,
          ),
          child: builder(context),
        ),
      ),
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    // En ventanas anchas no-web el sheet queda centrado y angosto.
    constraints: const BoxConstraints(maxWidth: AppBreakpoints.sheetMaxWidth),
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: builder,
  );
}
