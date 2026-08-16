import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../domain/entities/app_preferences.dart';
import '../../domain/repositories/app_preferences_repository.dart';

class HiveAppPreferencesRepository implements AppPreferencesRepository {
  HiveAppPreferencesRepository({required Box<dynamic> box}) : _box = box;

  static const themeModeKey = 'app_theme_mode';
  static const languageKey = 'app_language';

  final Box<dynamic> _box;

  @override
  AppPreferences loadPreferences() {
    return AppPreferences(
      themeMode: _themeModeFromStorage(_box.get(themeModeKey)),
      language: AppLanguage.fromStorage(_box.get(languageKey)),
    );
  }

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) {
    return _box.put(themeModeKey, themeMode.name);
  }

  @override
  Future<void> saveLanguage(AppLanguage language) {
    return _box.put(languageKey, language.storageValue);
  }

  ThemeMode _themeModeFromStorage(Object? value) => switch (value) {
    'dark' => ThemeMode.dark,
    // Only light and dark are exposed by the UI. Unknown and legacy values
    // intentionally fall back to the required light default.
    _ => ThemeMode.light,
  };
}
