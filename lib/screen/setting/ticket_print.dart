import 'package:flutter/material.dart';
import 'package:quicserve_flutter/constants/theme.dart';
import 'package:quicserve_flutter/models/menu_category.dart';
import 'package:quicserve_flutter/services/api/menu_services.dart';
import 'package:quicserve_flutter/services/local/ticket_settings_storage.dart';
import 'package:quicserve_flutter/widgets/dialog/ticket_settings_dialog.dart';

class TicketPrint extends StatefulWidget {
  const TicketPrint({super.key});

  @override
  State<TicketPrint> createState() => _TicketPrintState();
}

class _TicketPrintState extends State<TicketPrint> {
  bool isFOHEnabled = true;
  bool isBOHEnabled = true;
  List<MenuCategory> categories = [];
  bool isLoading = true;

  List<String> selectedFOHCategories = [];
  List<String> selectedBOHCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _initializeStateFromStorage();
  }

  void _initializeStateFromStorage() async {
    final fohEnabled = await TicketSettingsStorage.getFOHEnabled();
    final bohEnabled = await TicketSettingsStorage.getBOHEnabled();
    final fohCategories = await TicketSettingsStorage.getFOHCategories();
    final bohCategories = await TicketSettingsStorage.getBOHCategories();
    print('FOH Categories: $fohCategories');
    print('BOH Categories: $bohCategories');

    setState(() {
      isFOHEnabled = fohEnabled;
      isBOHEnabled = bohEnabled;
      selectedFOHCategories = fohCategories;
      selectedBOHCategories = bohCategories;
    });
  }

  void _loadCategories() {
    final futureMenuCategories = MenuServices().fetchMenuCategory();

    futureMenuCategories.then((loadedCategories) {
      final validCategories = loadedCategories.where((c) => c.categoryID != null && c.categoryName != null && c.hide == 0).toList();

      setState(() {
        categories = validCategories;
        isLoading = false;
      });
    }).catchError((e) {
      print('Error loading categories: $e');
      setState(() => isLoading = false);
    });
  }

  void _showCategoryDialog({
    required String title,
    required List<String> selectedList,
    required void Function(List<String>) onSelectedChanged,
  }) {
    showDialog(
      context: context,
      builder: (_) => TicketSettingsDialog(
        title: title,
        categories: categories.map((c) => c.categoryName!).toList(),
        selectedCategories: selectedList,
        onConfirm: (list) {
          onSelectedChanged(list);
          if (title == 'FOH') {
            TicketSettingsStorage.saveFOHSettings(isFOHEnabled, list);
          } else {
            TicketSettingsStorage.saveBOHSettings(isBOHEnabled, list);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.yellow2,
                  AppColors.orange2,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Center(
              child: Text(
                'Ticket Settings',
                style: CustomFont.daysone14.copyWith(fontSize: 16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  title: const Text(
                    "Enable FOH Ticket Printing",
                    style: CustomFont.calibri22,
                  ),
                  activeColor: const Color.fromARGB(255, 64, 146, 200),
                  value: isFOHEnabled,
                  onChanged: (value) {
                    setState(() {
                      isFOHEnabled = value;
                      TicketSettingsStorage.saveFOHSettings(value, selectedFOHCategories);
                    });
                  },
                ),
                ListTile(
                  title: const Text("Select FOH Categories"),
                  subtitle: Text(selectedFOHCategories.isEmpty ? "No categories selected" : selectedFOHCategories.join(", ")),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: isFOHEnabled
                      ? () => _showCategoryDialog(
                            title: 'FOH',
                            selectedList: selectedFOHCategories,
                            onSelectedChanged: (list) {
                              setState(() => selectedFOHCategories = list);
                            },
                          )
                      : null,
                ),
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text(
                    "Enable BOH Ticket Printing",
                    style: CustomFont.calibri22,
                  ),
                  activeColor: const Color.fromARGB(255, 64, 146, 200),
                  value: isBOHEnabled,
                  onChanged: (value) {
                    setState(() {
                      isBOHEnabled = value;
                      TicketSettingsStorage.saveBOHSettings(value, selectedBOHCategories);
                    });
                  },
                ),
                ListTile(
                  title: const Text("Select BOH Categories"),
                  subtitle: Text(selectedBOHCategories.isEmpty ? "No categories selected" : selectedBOHCategories.join(", ")),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: isBOHEnabled
                      ? () => _showCategoryDialog(
                            title: 'BOH',
                            selectedList: selectedBOHCategories,
                            onSelectedChanged: (list) {
                              setState(() => selectedBOHCategories = list);
                            },
                          )
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
