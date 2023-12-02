// ignore_for_file: division_optimization

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../controllers/cart_content_controller.dart';
import '../controllers/currency_converter_controller.dart';
import '../models/add_to_cart_list_model.dart';
import '../utils/app_tags.dart';
import '../utils/app_theme_data.dart';
import '../utils/responsive.dart';

class CartItem extends StatefulWidget {
  late final Carts cart;
  // ignore: prefer_const_constructors_in_immutables
  CartItem({required cartList, required this.cart, Key? key}) : super(key: key);

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  final _cartController = Get.find<CartContentController>();

  final currencyConverterController = Get.find<CurrencyConverterController>();

  late final AddToCartListModel cartList;

  Future<dynamic> fetchProductData(int productId, double price, int qty) async {
    final response = await http.get(
      Uri.parse(
          'http://julius.ltd/hotcard/api/v100/product-details/$productId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final categoryId = data['data']['category'];
      final response2 = await http.get(
        Uri.parse(
            'http://julius.ltd/hotcard/api/v100/products-by-category/$categoryId'),
      );

      if (response2.statusCode == 200) {
        final data2 = jsonDecode(response2.body);

        final filteredData = data2['data']
            .where((product) =>
                (double.parse(product['formatted_price'].toString())) <=
                price * qty)
            .toList();
        return filteredData;
      } else {
        return fetchProductData(productId, price, qty);
      }
    } else {
      return fetchProductData(productId, price, qty);
    }
  }

  int selectedValue = 25;
  double additionalPrice = 0.00;
  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(widget.cart),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(
          onDismissed: () async {
            _cartController.deleteAProductFromCart(
                productId: widget.cart.id.toString());
          },
        ),
        children: [
          SlidableAction(
            onPressed: (c) async {
              _cartController.deleteAProductFromCart(
                  productId: widget.cart.id.toString());
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: AppTags.delete.tr,
          ),
        ],
      ),
      child: SizedBox(
        height: 300,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile(context) ? 15.w : 10.w, vertical: 8.h),
              child: Container(
                //height:isMobile(context)? 115.h:125.h,
                decoration: BoxDecoration(
                  color: AppThemeData.cartItemBoxDecorationColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                        spreadRadius: 30,
                        blurRadius: 5,
                        color: AppThemeData.boxShadowColor.withOpacity(0.01),
                        offset: const Offset(0, 15))
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(8.r),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(100.0)),
                        child: Image.network(
                            widget.cart.productImage.toString(),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 6,
                        child: Padding(
                          padding: EdgeInsets.only(left: 4.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.cart.productName.toString(),
                                style: isMobile(context)
                                    ? AppThemeData.labelTextStyle_16
                                        .copyWith(fontSize: 14.sp)
                                    : AppThemeData.todayDealDiscountPriceStyle,
                                textScaleFactor: 1.0,
                                maxLines: 2,
                              ),
                              Text(
                                widget.cart.variant.toString(),
                                style: isMobile(context)
                                    ? AppThemeData.hintTextStyle_13
                                    : AppThemeData.hintTextStyle_10Tab,
                              ),
                              Text(
                                currencyConverterController.convertCurrency(
                                    widget.cart.formattedPrice.toString()),
                                style: isMobile(context)
                                    ? AppThemeData.priceTextStyle_14
                                    : AppThemeData.titleTextStyle_11Tab,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: child,
                                );
                              },
                              child: Text(
                                widget.cart.quantity.toString(),
                                style: isMobile(context)
                                    ? AppThemeData.priceTextStyle_14
                                    : AppThemeData.titleTextStyle_11Tab,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Text(
              AppTags.chooseAdditionalDish.tr,
            ),
            FutureBuilder<dynamic>(
                future: fetchProductData(widget.cart.productId!,
                    double.parse(widget.cart.price), widget.cart.quantity!),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data;
                    int productCount = data.length;
                    return SizedBox(
                      height: 186,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: productCount,
                        itemBuilder: (BuildContext context, int index) {
                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: isMobile(context) ? 15.w : 10.w,
                                  vertical: 8.h),
                              child: Padding(
                                padding: EdgeInsets.all(8.r),
                                child: Row(
                                  children: [
                                    Radio(
                                        value: index,
                                        groupValue: selectedValue,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedValue = value!;
                                            additionalPrice = double.parse(
                                                    data[index]['price']
                                                        .toString()) *
                                                (((double.parse(widget
                                                                .cart.quantity
                                                                .toString()) *
                                                            double.parse(widget
                                                                .cart
                                                                .formattedPrice
                                                                .toString())) /
                                                        double.parse(data[index]
                                                                ['price']
                                                            .toString())))
                                                    .toInt();
                                          });
                                        }),
                                    InkWell(
                                      child: Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(100.0)),
                                          image: DecorationImage(
                                              image: NetworkImage(data[index]
                                                      ['image']
                                                  .toString()),
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      flex: 6,
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 4.w),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data[index]['title'].toString(),
                                              style: isMobile(context)
                                                  ? AppThemeData
                                                      .labelTextStyle_16
                                                      .copyWith(fontSize: 12.sp)
                                                  : AppThemeData
                                                      .todayDealDiscountPriceStyle,
                                              textScaleFactor: 1.0,
                                              maxLines: 2,
                                            ),
                                            Text(
                                              data[index]['title'].toString(),
                                              style: isMobile(context)
                                                  ? AppThemeData
                                                      .hintTextStyle_13
                                                      .copyWith(fontSize: 9.sp)
                                                  : AppThemeData
                                                      .hintTextStyle_10Tab,
                                            ),
                                            Text(
                                              currencyConverterController
                                                  .convertCurrency(data[index]
                                                          ['price']
                                                      .toString()),
                                              style: isMobile(context)
                                                  ? AppThemeData
                                                      .priceTextStyle_14
                                                      .copyWith(fontSize: 12.sp)
                                                  : AppThemeData
                                                      .titleTextStyle_11Tab,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 500),
                                            transitionBuilder: (Widget child,
                                                Animation<double> animation) {
                                              return ScaleTransition(
                                                scale: animation,
                                                child: child,
                                              );
                                            },
                                            child: Text(
                                              (((double.parse(widget
                                                              .cart.quantity
                                                              .toString()) *
                                                          double.parse(widget
                                                              .cart
                                                              .formattedPrice
                                                              .toString())) /
                                                      double.parse(data[index]
                                                              ['price']
                                                          .toString())))
                                                  .toInt()
                                                  .toString(),
                                              style: isMobile(context)
                                                  ? AppThemeData
                                                      .priceTextStyle_14
                                                  : AppThemeData
                                                      .titleTextStyle_11Tab,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }
                  return const CircularProgressIndicator();
                })
          ],
        ),
      ),
    );
  }
}
