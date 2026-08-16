import 'dart:io';

import 'package:billing_app/features/settings/data/repositories/hive_app_preferences_repository.dart';
import 'package:billing_app/features/settings/domain/entities/app_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory temporaryDirectory;
  late Box<dynamic> box;
  late HiveAppPreferencesRepository repository;

  setUpAll(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'billing_app_preferences_test_',
    );
    Hive.init(temporaryDirectory.path);
    box = await Hive.openBox<dynamic>('app_preferences_test');
    repository = HiveAppPreferencesRepository(box: box);
  });

  setUp(() => box.clear());

  tearDownAll(() async {
    await box.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test('uses light theme and system language by default', () {
    final preferences = repository.loadPreferences();

    expect(preferences.themeMode, ThemeMode.light);
    expect(preferences.language, AppLanguage.system);
    expect(preferences.locale, isNull);
  });

  test('persists dark theme and French language', () async {
    await repository.saveThemeMode(ThemeMode.dark);
    await repository.saveLanguage(AppLanguage.french);

    final restored = repository.loadPreferences();

    expect(restored.themeMode, ThemeMode.dark);
    expect(restored.language, AppLanguage.french);
    expect(restored.locale, const Locale('fr'));
    expect(box.get(HiveAppPreferencesRepository.themeModeKey), 'dark');
    expect(box.get(HiveAppPreferencesRepository.languageKey), 'fr');
  });

  test('falls back safely when stored values are unknown', () async {
    await box.put(HiveAppPreferencesRepository.themeModeKey, 'unexpected');
    await box.put(HiveAppPreferencesRepository.languageKey, 'de');

    final restored = repository.loadPreferences();

    expect(restored, const AppPreferences());
  });

  test('maps English and French to explicit locales', () {
    expect(AppLanguage.english.locale, const Locale('en'));
    expect(AppLanguage.french.locale, const Locale('fr'));
    expect(AppLanguage.system.locale, isNull);
  });
}
