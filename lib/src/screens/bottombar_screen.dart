import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pos/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomBarScreen extends StatefulWidget {
  const BottomBarScreen({super.key});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  List navItems = [
    {"index": 0, "icon": "assets/icons/home.svg", "label": "Home"},
    {"index": 1, "icon": "assets/icons/history.svg", "label": "History"},
    {"index": 2, "icon": "assets/icons/setting.svg", "label": "Setting"}
  ];

  Future<void> _onTabSelected(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("currentIndex", index.toString());
    var data = navItems[index];
    if (data["label"] == 'Home') {
      Navigator.pushNamed(context, Routes.home);
    } else if (data["label"] == 'History') {
      Navigator.pushNamed(context, Routes.history);
    } else if (data["label"] == 'Setting') {
      Navigator.pushNamed(context, Routes.setting);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder:
          (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
        if (snapshot.hasData) {
          final SharedPreferences? prefs = snapshot.data;
          var currentIndex = 0;
          var index = prefs!.getString("currentIndex");
          if (index != null) {
            currentIndex = int.parse(index);
          }
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Theme.of(context).primaryColor,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
              selectedFontSize: 10,
              unselectedFontSize: 10,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
              onTap: _onTabSelected,
              items: navItems.map((navItem) {
                return BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    navItem["icon"],
                    colorFilter: ColorFilter.mode(
                        navItem["index"] == currentIndex
                            ? Colors.white
                            : Colors.grey,
                        BlendMode.srcIn),
                    width: 24,
                    height: 24,
                  ),
                  label: navItem["label"],
                );
              }).toList(),
            ),
          );
        } else {
          return Text('Error: ${snapshot.error}');
        }
      },
    );
  }
}
