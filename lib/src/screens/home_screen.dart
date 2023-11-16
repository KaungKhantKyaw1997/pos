import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pos/global.dart';
import 'package:pos/src/constants/api_constants.dart';
import 'package:pos/src/screens/bottombar_screen.dart';
import 'package:pos/src/services/categories_service.dart';
import 'package:pos/src/services/items_service.dart';
import 'package:pos/src/services/orders_service.dart';
import 'package:pos/src/services/tables_service.dart';
import 'package:pos/src/utils/format_amount.dart';
import 'package:pos/src/utils/loading.dart';
import 'package:pos/src/utils/toast.dart';
import 'package:pos/src/widgets/custom_autocomplete.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final categoriesService = CategoriesService();
  final itemsService = ItemsService();
  final tablesService = TablesService();
  final orderService = OrderService();
  final ScrollController _scrollController = ScrollController();
  List items = [];
  List categories = [];
  int categoryid = 0;
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
    getCategories();
    getItems();
    getTables();
  }

  @override
  void dispose() {
    itemsService.cancelRequest();
    categoriesService.cancelRequest();
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

  getCategories() async {
    try {
      categories = [
        {
          "id": 0,
          "name": "All",
        }
      ];

      final response = await categoriesService.getCategoriesData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          categories = [
            ...categories,
            ...(response["data"] as List).cast<Map<String, dynamic>>()
          ];
        }
        setState(() {});
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  getItems() async {
    try {
      final response = await itemsService.getItemsData(id: categoryid);
      if (response!["code"] == 200) {
        items = [];
        if (response["data"].isNotEmpty) {
          items = response["data"].map((item) {
            return {
              ...item,
              "quantity": 0,
              "totalamount": 0,
            };
          }).toList();
        }
        setState(() {});
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  getTables() async {
    try {
      final response = await tablesService.getTablesData();
      if (response!["code"] == 200) {
        if (response["data"].isNotEmpty) {
          tables = response["data"];

          for (var data in response["data"]) {
            if (data["table_number"] != null) {
              tablesNumber.add(data["table_number"]);
            }
          }
          tableId = tables[0]["id"];
          tableNumber.text = tables[0]["table_number"];
        }
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  createOrder() async {
    showLoadingDialog(context);
    final prefs = await SharedPreferences.getInstance();
    try {
      final body = {
        "table_id": tableId,
        "items": items,
      };
      final response = await orderService.createOrderData(body);
      Navigator.pop(context);
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
      Navigator.pop(context);
      print('Error: $e');
    }
  }

  cartCard(index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
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
                width: 110,
                height: 110,
                margin: const EdgeInsets.only(
                  right: 8,
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
                    Text(
                      carts[index]["name"].toString(),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
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
                                  carts[index]['totalamount'] = double.parse(
                                          carts[index]["price"].toString()) *
                                      carts[index]['quantity'];
                                } else {
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
                              child: Center(
                                child: Text(
                                  carts[index]['quantity'].toString(),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
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
                                carts[index]['totalamount'] = double.parse(
                                        carts[index]["price"].toString()) *
                                    carts[index]['quantity'];
                                calculateTotal();
                                saveListToSharedPreferences(carts);
                              },
                            ),
                          ],
                        ),
                        FormattedAmount(
                          amount:
                              double.parse(carts[index]["price"].toString()),
                          mainTextStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          decimalTextStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FormattedAmount(
                        amount: double.parse(
                            carts[index]["totalamount"].toString()),
                        mainTextStyle: Theme.of(context).textTheme.titleLarge,
                        decimalTextStyle:
                            Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

  itemCard(index) {
    return Container(
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
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    '${ApiConstants.baseUrl}${items[index]["image_url"].toString()}'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  items[index]["name"].toString(),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Row(
                children: [
                  Text(
                    "Ks ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                  Expanded(
                    child: FormattedAmount(
                      amount: double.parse(items[index]["price"].toString()),
                      mainTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      decimalTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColorDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 8,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        bottom: 16,
                      ),
                      height: 50,
                      child: ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final isSelected =
                              categories[index]["id"] == categoryid;
                          return GestureDetector(
                            onTap: () async {
                              categoryid = categories[index]["id"];
                              getItems();
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                right: 16,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).primaryColorLight
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.white,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    spreadRadius: 0.5,
                                    blurRadius: 7,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Center(
                                child: Text(
                                  categories[index]["name"],
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ),
                          );
                        },
                        itemExtent: null,
                      ),
                    ),
                    GridView.builder(
                      controller: _scrollController,
                      shrinkWrap: true,
                      itemCount: items.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisExtent: 330,
                        crossAxisSpacing: 16,
                        crossAxisCount: MediaQuery.of(context).orientation ==
                                Orientation.landscape
                            ? 3
                            : 2,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            for (var cart in carts) {
                              if (cart["id"] == items[index]["id"]) {
                                return;
                              }
                            }
                            Map<String, dynamic> item = {
                              'id': items[index]["id"],
                              'image_url': items[index]["image_url"],
                              'name': items[index]["name"],
                              'description': items[index]["description"],
                              'price': items[index]["price"],
                              'quantity': 1,
                              'totalamount': double.parse(
                                      items[index]["price"].toString()) *
                                  1,
                            };

                            carts.add(item);
                            calculateTotal();
                            saveListToSharedPreferences(carts);
                          },
                          child: itemCard(index),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: MediaQuery.of(context).orientation == Orientation.landscape
                ? 4
                : 6,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    spreadRadius: 0.5,
                    blurRadius: 7,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              height: double.infinity,
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 24,
                        left: 16,
                        right: 16,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          language["Cart"] ?? "Cart",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 12,
                    child: ListView.builder(
                      controller: _scrollController,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: carts.length,
                      itemBuilder: (context, index) {
                        return cartCard(index);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 4,
                    ),
                    child: Divider(
                      height: 0,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FormattedAmount(
                        amount: double.parse(totalAmount.toString()),
                        mainTextStyle: Theme.of(context).textTheme.titleLarge,
                        decimalTextStyle:
                            Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
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
                          ? 423
                          : 405,
                    ),
                  ),
                  Container(
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
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: () async {
                        createOrder();
                      },
                      child: Text(
                        language["Order"] ?? "Order",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomBarScreen(),
    );
  }
}
