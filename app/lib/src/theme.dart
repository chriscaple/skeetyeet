import 'package:flutter/material.dart';

/// SkeetYeet brand palette. See brand/README.md.
abstract final class Palette {
  static const hibiscus = Color(0xFFFF3E7F);
  static const mango = Color(0xFFFF9F1C);
  static const sunshine = Color(0xFFFFD23F);
  static const palm = Color(0xFF2EC27E);
  static const lagoon = Color(0xFF00B4C6);
  static const deepSea = Color(0xFF1B2A49);
  static const sand = Color(0xFFFFF4E0);

  // Accessible variants for fills that carry text (WCAG AA, 4.5:1+).
  /// White text on this: 4.8:1.
  static const hibiscusDeep = Color(0xFFD6246E);

  /// Deep sea text on this: 5.3:1.
  static const hibiscusLight = Color(0xFFFF6B9D);
}

const _display = 'LilitaOne';

ThemeData buildTheme(Brightness brightness) {
  final light = brightness == Brightness.light;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: light ? Palette.hibiscusDeep : Palette.hibiscusLight,
    onPrimary: light ? Colors.white : Palette.deepSea,
    secondary: Palette.lagoon,
    onSecondary: Palette.deepSea,
    tertiary: Palette.mango,
    onTertiary: Palette.deepSea,
    error: const Color(0xFFB3261E),
    onError: Colors.white,
    surface: light ? Palette.sand : Palette.deepSea,
    onSurface: light ? Palette.deepSea : Palette.sand,
  );

  final base = ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    scaffoldBackgroundColor: scheme.surface,
  );

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      displaySmall: base.textTheme.displaySmall?.copyWith(
        fontFamily: _display,
        color: scheme.onSurface,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontFamily: _display,
        color: scheme.onSurface,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontFamily: _display,
        color: scheme.onSurface,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    ),
  );
}
