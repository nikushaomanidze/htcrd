import 'dart:convert' as convert;
import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hot_card/src/Providers/PaymentProvider.dart';
import 'package:hot_card/src/screen/dashboard/dashboard_screen.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../controllers/currency_converter_controller.dart';
import '../../../controllers/my_wallet_controller.dart';
import '../../../controllers/profile_content_controller.dart';
import '../../../models/user_data_model.dart';
import '../../../utils/app_theme_data.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/loader/loader_widget.dart';
import 'package:hot_card/src/utils/app_tags.dart';

class MyWalletScreen extends StatefulWidget {
  final UserDataModel userDataModel;
  const MyWalletScreen({Key? key, required this.userDataModel})
      : super(key: key);

  @override
  State<MyWalletScreen> createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen> {
  final MyWalletController myWalletController = Get.put(MyWalletController());

  final currencyConverterController = Get.find<CurrencyConverterController>();

  final ProfileContentController _profileContentController =
      Get.put(ProfileContentController());

  final TextEditingController amountController = TextEditingController();

  var cardCode1;
  var jsonData;
  var daysLeft;
  late String userId;

  final String apiKey = '2UwIqaRBAfEQ8y1Po8bn9y8n7ABMFWJR';
  final String clientId = '7001220';
  final String clientSecret = 'OL5p8EsGnIM7hHF7';

  Future<String> getToken(
      String apiKey, String clientId, String clientSecret) async {
    const String url = 'https://api.tbcbank.ge/v1/tpay/access-token';

    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'apikey': apiKey,
    };

    final Map<String, String> data = {
      'client_Id': clientId,
      'client_secret': clientSecret,
    };

    final http.Response response =
        await http.post(Uri.parse(url), headers: headers, body: data);

    final Map<String, dynamic> responseData = jsonDecode(response.body);
    final String accessToken = responseData['access_token'];

    return accessToken;
  }

