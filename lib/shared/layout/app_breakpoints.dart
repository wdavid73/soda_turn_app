import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Breakpoints y anchos del layout por plataforma.
/// El diseño web (mockups de design/web, sidebar de 280px) solo aplica en
/// plataforma web con ventana ancha; ver [WebLayoutContext.useWebLayout].
abstract final class AppBreakpoints {
  /// En el shell mobile, si la ventana supera este ancho el contenido se
  /// centra (web angosta / tablets) en vez de estirarse.
  static const double tablet = 600;

  /// Desde aquí (y solo en plataforma web) se usa el diseño web.
  static const double desktop = 1024;

  /// Ancho máximo del área de contenido en el shell web.
  static const double contentMaxWidth = 1200;

  /// Ancho máximo de sheets/diálogos en pantallas anchas.
  static const double sheetMaxWidth = 480;

  /// Ancho del sidebar web (token `nav-width` del mockup).
  static const double sideNavWidth = 280;
}

/// Plataforma "web" con override para tests, siguiendo el patrón de
/// `debugDefaultTargetPlatformOverride` de Flutter: los widget tests no
/// corren en web (`kIsWeb` false), así que sin esto el diseño web sería
/// intesteable.
abstract final class AppPlatform {
  /// Solo tests: null = usar `kIsWeb` real.
  static bool? debugIsWebOverride;

  static bool get isWeb => debugIsWebOverride ?? kIsWeb;
}

extension WebLayoutContext on BuildContext {
  /// `true` cuando corresponde el diseño web (mockups de design/web):
  /// plataforma web Y ventana ancha. En Android siempre es `false`; en web
  /// con ventana angosta (p. ej. un celular abriendo la web) se usa el
  /// diseño mobile.
  bool get useWebLayout =>
      AppPlatform.isWeb &&
      MediaQuery.sizeOf(this).width >= AppBreakpoints.desktop;
}
