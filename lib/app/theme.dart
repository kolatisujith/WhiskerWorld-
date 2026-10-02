import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized Material 3 Theme for Whisker World with Light & Dark mode support
class AppTheme {
  AppTheme._();

  // Curated Brand Palette (Light)
  static const Color primaryCoral = Color(0xFFFF6B4A);
  static const Color primaryDarkCoral = Color(0xFFE25232);
  static const Color warmCream = Color(0xFFFAF7F2);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color charcoal = Color(0xFF22252A);
  static const Color charcoalLight = Color(0xFF5A5E67);
  static const Color naturalSageGreen = Color(0xFF4A7C59);
  static const Color lightSageGreen = Color(0xFFE8F1EB);
  static const Color borderSubtle = Color(0xFFE9E5DE);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color accentAmber = Color(0xFFF39C12);

  // Dark Mode Palette
  static const Color darkBackground = Color(0xFF141619);
  static const Color darkSurface = Color(0xFF1C1F24);
  static const Color darkCardBg = Color(0xFF242830);
  static const Color darkBorder = Color(0xFF333842);
  static const Color darkTextPrimary = Color(0xFFF2F4F7);
  static const Color darkTextSecondary = Color(0xFFA0A5B1);
  static const Color darkCoral = Color(0xFFFF7D5F);
  static const Color darkSageGreen = Color(0xFF5E9C72);

  /// Helper to check if dark mode is active
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  /// Dynamic background color based on theme
  static Color background(BuildContext context) {
    return isDark(context) ? darkBackground : warmCream;
  }

  /// Dynamic surface/card background color based on theme
  static Color cardBackground(BuildContext context) {
    return isDark(context) ? darkCardBg : pureWhite;
  }

  /// Dynamic elevated surface color based on theme
  static Color surface(BuildContext context) {
    return isDark(context) ? darkSurface : pureWhite;
  }

  /// Dynamic border color based on theme
  static Color border(BuildContext context) {
    return isDark(context) ? darkBorder : borderSubtle;
  }

  /// Dynamic primary text color based on theme
  static Color textPrimary(BuildContext context) {
    return isDark(context) ? darkTextPrimary : charcoal;
  }

  /// Dynamic secondary text color based on theme
  static Color textSecondary(BuildContext context) {
    return isDark(context) ? darkTextSecondary : charcoalLight;
  }

  // ================= LIGHT THEME =================
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: warmCream,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primaryCoral,
        onPrimary: pureWhite,
        primaryContainer: const Color(0xFFFFE8E2),
        onPrimaryContainer: primaryDarkCoral,
        secondary: naturalSageGreen,
        onSecondary: pureWhite,
        secondaryContainer: lightSageGreen,
        onSecondaryContainer: const Color(0xFF23442E),
        surface: pureWhite,
        onSurface: charcoal,
        error: const Color(0xFFD32F2F),
        onError: pureWhite,
      ),
      textTheme: _buildTextTheme(baseTextTheme, charcoal, charcoalLight),
      appBarTheme: const AppBarTheme(
        backgroundColor: warmCream,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: charcoal),
        titleTextStyle: TextStyle(
          color: charcoal,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCoral,
          foregroundColor: pureWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: charcoal,
          side: const BorderSide(color: borderSubtle, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: pureWhite,
        side: const BorderSide(color: borderSubtle),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: charcoal,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderSubtle,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // ================= DARK THEME =================
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: darkCoral,
        onPrimary: pureWhite,
        primaryContainer: const Color(0xFF421D15),
        onPrimaryContainer: const Color(0xFFFFB4A2),
        secondary: darkSageGreen,
        onSecondary: pureWhite,
        secondaryContainer: const Color(0xFF1B3824),
        onSecondaryContainer: const Color(0xFFBCE3C6),
        surface: darkSurface,
        onSurface: darkTextPrimary,
        error: const Color(0xFFEF5350),
        onError: pureWhite,
      ),
      textTheme: _buildTextTheme(baseTextTheme, darkTextPrimary, darkTextSecondary),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: darkTextPrimary),
        titleTextStyle: TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkCoral,
          foregroundColor: pureWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTextPrimary,
          side: const BorderSide(color: darkBorder, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurface,
        side: const BorderSide(color: darkBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: darkTextPrimary,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base, Color primaryColor, Color secondaryColor) {
    return base.copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: primaryColor,
        letterSpacing: -1.0,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primaryColor,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }
}
