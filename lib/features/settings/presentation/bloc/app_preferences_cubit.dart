import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_preferences.dart';
import '../../domain/repositories/app_preferences_repository.dart';

class AppPreferencesCubit extends Cubit<AppPreferences> {
  AppPreferencesCubit({required AppPreferencesRepository repository})
    : _repository = repository,
      super(repository.loadPreferences());

  final AppPreferencesRepository _repository;

  /// Applies the new theme immediately and persists it locally.
  ///
  /// Returns false and restores the previous value if local persistence fails,
  /// allowing the settings screen to display an error without an unhandled
  /// asynchronous exception.
  Future<bool> setThemeMode(ThemeMode themeMode) async {
    if (themeMode == state.themeMode) return true;

    final previous = state;
    emit(state.copyWith(themeMode: themeMode));
    try {
      await _repository.saveThemeMode(themeMode);
      return true;
    } catch (_) {
      emit(previous);
      return false;
    }
  }

  /// Applies and persists the selected application language.
  Future<bool> setLanguage(AppLanguage language) async {
    if (language == state.language) return true;

    final previous = state;
    emit(state.copyWith(language: language));
    try {
      await _repository.saveLanguage(language);
      return true;
    } catch (_) {
      emit(previous);
      return false;
    }
  }
}
