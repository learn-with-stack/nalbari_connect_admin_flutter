import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appSettingsProvider = StateNotifierProvider<AppSettingsController, AppSettingsState>((ref) {
  return AppSettingsController();
});

class AppSettingsState {
  const AppSettingsState({
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
  });

  final ThemeMode themeMode;
  final bool notificationsEnabled;

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class AppSettingsController extends StateNotifier<AppSettingsState> {
  AppSettingsController() : super(const AppSettingsState()) {
    load();
  }

  static const _themeKey = 'settings.themeMode';
  static const _notificationsKey = 'settings.notificationsEnabled';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeKey);
    final notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    state = AppSettingsState(
      themeMode: _themeModeFromString(themeName),
      notificationsEnabled: notificationsEnabled,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  ThemeMode _themeModeFromString(String? value) {
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }
}
