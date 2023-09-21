import 'package:flutter/material.dart';
import 'package:pos/global.dart';
import 'package:pos/src/constants/font_constants.dart';
import 'package:pos/src/screens/bottombar_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          language["History"] ?? "History",
          style: FontConstants.title1,
        ),
      ),
      bottomNavigationBar: const BottomBarScreen(),
    );
  }
}
