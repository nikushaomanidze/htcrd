import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hot_card/src/screen/home/category/product_by_category_screen.dart';
import 'package:ribbon_widget/ribbon_widget.dart';

import '../../../config.dart';
import '../../controllers/cart_content_controller.dart';
import '../../controllers/currency_converter_controller.dart';
import '../../controllers/home_screen_controller.dart';
import '../../models/search_product_model.dart';
import '../../utils/app_tags.dart';
import '../../utils/app_theme_data.dart';
import '../../utils/responsive.dart';

class SearchProductCard extends StatelessWidget {
  SearchProductCard({required this.data, Key? key}) : super(key: key);
  late final SearchProductData data;
  final currencyConverterController = Get.find<CurrencyConverterController>();
  final homeController = Get.put(HomeScreenController());
  final _cartController = Get.find<CartContentController>();

  @override
  Widget build(BuildContext context) {
    return Ribbon(
      farLength: data.isNew! ? 20 : 1,
      nearLength: data.isNew! ? 40 : 1,
      title: data.isNew! ? AppTags.neW.tr : "",
      titleStyle: AppThemeData.timeDateTextStyle_11.copyWith(fontSize: 10.sp),
      color: AppThemeData.productBannerColor,
      location: RibbonLocation.topEnd,
      child: Container(
        height: 230.h,
        width: 165.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10.r)),
          boxShadow: [
            BoxShadow(
              color: AppThemeData.boxShadowColor.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 20.r,
              offset: const Offset(0, 10), // changes position of shadow
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            Get.to(ProductByCategory(
              id: data.categoryId,
              title: data.categoryTitle,
              category: data.categoryFilter,
              imgurl:
                  'https://hotcard.online/api/public/${data.categoryBanner!['image_835x200']}',
              latlong: data.categoryLatlong,
              number: data.categoryNumber,
              soc_fb: data.categoryFb,
              soc_in: data.categoryIg,
              soc_yt: data.categoryYt,
            ));
          },
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(5.r),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            data.specialDiscountType == 'flat'
                                ? double.parse(data.specialDiscount ?? "0") ==
                                        0.000
                                    ? const SizedBox()
                                    : Container(
                                        height: 20.h,
                                        decoration: BoxDecoration(
                                          color: AppThemeData
                                              .productBoxDecorationColor
                                              .withOpacity(0.06),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(3.r),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${currencyConverterController.convertCurrency(data.specialDiscount)} OFF",
                                            style: isMobile(context)
                                                ? AppThemeData.todayDealNewStyle
                                                : AppThemeData
                                                    .todayDealNewStyleTab,
                                          ),
                                        ),
                                      )
                                : data.specialDiscountType == 'percentage'
                                    ? double.parse(
                                                data.specialDiscount ?? "0") ==
                                            0.000
                                        ? const SizedBox()
                                        : Container(
                                            height: 20.h,
                                            decoration: BoxDecoration(
                                              color: AppThemeData
                                                  .productBoxDecorationColor
                                                  .withOpacity(0.06),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(3.r),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "${homeController.removeTrailingZeros(data.specialDiscount ?? "0")}% OFF",
                                                textAlign: TextAlign.center,
                                                style: isMobile(context)
                                                    ? AppThemeData
                                                        .todayDealNewStyle
                                                    : AppThemeData
                                                        .todayDealNewStyleTab,
                                              ),
                                            ),
                                          )
                                    : Container(),
                          ],
                        ),
                        // data.specialDiscount == null
                        //     ? const SizedBox()
                        //     : SizedBox(width: 5.w),
                        // data.currentStock == 0
                        //     ? Container(
                        //         height: 20.h,
                        //         decoration: BoxDecoration(
                        //           color: AppThemeData.productBoxDecorationColor
                        //               .withOpacity(0.06),
                        //           borderRadius:
                        //               BorderRadius.all(Radius.circular(3.r)),
                        //         ),
                        //         child: Center(
                        //           child: Text(
                        //             AppTags.stockOut.tr,
                        //             style: isMobile(context)
                        //                 ? AppThemeData.todayDealNewStyle
                        //                 : AppThemeData.todayDealNewStyleTab,
                        //           ),
                        //         ),
                        //       )
                        //     : const SizedBox(),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 18.h,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.r),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          data.image!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 7.w),
                    child: Text(
                      data.title!,
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
                        horizontal: isMobile(context) ? 18.w : 10.w),
                    child: Center(
                      child: double.parse(data.specialDiscount ?? "0") == 0.000
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  currencyConverterController
                                      .convertCurrency(data.price!),
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
                                      .convertCurrency(data.price!),
                                  style:
                                      AppThemeData.todayDealOriginalPriceStyle,
                                ),
                                SizedBox(width: isMobile(context) ? 15.w : 5.w),
                                Text(
                                  currencyConverterController
                                      .convertCurrency(data.discountPrice!),
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
                  ? data.hasVariant!
                      ? const SizedBox()
                      : Obx(
                          () => Positioned(
                              bottom: isMobile(context) ? 50.h : 52.h,
                              right: 10,
                              child: Container(
                                height: isMobile(context) ? 26.h : 30.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.25),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(28.r),
                                  ),
                                ),
                                child: _cartController
                                            .incrementProduct(data.id!) ==
                                        -1
                                    ? Obx(() => InkWell(
                                          onTap: () async {
                                            int cartMinOrder =
                                                data.minimumOrderQuantity!;
                                            _cartController.addToCart(
                                              productId: data.id!.toString(),
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
                                                        data.id.toString() &&
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
                                                            data.id!);
                                                int cartMinOrder =
                                                    data.minimumOrderQuantity!;
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
                                                          quantity: -1);
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
                                                            data.id
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
                                                        horizontal: 3.0),
                                                child: Text(
                                                  _cartController
                                                      .addToCartListModel
                                                      .data!
                                                      .carts![_cartController
                                                          .incrementProduct(
                                                              data.id!)]
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
                                                            data.id!);
                                                int cartStock =
                                                    data.currentStock!;
                                                int cartMinOrder =
                                                    data.minimumOrderQuantity!;
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
                                                            data.id
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

class SearchRestaurantCard extends StatelessWidget {
  SearchRestaurantCard({required this.data, Key? key}) : super(key: key);
  late final SearchRestaurantData data;
  final currencyConverterController = Get.find<CurrencyConverterController>();
  final homeController = Get.put(HomeScreenController());

  @override
  Widget build(BuildContext context) {
    return Ribbon(
      farLength: data.id! == 5550 ? 20 : 1,
      nearLength: data.id! == 5550 ? 40 : 1,
      title: data.id! == 5550 ? AppTags.neW.tr : "",
      titleStyle: AppThemeData.timeDateTextStyle_11.copyWith(fontSize: 10.sp),
      color: AppThemeData.productBannerColor,
      location: RibbonLocation.topEnd,
      child: Container(
        height: 230.h,
        width: 165.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(7.r)),
          boxShadow: [
            BoxShadow(
              color: AppThemeData.boxShadowColor.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 20.r,
              offset: const Offset(0, 10), // changes position of shadow
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            Get.to(ProductByCategory(
              id: data.id,
              category: data.category_filter,
              imgurl: data.banner,
              latlong: data.latlong,
              number: data.number,
              soc_fb: data.soc_fb,
              soc_in: data.soc_in,
              soc_yt: data.soc_yt,
              title: data.title,
            ));
          },
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 18.h,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.r),
                      child: ClipRRect (
                        borderRadius: BorderRadius.circular(20),
                         child:  Image.network(
                        data.image!,
                        fit: BoxFit.cover,
                      )),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 7.w),
                    child: Text(
                      data.title!,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: isMobile(context)
                          ? AppThemeData.todayDealTitleStyle
                          : AppThemeData.todayDealTitleStyleTab,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  SizedBox(
                    height: 5.h,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
