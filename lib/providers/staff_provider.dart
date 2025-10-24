import 'package:flutter/material.dart';

class StaffProvider with ChangeNotifier {
  String _staffName = '...';

  String get staffName => _staffName;

  void setStaffName(String name) {
    _staffName = name;
    notifyListeners();
  }

  Future<void> loadStaffFromSessionOrDB() async {
    // Example: simulate fetching
    await Future.delayed(const Duration(milliseconds: 500));
    _staffName = 'John Doe'; // ← Replace this with actual fetch logic
    notifyListeners();
  }
}
