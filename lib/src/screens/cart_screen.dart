import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pos/global.dart';
import 'package:pos/src/constants/api_constants.dart';
import 'package:pos/src/constants/font_constants.dart';
import 'package:pos/src/models/table_selection_model.dart';
import 'package:pos/src/screens/bottombar_screen.dart';
import 'package:pos/src/services/orders_service.dart';
import 'package:pos/src/services/tables_service.dart';
import 'package:pos/src/utils/format_amount.dart';
import 'package:pos/src/utils/toast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final tablesService = TablesService();
  final orderService = OrderService();
  final ScrollController _cartController = ScrollController();
  List<Map<String, dynamic>> carts = [];
  List items = [];
  List tables = [];
  int tableid = 0;

  @override
  void initState() {
    super.initState();
    getCart();
    getTables();
  }

  @override
  void dispose() {
    tablesService.cancelRequest();
    super.dispose();
  }

  getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartsJson = prefs.getString("carts");
    if (cartsJson != null) {
      setState(() {
        List jsonData = jsonDecode(cartsJson) ?? [];
        for (var item in jsonData) {
          Map<String, dynamic> cart = {
            'item_id': item["id"],
            'quantity': item["qty"],
            'special_instructions': '',
          };

          carts.add(item);
          items.add(cart);
        }
      });
    }
  }

  getTables() async {
    try {
      final response = await tablesService.getTablesData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          tables = response["data"];
        }
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  createOrder() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final body = {
        "table_id": tableid,
        "items": items,
      };
      final response = await orderService.createOrderData(body);
      if (response["code"] == 200) {
        setState(() {
          carts = [];
          items = [];
          prefs.remove("carts");
        });
        ToastUtil.showToast(response["code"], response["message"]);
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> saveListToSharedPreferences(
      List<Map<String, dynamic>> datalist) async {
    final prefs = await SharedPreferences.getInstance();
    const key = "carts";

    final jsonData = jsonEncode(datalist);

    await prefs.setString(key, jsonData);
  }

  void _showTableSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final tableSelectionModel =
            Provider.of<TableSelectionModel>(context, listen: true);

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          height: double.infinity,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: tables.length,
                  itemBuilder: (BuildContext context, int index) {
                    int tableNumber = tables[index]["table_number"];
                    return ListTile(
                      title: Text(
                        'Table $tableNumber',
                        style: FontConstants.body1,
                      ),
                      trailing:
                          tableSelectionModel.selectedTableId == tableNumber
                              ? SvgPicture.asset(
                                  "assets/icons/check.svg",
                                  width: 24,
                                  height: 24,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.black,
                                    BlendMode.srcIn,
                                  ),
                                )
                              : null,
                      onTap: () {
                        tableSelectionModel.selectTable(tableNumber);
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 32,
                ),
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  onPressed: () async {
                    tableid = tableSelectionModel.selectedTableId;
                    Navigator.pop(context);
                    createOrder();
                  },
                  child: Text(
                    language["Order"] ?? "Order",
                    style: FontConstants.button1,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      final tableSelectionModel =
          Provider.of<TableSelectionModel>(context, listen: false);
      tableSelectionModel.selectTable(0);
    });
  }

  void showItemModal(context, index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(
                      16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          margin: const EdgeInsets.only(
                            right: 8,
                          ),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                  '${ApiConstants.baseUrl}${carts[index]["image_url"].toString()}'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    carts[index]["name"].toString(),
                                    style: FontConstants.body1,
                                  ),
                                  Text(
                                    carts[index]["description"].toString(),
                                    style: FontConstants.caption1,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 30,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          amount: double.parse(
                                              carts[index]["price"].toString()),
                                          mainTextStyle:
                                              FontConstants.subheadline1,
                                          decimalTextStyle:
                                              FontConstants.caption3,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          language["Total Amount"] ??
                                              "Total Amount",
                                          style: FontConstants.caption1,
                                        ),
                                        FormattedAmount(
                                          amount: double.parse(carts[index]
                                                  ["totalamount"]
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
                      ],
                    ),
                  ),
                  const Divider(
                    height: 0,
                    color: Colors.grey,
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 24,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          language["Quantity"] ?? "Quantity",
                          style: FontConstants.caption1,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (carts[index]["qty"] > 0) {
                                    carts[index]["qty"]--;
                                    carts[index]["totalamount"] = (double.parse(
                                                carts[index]["price"]
                                                    .toString()) *
                                            carts[index]["qty"])
                                        .toString();
                                  }
                                });
                              },
                            ),
                            Text(
                              carts[index]["qty"].toString(),
                              textAlign: TextAlign.center,
                              style: FontConstants.headline1,
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  carts[index]["qty"]++;
                                  carts[index]["totalamount"] = (double.parse(
                                              carts[index]["price"]
                                                  .toString()) *
                                          carts[index]["qty"])
                                      .toString();
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 32,
                    ),
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: () async {
                        if (carts[index]["qty"] == 0) {
                          carts.removeAt(index);
                        }
                        saveListToSharedPreferences(carts);
                        for (var item in carts) {
                          Map<String, dynamic> cart = {
                            'item_id': item["id"],
                            'quantity': item["qty"],
                            'special_instructions': '',
                          };

                          items.add(cart);
                        }
                        Navigator.pop(context);
                      },
                      child: Text(
                        language["Add to cart"] ?? "Add to cart",
                        style: FontConstants.button1,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          language["Cart"] ?? "Cart",
          style: FontConstants.title1,
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/check.svg",
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              _showTableSelectionBottomSheet(context);
            },
          ),
        ],
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
              controller: _cartController,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: carts.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Slidable(
                      key: const ValueKey(0),
                      startActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (BuildContext context) {
                              showItemModal(context, index);
                            },
                            backgroundColor: const Color(0xFF33A031),
                            foregroundColor: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(index == 0 ? 10 : 0),
                              bottomLeft: Radius.circular(
                                  index == carts.length - 1 ? 10 : 0),
                            ),
                            icon: Icons.update,
                            label: 'Update',
                          ),
                        ],
                      ),
                      endActionPane: ActionPane(
                        motion: const BehindMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (BuildContext context) {
                              carts.removeAt(index);
                              saveListToSharedPreferences(carts);
                              for (var item in carts) {
                                Map<String, dynamic> cart = {
                                  'item_id': item["id"],
                                  'quantity': item["qty"],
                                  'special_instructions': '',
                                };

                                items.add(cart);
                              }
                            },
                            backgroundColor: const Color(0xFFE3200F),
                            foregroundColor: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(index == 0 ? 10 : 0),
                              bottomRight: Radius.circular(
                                  index == carts.length - 1 ? 10 : 0),
                            ),
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: Container(
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
                                      '${ApiConstants.baseUrl}${carts[index]["image_url"].toString()}'),
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
                                      '${carts[index]["name"].toString()} x ${carts[index]["qty"].toString()}',
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
                                                amount: double.parse(
                                                    carts[index]["price"]
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
                                                amount: double.parse(
                                                    carts[index]["totalamount"]
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
                    ),
                    index < carts.length - 1
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
      bottomNavigationBar: const BottomBarScreen(),
    );
  }
}
