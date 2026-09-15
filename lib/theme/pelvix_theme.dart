import 'package:flutter/material.dart';

class PelvixTheme {
  PelvixTheme._();

  // Athletic Deep Navy and Neon Green Palette
  static const Color darkNavyBg = Color(0xFF090E17);
  static const Color cardNavy = Color(0xFF131B2B);
  static const Color cardNavyElevated = Color(0xFF1C273C);
  static const Color borderNavy = Color(0xFF223049);

  // Neon & energetic accents
  static const Color neonGreen = Color(0xFF22C55E);
  static const Color neonLime = Color(0xFF4ADE80);
  static const Color neonGreenDim = Color(0x2822C55E);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color alertOrange = Color(0xFFF97316);

  // Typography colors
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textDark = Color(0xFF475569);

  static ThemeData themeData() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkNavyBg,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: neonGreen,
        onPrimary: darkNavyBg,
        secondary: accentCyan,
        onSecondary: darkNavyBg,
        error: alertOrange,
        onError: Colors.white,
        surface: cardNavy,
        onSurface: textLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkNavyBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textLight),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardNavy,
        indicatorColor: neonGreenDim,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: neonGreen,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            );
          }
          return const TextStyle(
            color: textMuted,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: neonGreen);
          }
          return const IconThemeData(color: textMuted);
        }),
      ),
      cardTheme: CardThemeData(
        color: cardNavy,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: borderNavy, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
