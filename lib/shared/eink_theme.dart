import 'package:flutter/material.dart';

class EInkTheme {
  const EInkTheme._();

  static const Color ink = Color(0xFF2C2825);
  static const Color paper = Color(0xFFF5F0EB);
  static const Color muted = Color(0xFF6E6964);
  static const Color divider = Color(0xFFD8D1C9);
  static const Color panel = Color(0xFFFAF7F3);
  static const Color darkInk = Color(0xFFD4CFC8);
  static const Color darkPaper = Color(0xFF1A1A1A);
  static const Color darkMuted = Color(0xFF9B9590);
  static const Color darkDivider = Color(0xFF3A3734);
  static const Color darkPanel = Color(0xFF222222);

  static ThemeData data({bool isDark = false}) {
    final Color activeInk = isDark ? darkInk : ink;
    final Color activePaper = isDark ? darkPaper : paper;
    final Color activeMuted = isDark ? darkMuted : muted;
    final Color activeDivider = isDark ? darkDivider : divider;
    final Color activePanel = isDark ? darkPanel : panel;
    final BorderSide borderSide = BorderSide(color: activeDivider, width: 1);

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: activeInk,
        onPrimary: activePaper,
        secondary: activeInk,
        onSecondary: activePaper,
        error: activeInk,
        onError: activePaper,
        surface: activePaper,
        onSurface: activeInk,
      ),
      scaffoldBackgroundColor: activePaper,
      fontFamily: 'monospace',
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: activeInk,
          fontSize: 56,
          fontWeight: FontWeight.w300,
          letterSpacing: 0,
          height: 1,
        ),
        headlineLarge: TextStyle(
          color: activeInk,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          color: activeInk,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
        titleLarge: TextStyle(
          color: activeInk,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: activeInk, fontSize: 15),
        bodyMedium: TextStyle(color: activeMuted, fontSize: 13),
        labelLarge: TextStyle(
          color: activeInk,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: activePanel,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: borderSide,
        ),
      ),
      dividerTheme: DividerThemeData(color: activeDivider, thickness: 1),
      iconTheme: IconThemeData(color: activeInk, size: 20),
      appBarTheme: AppBarTheme(
        backgroundColor: activePaper,
        foregroundColor: activeInk,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: _buttonStyle(borderSide, activePanel, activeInk),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: _buttonStyle(borderSide, activePanel, activeInk),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: activeInk,
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: activePanel,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: borderSide,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: borderSide,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: activeInk, width: 2),
        ),
      ),
    );
  }

  static ButtonStyle _buttonStyle(
    BorderSide borderSide,
    Color background,
    Color foreground,
  ) {
    return ButtonStyle(
      backgroundColor: WidgetStateProperty.all(background),
      foregroundColor: WidgetStateProperty.all(foreground),
      elevation: WidgetStateProperty.all(0),
      minimumSize: WidgetStateProperty.all(const Size(48, 48)),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: borderSide,
        ),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }
}
