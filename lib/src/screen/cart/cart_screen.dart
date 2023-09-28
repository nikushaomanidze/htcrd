import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../config.dart';
import '../../_route/routes.dart';
import '../../controllers/cart_content_controller.dart';
import '../../controllers/currency_converter_controller.dart';
import '../../data/local_data_helper.dart';
import '../../models/add_to_cart_list_model.dart';
import '../../models/shipping_address_model/shipping_address_model.dart';
import '../../servers/network_service.dart';
import '../../servers/repository.dart';
import '../../utils/app_tags.dart';
import '../../utils/app_theme_data.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/cart_item.dart';
import '../../widgets/loader/shimmer_cart_content.dart';
import 'empty_cart_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final TextEditingController couponController = TextEditingController();
  late final CartContentController _cartController;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final postalCodeController = TextEditingController();
  final addressController = TextEditingController();
  // final MyWalletController myWalletController = Get.put(MyWalletController());
  final currencyConverterController = Get.find<CurrencyConverterController>();
  bool isSelectPickup = false;
  bool isSelectBilling = false;
  int? shippingIndex = 0;
  String? token = LocalDataHelper().getUserToken();
  void onShippingTapped(int? index) {
    setState(() {
      shippingIndex = index!;
    });
  }
  // final currencyConverterController = Get.find<CurrencyConverterController>();

  String? phoneCode = "995";
  dynamic selectPickUpAddress;
