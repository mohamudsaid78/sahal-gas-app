import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  static const _notificationsKey = 'app_notifications_enabled';
  static const _offersKey = 'app_offers_enabled';
  static const _languageKey = 'app_language';
  static const _appearanceKey = 'app_appearance';
  static const _analyticsKey = 'app_analytics_enabled';
  static const _locationKey = 'app_location_enabled';

  static Future<bool> notificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
  }

  static Future<bool> offersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_offersKey) ?? true;
  }

  static Future<void> setOffersEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offersKey, value);
  }

  static Future<String> language() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'English';
  }

  static Future<void> setLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, value);
  }

  static Future<String> appearance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_appearanceKey) ?? 'Light';
  }

  static Future<void> setAppearance(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_appearanceKey, value);
  }

  static Future<bool> analyticsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_analyticsKey) ?? true;
  }

  static Future<void> setAnalyticsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_analyticsKey, value);
  }

  static Future<bool> locationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_locationKey) ?? true;
  }

  static Future<void> setLocationEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationKey, value);
  }
}
