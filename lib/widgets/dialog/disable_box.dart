import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quicserve_flutter/constants/theme.dart';
import 'package:quicserve_flutter/models/menu_item.dart';
import 'package:quicserve_flutter/services/api/menu_services.dart';

class DisableItemDialog extends StatefulWidget {
  final MenuItem item;
  final int? selectedCategoryIndex;
  final VoidCallback refreshItems;

  const DisableItemDialog({
    required this.item,
    required this.selectedCategoryIndex,
    required this.refreshItems,
  });

  @override
  State<DisableItemDialog> createState() => DisableItemDialogState();
}

class DisableItemDialogState extends State<DisableItemDialog> {
  late bool isInStock;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isInStock = widget.item.disable == 0;
  }

  Future<void> _updateStatus(bool newValue) async {
    if (widget.item.itemID == null) return;
    setState(() => isLoading = true);
    try {
      await MenuServices().updateItemDisable(widget.item.itemID!, newValue ? 0 : 1);
      widget.refreshItems(); // e.g., re-fetch menu items
      Navigator.pop(context);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          backgroundColor: Colors.transparent,
          child: Container(
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
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
                  child: const Center(
                    child: Text('Disable Item', style: CustomFont.daysone14),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'In Stock?',
                  style: CustomFont.calibribold24,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No'),
                    const SizedBox(width: 20),
                    Switch(
                      activeColor: const Color.fromARGB(255, 64, 146, 200),
                      value: isInStock,
                      onChanged: (value) {
                        setState(() => isInStock = value);
                        _updateStatus(value);
                      },
                    ),
                    const SizedBox(width: 20),
                    const Text('Yes'),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
