import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pos/global.dart';
import 'package:pos/src/constants/api_constants.dart';
import 'package:pos/src/constants/font_constants.dart';
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
  final PageController _categoryController = PageController(
    viewportFraction: 0.5,
  );
  List items = [];
  List categories = [];
  int categoryid = 0;

  @override
  void initState() {
    super.initState();
    getData();
    getCategories();
    getItems();
  }

  @override
  void dispose() {
    itemsService.cancelRequest();
    super.dispose();
  }

  getData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("_currentIndex", "0");
  }

  getCategories() async {
    try {
      final response = await categoriesService.getCategoriesData();
      if (response["code"] == 200) {
        if (response["data"].isNotEmpty) {
          categories = response["data"];
        }
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
              "qty": 0,
              "totalamount": "0.00",
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
                                    style: FontConstants.body1,
                                  ),
                                  Text(
                                    items[index]["description"].toString(),
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
                                              items[index]["price"].toString()),
                                          mainTextStyle:
                                              FontConstants.subheadline1,
                                          decimalTextStyle: FontConstants.body1,
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
                                          amount: double.parse(items[index]
                                                  ["totalamount"]
                                              .toString()),
                                          mainTextStyle:
                                              FontConstants.subheadline1,
                                          decimalTextStyle: FontConstants.body1,
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
                              style: FontConstants.headline1,
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

  itemCard(index) {
    return Column(
      children: [
        Container(
          width: 150,
          height: 150,
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
            style: FontConstants.body1,
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
        elevation: 0,
        title: Text(
          language["Home"] ?? "Home",
          style: FontConstants.title1,
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/search.svg",
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, Routes.search);
            },
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () => exit(0),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    bottom: 4,
                  ),
                  height: 50,
                  child: PageView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: _categoryController,
                    itemCount: categories.length,
                    itemBuilder: (context, i) {
                      final isSelected = categories[i]["id"] == categoryid;
                      return Card(
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: isSelected
                            ? Theme.of(context).primaryColorLight
                            : Colors.white,
                        child: GestureDetector(
                          onTap: () {
                            categoryid = categories[i]["id"];
                            getItems();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            child: Text(
                              categories[i]["name"],
                              style: FontConstants.caption2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                GridView.builder(
                  controller: _itemController,
                  shrinkWrap: true,
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisExtent: 200,
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
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomBarScreen(),
    );
  }
}
