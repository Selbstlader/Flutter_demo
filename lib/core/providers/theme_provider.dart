import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/storage_service.dart';
import '../constants/app_constants.dart';

/// 主题模式状态管理
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  /// 加载保存的主题模式
  Future<void> _loadThemeMode() async {
    final savedTheme = StorageService.getString(AppConstants.themeKey);
    if (savedTheme != null) {
      switch (savedTheme) {
        case 'light':
          state = ThemeMode.light;
          break;
        case 'dark':
          state = ThemeMode.dark;
          break;
        default:
          state = ThemeMode.system;
      }
    }
  }

  /// 切换到浅色主题
  Future<void> setLightTheme() async {
    state = ThemeMode.light;
    await StorageService.setString(AppConstants.themeKey, 'light');
  }

  /// 切换到深色主题
  Future<void> setDarkTheme() async {
    state = ThemeMode.dark;
    await StorageService.setString(AppConstants.themeKey, 'dark');
  }

  /// 切换到系统主题
  Future<void> setSystemTheme() async {
    state = ThemeMode.system;
    await StorageService.setString(AppConstants.themeKey, 'system');
  }

  /// 切换主题模式
  Future<void> toggleTheme() async {
    switch (state) {
      case ThemeMode.light:
        await setDarkTheme();
        break;
      case ThemeMode.dark:
        await setSystemTheme();
        break;
      case ThemeMode.system:
        await setLightTheme();
        break;
    }
  }
}

/// 主题模式Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);