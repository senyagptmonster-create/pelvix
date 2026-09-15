import 'package:flutter/material.dart';

class PelvixTheme {
  static const bg = Color(0xFF0E0D13);
  static const surface = Color(0xFF171520);
  static const edge = Color(0xFF242131);
  static const accent = Color(0xFFEAB308); // Gold Amber
  static const accentLight = Color(0xFFFDE047);
  static const ink = Color(0xFFFEFCE8);
  static const muted = Color(0xFF8C8799);

  static ThemeData get themeData {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      fontFamily: 'AppFont',
      primaryColor: accent,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: ink,
      ),
    );
  }
}
