import 'package:flutter/material.dart';
import 'package:pos/global.dart';
import 'package:pos/src/constants/api_constants.dart';
import 'package:pos/src/constants/font_constants.dart';
import 'package:pos/src/services/orders_service.dart';
import 'package:pos/src/utils/format_amount.dart';
import 'package:pos/src/utils/toast.dart';

class HistoryDetailsScreen extends StatefulWidget {
  const HistoryDetailsScreen({super.key});

  @override
  State<HistoryDetailsScreen> createState() => _HistoryDetailsScreenState();
}

class _HistoryDetailsScreenState extends State<HistoryDetailsScreen> {
  int id = 0;
  final orderService = OrderService();
  final ScrollController _orderController = ScrollController();
  Object detail = {};
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
    orderService.cancelRequest();
    super.dispose();
  }

  getOrderDetails() async {
    try {
      final response = await orderService.getOrderDetailsData(id);
      if (response!["code"] == 200) {
        if (response["data"] != null) {
          detail = response["data"];
        }
        if (response["data"]["items"].isNotEmpty) {
          items = response["data"]["items"];
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
          language["Details"] ?? "Details",
          style: FontConstants.title1,
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 8,
                        bottom: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                    '${ApiConstants.baseUrl}${items[index]["image_url"].toString()}'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(
                                left: 4,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${items[index]["item_name"].toString()} x ${items[index]["quantity"].toString()}',
                                    style: FontConstants.body1,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 14,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              language["Amount"] ?? "Amount",
                                              style: FontConstants.caption1,
                                            ),
                                            FormattedAmount(
                                              amount: double.parse(items[index]
                                                      ["price"]
                                                  .toString()),
                                              mainTextStyle:
                                                  FontConstants.subheadline1,
                                              decimalTextStyle:
                                                  FontConstants.caption3,
                                            ),
                                          ],
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              language["Total Amount"] ??
                                                  "Total Amount",
                                              style: FontConstants.caption1,
                                            ),
                                            FormattedAmount(
                                              amount: double.parse(items[index]
                                                          ["quantity"]
                                                      .toString()) *
                                                  double.parse(items[index]
                                                          ["price"]
                                                      .toString()),
                                              mainTextStyle:
                                                  FontConstants.subheadline1,
                                              decimalTextStyle:
                                                  FontConstants.caption3,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    index < items.length - 1
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
          ),
        ),
      ),
    );
  }
}
