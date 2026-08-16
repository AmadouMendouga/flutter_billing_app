import 'package:flutter/material.dart';

import '../entities/app_preferences.dart';

abstract interface class AppPreferencesRepository {
  AppPreferences loadPreferences();

  Future<void> saveThemeMode(ThemeMode themeMode);

  Future<void> saveLanguage(AppLanguage language);
}
