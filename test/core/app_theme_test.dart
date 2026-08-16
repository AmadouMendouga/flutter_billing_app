import 'package:billing_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final lightTheme = AppTheme.buildThemeForTesting(Brightness.light);
  final darkTheme = AppTheme.buildThemeForTesting(Brightness.dark);

  test('exposes complete light and dark themes', () {
    expect(lightTheme.brightness, Brightness.light);
    expect(lightTheme.colorScheme.brightness, Brightness.light);
    expect(darkTheme.brightness, Brightness.dark);
    expect(darkTheme.colorScheme.brightness, Brightness.dark);
    expect(darkTheme.scaffoldBackgroundColor, AppTheme.darkBackgroundColor);
  });

  test('theme text and primary pairs meet normal-text contrast', () {
    for (final theme in [lightTheme, darkTheme]) {
      final scheme = theme.colorScheme;

      expect(
        _contrastRatio(scheme.onSurface, scheme.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(scheme.onPrimary, scheme.primary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        _contrastRatio(scheme.onError, scheme.error),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  test('legacy brand color remains visible on both app backgrounds', () {
    expect(
      _contrastRatio(AppTheme.primaryColor, AppTheme.surfaceColor),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(AppTheme.primaryColor, AppTheme.darkSurfaceColor),
      greaterThanOrEqualTo(3),
    );
  });
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter =
      foregroundLuminance > backgroundLuminance
          ? foregroundLuminance
          : backgroundLuminance;
  final darker =
      foregroundLuminance > backgroundLuminance
          ? backgroundLuminance
          : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
