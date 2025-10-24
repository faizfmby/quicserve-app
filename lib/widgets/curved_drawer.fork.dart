import 'package:curved_drawer_fork/curved_drawer_fork.dart';
import 'package:flutter/material.dart';
import 'package:quicserve_flutter/constants/custom_icon.dart';

class AppDrawer extends StatelessWidget {
  final PageController pageController;

  const AppDrawer({Key? key, required this.pageController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // **🔹 Drawer Background (to prevent white background)**
        Container(
          color: Colors.transparent, // Ensures the rest of the screen remains visible
        ),

        // **🔹 Positioned Drawer**
        Align(
          alignment: Alignment.centerLeft, // Ensures it stays on the left
          child: Container(
            width: 110, // Adjust to match the design properly
            height: MediaQuery.of(context).size.height, // Full height
            child: Drawer(
              backgroundColor: Colors.transparent, // Keeps background clean
              child: Column(
                children: [
                  // **🔹 Logo at the Top**
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Image.asset(
                      'images/quicserve_logo.png',
                      width: 70,
                    ),
                  ),

                  // **🔹 Curved Drawer Menu**
                  Scaffold(
                    drawer: CurvedDrawer(
                      color: Colors.white,
                      labelColor: Colors.black54,
                      width: 75.0,
                      items: const <DrawerItem>[
                        DrawerItem(icon: Icon(AppIcons.close)),
                        //Optional Label Text
                        DrawerItem(icon: Icon(AppIcons.menu), label: "Messages")
                      ],
                      onTap: (index) {
                        //Handle button tap
                      },
                    ),
                    body: Container(),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
