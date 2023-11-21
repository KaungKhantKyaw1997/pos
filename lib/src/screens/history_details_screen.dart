import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pos/global.dart';
import 'package:pos/routes.dart';
import 'package:pos/src/constants/api_constants.dart';
import 'package:pos/src/constants/color_constants.dart';
import 'package:pos/src/services/order_service.dart';
import 'package:pos/src/utils/format_amount.dart';
import 'package:pos/src/utils/loading.dart';
import 'package:pos/src/utils/toast.dart';

class HistoryDetailsScreen extends StatefulWidget {
  const HistoryDetailsScreen({super.key});

  @override
  State<HistoryDetailsScreen> createState() => _HistoryDetailsScreenState();
}

class _HistoryDetailsScreenState extends State<HistoryDetailsScreen> {
  int id = 0;
  final orderService = OrderService();
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic> details = {};
  List items = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        id = arguments["id"];
        getOrderDetails();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getOrderDetails() async {
    try {
      final response = await orderService.getOrderDetailsData(id);
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          details = response["data"];
        }
        if (response["data"]["items"].isNotEmpty) {
          items = response["data"]["items"];
        }
        setState(() {});
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      if (e is DioException &&
          e.error is SocketException &&
          !isConnectionTimeout) {
        isConnectionTimeout = true;
        Navigator.pushNamed(
          context,
          Routes.connection_timeout,
        );
        return;
      }
      if (e is DioException && e.response != null && e.response!.data != null) {
        if (e.response!.data["message"].toLowerCase() == "invalid token" ||
            e.response!.data["message"].toLowerCase() ==
                "invalid authorization header format") {
          Navigator.pushNamed(
            context,
            Routes.unauthorized,
          );
        } else {
          ToastUtil.showToast(
              e.response!.data['code'], e.response!.data['message']);
        }
      }
    }
  }

  updateOrder(status) async {
    showLoadingDialog(context);
    try {
      final body = {
        "status": status,
      };

      final response = await orderService.updateOrderData(details["id"], body);
      Navigator.pop(context);
      if (response!["code"] == 200) {
        setState(() {
          details["status"] = status;
        });
        Navigator.pop(context);
        ToastUtil.showToast(response["code"], response["message"]);
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e, s) {
      Navigator.pop(context);
      if (e is DioException &&
          e.error is SocketException &&
          !isConnectionTimeout) {
        isConnectionTimeout = true;
        Navigator.pushNamed(
          context,
          Routes.connection_timeout,
        );
        return;
      }
      if (e is DioException && e.response != null && e.response!.data != null) {
        if (e.response!.data["message"] == "invalid token" ||
            e.response!.data["message"] ==
                "invalid authorization header format") {
          Navigator.pushNamed(
            context,
            Routes.unauthorized,
          );
        } else {
          ToastUtil.showToast(
              e.response!.data['code'], e.response!.data['message']);
        }
      }
    }
  }

  itemCard(index) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            spreadRadius: 0.5,
            blurRadius: 7,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              margin: EdgeInsets.only(
                right: 8,
              ),
              height: 140,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      '${ApiConstants.baseUrl}${items[index]["image_url"]}'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Expanded(
            flex: 9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${items[index]["item_name"]}",
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "${language["Quantity"] ?? "Quantity"}: ",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      "${items[index]["quantity"]}",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "${language["Amount"] ?? "Amount"}: ",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Expanded(
                      child: FormattedAmount(
                        amount: items[index]["price"],
                        mainTextStyle: Theme.of(context).textTheme.bodyLarge,
                        decimalTextStyle: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      "${language["Total Amount"] ?? "Total Amount"}: ",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Expanded(
                      child: FormattedAmount(
                        amount:
                            double.parse(items[index]["quantity"].toString()) *
                                double.parse(items[index]["price"].toString()),
                        mainTextStyle: Theme.of(context).textTheme.bodyLarge,
                        decimalTextStyle: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var smallestDimension = MediaQuery.of(context).size.shortestSide;
    final useMobileLayout = smallestDimension < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          language["Details"] ?? "Details",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  details.isEmpty || details["created_at"].isEmpty
                      ? ""
                      : Jiffy.parseFromDateTime(
                              DateTime.parse(details["created_at"] + "Z")
                                  .toLocal())
                          .format(pattern: "dd MMM yyyy, hh:mm a"),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              SizedBox(
                height: 4,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${language["Order ID"] ?? "Order ID"}: ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '#${details["id"]}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              SizedBox(
                height: 2,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${language["Name"] ?? "Name"}: ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    details["waiter_name"].toString(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              SizedBox(
                height: 4,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${language["Table No."] ?? "Table No."}: ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    details["table_number"].toString(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              GridView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisExtent: !useMobileLayout ? 170 : 120,
                  crossAxisSpacing: !useMobileLayout ? 16 : 8,
                  crossAxisCount: !useMobileLayout
                      ? MediaQuery.of(context).orientation ==
                              Orientation.landscape
                          ? 3
                          : 2
                      : 1,
                  mainAxisSpacing: !useMobileLayout ? 16 : 8,
                ),
                itemBuilder: (context, index) {
                  return itemCard(index);
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
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
            backgroundColor: ColorConstants.redColor,
          ),
          onPressed: () async {
            updateOrder("Canceled");
          },
          child: Text(
            language["Order Cancel"] ?? "Order Cancel",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
}
