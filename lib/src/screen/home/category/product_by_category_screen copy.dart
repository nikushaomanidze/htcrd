import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hot_card/src/screen/home/qr_page.dart';
import 'package:http/http.dart' as http;
import 'package:pagination_view/pagination_view.dart';

import '../../../controllers/home_screen_controller.dart';
import '../../../models/add_to_cart_list_model.dart';
import '../../../models/product_by_category_model.dart';
import '../../../servers/repository.dart';
import '../../../utils/app_theme_data.dart';
import '../../../utils/responsive.dart';
import 'package:hot_card/src/utils/app_tags.dart';

class ProductByCategory extends StatefulWidget {
  const ProductByCategory({
    Key? key,
    required this.id,
    this.title,
  }) : super(key: key);
  final int? id;
  final String? title;

  @override
  State<ProductByCategory> createState() => _ProductByCategoryState();
}

class _ProductByCategoryState extends State<ProductByCategory> {
  final homeController = Get.put(HomeScreenController());

  late final AddToCartListModel cartList;

  int page = 0;
  int productId = 0;
  int dickHead = 0;
  int dickHead2 = 0;

  int maxFreeDish = 3;

  GlobalKey<PaginationViewState> key2 = GlobalKey<PaginationViewState>();
  GlobalKey<PaginationViewState> key = GlobalKey<PaginationViewState>();

  late List<CategoryProductData> data = [];

  Future<List<CategoryProductData>> getData(int offset) async {
    page++;
    return await Repository()
        .getProductByCategoryItem(id: widget.id, page: page);
  }

  Future<Map<String, dynamic>> getProductsByCategory(int categoryId) async {
    final response = await http.get(Uri.parse(
        "https://julius.ltd/hotcard/api/v100/products-by-category/${categoryId.toString()}"));

    if (response.statusCode == 200) {
      if (dickHead < 1) {
        for (int i = 0; i < json.decode(response.body)['data'].length; i++) {
          quantity.add(0);
          var res = json.decode(response.body);
          ids.add(res['data'][i]['id']);
        }
        dickHead += 1;
      } else {}
      return json.decode(response.body);
    } else {
      return getProductsByCategory(categoryId);
    }
  }

  Future<List<dynamic>> getCheaperProducts(int categoryId, double price) async {
    // Fetch data from API
    var response = await http.get(Uri.parse(
        'https://julius.ltd/hotcard/api/v100/products-by-category/$categoryId'));

    // Decode the JSON response
    var decodedData = json.decode(response.body);
    // Convert the decoded data to a List
    List<dynamic> products = decodedData['data'];

    // Return the list of products that are cheaper than the given price
    return products
        .where((product) =>
            double.parse(product['formatted_price'].toString()) <= price)
        .toList();
  }

  int finalIndex = 0;
  double mainDishPrice = 0;
  int additionalfinalIndex = 250;
  int selectedQty = 0;
  List quantity = [];
  List ids = [];
  List additionals = [];
  List addedIndexes = [];

