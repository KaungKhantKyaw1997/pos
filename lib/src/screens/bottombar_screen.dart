import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pos/global.dart';
import 'package:pos/src/providers/bottom_provider.dart';
import 'package:pos/src/providers/cart_provider.dart';
import 'package:pos/src/screens/cart_screen.dart';
import 'package:pos/src/screens/history_screen.dart';
import 'package:pos/src/screens/home_screen.dart';
import 'package:pos/src/screens/setting_screen.dart';
import 'package:provider/provider.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  List navItems = [];

  getData(useMobileLayout) async {
    if (!useMobileLayout) {
      navItems = [
        {"index": 0, "icon": "assets/icons/home.svg", "label": "Home"},
        {"index": 1, "icon": "assets/icons/history.svg", "label": "History"},
        {"index": 2, "icon": "assets/icons/setting.svg", "label": "Settings"}
      ];
    } else {
      navItems = [
        {"index": 0, "icon": "assets/icons/home.svg", "label": "Home"},
        {"index": 1, "icon": "assets/icons/cart.svg", "label": "Cart"},
        {"index": 2, "icon": "assets/icons/history.svg", "label": "History"},
        {"index": 3, "icon": "assets/icons/setting.svg", "label": "Settings"}
      ];
    }
  }

  Future<void> _onTabSelected(int index) async {
    BottomProvider bottomProvider =
        Provider.of<BottomProvider>(context, listen: false);

    if (bottomProvider.currentIndex != index) {
      bottomProvider.selectIndex(index);

      var data = navItems[index];
      if (data["label"] == 'Home') {
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return HomeScreen();
            },
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child) {
              return child;
            },
            transitionDuration: Duration(seconds: 0),
          ),
          (route) => false,
        );
      } else if (data["label"] == 'Cart') {
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return CartScreen();
            },
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child) {
              return child;
            },
            transitionDuration: Duration(seconds: 0),
          ),
          (route) => false,
        );
      } else if (data["label"] == 'History') {
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return HistoryScreen();
            },
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child) {
              return child;
            },
            transitionDuration: Duration(seconds: 0),
          ),
          (route) => false,
        );
      } else if (data["label"] == 'Settings') {
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return SettingScreen();
            },
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child) {
              return child;
            },
            transitionDuration: Duration(seconds: 0),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var smallestDimension = MediaQuery.of(context).size.shortestSide;
    final useMobileLayout = smallestDimension < 600;
    getData(useMobileLayout);

    CartProvider cartProvider =
        Provider.of<CartProvider>(context, listen: true);

    return Consumer<BottomProvider>(builder: (context, bottomProvider, child) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          currentIndex: bottomProvider.currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).primaryColorDark,
          unselectedItemColor: Colors.grey,
          selectedFontSize: !useMobileLayout ? 14 : 12,
          unselectedFontSize: !useMobileLayout ? 14 : 12,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
          ),
          onTap: _onTabSelected,
          items: navItems.map((navItem) {
            return BottomNavigationBarItem(
              icon: cartProvider.count > 0 && navItem["label"] == "Cart"
                  ? Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                            top: 8,
                            right: 8,
                          ),
                          child: SvgPicture.asset(
                            navItem["icon"],
                            colorFilter: ColorFilter.mode(
                              navItem["index"] == bottomProvider.currentIndex
                                  ? Theme.of(context).primaryColorDark
                                  : Colors.grey,
                              BlendMode.srcIn,
                            ),
                            width: 24,
                            height: 24,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Text(
                              '${cartProvider.count}',
                              style: Theme.of(context).textTheme.labelMedium,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        top: 8,
                        right: 8,
                      ),
                      child: SvgPicture.asset(
                        navItem["icon"],
                        colorFilter: ColorFilter.mode(
                          navItem["index"] == bottomProvider.currentIndex
                              ? Theme.of(context).primaryColorDark
                              : Colors.grey,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
              label: language[navItem["label"]] ?? navItem["label"],
            );
          }).toList(),
        ),
      );
    });
  }
}
