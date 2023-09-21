import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pos/global.dart';
import 'package:pos/src/constants/api_constants.dart';
import 'package:pos/src/constants/font_constants.dart';
import 'package:pos/src/screens/bottombar_screen.dart';
import 'package:pos/src/services/orders_service.dart';
import 'package:pos/src/utils/format_amount.dart';
import 'package:pos/src/utils/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final orderService = OrderService();
  final ScrollController _cartController = ScrollController();
  List carts = [];
  List items = [];
  int tableid = 1;

  @override
  void initState() {
    super.initState();
    getCart();
  }

  getCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartsJson = prefs.getString("carts");
    if (cartsJson != null) {
      setState(() {
        final jsonData = jsonDecode(cartsJson);
        carts = jsonData;
        for (var item in carts) {
          Map<String, dynamic> cart = {
            'item_id': item["id"],
            'quantity': item["qty"],
            'special_instructions': '',
          };

          items.add(cart);
        }
      });
    }
  }

  createOrder() async {
    try {
      final body = {
        "table_id": tableid,
        "items": items,
      };
      final response = await orderService.createOrderData(body);
      if (response["code"] == 200) {
        ToastUtil.showToast(response["code"], response["message"]);
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
              createOrder();
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
          child: ListView.builder(
            controller: _cartController,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: carts.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(
                  bottom: 8,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Slidable(
                      key: const ValueKey(0),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        dismissible: DismissiblePane(onDismissed: () {}),
                        children: [
                          SlidableAction(
                            onPressed: (context) {},
                            backgroundColor: const Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            borderRadius: BorderRadius.circular(10),
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
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
                            )
                          ],
                        ),
                      ),
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
