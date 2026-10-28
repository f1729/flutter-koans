import 'package:flutter/material.dart';

abstract final class Palette {
  static const ink = Color(0xFF0E1014);
  static const surface = Color(0xFF161920);
  static const raised = Color(0xFF1D212A);
  static const line = Color(0xFF2A2F3A);
  static const text = Color(0xFFE6E3DC);
  static const muted = Color(0xFF9A9A94);
  static const faint = Color(0xFF63656B);
  static const jade = Color(0xFF7FD1AE);
  static const ember = Color(0xFFE88A7A);
  static const dart = Color(0xFF3DD6C6);
  static const flutter = Color(0xFF6CB8FF);

  static Color forWay(String id) => id == 'flutter' ? flutter : dart;
}

TextStyle codeStyle({double size = 15, Color color = Palette.text}) =>
    TextStyle(fontFamily: 'JetBrainsMono', fontSize: size, height: 1.9, letterSpacing: 0, color: color);

TextStyle promptStyle(BuildContext context) => const TextStyle(
      fontFamily: 'NotoSerif',
      fontSize: 22,
      height: 1.45,
      color: Palette.text,
      fontWeight: FontWeight.w400,
    );

ThemeData buildTheme({Color accent = Palette.dart}) {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: accent,
      surface: Palette.surface,
      onSurface: Palette.text,
      error: Palette.ember,
      outline: Palette.line,
    ),
    scaffoldBackgroundColor: Palette.ink,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      fontFamily: 'Inter',
      bodyColor: Palette.text,
      displayColor: Palette.text,
    ),
    dividerTheme: const DividerThemeData(color: Palette.line, space: 1),
    tooltipTheme: const TooltipThemeData(waitDuration: Duration(milliseconds: 400)),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: Palette.ink,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Palette.text,
        side: const BorderSide(color: Palette.line),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Palette.muted,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      ),
    ),
  );
}

final _themes = <String, ThemeData>{};

/// The app theme tinted with the accent of a Way.
ThemeData themeFor(String wayId) =>
    _themes[wayId] ??= buildTheme(accent: Palette.forWay(wayId));
