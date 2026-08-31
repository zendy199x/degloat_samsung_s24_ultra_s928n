import 'package:flutter/material.dart';

class AppColors {
  static const List<Color> lightBgGradient = [
    Color(0xFFE2E8F0),
    Color(0xFFECE9E6),
    Color(0xFFE8E5F7),
  ];

  static const List<Color> darkBgGradient = [
    Color(0xFF0F172A),
    Color(0xFF070B19),
    Color(0xFF1E112C),
  ];

  static Color lightPanelBg = Colors.white.withValues(alpha: 0.35);
  static Color darkPanelBg = const Color(0xFF0F1422).withValues(alpha: 0.35);

  static Color lightBorder = Colors.black.withValues(alpha: 0.08);
  static Color darkBorder = Colors.white.withValues(alpha: 0.08);

  static const Color cyanAccent = Color(0xFF00E5FF);
  static const Color blueAccent = Color(0xFF00B0FF);
  static const Color purpleAccent = Color(0xFF7C4DFF);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF4F5F7),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF007AFF),
        onPrimary: Colors.white,
        secondary: Color(0xFF8E8E93),
        surface: Color(0xFFF9FAFB),
        surfaceContainerHighest: Color(0xFFE8E8ED),
        onSurface: Color(0xFF1C1C1E),
        error: Color(0xFFFF3B30),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.72),
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      dividerColor: Colors.black.withValues(alpha: 0.06),
      iconTheme: const IconThemeData(color: Color(0xFF1D1D1F)),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0B0F),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF5AC8FA),
        onPrimary: Color(0xFF001A2D),
        secondary: Color(0xFFA78BFA),
        surface: Color(0xFF121721),
        surfaceContainerHighest: Color(0xFF1D2433),
        onSurface: Color(0xFFF2F4F8),
        error: Color(0xFFFF453A),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF171D2A).withValues(alpha: 0.78),
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      dividerColor: Colors.white.withValues(alpha: 0.08),
      iconTheme: const IconThemeData(color: Color(0xFFEAF2FF)),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF171D2A).withValues(alpha: 0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
