import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  /// Accessible form of the existing purple brand color.
  ///
  /// It has a 4.92:1 contrast ratio against white and remains above the 3:1
  /// non-text UI threshold on the dark application background.
  static const Color primaryColor = Color(0xFF6259F5);
  static const Color secondaryColor = Color(0xFF006B5F);
  static const Color backgroundColor = Color(0xFFF2F2F7);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFB3261E);
  static const Color darkBackgroundColor = Color(0xFF121318);
  static const Color darkSurfaceColor = Color(0xFF1B1C23);

  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  /// Builds the same palette and component themes without requesting a
  /// runtime Google Font. This keeps unit tests deterministic and offline.
  @visibleForTesting
  static ThemeData buildThemeForTesting(Brightness brightness) {
    return _buildTheme(brightness, useGoogleFonts: false);
  }

  /// Kept for widgets that consume the application's public text theme.
  static TextTheme get textTheme => _buildTextTheme(_lightColorScheme);

  static ColorScheme get _lightColorScheme {
    return ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ).copyWith(
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
      onError: Colors.white,
    );
  }

  static ColorScheme get _darkColorScheme {
    final generated = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    );
    return generated.copyWith(surface: darkSurfaceColor);
  }

  static ThemeData _buildTheme(
    Brightness brightness, {
    bool useGoogleFonts = true,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = isDark ? _darkColorScheme : _lightColorScheme;
    final themedText = _buildTextTheme(
      colorScheme,
      useGoogleFonts: useGoogleFonts,
    );
    final scaffoldColor = isDark ? darkBackgroundColor : backgroundColor;
    final fieldColor =
        isDark ? colorScheme.surfaceContainerHigh : colorScheme.surface;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: colorScheme.primary,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldColor,
      canvasColor: scaffoldColor,
      textTheme: themedText,
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        modalBackgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: themedText.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: isDark ? 0 : 4,
        shadowColor: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isDark ? colorScheme.surfaceContainerLow : colorScheme.surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldColor,
        hintStyle: themedText.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.normal,
          fontSize: 13,
        ),
        border: _inputBorder(colorScheme.outlineVariant),
        enabledBorder: _inputBorder(colorScheme.outlineVariant),
        focusedBorder: _inputBorder(colorScheme.primary, width: 2),
        errorBorder: _inputBorder(colorScheme.error, width: 2),
        focusedErrorBorder: _inputBorder(colorScheme.error, width: 2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: isDark ? 0 : 4,
          shadowColor: colorScheme.primary.withValues(alpha: 0.35),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: themedText.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: themedText.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(
    ColorScheme colorScheme, {
    bool useGoogleFonts = true,
  }) {
    final platformTheme =
        colorScheme.brightness == Brightness.dark
            ? ThemeData.dark().textTheme
            : ThemeData.light().textTheme;
    final selectedTheme =
        useGoogleFonts
            ? GoogleFonts.ibmPlexSansTextTheme(platformTheme)
            : platformTheme;
    return selectedTheme
        .apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        )
        .copyWith(
          bodyLarge:
              useGoogleFonts
                  ? GoogleFonts.ibmPlexSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  )
                  : selectedTheme.bodyLarge?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
        );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
