import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pos/global.dart';
import 'package:pos/routes.dart';
import 'package:pos/src/constants/api_constants.dart';
import 'package:pos/src/providers/cart_provider.dart';
import 'package:pos/src/screens/bottombar_screen.dart';
import 'package:pos/src/services/order_service.dart';
import 'package:pos/src/services/table_service.dart';
import 'package:pos/src/utils/format_amount.dart';
import 'package:pos/src/utils/loading.dart';
import 'package:pos/src/utils/toast.dart';
import 'package:pos/src/widgets/custom_autocomplete.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final tableService = TableService();
  final orderService = OrderService();
  final ScrollController _cartController = ScrollController();
  List<Map<String, dynamic>> carts = [];
  List tables = [];
  List<String> tablesNumber = [];
  TextEditingController tableNumber = TextEditingController(text: '');
  int tableId = 0;
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    getCart();
    getTables();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartsJson = prefs.getString("carts");
    if (cartsJson != null) {
      setState(() {
        List jsonData = jsonDecode(cartsJson) ?? [];
        for (var item in jsonData) {
          carts.add(item);
        }
      });
      calculateTotal();
    }
  }

  getTables() async {
    try {
      final response = await tableService.getTablesData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          tables = response["data"];

          for (var data in response["data"]) {
            if (data["table_number"] != null) {
              tablesNumber.add(data["table_number"]);
            }
          }
        }
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

  createOrder() async {
    showLoadingDialog(context);
    final prefs = await SharedPreferences.getInstance();

    List _items = [];
    for (var item in carts) {
      Map<String, dynamic> cart = {
        'item_id': item["id"],
        'quantity': item["quantity"],
        'special_instructions': '',
      };

      _items.add(cart);
    }
    try {
      final body = {
        "table_id": tableId,
        "items": _items,
      };
      final response = await orderService.createOrderData(body);
      Navigator.pop(context);
      if (response!["code"] == 200) {
        CartProvider cartProvider =
            Provider.of<CartProvider>(context, listen: false);
        cartProvider.addCount(0);

        setState(() {
          carts = [];
          tableNumber.text = '';
          tableId = 0;
          totalAmount = 0.0;
          prefs.remove("carts");
        });
        ToastUtil.showToast(response["code"], response["message"]);
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
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

  Future<void> saveListToSharedPreferences(
      List<Map<String, dynamic>> datalist) async {
    final prefs = await SharedPreferences.getInstance();
    const key = "carts";

    final jsonData = jsonEncode(datalist);

    await prefs.setString(key, jsonData);
    setState(() {});
  }

  void calculateTotal() {
    totalAmount = 0.0;
    for (Map<String, dynamic> cart in carts) {
      totalAmount += cart["totalamount"];
    }
    setState(() {});
  }

  cartCard(index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.only(
                left: 16,
                right: 8,
                top: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      '${ApiConstants.baseUrl}${carts[index]["image_url"]}'),
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
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 16,
                      right: 16,
                    ),
                    child: Text(
                      carts[index]["name"].toString(),
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 16,
                      bottom: 8,
                    ),
                    child: Text(
                      carts[index]["description"].toString(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "Ks",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        FormattedAmount(
                          amount: double.parse(
                              carts[index]["totalamount"].toString()),
                          mainTextStyle: Theme.of(context).textTheme.bodyLarge,
                          decimalTextStyle:
                              Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.remove,
                          size: 24,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          if (carts[index]['quantity'] > 1) {
                            carts[index]['quantity']--;
                            carts[index]['totalamount'] =
                                double.parse(carts[index]["price"].toString()) *
                                    carts[index]['quantity'];
                          } else {
                            CartProvider cartProvider =
                                Provider.of<CartProvider>(context,
                                    listen: false);
                            cartProvider.addCount(cartProvider.count - 1);
                            carts.removeAt(index);
                          }
                          calculateTotal();
                          saveListToSharedPreferences(carts);
                        },
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        child: Text(
                          carts[index]['quantity'].toString(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          size: 24,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          carts[index]['quantity']++;
                          carts[index]['totalamount'] =
                              double.parse(carts[index]["price"].toString()) *
                                  carts[index]['quantity'];
                          calculateTotal();
                          saveListToSharedPreferences(carts);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
          style: Theme.of(context).textTheme.titleLarge,
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 24,
                  bottom: 16,
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
                      return Slidable(
                        key: const ValueKey(0),
                        endActionPane: ActionPane(
                          motion: const BehindMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (BuildContext context) {
                                CartProvider cartProvider =
                                    Provider.of<CartProvider>(context,
                                        listen: false);
                                cartProvider.addCount(cartProvider.count - 1);

                                carts.removeAt(index);
                                calculateTotal();
                                saveListToSharedPreferences(carts);
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
                        child: cartCard(index),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            padding: const EdgeInsets.all(
              16,
            ),
            margin: const EdgeInsets.only(
              top: 8,
              bottom: 10,
              left: 16,
              right: 16,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "Ks",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      FormattedAmount(
                        amount: double.parse(totalAmount.toString()),
                        mainTextStyle: Theme.of(context).textTheme.titleLarge,
                        decimalTextStyle:
                            Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 16,
                  ),
                  child: CustomAutocomplete(
                    datalist: tablesNumber,
                    textController: tableNumber,
                    label: language["Table No."] ?? "Table No.",
                    onSelected: (String selection) {
                      tableNumber.text = selection;

                      for (var data in tables) {
                        if (data["table_number"] == tableNumber.text) {
                          tableId = data["id"];
                        }
                      }
                    },
                    onChanged: (String value) {
                      tableNumber.text = value;

                      for (var data in tables) {
                        if (data["table_number"] == tableNumber.text) {
                          tableId = data["id"];
                        }
                      }
                    },
                    maxWidth: MediaQuery.of(context).orientation ==
                            Orientation.landscape
                        ? 790
                        : 327,
                  ),
                ),
                Container(
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
                    onPressed: () async {
                      if (tableId == 0) {
                        ToastUtil.showToast(0,
                            language["Choose Table No."] ?? "Choose Table No.");
                        return;
                      }
                      createOrder();
                    },
                    child: Text(
                      language["Order"] ?? "Order",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomBarScreen(),
    );
  }
}
