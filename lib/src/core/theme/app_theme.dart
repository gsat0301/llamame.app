import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// "Professional & Reliable" palette
// Main Blue · Bright Yellow accent · White / Light-Gray background
// ---------------------------------------------------------------------------

class AppTheme {
  AppTheme._();

  // ── Brand colours ──────────────────────────────────────────────────────
  static const _blue = Color(0xFF1565C0);
  static const _blueLight = Color(0xFF1E88E5);
  static const _blueDark = Color(0xFF0D47A1);
  static const _yellow = Color(0xFFFFC107);
  static const _yellowDark = Color(0xFFFFA000);

  static const _bgLight = Color(0xFFF5F7FA);
  static const _surface = Color(0xFFFFFFFF);
  static const _textDark = Color(0xFF1A1A2E);
  static const _textSubtle = Color(0xFF64748B);
  static const _error = Color(0xFFD32F2F);

  // Dark-mode surfaces
  static const _bgDarkScaffold = Color(0xFF121212);
  static const _surfaceDark = Color(0xFF1E1E1E);
  static const _surfaceDarkHi = Color(0xFF2C2C2C);

  // ── Light theme ────────────────────────────────────────────────────────
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: _textDark,
      displayColor: _textDark,
    );

    const colorScheme = ColorScheme.light(
      primary: _blue,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFD4E4FA),
      onPrimaryContainer: _blueDark,
      secondary: _yellow,
      onSecondary: _textDark,
      secondaryContainer: Color(0xFFFFF3D0),
      onSecondaryContainer: Color(0xFF5D4200),
      tertiary: _blueLight,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFBBDEFB),
      onTertiaryContainer: _blueDark,
      error: _error,
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF93000A),
      surface: _surface,
      onSurface: _textDark,
      onSurfaceVariant: _textSubtle,
      outline: Color(0xFFBDBDBD),
      outlineVariant: Color(0xFFE0E0E0),
      surfaceContainerHighest: Color(0xFFEEEEEE),
      surfaceContainerHigh: Color(0xFFF0F0F0),
      surfaceContainerLowest: Color(0xFFFAFAFA),
      inversePrimary: Color(0xFF90CAF9),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: _bgLight,

      // ── AppBar ────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: _blue,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black26,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // ── Buttons ───────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _blue.withValues(alpha: 0.38),
          disabledForegroundColor: Colors.white54,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _blue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _blue,
          side: const BorderSide(color: _blue, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // ── Segmented button ──────────────────────────────────────────────
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return _yellow;
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return _textDark;
            return Colors.white70;
          }),
          side: WidgetStateProperty.all(
            const BorderSide(color: Colors.white54, width: 1),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),

      // ── Input fields ─────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F9FB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _error),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: _textSubtle),
        hintStyle: textTheme.bodyMedium
            ?.copyWith(color: _textSubtle.withValues(alpha: 0.6)),
      ),

      // ── Cards ─────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),

      // ── Chips ─────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFE3F0FF),
        labelStyle: textTheme.labelMedium?.copyWith(color: _blueDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ── Navigation bar ────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surface,
        elevation: 4,
        shadowColor: Colors.black12,
        indicatorColor: const Color(0xFFD4E4FA),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _blue, size: 24);
          }
          return const IconThemeData(color: _textSubtle, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: _blue,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(color: _textSubtle);
        }),
      ),

      // ── Tabs ──────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: _yellow, width: 3),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: textTheme.labelLarge,
      ),

      // ── Dialogs ───────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: _surface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: _textDark,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ── SnackBar ──────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF323232),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // ── Bottom sheet ──────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // ── Checkbox ──────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _blue;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),

      // ── Floating action button ────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _yellow,
        foregroundColor: _textDark,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ── Divider ───────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE8E8E8),
        thickness: 1,
      ),

      // ── Progress indicators ───────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _blue,
        linearTrackColor: Color(0xFFD4E4FA),
      ),
    );
  }

  // ── Dark theme ─────────────────────────────────────────────────────────
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );

    const colorScheme = ColorScheme.dark(
      primary: _blueLight,
      onPrimary: Color(0xFF0D47A1),
      primaryContainer: Color(0xFF1A3A5C),
      onPrimaryContainer: Color(0xFFBBDEFB),
      secondary: _yellowDark,
      onSecondary: _textDark,
      secondaryContainer: Color(0xFF5D4200),
      onSecondaryContainer: Color(0xFFFFE082),
      tertiary: Color(0xFF64B5F6),
      onTertiary: Color(0xFF0D47A1),
      tertiaryContainer: Color(0xFF1A3A5C),
      onTertiaryContainer: Color(0xFFBBDEFB),
      error: Color(0xFFEF5350),
      onError: Colors.white,
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: _surfaceDark,
      onSurface: Colors.white,
      onSurfaceVariant: Color(0xFFB0B0B0),
      outline: Color(0xFF5A5A5A),
      outlineVariant: Color(0xFF3A3A3A),
      surfaceContainerHighest: _surfaceDarkHi,
      surfaceContainerHigh: Color(0xFF262626),
      surfaceContainerLowest: Color(0xFF0E0E0E),
      inversePrimary: _blue,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: _bgDarkScaffold,
      appBarTheme: AppBarTheme(
        backgroundColor: _surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _blueLight,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _blueLight.withValues(alpha: 0.38),
          disabledForegroundColor: Colors.white54,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _blueLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _blueLight,
          side: const BorderSide(color: _blueLight, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return _yellowDark;
            return Colors.transparent;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return _textDark;
            return Colors.white60;
          }),
          side: WidgetStateProperty.all(
            const BorderSide(color: Colors.white30, width: 1),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceDarkHi,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5A5A5A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5A5A5A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _blueLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF5350)),
        ),
        labelStyle:
            textTheme.bodyMedium?.copyWith(color: const Color(0xFFB0B0B0)),
        hintStyle:
            textTheme.bodyMedium?.copyWith(color: const Color(0xFF808080)),
      ),
      cardTheme: CardThemeData(
        color: _surfaceDark,
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1A3A5C),
        labelStyle:
            textTheme.labelMedium?.copyWith(color: const Color(0xFFBBDEFB)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surfaceDark,
        elevation: 0,
        indicatorColor: const Color(0xFF1A3A5C),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _blueLight, size: 24);
          }
          return const IconThemeData(color: Color(0xFFB0B0B0), size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: _blueLight,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelSmall?.copyWith(color: const Color(0xFFB0B0B0));
        }),
      ),
      tabBarTheme: TabBarThemeData(
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: _yellowDark, width: 3),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: textTheme.labelLarge,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: _surfaceDark,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surfaceDarkHi,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _blueLight;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _yellowDark,
        foregroundColor: _textDark,
        elevation: 4,
        shape: CircleBorder(),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF3A3A3A),
        thickness: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _blueLight,
        linearTrackColor: Color(0xFF1A3A5C),
      ),
    );
  }
}
