import 'package:shared_preferences/shared_preferences.dart';

class TicketSettingsStorage {
  static Future<void> saveFOHSettings(bool enabled, List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('foh_enabled', enabled);
    await prefs.setStringList('foh_categories', categories);
  }

  static Future<void> saveBOHSettings(bool enabled, List<String> categories) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('boh_enabled', enabled);
    await prefs.setStringList('boh_categories', categories);
  }

  static Future<bool> getFOHEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('foh_enabled') ?? true;
  }

  static Future<List<String>> getFOHCategories() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('foh_categories') ?? [];
  }

  static Future<bool> getBOHEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('boh_enabled') ?? true;
  }

  static Future<List<String>> getBOHCategories() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('boh_categories') ?? [];
  }
}
