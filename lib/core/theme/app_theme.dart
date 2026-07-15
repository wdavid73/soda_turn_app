import 'package:flutter/material.dart';

/// Tema SodaTurn: tokens tomados de design/sodaturn_design_system/DESIGN.md.
/// Base MD3 con primario "Indigo Refresh" y acento "Sparkling Mint",
/// tipografía Plus Jakarta Sans, cards de radio 24 y botones/chips pill.
class AppTheme {
  AppTheme._();

  // Colores del design system.
  static const Color primary = Color(0xFF24389C);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF3F51B5);
  static const Color onPrimaryContainer = Color(0xFFCACFFF);
  static const Color secondary = Color(0xFF006E2A);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color mint = Color(0xFF5CFD80); // secondary-container
  static const Color onMint = Color(0xFF00732C);
  static const Color tertiary = Color(0xFF004A57);
  static const Color tertiaryContainer = Color(0xFF006474);
  static const Color onTertiaryContainer = Color(0xFF63E3FF);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color surface = Color(0xFFFBF8FE);
  static const Color onSurface = Color(0xFF1B1B1F);
  static const Color onSurfaceVariant = Color(0xFF454652);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF6F2F8);
  static const Color surfaceContainer = Color(0xFFF0EDF2);
  static const Color surfaceContainerHigh = Color(0xFFEAE7ED);
  static const Color surfaceContainerHighest = Color(0xFFE4E1E7);
  static const Color outline = Color(0xFF757684);
  static const Color outlineVariant = Color(0xFFC5C5D4);

  /// Radio grande de cards según el design system.
  static const double cardRadius = 24;

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: mint,
      onSecondaryContainer: onMint,
      tertiary: tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: Colors.white,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
      outline: outline,
      outlineVariant: outlineVariant,
      inverseSurface: Color(0xFF303034),
      onInverseSurface: Color(0xFFF3F0F5),
      inversePrimary: Color(0xFFBAC3FF),
      surfaceTint: Color(0xFF4355B9),
      shadow: Colors.black,
      scrim: Colors.black,
    );

    final textTheme = ThemeData(brightness: Brightness.light).textTheme.apply(
      fontFamily: 'PlusJakartaSans',
      bodyColor: onSurface,
      displayColor: onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'PlusJakartaSans',
      textTheme: textTheme,
      scaffoldBackgroundColor: surface,
      cardTheme: CardThemeData(
        color: surfaceContainerLowest,
        elevation: 1,
        shadowColor: primary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: const StadiumBorder()),
      ),
      chipTheme: const ChipThemeData(
        shape: StadiumBorder(),
        side: BorderSide(color: outlineVariant),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        filled: true,
        fillColor: surfaceContainerLow,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: mint,
        foregroundColor: primary,
        shape: StadiumBorder(),
        elevation: 3,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceContainerLow,
        indicatorColor: mint,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? onMint
                : onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium!.copyWith(
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? onMint
                : onSurfaceVariant,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(color: outlineVariant, space: 1),
    );
  }
}
