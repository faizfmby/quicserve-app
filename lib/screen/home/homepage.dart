/* import 'package:flutter/material.dart';
import 'package:quicserve_flutter/models/menu_category.dart';
import 'package:quicserve_flutter/models/menu_item.dart';
import 'package:quicserve_flutter/services/api_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<MenuCategory>> futureMenuCategories;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Column(children: [
          SizedBox(
            child: FutureBuilder<List<MenuCategory>>(
              future: ApiService.fetchMenuCategory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No categories found.');
                } else {
                  final categories = snapshot.data!;
                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(categories[index].categoryName!),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Expanded(
              child: SizedBox(
            child: FutureBuilder<List<MenuItem>>(
              future: ApiService.fetchMenuItems(categoryID: 3),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No items found.');
                } else {
                  final items = snapshot.data!;
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(items[index].itemName!),
                        subtitle: Text('RM ${items[index].price!.toStringAsFixed(2)}'),
                      );
                    },
                  );
                }
              },
            ),
          ))
        ]),
      )
    ]);
  }
}
 */