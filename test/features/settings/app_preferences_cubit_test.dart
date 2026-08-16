import 'package:billing_app/features/settings/domain/entities/app_preferences.dart';
import 'package:billing_app/features/settings/domain/repositories/app_preferences_repository.dart';
import 'package:billing_app/features/settings/presentation/bloc/app_preferences_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('restores preferences supplied by the repository', () {
    final repository = _FakePreferencesRepository(
      initial: const AppPreferences(
        themeMode: ThemeMode.dark,
        language: AppLanguage.french,
      ),
    );
    final cubit = AppPreferencesCubit(repository: repository);
    addTearDown(cubit.close);

    expect(cubit.state.themeMode, ThemeMode.dark);
    expect(cubit.state.language, AppLanguage.french);
    expect(cubit.state.locale, const Locale('fr'));
  });

  test('updates and persists the selected theme', () async {
    final repository = _FakePreferencesRepository();
    final cubit = AppPreferencesCubit(repository: repository);
    addTearDown(cubit.close);

    expect(await cubit.setThemeMode(ThemeMode.dark), isTrue);

    expect(cubit.state.themeMode, ThemeMode.dark);
    expect(repository.savedThemeMode, ThemeMode.dark);
  });

  test('updates language and exposes its locale', () async {
    final repository = _FakePreferencesRepository();
    final cubit = AppPreferencesCubit(repository: repository);
    addTearDown(cubit.close);

    expect(await cubit.setLanguage(AppLanguage.english), isTrue);

    expect(cubit.state.language, AppLanguage.english);
    expect(cubit.state.locale, const Locale('en'));
    expect(repository.savedLanguage, AppLanguage.english);
  });

  test('restores the previous theme when persistence fails', () async {
    final repository = _FakePreferencesRepository(failWrites: true);
    final cubit = AppPreferencesCubit(repository: repository);
    addTearDown(cubit.close);

    expect(await cubit.setThemeMode(ThemeMode.dark), isFalse);
    expect(cubit.state.themeMode, ThemeMode.light);
  });
}

class _FakePreferencesRepository implements AppPreferencesRepository {
  _FakePreferencesRepository({
    this.initial = const AppPreferences(),
    this.failWrites = false,
  });

  final AppPreferences initial;
  final bool failWrites;
  ThemeMode? savedThemeMode;
  AppLanguage? savedLanguage;

  @override
  AppPreferences loadPreferences() => initial;

  @override
  Future<void> saveLanguage(AppLanguage language) async {
    if (failWrites) throw StateError('write failed');
    savedLanguage = language;
  }

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    if (failWrites) throw StateError('write failed');
    savedThemeMode = themeMode;
  }
}
