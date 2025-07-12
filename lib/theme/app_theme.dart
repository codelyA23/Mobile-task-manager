import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light theme colors
  static const Color _lightPrimaryColor = Color(0xFF6C63FF);
  static const Color _lightSecondaryColor = Color(0xFFFF6584);
  static const Color _lightBackgroundColor = Color(0xFFF8F9FF);
  static const Color _lightCardColor = Colors.white;
  static const Color _lightTextPrimary = Color(0xFF2D3748);
  static const Color _lightTextSecondary = Color(0xFF718096);
  static const Color _lightDividerColor = Color(0xFFE2E8F0);

  // Dark theme colors
  static const Color _darkPrimaryColor = Color(0xFF8B85FF);
  static const Color _darkSecondaryColor = Color(0xFFFF8FA3);
  static const Color _darkBackgroundColor = Color(0xFF121212);
  static const Color _darkCardColor = Color(0xFF1E1E1E);
  static const Color _darkTextPrimary = Color(0xFFFFFFFF);
  static const Color _darkTextSecondary = Color(0xFFA0AEC0);
  static const Color _darkDividerColor = Color(0xFF2D3748);

  // Common colors
  static const Color successColor = Color(0xFF48BB78);
  static const Color warningColor = Color(0xFFED8936);
  static const Color errorColor = Color(0xFFF56565);

  static ThemeData get lightTheme => _buildTheme(
        brightness: Brightness.light,
        primaryColor: _lightPrimaryColor,
        secondaryColor: _lightSecondaryColor,
        backgroundColor: _lightBackgroundColor,
        cardColor: _lightCardColor,
        textPrimary: _lightTextPrimary,
        textSecondary: _lightTextSecondary,
        dividerColor: _lightDividerColor,
      );

  static ThemeData get darkTheme => _buildTheme(
        brightness: Brightness.dark,
        primaryColor: _darkPrimaryColor,
        secondaryColor: _darkSecondaryColor,
        backgroundColor: _darkBackgroundColor,
        cardColor: _darkCardColor,
        textPrimary: _darkTextPrimary,
        textSecondary: _darkTextSecondary,
        dividerColor: _darkDividerColor,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primaryColor,
    required Color secondaryColor,
    required Color backgroundColor,
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color dividerColor,
  }) {
    final isDark = brightness == Brightness.dark;
    
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        surface: cardColor,
        onSurface: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? _darkCardColor : Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.poppins(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.poppins(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),
      cardTheme: CardTheme(
        elevation: isDark ? 4 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: dividerColor, width: isDark ? 0 : 1),
        ),
        color: cardColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? _darkCardColor : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: GoogleFonts.poppins(
          color: textSecondary.withOpacity(0.6),
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        elevation: 2,
      ),
      dividerColor: dividerColor,
      dividerTheme: DividerThemeData(
        color: dividerColor.withOpacity(0.5),
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(
        color: textPrimary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }
            return isDark ? Colors.grey.shade400 : Colors.grey.shade600;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor.withOpacity(0.5);
            }
            return isDark ? Colors.grey.shade800 : Colors.grey.shade300;
          },
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: isDark ? const Color(0xFF242424) : Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        titleTextStyle: GoogleFonts.poppins(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        contentTextStyle: GoogleFonts.poppins(
          color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
          fontSize: 15,
          height: 1.5,
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        alignment: Alignment.center,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
