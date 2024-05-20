import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pos/global.dart';
import 'package:pos/routes.dart';
import 'package:pos/src/screens/bottombar_screen.dart';
import 'package:pos/src/services/order_service.dart';
import 'package:pos/src/utils/toast.dart';
import 'package:pos/src/widgets/custom_date_range.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final orderService = OrderService();
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List orders = [];
  List data = [];
  int page = 1;
  DateTime? startDate = null;
  DateTime? endDate = null;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  getOrders() async {
    try {
      String fromDate = "";
      if (startDate != null) {
        fromDate = DateFormat('yyyy-MM-dd').format(startDate!);
      }

      String toDate = "";
      if (endDate != null) {
        toDate = DateFormat('yyyy-MM-dd').format(endDate!);
      }

      final response = await orderService.getOrdersData(
          page: page, fromDate: fromDate, toDate: toDate);
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();

      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          orders = [];

          data += response["data"];
          page++;

          final groupedItemsMap = groupBy(data, (item) {
            return Jiffy.parseFromDateTime(
                    DateTime.parse(item["created_at"] + "Z").toLocal())
                .format(pattern: 'dd/MM/yyyy');
          });

          groupedItemsMap.forEach((date, items) {
            orders.add({
              "date": date,
              "items": items,
            });
          });
        }
        if (orders.isEmpty) {
          _dataLoaded = true;
        }
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
      setState(() {});
    } catch (e) {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
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

  _selectDateRange(BuildContext context) async {
    return showCustomDateRangePicker(
      context,
      dismissible: true,
      minimumDate: DateTime.now().subtract(Duration(days: 30 * 12 * 1)),
      maximumDate: DateTime.now(),
      endDate: endDate,
      startDate: startDate,
      backgroundColor: Colors.white,
      primaryColor: Theme.of(context).primaryColor,
      onApplyClick: (start, end) {
        page = 1;
        orders = [];
        data = [];
        endDate = end;
        startDate = start;
        getOrders();
      },
      onCancelClick: () {
        page = 1;
        orders = [];
        data = [];
        endDate = null;
        startDate = null;
        getOrders();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String currentDate =
        DateFormat("dd/MM/yyyy").format(DateTime.now()).toString();
    String yesterdayDate = DateFormat("dd/MM/yyyy")
        .format(DateTime.now().subtract(const Duration(days: 1)))
        .toString();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            language["History"] ?? "History",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        // actions: [
        //   IconButton(
        //     icon: SvgPicture.asset(
        //       "assets/icons/calendar.svg",
        //       colorFilter: ColorFilter.mode(
        //         Colors.black,
        //         BlendMode.srcIn,
        //       ),
        //     ),
        //     onPressed: () {
        //       _selectDateRange(context);
        //     },
        //   ),
        // ],
      ),
      body: SmartRefresher(
        header: WaterDropMaterialHeader(
          backgroundColor: Theme.of(context).primaryColor,
          color: Colors.white,
        ),
        footer: ClassicFooter(),
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: true,
        onRefresh: () async {
          page = 1;
          data = [];
          await getOrders();
        },
        onLoading: () async {
          await getOrders();
        },
        child: orders.isNotEmpty
            ? SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  width: double.infinity,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      String date = orders[index]["date"];

                      return Container(
                        margin: const EdgeInsets.only(
                          bottom: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
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
                                currentDate == date
                                    ? "Today"
                                    : yesterdayDate == date
                                        ? "Yesterday"
                                        : date,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                            const Divider(
                              height: 0,
                              color: Colors.grey,
                              thickness: 0.2,
                            ),
                            ListView.builder(
                              controller: _scrollController,
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: orders[index]["items"].length,
                              itemBuilder: (context, i) {
                                return GestureDetector(
                                  onTap: () async {
                                    await Navigator.pushNamed(
                                      context,
                                      Routes.history_details,
                                      arguments: {
                                        "id": orders[index]["items"][i]["id"],
                                      },
                                    );

                                    orders = [];
                                    data = [];
                                    page = 1;
                                    startDate = null;
                                    endDate = null;
                                    _dataLoaded = false;
                                    getOrders();
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.baseline,
                                              textBaseline:
                                                  TextBaseline.alphabetic,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '#${orders[index]["items"][i]["id"]}',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge,
                                                  ),
                                                ),
                                                Text(
                                                  Jiffy.parseFromDateTime(DateTime
                                                              .parse(orders[index]
                                                                          [
                                                                          "items"][i]
                                                                      [
                                                                      "created_at"] +
                                                                  "Z")
                                                          .toLocal())
                                                      .format(
                                                          pattern: 'hh:mm a'),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.baseline,
                                              textBaseline:
                                                  TextBaseline.alphabetic,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    orders[index]["items"][i]
                                                        ["table_number"],
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall,
                                                  ),
                                                ),
                                                Text(
                                                  orders[index]["items"][i]
                                                      ["status"],
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ],
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
                                                thickness: 0.2,
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              )
            : _dataLoaded
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/icons/empty_history.svg",
                          width: 120,
                          height: 120,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: 10,
                          ),
                          child: Text(
                            "Empty History",
                            textAlign: TextAlign.center,
                            style: MediaQuery.of(context).orientation ==
                                    Orientation.landscape
                                ? Theme.of(context).textTheme.bodyLarge
                                : Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                          ),
                          child: Text(
                            "There is no data...",
                            textAlign: TextAlign.center,
                            style: MediaQuery.of(context).orientation ==
                                    Orientation.landscape
                                ? Theme.of(context).textTheme.bodyLarge
                                : Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
      ),
      bottomNavigationBar: const BottomBarScreen(),
    );
  }
}
