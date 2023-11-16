import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pos/global.dart';
import 'package:pos/src/constants/font_constants.dart';
import 'package:pos/routes.dart';
import 'package:pos/src/providers/bottom_provider.dart';
import 'package:provider/provider.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  List navItems = [
    {"index": 0, "icon": "assets/icons/home.svg", "label": "Home"},
    {"index": 1, "icon": "assets/icons/history.svg", "label": "History"},
    {"index": 2, "icon": "assets/icons/setting.svg", "label": "Settings"}
  ];

  Future<void> _onTabSelected(int index) async {
    BottomProvider bottomProvider =
        Provider.of<BottomProvider>(context, listen: false);

    if (bottomProvider.currentIndex != index) {
      bottomProvider.selectIndex(index);

      var data = navItems[index];
      if (data["label"] == 'Home') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.home,
          (route) => false,
        );
      } else if (data["label"] == 'History') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.history,
          (route) => false,
        );
      } else if (data["label"] == 'Settings') {
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.setting,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          selectedFontSize: FontConstants.bottom,
          unselectedFontSize: FontConstants.bottom,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
          ),
          onTap: _onTabSelected,
          items: navItems.map((navItem) {
            return BottomNavigationBarItem(
              icon: Padding(
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
              label: language[navItem["label"]] ?? navItem["label"],
            );
          }).toList(),
        ),
      );
    });
  }
}
