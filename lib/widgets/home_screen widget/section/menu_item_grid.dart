import 'package:flutter/material.dart';
import 'package:quicserve_flutter/constants/theme.dart';
import 'package:quicserve_flutter/models/menu_item.dart';

class MenuItemGrid extends StatelessWidget {
  final Future<List<MenuItem>> futureMenuItems;
  final Widget Function(MenuItem item) itemBuilder;

  const MenuItemGrid({
    super.key,
    required this.futureMenuItems,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MenuItem>>(
      future: futureMenuItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Opacity(
              opacity: 0.25,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_outlined,
                    size: 80,
                    color: AppColors.black,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No item in this category',
                    style: CustomFont.calibribold18.copyWith(color: AppColors.black),
                  ),
                ],
              ),
            ),
          );
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10, // Added spacing
            mainAxisSpacing: 10, // Added spacing
            childAspectRatio: 1 / 1.35,
          ),
          padding: const EdgeInsets.only(right: 5),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            return itemBuilder(item);
          },
        );
      },
    );
  }
}
