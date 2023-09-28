import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../../config.dart';
import '../../../_route/routes.dart';
import '../../../controllers/payment_controller.dart';
import '../../../data/local_data_helper.dart';
import '../../../servers/network_service.dart';
import '../../../utils/app_tags.dart';
import '../../../utils/app_theme_data.dart';
import '../../../utils/constants.dart';
import '../../../widgets/loader/loader_widget.dart';

class MyWalletRechargeScreen extends GetView<PaymentController> {
  MyWalletRechargeScreen({Key? key}) : super(key: key);

  final String amount = Get.parameters['amount']!;
  final String token = Get.parameters['token']!;
  final String langCurrCode =
      "lang=${LocalDataHelper().getLangCode() ?? "en"}&curr=${LocalDataHelper().getCurrCode()}";

  void topUpWallet(int amount, String token, String langCurrCode) async {
    try {
      final response = await http.post(
        Uri.parse("${NetworkService.apiUrl}/user/recharge"),
        headers: {"apiKey": Config.apiKey},
        body: {"amount": amount, "token": token, "langCurrCode": langCurrCode},
      );
      if (response.statusCode == 200) {
        // Successfully topped up wallet
        // You can add any additional handling for a successful wallet top up here
      } else {
        // Handle failed wallet top up
      }
    } catch (error) {
      // Handle error making API call to top up wallet
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaymentController>(
      builder: (paymentController) {
        return Scaffold(
          extendBody: true,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: Text(
              AppTags.paymentGateway.tr,
              style: AppThemeData.headerTextStyle_16,
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      TextButton.icon(
                          onPressed: () => topUpWallet(55, token, langCurrCode),
                          icon: const Icon(Icons.abc),
                          label: const Text('Buy')),
                      InAppWebView(
                        key: paymentController.webViewKey,
                        initialUrlRequest: URLRequest(
                          headers: {"apiKey": Config.apiKey},
                          url: Uri.parse(
                              "${NetworkService.apiUrl}/user/recharge?amount=$amount&token=$token&$langCurrCode"),
                        ),
                        initialUserScripts:
                            UnmodifiableListView<UserScript>([]),
                        initialOptions: paymentController.options,
                        pullToRefreshController:
                            paymentController.pullToRefreshController,
                        onWebViewCreated: (controller) {
                          paymentController.webViewController = controller;
                        },
                        onLoadStart: (controller, url) {
                          printLog("LoadStart URL: $url");
                          if (url ==
                              Uri.parse(
                                  "${Config.apiServerUrl}/payment-success")) {
                            Get.offAllNamed(Routes.rechargeConfirm);
                          }
                        },
                        androidOnPermissionRequest:
                            (controller, origin, resources) async {
                          return PermissionRequestResponse(
                              resources: resources,
                              action: PermissionRequestResponseAction.GRANT);
                        },
                        shouldOverrideUrlLoading:
                            (controller, navigationAction) async {
                          return NavigationActionPolicy.ALLOW;
                        },
                        onLoadStop: (controller, url) async {
                          printLog("${NetworkService.walletRechargeUrl}/login");
                          printLog("LoadStart URL: $url");
                          if (url ==
                              Uri.parse(
                                  "${Config.apiServerUrl}/payment-success")) {
                            Get.offAllNamed(Routes.rechargeConfirm);
                          }
                          paymentController.isLoadingUpdate(false);
                          paymentController.pullToRefreshController
                              .endRefreshing();
                          paymentController.webViewController!
                              .evaluateJavascript(
                                  source: "javascript:(function() { "
                                      "var order = document.getElementById('order_btn');"
                                      "order.parentNode.removeChild(order);"
                                      "})()")
                              .then((value) => debugPrint(
                                  'Page finished loading Javascript'))
                              .catchError((onError) => debugPrint('$onError'));

                          paymentController.webViewController!
                              .evaluateJavascript(
                                  source: "javascript:(function() { "
                                      "var shipping = document.getElementById('shipping_btn');"
                                      "shipping.parentNode.removeChild(shipping);"
                                      "})()")
                              .then((value) => debugPrint(
                                  'Page finished loading Javascript'))
                              .catchError((onError) => debugPrint('$onError'));
                        },
                        onLoadError: (controller, url, code, message) {
                          paymentController.pullToRefreshController
                              .endRefreshing();
                        },
                        onProgressChanged: (controller, progress) {
                          paymentController.progressUpdate(progress);

                          if (progress == 100) {
                            paymentController.pullToRefreshController
                                .endRefreshing();
                          }
                        },
                        onUpdateVisitedHistory:
                            (controller, url, androidIsReload) {},
                        onConsoleMessage: (controller, consoleMessage) {},
                      ),
                      paymentController.isLoading
                          ? const Center(child: LoaderWidget())
                          : Container(),
                      Positioned(
                        bottom: 100.h,
                        child: Column(
                          children: [
                            paymentController.showButton
                                ? SizedBox(
                                    width: 160.w,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Get.toNamed(Routes.dashboardScreen);
                                      },
                                      child: Text(AppTags.continueShopping.tr),
                                    ),
                                  )
                                : Container(),
                            paymentController.showButton
                                ? SizedBox(
                                    width: 160.w,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Get.toNamed(Routes.categoryContent);
                                      },
                                      child: Text(AppTags.viewOrder.tr),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
