import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info/package_info.dart';
import 'package:pos/global.dart';
import 'package:pos/routes.dart';
import 'package:pos/src/providers/bottom_provider.dart';
import 'package:pos/src/screens/bottombar_screen.dart';
import 'package:pos/src/services/auth_service.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  String version = '';

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    setState(() {});
  }

  showExitDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5,
          sigmaY: 5,
        ),
        child: AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            language["Log Out"] ?? "Log Out",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            language["Are you sure you want to log out?"] ??
                "Are you sure you want to log out?",
            style: Theme.of(context).textTheme.bodySmall,
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(
                left: 8,
                right: 4,
              ),
              child: TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                child: Text(
                  language["Cancel"] ?? "Cancel",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 4,
                right: 8,
              ),
              child: TextButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Theme.of(context).primaryColor),
                ),
                child: Text(
                  language["Ok"] ?? "Ok",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onPressed: () async {
                  authService.logout(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            language["Settings"] ?? "Settings",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          width: double.infinity,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                margin: EdgeInsets.only(
                  bottom: 24,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          language["General"] ?? "General",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await Navigator.pushNamedAndRemoveUntil(
                          context,
                          Routes.language,
                          (route) => true,
                        );
                        BottomProvider bottomProvider =
                            Provider.of<BottomProvider>(context, listen: false);
                        bottomProvider.selectIndex(bottomProvider.currentIndex);
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 16,
                                top: 16,
                                bottom: 16,
                              ),
                              child: SvgPicture.asset(
                                "assets/icons/global.svg",
                                width: 24,
                                height: 24,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: 16,
                                  top: 16,
                                  bottom: 16,
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            language["Language"] ?? "Language",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                                top: 16,
                                bottom: 16,
                              ),
                              child: Text(
                                selectedLangIndex == 0 ? "English" : "မြန်မာ",
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          language["Help & Support"] ?? "Help & Support",
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                right: 16,
                                top: 16,
                                bottom: 16,
                              ),
                              child: SvgPicture.asset(
                                "assets/icons/version.svg",
                                width: 24,
                                height: 24,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: 16,
                                  top: 16,
                                  bottom: 16,
                                ),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: language["App Version"] ??
                                            "App Version",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                right: 5,
                                top: 16,
                                bottom: 16,
                              ),
                              child: Text(
                                'v$version',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  bottom: 24,
                ),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    showExitDialog();
                  },
                  child: Text(
                    language["Log Out"] ?? "Log Out",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomBarScreen(),
    );
  }
}
