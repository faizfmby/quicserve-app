class AppState {
  int? _statusIndex;
  int? getStatusIndex() => _statusIndex;
  void setStatusIndex(int index) {
    _statusIndex = index;
  }

  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  // Selected Order ID
  String? selectedOrderIndex;
  void setSelectedOrder(String? orderID) {
    selectedOrderIndex = orderID;
  }

  String? getSelectedOrder() {
    return selectedOrderIndex;
  }

  // FOH/BOH Ticket Settings
  bool isFOHEnabled = true;
  bool isBOHEnabled = true;

  List<String> selectedFOHCategories = [];
  List<String> selectedBOHCategories = [];

  void setFOHSettings({required bool enabled, required List<String> categories}) {
    isFOHEnabled = enabled;
    selectedFOHCategories = categories;
  }

  void setBOHSettings({required bool enabled, required List<String> categories}) {
    isBOHEnabled = enabled;
    selectedBOHCategories = categories;
  }
}
