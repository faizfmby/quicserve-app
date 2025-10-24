import 'package:flutter/material.dart';
import 'package:quicserve_flutter/constants/theme.dart';
import 'package:quicserve_flutter/models/menu_category.dart';

class MenuCategoryTabs extends StatelessWidget {
  final Future<List<MenuCategory>> futureMenuCategories;
  final bool isLoading;
  final int? selectedCategoryID;
  final Function(MenuCategory) onCategorySelected;

  const MenuCategoryTabs({
    super.key,
    required this.futureMenuCategories,
    required this.isLoading,
    required this.selectedCategoryID,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MenuCategory>>(
      future: futureMenuCategories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No menu categories found.'));
        }

        final categories = snapshot.data!.where((c) => c.categoryID != null && c.categoryName != null && c.hide == 0).toList();
        if (categories.isEmpty) {
          return const Center(child: Text('No valid menu categories found.'));
        }

        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 25),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return GestureDetector(
                      onTap: () => onCategorySelected(category),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 68, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: category.categoryID == selectedCategoryID
                                ? const LinearGradient(
                                    colors: [
                                      AppColors.yellow2,
                                      AppColors.orange2
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  )
                                : null,
                            color: category.categoryID == selectedCategoryID ? null : AppColors.lightgrey4.withOpacity(0.15),
                            border: category.categoryID == selectedCategoryID ? Border.all(color: AppColors.black, width: 2) : null,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              category.categoryName!,
                              style: CustomFont.calibribold18.copyWith(color: AppColors.darkgrey1),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
