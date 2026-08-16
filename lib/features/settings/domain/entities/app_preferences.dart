import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Language selected by the user for the application.
///
/// [system] follows the device/browser language. Its locale is intentionally
/// null so that Flutter can perform its normal locale resolution.
enum AppLanguage {
  system,
  english,
  french;

  Locale? get locale => switch (this) {
    AppLanguage.system => null,
    AppLanguage.english => const Locale('en'),
    AppLanguage.french => const Locale('fr'),
  };

  String get storageValue => switch (this) {
    AppLanguage.system => 'system',
    AppLanguage.english => 'en',
    AppLanguage.french => 'fr',
  };

  static AppLanguage fromStorage(Object? value) => switch (value) {
    'en' => AppLanguage.english,
    'fr' => AppLanguage.french,
    _ => AppLanguage.system,
  };
}

/// Device-local display preferences.
class AppPreferences extends Equatable {
  const AppPreferences({
    this.themeMode = ThemeMode.light,
    this.language = AppLanguage.system,
  });

  final ThemeMode themeMode;
  final AppLanguage language;

  /// Null means that Flutter should follow the device/browser locale.
  Locale? get locale => language.locale;

  AppPreferences copyWith({ThemeMode? themeMode, AppLanguage? language}) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
    );
  }

  @override
  List<Object> get props => [themeMode, language];
}
