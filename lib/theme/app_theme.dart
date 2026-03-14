import 'package:flutter/material.dart';

class AppTheme {
  // Core palette - Indigo/Teal campus vibe
  static const Color primary = Color(0xFF4F46E5);       // Indigo 600
  static const Color primaryLight = Color(0xFF818CF8);   // Indigo 400
  static const Color primaryDark = Color(0xFF3730A3);    // Indigo 800
  static const Color secondary = Color(0xFF0D9488);      // Teal 600
  static const Color secondaryLight = Color(0xFF5EEAD4); // Teal 300

  // Status colors
  static const Color lost = Color(0xFFDC2626);           // Red 600
  static const Color lostLight = Color(0xFFFEE2E2);      // Red 100
  static const Color found = Color(0xFF059669);           // Emerald 600
  static const Color foundLight = Color(0xFFD1FAE5);      // Emerald 100
  static const Color warning = Color(0xFFF59E0B);         // Amber 500
  static const Color warningLight = Color(0xFFFEF3C7);    // Amber 100

  // Neutrals
  static const Color surface = Color(0xFFF8FAFC);        // Slate 50
  static const Color surfaceCard = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);    // Slate 800
  static const Color textSecondary = Color(0xFF64748B);  // Slate 500
  static const Color textMuted = Color(0xFF94A3B8);      // Slate 400
  static const Color border = Color(0xFFE2E8F0);         // Slate 200
  static const Color divider = Color(0xFFF1F5F9);        // Slate 100

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,

      // AppBar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: textPrimary,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
        color: surfaceCard,
        margin: EdgeInsets.zero,
      ),

      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: primary, width: 1.5),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: lost),
        ),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 14),
        prefixIconColor: textMuted,
      ),

      // Chips
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: const BorderSide(color: border),
        backgroundColor: Colors.white,
        selectedColor: primary.withValues(alpha: 0.12),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Navigation bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        indicatorColor: primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primary,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: textSecondary, size: 24);
        }),
      ),

      // Badge
      badgeTheme: const BadgeThemeData(
        backgroundColor: lost,
        textColor: Colors.white,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: textPrimary,
      ),

      // ListTile
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
