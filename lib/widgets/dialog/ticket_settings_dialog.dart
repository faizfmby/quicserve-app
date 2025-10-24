import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:quicserve_flutter/constants/theme.dart';

class TicketSettingsDialog extends StatefulWidget {
  final String title;
  final List<String> categories;
  final List<String> selectedCategories;
  final Function(List<String>) onConfirm;

  const TicketSettingsDialog({
    super.key,
    required this.title,
    required this.categories,
    required this.selectedCategories,
    required this.onConfirm,
  });

  @override
  State<TicketSettingsDialog> createState() => _TicketSettingsDialogState();
}

class _TicketSettingsDialogState extends State<TicketSettingsDialog> {
  late List<String> tempSelected;

  @override
  void initState() {
    super.initState();
    tempSelected = List.from(widget.selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 520,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.yellow1,
                        AppColors.orange1
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.title, style: CustomFont.daysone14),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            tempSelected.clear();
                          });
                        },
                        child: const Text(
                          'Reset',
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    height: 300, // max height for the list, adjust as needed
                    child: ListView(
                      shrinkWrap: true,
                      children: widget.categories.map((category) {
                        return CheckboxListTile(
                          activeColor: const Color.fromARGB(255, 64, 146, 200),
                          value: tempSelected.contains(category),
                          title: Text(category),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                tempSelected.add(category);
                              } else {
                                tempSelected.remove(category);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                            alignment: Alignment.center,
                            child: Text(
                              'Cancel',
                              style: CustomFont.calibri16.copyWith(color: AppColors.black),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          widget.onConfirm(tempSelected);
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: AppColors.gradient2,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            alignment: Alignment.center,
                            child: Text(
                              'Confirm',
                              style: CustomFont.calibri16.copyWith(color: AppColors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
