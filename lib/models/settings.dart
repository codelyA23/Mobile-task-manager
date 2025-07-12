import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _showCompletedTasks = true;
  bool _enableNotifications = true;
  String _languageCode = 'en';
  String _dateFormat = 'MM/dd/yyyy';

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get showCompletedTasks => _showCompletedTasks;
  bool get enableNotifications => _enableNotifications;
  String get languageCode => _languageCode;
  String get dateFormat => _dateFormat;

  // Setters
  Future<bool> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      notifyListeners();
      return await saveSettings();
    } catch (e) {
      debugPrint('Error setting theme mode: $e');
      return false;
    }
  }

  Future<bool> toggleShowCompletedTasks() async {
    try {
      _showCompletedTasks = !_showCompletedTasks;
      notifyListeners();
      return await saveSettings();
    } catch (e) {
      debugPrint('Error toggling show completed tasks: $e');
      return false;
    }
  }

  Future<bool> toggleNotifications() async {
    try {
      _enableNotifications = !_enableNotifications;
      notifyListeners();
      return await saveSettings();
    } catch (e) {
      debugPrint('Error toggling notifications: $e');
      return false;
    }
  }

  Future<bool> setLanguage(String code) async {
    try {
      _languageCode = code;
      notifyListeners();
      return await saveSettings();
    } catch (e) {
      debugPrint('Error setting language: $e');
      return false;
    }
  }

  Future<bool> setDateFormat(String format) async {
    try {
      _dateFormat = format;
      notifyListeners();
      return await saveSettings();
    } catch (e) {
      debugPrint('Error setting date format: $e');
      return false;
    }
  }

  // Load settings from shared preferences
  Future<bool> loadSettings(SharedPreferences prefs) async {
    try {
      _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? ThemeMode.system.index];
      _showCompletedTasks = prefs.getBool('showCompletedTasks') ?? true;
      _enableNotifications = prefs.getBool('enableNotifications') ?? true;
      _languageCode = prefs.getString('languageCode') ?? 'en';
      _dateFormat = prefs.getString('dateFormat') ?? 'MM/dd/yyyy';
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error loading settings: $e');
      // Reset to default values
      _themeMode = ThemeMode.system;
      _showCompletedTasks = true;
      _enableNotifications = true;
      _languageCode = 'en';
      _dateFormat = 'MM/dd/yyyy';
      return false;
    }
  }

  // Save settings to shared preferences
  Future<bool> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('themeMode', _themeMode.index);
      await prefs.setBool('showCompletedTasks', _showCompletedTasks);
      await prefs.setBool('enableNotifications', _enableNotifications);
      await prefs.setString('languageCode', _languageCode);
      await prefs.setString('dateFormat', _dateFormat);
      return true;
    } catch (e) {
      debugPrint('Error saving settings: $e');
      return false;
    }
  }
}
