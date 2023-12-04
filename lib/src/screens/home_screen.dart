import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pos/global.dart';
import 'package:pos/routes.dart';
import 'package:pos/src/constants/api_constants.dart';
import 'package:pos/src/constants/color_constants.dart';
import 'package:pos/src/providers/cart_provider.dart';
import 'package:pos/src/screens/bottombar_screen.dart';
import 'package:pos/src/services/category_service.dart';
import 'package:pos/src/services/item_service.dart';
import 'package:pos/src/services/order_service.dart';
import 'package:pos/src/services/table_service.dart';
import 'package:pos/src/utils/format_amount.dart';
import 'package:pos/src/utils/loading.dart';
import 'package:pos/src/utils/toast.dart';
import 'package:pos/src/widgets/custom_autocomplete.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final categoryService = CategoryService();
  final itemService = ItemService();
  final tableService = TableService();
  final orderService = OrderService();
  TextEditingController search = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();
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
    _searchFocusNode.dispose();
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

      final response = await categoryService.getCategoriesData();
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

  void _handleSubmitted(String value) {
    getItems();
  }

  getItems() async {
    try {
      final response =
          await itemService.getItemsData(search: search.text, id: categoryid);
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

  showOrderAlert(code, msg) async {
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
          title: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(code == 200
                    ? 'assets/images/success.png'
                    : 'assets/images/error.png'),
              ),
            ),
          ),
          content: Text(
            msg,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          actions: [
            Container(
              width: double.infinity,
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
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
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
        setState(() {
          carts = [];
          tableNumber.text = '';
          tableId = 0;
          totalAmount = 0.0;
          prefs.remove("carts");
        });
      }
      showOrderAlert(response["code"], response["message"]);
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
          showOrderAlert(e.response!.data['code'], e.response!.data['message']);
        }
      }
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
                width: 80,
                height: 80,
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
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 16,
                      ),
                      child: Text(
                        carts[index]["name"].toString(),
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  "Ks",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Expanded(
                                  child: FormattedAmount(
                                    amount: double.parse(
                                        carts[index]["totalamount"].toString()),
                                    mainTextStyle:
                                        Theme.of(context).textTheme.bodyLarge,
                                    decimalTextStyle:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                    Theme.of(context).primaryColorLight,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.remove,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    if (carts[index]['quantity'] > 1) {
                                      carts[index]['quantity']--;
                                      carts[index]['totalamount'] =
                                          double.parse(carts[index]["price"]
                                                  .toString()) *
                                              carts[index]['quantity'];
                                    } else {
                                      CartProvider cartProvider =
                                          Provider.of<CartProvider>(context,
                                              listen: false);
                                      cartProvider
                                          .addCount(cartProvider.count - 1);
                                      carts.removeAt(index);
                                    }
                                    calculateTotal();
                                    saveListToSharedPreferences(carts);
                                  },
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 8,
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
                              CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                    Theme.of(context).primaryColorLight,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.add,
                                    size: 16,
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
        index < carts.length - 1
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

  itemCard(index, useMobileLayout) {
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
            height: !useMobileLayout ? 260 : 160,
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
                  style: Theme.of(context).textTheme.bodySmall,
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
                    "Ks",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Expanded(
                    child: FormattedAmount(
                      amount: double.parse(items[index]["price"].toString()),
                      mainTextStyle: Theme.of(context).textTheme.bodyLarge,
                      decimalTextStyle: Theme.of(context).textTheme.bodyLarge,
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
    CartProvider cartProvider =
        Provider.of<CartProvider>(context, listen: false);
    var smallestDimension = MediaQuery.of(context).size.shortestSide;
    final useMobileLayout = smallestDimension < 600;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _searchFocusNode.unfocus();
      },
      child: Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 8,
              child: Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: !useMobileLayout ? 32 : 60,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: 24,
                      ),
                      child: TextFormField(
                        controller: search,
                        focusNode: _searchFocusNode,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        style: Theme.of(context).textTheme.bodyLarge,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          hintText: language["Search"] ?? "Search",
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(
                              color: ColorConstants.borderColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          suffixIcon: IconButton(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            onPressed: () {
                              getItems();
                            },
                            icon: SvgPicture.asset(
                              "assets/icons/search.svg",
                              colorFilter: ColorFilter.mode(
                                Colors.black,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        onFieldSubmitted: _handleSubmitted,
                      ),
                    ),
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
                    Expanded(
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        controller: _scrollController,
                        shrinkWrap: true,
                        itemCount: items.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisExtent: !useMobileLayout ? 340 : 220,
                          crossAxisSpacing: !useMobileLayout ? 16 : 8,
                          crossAxisCount: MediaQuery.of(context).orientation ==
                                  Orientation.landscape
                              ? 3
                              : 2,
                          mainAxisSpacing: !useMobileLayout ? 16 : 8,
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

                              CartProvider cartProvider =
                                  Provider.of<CartProvider>(context,
                                      listen: false);
                              cartProvider.addCount(carts.length);
                            },
                            child: itemCard(index, useMobileLayout),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!useMobileLayout)
              Expanded(
                flex:
                    MediaQuery.of(context).orientation == Orientation.landscape
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
                            top: 32,
                            left: 16,
                            right: 16,
                          ),
                          child: Row(
                            children: [
                              Text(
                                language["Cart"] ?? "Cart",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              if (cartProvider.count > 0)
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 30,
                                    minHeight: 30,
                                  ),
                                  child: Text(
                                    '${cartProvider.count}',
                                    style:
                                        Theme.of(context).textTheme.labelMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: MediaQuery.of(context).orientation ==
                                Orientation.landscape
                            ? 9
                            : 12,
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
                          thickness: 0.5,
                        ),
                      ),
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
                            FormattedAmount(
                              amount: double.parse(totalAmount.toString()),
                              mainTextStyle:
                                  Theme.of(context).textTheme.titleLarge,
                              decimalTextStyle:
                                  Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
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
                            if (tableId == 0) {
                              ToastUtil.showToast(
                                  0,
                                  language["Choose Table No."] ??
                                      "Choose Table No.");
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
              ),
          ],
        ),
        bottomNavigationBar: const BottomBarScreen(),
      ),
    );
  }
}
