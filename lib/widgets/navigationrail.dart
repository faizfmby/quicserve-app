import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class SideNavBarTest extends StatefulWidget {
  @override
  _SideNavBarTestState createState() => _SideNavBarTestState();
}

class _SideNavBarTestState extends State<SideNavBarTest> {
  int _page = 0;
  GlobalKey<CurvedNavigationBarState> _navKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 🔄 Rotated Navigation Bar
          RotatedBox(
            quarterTurns: 1, // 90 degrees counter-clockwise
            child: CurvedNavigationBar(
              key: _navKey,
              index: _page,
              items: const <Widget>[
                Icon(Icons.home, size: 30),
                Icon(Icons.shopping_cart, size: 30),
                Icon(Icons.bar_chart, size: 30),
                Icon(Icons.logout, size: 30),
                Icon(Icons.person, size: 30),
              ],
              color: Colors.white,
              buttonBackgroundColor: Colors.white,
              backgroundColor: Colors.transparent, // important!
              animationCurve: Curves.easeInOut,
              animationDuration: Duration(milliseconds: 600),
              onTap: (index) {
                setState(() {
                  _page = index;
                });
              },
            ),
          ),

          // 💻 Main Page Content
          Expanded(
            child: Center(
              child: Text(
                'Selected Page: $_page',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
