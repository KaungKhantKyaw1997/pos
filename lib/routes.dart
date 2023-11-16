import 'package:flutter/material.dart';
import 'package:pos/src/screens/history_details_screen.dart';
import 'package:pos/src/screens/history_screen.dart';
import 'package:pos/src/screens/home_screen.dart';
import 'package:pos/src/screens/login_screen.dart';
import 'package:pos/src/screens/setting_screen.dart';
import 'package:pos/src/screens/splash_screen.dart';

class Routes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String history = '/history';
  static const String history_details = '/history_details';
  static const String setting = '/setting';

  static final Map<String, WidgetBuilder> routes = {
    splash: (BuildContext context) => const SplashScreen(),
    login: (BuildContext context) => const LoginScreen(),
    home: (BuildContext context) => const HomeScreen(),
    history: (BuildContext context) => const HistoryScreen(),
    history_details: (BuildContext context) => const HistoryDetailsScreen(),
    setting: (BuildContext context) => const SettingScreen(),
  };
}
