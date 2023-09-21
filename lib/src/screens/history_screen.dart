import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final ScrollController _orderController = ScrollController();
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
          List data = response["data"];

          final groupedItems = groupBy(data, (item) => item["table_number"]);
          final groupedItemsMap = Map.from(groupedItems);

          groupedItemsMap.forEach((tableNumber, items) {
            orders.add({
              "title": tableNumber,
              "items": items,
            });
          });

          orders.sort((a, b) {
            final int tableNumberA = a["title"];
            final int tableNumberB = b["title"];
            return tableNumberA.compareTo(tableNumberB);
          });
        }
        setState(() {});
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String formatNumber(int number) {
    return number.toString().padLeft(6, '0');
  }

  String formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final formattedDate = DateFormat.yMMMd().add_jm().format(dateTime);
    return formattedDate;
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
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          width: double.infinity,
          child: ListView.builder(
            controller: _orderController,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(
                  bottom: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 8,
                        bottom: 4,
                      ),
                      child: Text(
                        'Table ${orders[index]["title"]}',
                        style: FontConstants.body1,
                      ),
                    ),
                    const Divider(
                      height: 0,
                      color: Colors.grey,
                    ),
                    ListView.builder(
                      controller: _orderController,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: orders[index]["items"].length,
                      itemBuilder: (context, i) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: 8,
                                top: 8,
                              ),
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ORD-${formatNumber(orders[index]["items"][i]["id"])}',
                                    style: FontConstants.body1,
                                  ),
                                  Text(
                                    formatTimestamp(orders[index]["items"][i]
                                            ["created_at"]
                                        .toString()),
                                    style: FontConstants.caption1,
                                  ),
                                ],
                              ),
                            ),
                            i < orders[index]["items"].length - 1
                                ? Container(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      right: 16,
                                    ),
                                    child: const Divider(
                                      height: 0,
                                      color: Colors.grey,
                                    ),
                                  )
                                : Container(),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const BottomBarScreen(),
    );
  }
}
