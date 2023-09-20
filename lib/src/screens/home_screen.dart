import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pos/api_constants.dart';
import 'package:pos/routes.dart';
import 'package:pos/src/screens/bottombar_screen.dart';
import 'package:pos/src/services/categories_service.dart';
import 'package:pos/src/services/items_service.dart';
import 'package:pos/src/utils/format_amount.dart';
import 'package:pos/src/utils/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final categoriesService = CategoriesService();
  final itemsService = ItemsService();
  final ScrollController _itemController = ScrollController();
  String search = '';
  List items = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("_currentIndex", "0");

    getCategories();
    getItems();
  }

  getCategories() async {
    try {
      final response = await categoriesService.getCategoriesData();
      if (response["code"] == 200) {
        if (response["data"].isNotEmpty) {}
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  getItems() async {
    try {
      final response = await itemsService.getItemsData(search);
      if (response["code"] == 200) {
        if (response["data"].isNotEmpty) {
          items = response["data"].map((item) {
            return {
              ...item,
              "qty": 0,
              "totalamount": "0.00",
            };
          }).toList();
          setState(() {});
        }
      } else {
        ToastUtil.showToast(response["code"], response["message"]);
      }
    } catch (e) {
      print('Error: $e');
    }
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
                                  '${ApiConstants.baseUrl}${items[index]["image_url"].toString()}'),
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
                                    items[index]["name"].toString(),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    items[index]["description"].toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
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
                                        const Text(
                                          "Amount",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        FormattedAmount(
                                          amount: double.parse(
                                              items[index]["price"].toString()),
                                          mainTextStyle: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          decimalTextStyle: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          "Total Amount",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        FormattedAmount(
                                          amount: double.parse(items[index]
                                                  ["totalamount"]
                                              .toString()),
                                          mainTextStyle: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          decimalTextStyle: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
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
                        const Text(
                          'Quantity',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (items[index]["qty"] > 0) {
                                    items[index]["qty"]--;
                                    items[index]["totalamount"] = (double.parse(
                                                items[index]["price"]
                                                    .toString()) *
                                            items[index]["qty"])
                                        .toString();
                                  }
                                });
                              },
                            ),
                            Text(
                              items[index]["qty"].toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  items[index]["qty"]++;
                                  items[index]["totalamount"] = (double.parse(
                                              items[index]["price"]
                                                  .toString()) *
                                          items[index]["qty"])
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
                      onPressed: () {
                        // Navigator.pushNamed(context, Routes.home);
                      },
                      child: const Text(
                        "Confirm",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
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

  itemCard(index) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  '${ApiConstants.baseUrl}${items[index]["image_url"].toString()}'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Center(
          child: Text(
            items[index]["name"].toString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'POS',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/search.svg",
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                Theme.of(context).primaryColor,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, Routes.search);
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 24,
        ),
        width: double.infinity,
        child: GridView.builder(
          controller: _itemController,
          shrinkWrap: true,
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisExtent: 150,
            childAspectRatio: 2 / 1,
            crossAxisSpacing: 15,
            crossAxisCount: 2,
            mainAxisSpacing: 15,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                showItemModal(context, index);
              },
              child: itemCard(index),
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomBarScreen(),
    );
  }
}
