import 'package:flutter/material.dart';
import 'package:pos/global.dart';
import 'package:pos/src/constants/font_constants.dart';
import 'package:pos/src/screens/bottombar_screen.dart';
import 'package:pos/src/services/orders_service.dart';
import 'package:pos/src/utils/toast.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final orderService = OrderService();
  List orders = [];

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  @override
  void dispose() {
    orderService.cancelRequest();
    super.dispose();
  }

  getOrders() async {
    try {
      final response = await orderService.getOrdersData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          orders = response["data"];
        }
        setState(() {});
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

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