// Option 2
// Option 2// Option 2
// Option 2

  ShippingAddressModel shippingAddressModel = ShippingAddressModel();
  Future getShippingAddress() async {
    shippingAddressModel = await Repository().getShippingAddress();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _cartController = Get.put(CartContentController());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _cartController.isLoading
          ? const ShimmerCartContent()
          : _mainUi(_cartController.addToCartListModel, context),
    );
  }

  //User Confirm Order
  Future postConfirmOrder() async {
    var headers = {"apiKey": Config.apiKey};
    Map<String, String> bodyData;

    if (isSelectPickup) {
      bodyData = {
        'pick_hub_id': selectPickUpAddress.toString(),
        'trx_id': LocalDataHelper().getCartTrxId().toString()
      };
    } else {
      bodyData = {
        'shipping_address[id]': "Shipping Address",
        'shipping_address[name]': "Shipping Address",
        'shipping_address[email]': "Gmail@Gmail.Com",
        'shipping_address[phone_no]': "555444333",
        'billing_address[id]': isSelectBilling
            ? shippingAddressModel.data!.addresses![shippingIndex!].id
                .toString()
            : "Billing Address",
        'billing_address[name]': isSelectBilling
            ? shippingAddressModel.data!.addresses![shippingIndex!].name
                .toString()
            : "Billing Name",
        'billing_address[email]': isSelectBilling
            ? shippingAddressModel.data!.addresses![shippingIndex!].email
                .toString()
            : "Email@Gmail.Com",
        'billing_address[phone_no]': isSelectBilling
            ? shippingAddressModel.data!.addresses![shippingIndex!].phoneNo
                .toString()
            : "555444333",
        'trx_id': LocalDataHelper().getCartTrxId().toString()
      };
    }

    Uri url;
    if (LocalDataHelper().getUserToken() == null) {
      url = Uri.parse("${NetworkService.apiUrl}/confirm-order");
    } else {
      url = Uri.parse(
          "${NetworkService.apiUrl}/confirm-order?token=${LocalDataHelper().getUserToken()}");
    }
    final response = await http.post(
      url,
      body: bodyData,
      headers: headers,
    );
    if (response.statusCode == 200) {
      //showShortToast(data["message"].toString());
    } else {
      showShortToast("No response");
    }
  }

  Widget _mainUi(AddToCartListModel addToCartListModel, context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppTags.myCart.tr,
          style: isMobile(context)
              ? AppThemeData.headerTextStyle_16
              : AppThemeData.headerTextStyle_14,
        ),
      ),
      body: addToCartListModel.data!.carts!.isNotEmpty
          ? SizedBox(
              height: size.height,
              width: size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: addToCartListModel.data!.carts!.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            CartItem(
                                cartList: addToCartListModel,
                                cart: addToCartListModel.data!.carts![index]),
                          ],
                        );
                      },
                    ),
                  ),

                  // Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 15.h),
                  //   child: Column(
                  //     children: [
                  //       Container(
                  //         decoration: BoxDecoration(
                  //           color: Colors.white,
                  //           borderRadius: BorderRadius.circular(10.r),
                  //           boxShadow: [
                  //             BoxShadow(
                  //               color: AppThemeData.boxShadowColor
                  //                   .withOpacity(0.1),
                  //               spreadRadius: 0,
                  //               blurRadius: 30,
                  //               offset: const Offset(
                  //                   0, 15), // changes position of shadow
                  //             ),
                  //           ],
                  //         ),
                  //         child: Theme(
                  //           data: Theme.of(context)
                  //               .copyWith(dividerColor: Colors.transparent),
                  //           child: ExpansionTile(
                  //             onExpansionChanged: (bool expanded) {},
                  //             title: Text(
                  //               AppTags.couponApply.tr,
                  //               style: isMobile(context)
                  //                   ? AppThemeData.buttonTextStyle_14Reg
                  //                       .copyWith(
                  //                           fontSize: 13.sp,
                  //                           fontFamily: "Poppins Medium")
                  //                   : AppThemeData.buttonTextStyleTab
                  //                       .copyWith(fontFamily: "Poppins Medium"),
                  //             ),
                  //             children: [
                  //               Column(
                  //                 children: [
                  //                   Padding(
                  //                     padding: EdgeInsets.symmetric(
                  //                         horizontal: 15.w),
                  //                     child: SizedBox(
                  //                       height: 40.h,
                  //                       width: double.infinity,
                  //                       child: ListView.builder(
                  //                         shrinkWrap: true,
                  //                         scrollDirection: Axis.horizontal,
                  //                         itemCount: _cartController
                  //                                     .appliedCouponList.data !=
                  //                                 null
                  //                             ? _cartController
                  //                                 .appliedCouponList
                  //                                 .data!
                  //                                 .length
                  //                             : 0,
                  //                         itemBuilder: (_, index) {
                  //                           return Padding(
                  //                             padding:
                  //                                 EdgeInsets.only(right: 4.w),
                  //                             child: Container(
                  //                               height: 40.h,
                  //                               padding: EdgeInsets.only(
                  //                                   left: 10.w, right: 6.w),
                  //                               decoration: BoxDecoration(
                  //                                 borderRadius:
                  //                                     BorderRadius.all(
                  //                                   Radius.circular(5.r),
                  //                                 ),
                  //                                 border: Border.all(
                  //                                   color: AppThemeData
                  //                                       .invoiceDividerColor,
                  //                                   width: 1.w,
                  //                                 ),
                  //                               ),
                  //                               child: Obx(
                  //                                 () => Column(
                  //                                   mainAxisAlignment:
                  //                                       MainAxisAlignment
                  //                                           .center,
                  //                                   crossAxisAlignment:
                  //                                       CrossAxisAlignment
                  //                                           .start,
                  //                                   children: [
                  //                                     Row(
                  //                                       mainAxisAlignment:
                  //                                           MainAxisAlignment
                  //                                               .spaceBetween,
                  //                                       children: [
                  //                                         Text(
                  //                                           _cartController
                  //                                               .appliedCouponList
                  //                                               .data![index]
                  //                                               .title
                  //                                               .toString(),
                  //                                           style: TextStyle(
                  //                                             color:
                  //                                                 Colors.black,
                  //                                             fontSize: isMobile(
                  //                                                     context)
                  //                                                 ? 12.sp
                  //                                                 : 9.sp,
                  //                                           ),
                  //                                         ),
                  //                                       ],
                  //                                     ),
                  //                                     Text(
                  //                                       _cartController
                  //                                           .appliedCouponList
                  //                                           .data![index]
                  //                                           .discount
                  //                                           .toString(),
                  //                                       style: isMobile(context)
                  //                                           ? AppThemeData
                  //                                               .todayDealNewStyle
                  //                                           : AppThemeData
                  //                                               .todayDealNewStyleTab,
                  //                                     ),
                  //                                   ],
                  //                                 ),
                  //                               ),
                  //                             ),
                  //                           );
                  //                         },
                  //                       ),
                  //                     ),
                  //                   ),
                  //                   SizedBox(
                  //                     height: 10.h,
                  //                   ),
                  //                   Padding(
                  //                     padding: EdgeInsets.symmetric(
                  //                         horizontal: 15.h),
                  //                     child: SizedBox(
                  //                       height: 48.h,
                  //                       child: TextFormField(
                  //                         autofocus: false,
                  //                         controller: couponController,
                  //                         keyboardType: TextInputType.text,
                  //                         textInputAction: TextInputAction.next,
                  //                         onSaved: (value) =>
                  //                             couponController.text = value!,
                  //                         decoration: InputDecoration(
                  //                           hintText: _cartController
                  //                               .couponCode.value,
                  //                           suffixIconConstraints:
                  //                               const BoxConstraints(
                  //                             minWidth: 0,
                  //                             minHeight: 0,
                  //                           ),
                  //                           hintStyle: isMobile(context)
                  //                               ? AppThemeData.dateTextStyle_12
                  //                               : AppThemeData
                  //                                   .dateTextStyle_9Tab,
                  //                           enabledBorder: OutlineInputBorder(
                  //                             borderRadius:
                  //                                 BorderRadius.circular(10.r),
                  //                             borderSide: const BorderSide(
                  //                               width: 1,
                  //                               color: AppThemeData
                  //                                   .invoiceDividerColor,
                  //                             ),
                  //                           ),
                  //                           focusedBorder: OutlineInputBorder(
                  //                             borderRadius:
                  //                                 BorderRadius.circular(10.r),
                  //                             borderSide: const BorderSide(
                  //                               width: 1,
                  //                               color: AppThemeData
                  //                                   .invoiceDividerColor,
                  //                             ),
                  //                           ),
                  //                           filled: true,
                  //                           fillColor: Colors.white,
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   ),
                  //                   SizedBox(
                  //                     height: 15.h,
                  //                   ),
                  //                   Padding(
                  //                     padding: EdgeInsets.symmetric(
                  //                         horizontal: 15.w),
                  //                     child: Row(
                  //                       mainAxisAlignment:
                  //                           MainAxisAlignment.end,
                  //                       children: [
                  //                         SizedBox(
                  //                           height: 30.h,
                  //                           child: Obx(
                  //                             () => ElevatedButton(
                  //                               onPressed: () async {
                  //                                 _cartController
                  //                                     .applyCouponCode(
                  //                                         code: couponController
                  //                                             .text);
                  //                               },
                  //                               style: ElevatedButton.styleFrom(
                  //                                 backgroundColor:
                  //                                     const Color(0xFF333333),
                  //                                 shape: RoundedRectangleBorder(
                  //                                   borderRadius:
                  //                                       BorderRadius.circular(
                  //                                           5.r),
                  //                                 ),
                  //                               ),
                  //                               child: _cartController
                  //                                       .isAplyingCoupon
                  //                                   ? SizedBox(
                  //                                       width: 15.w,
                  //                                       height: 15.h,
                  //                                       child:
                  //                                           CircularProgressIndicator(
                  //                                               strokeWidth:
                  //                                                   2.w),
                  //                                     )
                  //                                   : Text(
                  //                                       AppTags.apply.tr,
                  //                                       style: TextStyle(
                  //                                         fontSize:
                  //                                             isMobile(context)
                  //                                                 ? 12.sp
                  //                                                 : 9.sp,
                  //                                         color: Colors.white,
                  //                                       ),
                  //                                     ),
                  //                             ),
                  //                           ),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                   ),
                  //                   SizedBox(
                  //                     height: 15.h,
                  //                   ),
                  //                 ],
                  //               )
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  SizedBox(
                    height: 10.h,
                  ),

                  //Calculate Card

                  Padding(
                    padding:
                        EdgeInsets.only(right: 15.w, left: 15.w, bottom: 15.h),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10.r)),
                        boxShadow: [
                          BoxShadow(
                            spreadRadius: 30,
                            blurRadius: 5,
                            color:
                                AppThemeData.boxShadowColor.withOpacity(0.01),
                            offset: const Offset(0, 15),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10.r),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppTags.subTotal.tr,
                                  style: isMobile(context)
                                      ? AppThemeData.titleTextStyle_14
                                      : AppThemeData.titleTextStyle_11Tab,
                                ),
                                Text(
                                  currencyConverterController.convertCurrency(
                                      addToCartListModel.data!.calculations!
                                          .formattedSubTotal),
                                  style: isMobile(context)
                                      ? AppThemeData.titleTextStyle_14
                                      : AppThemeData.titleTextStyle_11Tab,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppTags.discount.tr,
                                  style: isMobile(context)
                                      ? AppThemeData.titleTextStyle_14
                                      : AppThemeData.titleTextStyle_11Tab,
                                ),
                                Text(
                                  currencyConverterController.convertCurrency(
                                      addToCartListModel
                                          .data!.calculations!.formattedDiscount
                                          .toString()),
                                  style: isMobile(context)
                                      ? AppThemeData.titleTextStyle_14
                                      : AppThemeData.titleTextStyle_11Tab,
                                ),
                              ],
                            ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text(AppTags.deliveryCharge.tr,
                            //         style: isMobile(context)? AppThemeData.titleTextStyle_14 : AppThemeData.titleTextStyle_11Tab),
                            //     Text(
                            //         currencyConverterController.convertCurrency(
                            //             addToCartListModel.data!.calculations!
                            //                 .formattedShippingCost
                            //                 .toString()),
                            //         style: isMobile(context)? AppThemeData.titleTextStyle_14 : AppThemeData.titleTextStyle_11Tab),
                            //   ],
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Text(AppTags.tax.tr,
                            //         style: isMobile(context)? AppThemeData.titleTextStyle_14 : AppThemeData.titleTextStyle_11Tab),
                            //     Text(
                            //         currencyConverterController.convertCurrency(
                            //             addToCartListModel
                            //                 .data!.calculations!.formattedTax
                            //                 .toString()),
                            //         style: isMobile(context)? AppThemeData.titleTextStyle_14 : AppThemeData.titleTextStyle_11Tab),
                            //   ],
                            // ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(AppTags.total.tr,
                                    style: isMobile(context)
                                        ? AppThemeData.titleTextStyle_14
                                        : AppThemeData.titleTextStyle_11Tab),
                                Text(
                                  currencyConverterController.convertCurrency(
                                      addToCartListModel
                                          .data!.calculations!.formattedTotal
                                          .toString()),
                                  style: isMobile(context)
                                      ? AppThemeData.titleTextStyle_14
                                      : AppThemeData.titleTextStyle_11Tab,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.h,
                            ),
                            Padding(
                              padding: EdgeInsets.all(5.r),
                              child: InkWell(
                                onTap: () async {
                                  await postConfirmOrder().then(
                                    (value) => Get.toNamed(
                                      Routes.paymentScreen,
                                      parameters: {
                                        'trxId':
                                            LocalDataHelper().getCartTrxId() ??
                                                "",
                                        'token':
                                            LocalDataHelper().getUserToken() ??
                                                ""
                                      },
                                    ),
                                  );
                                },
                                child: ButtonWidget(
                                  buttonTittle: AppTags.proceedToPayment.tr,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          : EmptyCartScreen(),
    );
  }
}
