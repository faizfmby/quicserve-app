import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quicserve_flutter/constants/theme.dart';
import 'package:quicserve_flutter/constants/custom_icon.dart';
import 'package:quicserve_flutter/providers/auth_provider.dart';
import 'package:quicserve_flutter/screen/home/home_screen.dart';
import 'package:quicserve_flutter/screen/sales/authorization_pincode.dart';
import 'package:quicserve_flutter/widgets/alert_message.dart';
import 'package:quicserve_flutter/widgets/curved_clipper.dart';
import 'package:quicserve_flutter/widgets/order_screen%20widget/section/order_history_bar.dart';
import 'package:quicserve_flutter/widgets/sales_screen%20widget/section/reports_bar.dart';
import 'package:quicserve_flutter/widgets/setting_screen%20widget/setting_bar.dart';

class SideMenu2 extends StatefulWidget {
  const SideMenu2({Key? key}) : super(key: key);

  @override
  State<SideMenu2> createState() => _SideMenu();
}

class _SideMenu extends State<SideMenu2> {
  String pageActive = 'Home';

  @override
  void initState() {
    super.initState();
    loadCashierID();
  }

  void loadCashierID() {}

  _pageView() {
    switch (pageActive) {
      case 'Home':
        return const HomeScreen();
      case 'Order':
        return const OrderHistory();
      case 'Sales':
        return const ReportsBar();
      case 'Setting':
        return const SettingBar();
      default:
        return const HomeScreen();
    }
  }

  _setPage(String page) {
    setState(() {
      pageActive = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Row(
        children: [
          Container(
            width: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.teal,
                  AppColors.blue.withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                _logo(),
                const SizedBox(height: 20),
                _navButton(menu: 'Home', icon: AppIcons.menu),
                const SizedBox(height: 20),
                _navButton(menu: 'Order', icon: AppIcons.orders),
                const SizedBox(height: 20),
                _navButton(menu: 'Sales', icon: AppIcons.sales),
                const SizedBox(height: 20),
                _navButton(menu: 'Setting', icon: AppIcons.settings),
                const Spacer(),
                _navButton(menu: 'Logout', icon: AppIcons.logOut, isBottom: true),
                _userInfo(),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 0, right: 0),
              padding: const EdgeInsets.only(top: 0, right: 0, left: 0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
                color: AppColors.white,
              ),
              child: _pageView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logo() {
    return Column(
      children: [
        Image.asset(
          'assets/images/quicserve_logo.png',
          width: 55,
          height: 55,
        ),
        const SizedBox(height: 6),
        Text(
          'QuicServe',
          style: CustomFont.daysone14.copyWith(
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _navButton({required String menu, required IconData icon, bool isBottom = false}) {
    final bool isActive = pageActive == menu;

    return GestureDetector(
      onTap: () async {
        if (menu == 'Logout') {
          try {
            await Provider.of<AuthProvider>(context, listen: false).logout(context);
          } catch (e) {
            AlertMessage.showError(context, 'Logout failed');
          }
        } else {
          _setPage(menu);
        }

        if (menu == 'Sales' || menu == 'Setting') {
          final authorized = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AuthorizationPIN()),
          );

          if (authorized == true && menu == 'Sales') {
            setState(() => pageActive = 'Sales');
          } else if (authorized == true && menu == 'Setting') {
            setState(() => pageActive = 'Setting');
          } else {
            // optionally show a message
            AlertMessage.showError(context, 'Authorization failed');
          }
        } else {
          setState(() => pageActive = menu);
        }
      },
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 5),
          transform: pageActive == menu ? Matrix4.translationValues(0.0, -5.0, 0.0) : Matrix4.translationValues(0.0, 0.0, 0.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isActive)
                ClipPath(
                  clipper: CurvedClipper(),
                  child: Container(
                    width: 100,
                    height: 150,
                    padding: const EdgeInsets.only(bottom: 2),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppColors.white),
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.yellow2,
                                AppColors.orange2,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(2, 4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInOut,
                transform: pageActive == menu ? Matrix4.translationValues(0.0, -0.5, 0.0) : Matrix4.translationValues(0.0, 0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: isActive
                          ? Colors.black
                          : isBottom
                              ? AppColors.white
                              : AppColors.white.withOpacity(0.5),
                      size: isBottom ? 28 : 32,
                    ),
                    if (!isBottom) const SizedBox(height: 4),
                    if (!isBottom)
                      Text(
                        menu,
                        style: CustomFont.daysone10.copyWith(
                          color: isActive ? Colors.black : AppColors.white.withOpacity(0.5),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget _userInfo() {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.user?.name ?? 'Unknown';

    return Column(
      children: [
        const Divider(color: Colors.white54, thickness: 0.5, indent: 8, endIndent: 8),
        const SizedBox(height: 6),
        Icon(AppIcons.user, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          'Cashier: $userName',
          style: CustomFont.daysone10.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