  //es funkcia iuzeris barats aaktiurebs
  Future<void> makeCardActive(
      String userId, int totalDays, String token) async {
    final url = Uri.parse(
        'https://julius.ltd/hotcard/api/v100/user/make_card_active/$userId?total_days=$totalDays');

    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
      } else {}
    } catch (e) {}
  }

  Future<Map<String, dynamic>> payment(String apiKey, String token) async {
    const url = 'https://api.tbcbank.ge/v1/tpay/payments';
    final headers = {
      'Content-Type': 'application/json',
      'apikey': apiKey,
      'Authorization': 'Bearer $token',
    };
    final data = {
      "amount": {
        "currency": "GEL",
        "total": 10.00,
        "subTotal": 0,
        "tax": 0,
        "shipping": 0
      },
      "returnurl": "https://www.google.com/",
      // "extra": "GE60TB7226145063300008",
      "userIpAddress": "127.0.0.1",
      "expirationMinutes": "10",
      "methods": [5],
      "installmentProducts": [
        {"Name": "Subscription", "Price": 10, "Quantity": 1},
      ],
      "callbackUrl": "https://www.google.com/",
      "preAuth": false,
      "language": "EN",
      "merchantPaymentId": "P123123",
      "saveCard": false,
      "saveCardToDate": "0924"
    };

    final response = await http.post(Uri.parse(url),
        headers: headers, body: jsonEncode(data));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData;
    } else {
      throw Exception('Payment request failed: ${response.statusCode}');
    }
  }

  void processPayment() async {
    final String accessToken1 = await getToken(apiKey, clientId, clientSecret);
    final String accessToken = widget.userDataModel.data!.token;
    final Map<String, dynamic> paymentResponse =
        await payment(apiKey, accessToken1);
    // print(accessToken);
    final String secondUrl = paymentResponse['links'][1]['uri'];
    final String tbcBankLink = secondUrl;
    // print(paymentResponse);
    // ignore: use_build_context_synchronously
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Container(
          color: Colors.white,
          child: SafeArea(
            child: WebView(
              initialUrl: tbcBankLink,
              javascriptMode: JavascriptMode.unrestricted,
              onPageStarted: (url) {},
              onPageFinished: (val) async {
                if (val == "https://www.google.com/") {
                  PaymentProvider paymentProvider =
                      Provider.of<PaymentProvider>(context, listen: false);
                  await paymentProvider.mCheckPaymentFunction(
                      payID: paymentResponse["payId"], token: accessToken);
                  await makeCardActive(userId, 30, accessToken);
                  const snackBar = SnackBar(
                    content: Text('Payment Successfully!'),
                    backgroundColor: Colors.green,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DashboardScreen()),
                    (route) => false,
                  );
                  // if (paymentProvider.paymentMessage == "Success") {
                  //   await makeCardActive(userId, 30, accessToken);
                  //   const snackBar = SnackBar(
                  //     content: Text('Payment Successfully!'),
                  //     backgroundColor: Colors.green,
                  //   );
                  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  //   Navigator.pushAndRemoveUntil(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => DashboardScreen()),
                  //     (route) => false,
                  //   );
                  // } else {
                  //   const snackBar = SnackBar(
                  //     content: Text('Payment UnSuccessfully!'),
                  //     backgroundColor: Colors.green,
                  //   );
                  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  //   Navigator.pushAndRemoveUntil(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => DashboardScreen()),
                  //     (route) => false,
                  //   );
                  // }
                }
              },
            ),
            // InAppWebView(
            //   initialUrlRequest: URLRequest(url: Uri.parse(tbcBankLink)),
            //   onConsoleMessage: (controller, consoleMessage) {
            //     if (consoleMessage.message=="https://google.com") {
            //       makeCardActive(userId, 30, accessToken);
            //     }
            //   },
            // ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchCardNumber(widget.userDataModel.data!.token);
  }

  Future<http.Response> postData(
      String url, Map<String, dynamic> body, String token) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: convert.jsonEncode(body),
    );
    jsonData = convert.jsonDecode(response.body);
    return response;
  }

  Future<String> fetchCardNumber(String token) async {
    final response = await http.get(
      Uri.parse('https://julius.ltd/hotcard/api/v100/user/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final cardNumber = data['data']['card_number'] ?? 'Not Available';
      daysLeft = data['data']['available_subscription_days'] ?? 'Inactive';
      userId = data['data']['id'].toString();

      return cardNumber;
    } else {
      throw Exception('Failed to load data');
    }
  }

  void updateCardCode(String newCardCode) {
    setState(() {
      cardCode1 = newCardCode;
    });
  }

  Future<void> showPopUp() async {
    TextEditingController cardCodeController = TextEditingController();
    var urlToSend =
        'https://julius.ltd/hotcard/api/v100/user/update_card_number/';

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppTags.enterCardCode.tr,
            style: const TextStyle(fontFamily: 'bpg'),
          ),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: cardCodeController,
                  decoration: const InputDecoration(
                      labelText: '000000000000',
                      labelStyle: TextStyle(fontFamily: 'bpg')),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                child: Text(AppTags.save.tr,
                    style: const TextStyle(fontFamily: 'bpg')),
                onPressed: () async {
                  String cardCode = cardCodeController.text;
                  if (cardCode.length >= 8 && cardCode.length <= 16) {
                    postData(urlToSend + userId, {"card_number": cardCode},
                        widget.userDataModel.data!.token);

                    updateCardCode(cardCode);

                    await Future.delayed(const Duration(seconds: 2));
                    Navigator.of(context).pop();
                    jsonData['data']['card_number'][0] !=
                            AppTags.alreadyLinked.tr
                        ? showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  AppTags.cardAddedSuccessfully.tr,
                                  style: const TextStyle(fontFamily: 'bpg'),
                                ),
                                content: Text(
                                    '${AppTags.card.tr}, ${AppTags.withCode.tr} $cardCode ${AppTags.addedSuccessfullyToUrAccount.tr}',
                                    style: const TextStyle(fontFamily: 'bpg')),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text("OK",
                                        style: TextStyle(fontFamily: 'bpg')),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          )
                        : showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(AppTags.error.tr,
                                    style: const TextStyle(fontFamily: 'bpg')),
                                content: Text(
                                    AppTags.alreadyUsedByAnotherUser.tr,
                                    style: const TextStyle(fontFamily: 'bpg')),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text("OK",
                                        style: TextStyle(fontFamily: 'bpg')),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(AppTags.error.tr,
                              style: const TextStyle(fontFamily: 'bpg')),
                          content: Text(AppTags.consistMin8Max16.tr,
                              style: const TextStyle(fontFamily: 'bpg')),
                          actions: <Widget>[
                            TextButton(
                              child: const Text("OK",
                                  style: TextStyle(fontFamily: 'bpg')),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                }),
            TextButton(
              child: Text(AppTags.cancellation.tr,
                  style: const TextStyle(fontFamily: 'bpg')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    cardCode1 =
        _profileContentController.profileDataModel.value.data!.cardNumber;

    return Scaffold(
      appBar: isMobile(context)
          ? AppBar(
              backgroundColor: AppThemeData.myRewardAppBarColor,
              elevation: 0,
              iconTheme: const IconThemeData(
                color: Colors.black, //change your color here
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 22.r,
                ),
                onPressed: () {
                  Get.back();
                },
              ),
            )
          : AppBar(
              backgroundColor: AppThemeData.myRewardAppBarColor,
              elevation: 0,
              toolbarHeight: 60.h,
              leadingWidth: 40.w,
              iconTheme: const IconThemeData(
                color: Colors.black, //change your color here
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 22.r,
                ),
                onPressed: () {
                  Get.back();
                },
              ),
            ),
      body: FutureBuilder<String>(
        future: fetchCardNumber(widget.userDataModel.data!.token),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Obx(
              () => myWalletController.myWalletModel.value.data != null
                  ? Container(
                      height: size.height,
                      width: size.width,
                      color: Colors.white,
                      child: ListView(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                height: isMobile(context) ? 200.h : 220.h,
                                width: MediaQuery.of(context).size.width,
                                color: AppThemeData.myRewardAppBarColor,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 8.0.h, horizontal: 10.w),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      //SizedBox(height: 5,),
                                      Container(
                                        width: isMobile(context) ? 74.w : 50.w,
                                        height: 74.h,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 0.w,
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor),
                                          boxShadow: [
                                            BoxShadow(
                                                spreadRadius: 2.r,
                                                blurRadius: 10.r,
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                offset: const Offset(0, 5))
                                          ],
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                              widget.userDataModel.data!.image!
                                                  .toString(),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      Text(
                                          "${widget.userDataModel.data!.firstName!.toString()} ${widget.userDataModel.data!.lastName!.toString()}",
                                          style: isMobile(context)
                                              ? AppThemeData.titleTextStyle_14
                                                  .copyWith(fontFamily: 'bpg')
                                              : AppThemeData
                                                  .titleTextStyle_11Tab
                                                  .copyWith(fontFamily: 'bpg')),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                  bottom: snapshot.data != 'Not Available'
                                      ? -130.h
                                      : -90.h,
                                  left: 20.w,
                                  child: SizedBox(
                                    width: size.width - 40,
                                    child: Column(
                                      children: [
                                        snapshot.data != 'Not Available'
                                            ? Container(
                                                transform:
                                                    Matrix4.translationValues(
                                                        0.0, -20.0, 0.0),
                                                alignment:
                                                    Alignment.bottomCenter,
                                                decoration: BoxDecoration(
                                                  color: const Color.fromARGB(
                                                      255, 43, 43, 43),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(15)),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppThemeData
                                                          .headlineTextColor
                                                          .withOpacity(0.1),
                                                      spreadRadius: 0.r,
                                                      blurRadius: 30.r,
                                                      offset: const Offset(0,
                                                          15), // changes position of shadow
                                                    ),
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(20.r),
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        height: widget
                                                                    .userDataModel
                                                                    .data!
                                                                    .phone ==
                                                                ""
                                                            ? 0.h
                                                            : 00.h,
                                                      ),
                                                      Row(
                                                        children: [
                                                          const Spacer(),
                                                          Text(
                                                            _profileContentController
                                                                        .profileDataModel
                                                                        .value
                                                                        .data!
                                                                        .cardStatus !=
                                                                    'Inactive'
                                                                ? "${AppTags.active.tr} $daysLeft ${AppTags.day.tr}"
                                                                : AppTags
                                                                    .nonActive
                                                                    .tr,
                                                            style: isMobile(
                                                                    context)
                                                                ? TextStyle(
                                                                    color: const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        255),
                                                                    fontFamily:
                                                                        "bpg",
                                                                    fontSize:
                                                                        14.sp,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .clip,
                                                                  )
                                                                : AppThemeData
                                                                    .titleTextStyle_11Tab
                                                                    .copyWith(
                                                                        fontFamily:
                                                                            'bpg'),
                                                          ),
                                                          const SizedBox(
                                                            width: 15,
                                                          )
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 60.h,
                                                      ),
                                                      widget.userDataModel.data!
                                                                  .email ==
                                                              ""
                                                          ? const SizedBox()
                                                          : Row(
                                                              children: [
                                                                SizedBox(
                                                                  width: 20.w,
                                                                ),
                                                                Text(
                                                                  snapshot.data
                                                                      .toString(),
                                                                  style: isMobile(
                                                                          context)
                                                                      ? TextStyle(
                                                                          color: const Color
                                                                              .fromARGB(
                                                                              255,
                                                                              255,
                                                                              255,
                                                                              255),
                                                                          fontFamily:
                                                                              "bpg",
                                                                          fontSize:
                                                                              18.sp,
                                                                          overflow:
                                                                              TextOverflow.clip,
                                                                        )
                                                                      : AppThemeData
                                                                          .titleTextStyle_11Tab
                                                                          .copyWith(
                                                                              fontFamily: 'bpg'),
                                                                ),
                                                              ],
                                                            ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : SizedBox(
                                                child: Center(
                                                  child: Text(
                                                      AppTags.noCardIsAdded.tr,
                                                      style: const TextStyle(
                                                          fontFamily: 'bpg')),
                                                ),
                                              ),
                                        SizedBox(
                                          height: 20.h,
                                        ),
                                      ],
                                    ),
                                  ))
                            ],
                          ),
                          const SizedBox(
                            height: 120,
                          ),
                          Row(
                            children: [
                              const Spacer(),
                              if (snapshot.data != 'Not Available')
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                              _profileContentController
                                                          .profileDataModel
                                                          .value
                                                          .data!
                                                          .cardStatus !=
                                                      'Inactive'
                                                  ? AppTags.cardUpgrade.tr
                                                  : AppTags.activeCard.tr,
                                              // ak kide erti dasturi unda ro recurrent gadaxdaze tanaxmaa
                                              style: const TextStyle(
                                                  fontFamily: 'bpg')),
                                          content: Text(AppTags.costsAndDate.tr,
                                              style: const TextStyle(
                                                  fontFamily: 'bpg')),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text(AppTags.yes.tr,
                                                  style: const TextStyle(
                                                      fontFamily: 'bpg')),
                                              onPressed: () async {
                                                // final String accessToken =
                                                //     await getToken(apiKey,
                                                //         clientId, clientSecret);
                                                // print(widget.userDataModel.data!.token);
                                                // print(userId);
                                                processPayment();
                                                // makeCardActive(
                                                //     userId, 30, accessToken);
                                                // Perform your "yes" action here
                                              },
                                            ),
                                            TextButton(
                                              child: Text(AppTags.no.tr,
                                                  style: const TextStyle(
                                                      fontFamily: 'bpg')),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                // Perform your "no" action here
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 120,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 15, 153, 61),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppThemeData.headlineTextColor
                                              .withOpacity(0.1),
                                          spreadRadius: 0.r,
                                          blurRadius: 30.r,
                                          offset: const Offset(0,
                                              15), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 25,
                                        ),
                                        const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                            _profileContentController
                                                        .profileDataModel
                                                        .value
                                                        .data!
                                                        .cardStatus !=
                                                    AppTags.nonActive.tr
                                                ? AppTags.upgrade.tr
                                                : AppTags.activate.tr,
                                            style: const TextStyle(
                                                fontFamily: 'bpg',
                                                color: Colors.white)),
                                        const SizedBox(
                                          height: 25,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                InkWell(
                                  onTap: () async {
                                    await showPopUp();
                                    setState(() {
                                      cardCode1 = snapshot.data;
                                    });
                                  },
                                  child: Container(
                                    width: 120,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 15, 153, 61),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(15)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppThemeData.headlineTextColor
                                              .withOpacity(0.1),
                                          spreadRadius: 0.r,
                                          blurRadius: 30.r,
                                          offset: const Offset(0,
                                              15), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 25,
                                        ),
                                        const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(AppTags.add.tr,
                                            style: const TextStyle(
                                                fontFamily: 'bpg',
                                                color: Colors.white)),
                                        const SizedBox(
                                          height: 25,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              snapshot.data != 'Not Available' &&
                                      _profileContentController.profileDataModel
                                              .value.data!.cardStatus !=
                                          'Inactive'
                                  ? const Spacer()
                                  : const SizedBox(),
                              snapshot.data != 'Not Available' &&
                                      _profileContentController.profileDataModel
                                              .value.data!.cardStatus !=
                                          'Inactive'
                                  ? InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text(
                                                AppTags.cardCencellation.tr,
                                                style: const TextStyle(
                                                    fontFamily: 'bpg'),
                                              ),
                                              content: Text(
                                                  AppTags
                                                      .cardCencellationCosts.tr,
                                                  style: const TextStyle(
                                                      fontFamily: 'bpg')),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text(AppTags.yes.tr,
                                                      style: const TextStyle(
                                                          fontFamily: 'bpg')),
                                                  onPressed: () {
                                                    processPayment();
                                                    // Perform your "yes" action here
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text(AppTags.no.tr,
                                                      style: const TextStyle(
                                                          fontFamily: 'bpg')),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    // Perform your "no" action here
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        width: 120,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 153, 15, 15),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(15)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppThemeData
                                                  .headlineTextColor
                                                  .withOpacity(0.1),
                                              spreadRadius: 0.r,
                                              blurRadius: 30.r,
                                              offset: const Offset(0,
                                                  15), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            const SizedBox(
                                              height: 25,
                                            ),
                                            const Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                              size: 35,
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(AppTags.cancellation.tr,
                                                style: const TextStyle(
                                                    fontFamily: 'bpg',
                                                    color: Colors.white)),
                                            const SizedBox(
                                              height: 25,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                              const Spacer(),
                            ],
                          ),
                          SizedBox(
                            height: 25.h,
                          ),
                        ],
                      ),
                    )
                  : const LoaderWidget(),
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text(AppTags.sorryForinconvenience.tr,
                    style: const TextStyle(fontFamily: 'bpg')));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
