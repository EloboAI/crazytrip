import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Provider - Manages dark mode state and preferences
/// Supports manual, automatic (system), and scheduled theme modes
class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _autoModeKey = 'auto_mode_enabled';
  static const String _scheduleStartKey = 'schedule_start_hour';
  static const String _scheduleEndKey = 'schedule_end_hour';

  ThemeMode _themeMode = ThemeMode.system;
  bool _autoModeEnabled = false;
  int _scheduleStartHour = 20; // 8 PM
  int _scheduleEndHour = 7; // 7 AM

  ThemeMode get themeMode => _themeMode;
  bool get autoModeEnabled => _autoModeEnabled;
  int get scheduleStartHour => _scheduleStartHour;
  int get scheduleEndHour => _scheduleEndHour;

  /// Check if dark mode is currently active
  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;

    // For system mode, check platform brightness
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  /// Initialize theme from saved preferences
  Future<void> loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load theme mode
      final themeModeIndex =
          prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
      _themeMode = ThemeMode.values[themeModeIndex];

      // Load auto mode settings
      _autoModeEnabled = prefs.getBool(_autoModeKey) ?? false;
      _scheduleStartHour = prefs.getInt(_scheduleStartKey) ?? 20;
      _scheduleEndHour = prefs.getInt(_scheduleEndKey) ?? 7;

      // Apply auto mode if enabled
      if (_autoModeEnabled) {
        _applyAutoMode();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _autoModeEnabled = false; // Disable auto mode when manually setting
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
      await prefs.setBool(_autoModeKey, false);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }

  /// Enable/disable automatic theme mode
  Future<void> setAutoMode(bool enabled) async {
    _autoModeEnabled = enabled;

    if (enabled) {
      _applyAutoMode();
    }

    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoModeKey, enabled);
    } catch (e) {
      debugPrint('Error saving auto mode: $e');
    }
  }

  /// Set custom schedule for dark mode
  Future<void> setSchedule(int startHour, int endHour) async {
    if (startHour < 0 || startHour > 23 || endHour < 0 || endHour > 23) {
      throw ArgumentError('Hours must be between 0 and 23');
    }

    _scheduleStartHour = startHour;
    _scheduleEndHour = endHour;

    if (_autoModeEnabled) {
      _applyAutoMode();
    }

    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_scheduleStartKey, startHour);
      await prefs.setInt(_scheduleEndKey, endHour);
    } catch (e) {
      debugPrint('Error saving schedule: $e');
    }
  }

  /// Use system theme preference
  Future<void> useSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  /// Apply automatic theme based on current time or system preference
  void _applyAutoMode() {
    final now = DateTime.now();
    final currentHour = now.hour;

    // Check if current time is within dark mode schedule
    bool shouldBeDark;
    if (_scheduleStartHour > _scheduleEndHour) {
      // Overnight schedule (e.g., 20:00 to 07:00)
      shouldBeDark =
          currentHour >= _scheduleStartHour || currentHour < _scheduleEndHour;
    } else {
      // Same day schedule (e.g., 08:00 to 18:00)
      shouldBeDark =
          currentHour >= _scheduleStartHour && currentHour < _scheduleEndHour;
    }

    _themeMode = shouldBeDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// Get readable description of current theme mode
  String get themeModeDescription {
    if (_autoModeEnabled) {
      return 'Auto (${_formatHour(_scheduleStartHour)} - ${_formatHour(_scheduleEndHour)})';
    }

    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:00 $period';
  }
}
