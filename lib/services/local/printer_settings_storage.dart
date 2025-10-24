import 'package:shared_preferences/shared_preferences.dart';

class PrinterSettingsStorage {
  static const _keyPrinterName = 'connectedPrinter';

  static Future<void> savePrinterName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPrinterName, name);
  }

  static Future<void> removePrinterName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPrinterName);
  }

  static Future<String?> getPrinterName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPrinterName);
  }
}
