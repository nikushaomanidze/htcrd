import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ribbon_widget/ribbon_widget.dart';

import '../../../config.dart';
import '../../_route/routes.dart';
import '../../controllers/cart_content_controller.dart';
import '../../controllers/currency_converter_controller.dart';
import '../../controllers/home_screen_controller.dart';
import '../../utils/app_tags.dart';
import '../../utils/app_theme_data.dart';
import '../../utils/constants.dart';
import '../../utils/responsive.dart';

class CategoryProductCard extends StatelessWidget {
  CategoryProductCard({
    Key? key,
    required this.dataModel,
    required this.index,
  }) : super(key: key);
  final dynamic dataModel;
  final int index;
  final currencyConverterController = Get.find<CurrencyConverterController>();
  final homeController = Get.put(HomeScreenController());
  final _cartController = Get.find<CartContentController>();

  @override
  Widget build(BuildContext context) {
    return Ribbon(
      farLength: dataModel.isNew!
          ? isMobile(context)
              ? 20
              : 30
          : 1,
      nearLength: dataModel.isNew!
          ? isMobile(context)
              ? 40
              : 60
          : 1,
      title: dataModel.isNew! ? AppTags.neW.tr : "",
      titleStyle: TextStyle(
        fontSize: isMobile(context) ? 10.sp : 8.sp,
        fontFamily: 'Poppins',
      ),
      color: AppThemeData.productBannerColor,
      location: RibbonLocation.topEnd,
      child: Container(
        height: 230.h,
        width: 165.w,
        decoration: BoxDecoration(
          color: const Color.fromARGB(0, 255, 255, 255),
          borderRadius: BorderRadius.all(Radius.circular(7.r)),
          // boxShadow: [
          //   BoxShadow(
          //     color: AppThemeData.boxShadowColor.withOpacity(0.1),
          //     spreadRadius: 0,
          //     blurRadius: 20.r,
          //     offset: const Offset(0, 10), // changes position of shadow
          //   ),
          // ],
        ),
        child: InkWell(
          onTap: () {
            Get.toNamed(
              Routes.detailsPage,
              parameters: {
                'productId': dataModel.id!.toString(),
              },
            );
          },
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 12.h,
                  ),
                  Container(
                    width: 120,
                    height: 80,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(dataModel.image!),
                          fit: BoxFit.cover,
                        )),
                  ),
                  // ClipRRect(
                  //   borderRadius: BorderRadius.circular(100.0),
                  //   child: Image.network(
                  //     dataModel.image!,
                  //     width: 100,
                  //     height: 100,
                  //     fit: BoxFit.cover,
                  //   ),
                  // ),
                  SizedBox(height: 14.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 7.w),
                    child: Text(
                      dataModel.title!,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: isMobile(context)
                          ? AppThemeData.todayDealTitleStyle
                          : AppThemeData.todayDealTitleStyleTab,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile(context) ? 18.w : 8.w),
                    child: Center(
                      child: double.parse(dataModel.specialDiscount) == 0.000
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  currencyConverterController
                                      .convertCurrency(dataModel.price!),
                                  style: isMobile(context)
                                      ? AppThemeData.todayDealDiscountPriceStyle
                                      : AppThemeData
                                          .todayDealDiscountPriceStyleTab,
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  currencyConverterController
                                      .convertCurrency(dataModel.price!),
                                  style: isMobile(context)
                                      ? AppThemeData.todayDealOriginalPriceStyle
                                      : AppThemeData
                                          .todayDealOriginalPriceStyleTab,
                                ),
                                SizedBox(width: isMobile(context) ? 15.w : 5.w),
                                Text(
                                  currencyConverterController.convertCurrency(
                                      dataModel.discountPrice!),
                                  style: isMobile(context)
                                      ? AppThemeData.todayDealDiscountPriceStyle
                                      : AppThemeData
                                          .todayDealDiscountPriceStyleTab,
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                ],
              ),
              Config.groceryCartMode
                  ? dataModel.hasVariant
                      ? const SizedBox()
                      : Obx(
                          () => Positioned(
                              bottom: isMobile(context) ? 50.h : 52.h,
                              right: 10,
                              child: Container(
                                height: isMobile(context) ? 26.h : 30.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(28.r),
                                  ),
                                ),
                                child: _cartController
                                            .incrementProduct(dataModel.id) ==
                                        -1
                                    ? Obx(() => InkWell(
                                          onTap: () async {
                                            int cartMinOrder =
                                                dataModel.minimumOrderQuantity!;
                                            _cartController.addToCart(
                                              productId:
                                                  dataModel.id!.toString(),
                                              quantity: cartMinOrder.toString(),
                                              variantsIds: "",
                                              variantsNames: "",
                                            );
                                          },
                                          child: Container(
                                            height:
                                                isMobile(context) ? 24.h : 15.h,
                                            width:
                                                isMobile(context) ? 24.w : 18.w,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: AppThemeData
                                                  .cartItemBoxDecorationColor,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  spreadRadius: 3,
                                                  blurRadius: 2,
                                                  color: AppThemeData
                                                      .boxShadowColor
                                                      .withOpacity(0.1),
                                                  offset: const Offset(0, 0),
                                                )
                                              ],
                                            ),
                                            child: _cartController
                                                        .isCartUpdating &&
                                                    _cartController
                                                            .updatingCartId ==
                                                        dataModel.id
                                                            .toString() &&
                                                    _cartController.isIncreasing
                                                ? const CircularProgressIndicator(
                                                    strokeWidth: 1)
                                                : Icon(
                                                    Icons.add,
                                                    size: 16.r,
                                                    color: AppThemeData
                                                        .cartItemIconColor,
                                                  ),
                                          ),
                                        ))
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                int indexProduct =
                                                    _cartController
                                                        .incrementProduct(
                                                            dataModel.id);
                                                int cartMinOrder = dataModel
                                                    .minimumOrderQuantity!;
                                                int? baseQny = _cartController
                                                    .addToCartListModel
                                                    .data!
                                                    .carts![indexProduct]
                                                    .quantity;
                                                if (cartMinOrder < baseQny!) {
                                                  _cartController
                                                      .updateCartProduct(
                                                          increasing: false,
                                                          cartId: _cartController
                                                              .addToCartListModel
                                                              .data!
                                                              .carts![
                                                                  indexProduct]
                                                              .id
                                                              .toString(),
                                                          quantity: -1)
                                                      .then((value) => printLog(
                                                          "value ========$value"));
                                                } else {
                                                  _cartController
                                                      .deleteAProductFromCart(
                                                          productId: _cartController
                                                              .addToCartListModel
                                                              .data!
                                                              .carts![
                                                                  indexProduct]
                                                              .id
                                                              .toString());
                                                }
                                              },
                                              child: Container(
                                                height: isMobile(context)
                                                    ? 23.h
                                                    : 25.h,
                                                width: isMobile(context)
                                                    ? 23.w
                                                    : 17.w,
                                                alignment: Alignment.center,
                                                decoration: const BoxDecoration(
                                                  color: AppThemeData
                                                      .cartItemBoxDecorationColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: _cartController
                                                            .isCartUpdating &&
                                                        _cartController
                                                                .updatingCartId ==
                                                            dataModel.id
                                                                .toString() &&
                                                        !_cartController
                                                            .isIncreasing
                                                    ? const CircularProgressIndicator(
                                                        strokeWidth: 1)
                                                    : Icon(
                                                        Icons.remove,
                                                        size: 16.r,
                                                        color: AppThemeData
                                                            .cartItemIconColor,
                                                      ),
                                              ),
                                            ),
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
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 3),
                                                child: Text(
                                                  _cartController
                                                      .addToCartListModel
                                                      .data!
                                                      .carts![_cartController
                                                          .incrementProduct(
                                                              dataModel.id)]
                                                      .quantity
                                                      .toString(),
                                                  style: isMobile(context)
                                                      ? AppThemeData
                                                          .priceTextStyle_14
                                                      : AppThemeData
                                                          .titleTextStyle_11Tab,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                int? indexProduct =
                                                    _cartController
                                                        .incrementProduct(
                                                            dataModel.id);
                                                printLog(indexProduct);
                                                int cartStock =
                                                    dataModel.currentStock;
                                                int cartMinOrder = dataModel
                                                    .minimumOrderQuantity;
                                                if (cartMinOrder < cartStock) {
                                                  _cartController
                                                      .updateCartProduct(
                                                          increasing: true,
                                                          cartId: _cartController
                                                              .addToCartListModel
                                                              .data!
                                                              .carts![
                                                                  indexProduct]
                                                              .id
                                                              .toString(),
                                                          quantity: 1);
                                                }
                                              },
                                              child: Container(
                                                height: isMobile(context)
                                                    ? 23.h
                                                    : 25.h,
                                                width: isMobile(context)
                                                    ? 23.w
                                                    : 17.w,
                                                alignment: Alignment.center,
                                                decoration: const BoxDecoration(
                                                  color: AppThemeData
                                                      .cartItemBoxDecorationColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: _cartController
                                                            .isCartUpdating &&
                                                        _cartController
                                                                .updatingCartId ==
                                                            dataModel.id
                                                                .toString() &&
                                                        _cartController
                                                            .isIncreasing
                                                    ? const CircularProgressIndicator(
                                                        strokeWidth: 1)
                                                    : Icon(
                                                        Icons.add,
                                                        size: 16.r,
                                                        color: AppThemeData
                                                            .cartItemIconColor,
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              )),
                        )
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