  int differentDishes = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    QrPage(qty: quantity, ids: ids, adds: additionals)),
          );
        },
        backgroundColor: const Color(0xffe07527),
        child: const Icon(Icons.shopping_cart_checkout),
      ),
      appBar: isMobile(context)
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                onPressed: () {
                  Get.back();
                },
              ),
              centerTitle: true,
              title: Text(
                widget.title.toString(),
                style: AppThemeData.headerTextStyle_16,
              ),
            )
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 60.h,
              leadingWidth: 40.w,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 25.r,
                ),

                onPressed: () {
                  Get.back();
                }, // null disables the button
              ),
              centerTitle: true,
              title: Text(
                widget.title.toString(),
                style: AppThemeData.headerTextStyle_14,
              ),
            ),
      body: Row(
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width / 2.1,
              child: FutureBuilder(
                future: getProductsByCategory(
                    widget.id!), // your function that returns a future
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // if the data has arrived, show the widget
                    return SingleChildScrollView(
                      physics: const ScrollPhysics(),
                      child: Column(children: [
                        const SizedBox(
                          height: 5,
                        ),
                        Center(
                            child: Text(
                          AppTags.chooseProduct.tr,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        )),
                        const SizedBox(
                          height: 15,
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!['data'].length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              color: finalIndex == index
                                  ? Colors.transparent
                                  : Colors.transparent,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            quantity[index] >= 1
                                                ? quantity[index] -= 1
                                                : quantity[index];

                                            selectedQty = quantity[index];
                                            if (!addedIndexes.contains(index) &&
                                                (quantity[index] != 0)) {
                                              differentDishes += 1;
                                              addedIndexes.add(index);
                                            } else if (quantity[index] == 0) {
                                              addedIndexes.removeWhere(
                                                  (element) =>
                                                      element == index);
                                              differentDishes -= 1;
                                            }
                                          });
                                        },
                                        child: quantity[index] != 0
                                            ? Container(
                                                width: 30,
                                                height: 30,
                                                color: Colors.green,
                                                child: const Center(
                                                    child: Icon(
                                                  Icons.remove,
                                                  color: Colors.white,
                                                )),
                                              )
                                            : Container(
                                                width: 30,
                                              ),
                                      ),
                                      const Spacer(),
                                      quantity[index] != 0
                                          ? Text(
                                              '${quantity[index]}',
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600),
                                            )
                                          : Container(),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            finalIndex = index;

                                            mainDishPrice = double.parse(
                                                snapshot.data!['data'][index]
                                                        ['formatted_price']
                                                    .toString());

                                            quantity[index] += 1;
                                            if (!addedIndexes.contains(index)) {
                                              differentDishes += 1;
                                              addedIndexes.add(index);
                                            }

                                            additionalfinalIndex = 250;
                                            selectedQty = quantity[index];
                                          });
                                          if (differentDishes > 3) {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    AppTags.limitExpired.tr,
                                                  ),
                                                  content: Text(
                                                    AppTags.limitIs3.tr,
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: Text(
                                                        AppTags.close.tr,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        },
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          color: Colors.green,
                                          child: const Center(
                                              child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          )),
                                        ),
                                      )
                                    ],
                                  ),
                                  ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(100.0)),
                                    child: Image.network(
                                      snapshot.data!['data'][index]['image'],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Text(snapshot.data!['data'][index]['title']
                                      .toString()),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Text(snapshot.data!['data'][index]
                                              ['formatted_price']
                                          .toString() +
                                      '₾'.toString()),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ]),
                    );
                  } else if (snapshot.hasError) {
                    // if an error has occurred, show an error message
                    return Text("An error has occurred: ${snapshot.error}");
                  }
                  // if the data hasn't arrived yet, show a loading indicator
                  return const Center(
                      child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator()));
                },
              )),
          const Spacer(),
          SizedBox(
              width: MediaQuery.of(context).size.width / 2.1,
              child: FutureBuilder(
                future: getCheaperProducts(
                  int.parse(widget.id!.toString()),
                  double.parse(mainDishPrice.toString()),
                ), // your function that returns a future
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // if the data has arrived, show the widget
                    return SingleChildScrollView(
                      physics: const ScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Center(
                              child: Text(
                            AppTags.additionalProduct.tr,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          )),
                          const SizedBox(
                            height: 15,
                          ),
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    additionalfinalIndex = index;
                                    if (additionals.length < 3) {
                                      additionals
                                          .add(snapshot.data![index]['id']);
                                    } else {}
                                  });
                                },
                                child: Container(
                                  color: additionalfinalIndex == index
                                      ? Colors.transparent
                                      : Colors.transparent,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100.0)),
                                            child: Image.network(
                                              snapshot.data![index]['image'],
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 70,
                                                child: Text(snapshot
                                                    .data![index]['title']
                                                    .toString()),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          additionalfinalIndex == index
                                              ? Container(
                                                  width: 30,
                                                  height: 70,
                                                  color: Colors.green,
                                                  child: const Center(
                                                      child: Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                  )),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    // if an error has occurred, show an error message
                    return Text("An error has occurred: ${snapshot.error}");
                  }
                  // if the data hasn't arrived yet, show a loading indicator
                  return const Center(
                      child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator()));
                },
              )),
        ],
      ),
    );
  }
}
