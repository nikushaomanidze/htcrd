// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names, use_build_context_synchronously, duplicate_ignore

import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hot_card/src/screen/dashboard/dashboard_screen.dart';
import 'package:hot_card/src/servers/network_service.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
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

  GlobalKey<_MyWalletScreenState> key = GlobalKey();

  void refreshPage() {
    setState(() {});
  }


  final ProfileContentController _profileContentController =
      Get.put(ProfileContentController());

  final TextEditingController amountController = TextEditingController();

  TextEditingController inputController = TextEditingController();

  var cardCode1;
  var momwveviUserId;
  var ammount;
  var jsonData;
  var daysLeft;
  int intDaysLeft = 0;
  var DeviceInfo;
  late String userId;

  final String apiKey = '2UwIqaRBAfEQ8y1Po8bn9y8n7ABMFWJR';
  final String clientId = '7001220';
  final String clientSecret = 'OL5p8EsGnIM7hHF7';

  Object? get momwvevi_useris_id => null;

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

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var DeviceInfo = await deviceInfo.iosInfo;
      if (kDebugMode) {
        print('iosDeviceInfo ${DeviceInfo.identifierForVendor}');
      }
      return DeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var DeviceInfo = await deviceInfo.androidInfo;
      if (kDebugMode) {
        print('androidDeviceInfo ${DeviceInfo.id}');
      }
      return DeviceInfo.id;
    } else {
      return null;
    }
  }

  Future<void> setUserDeviceId(
      String userIdd, String token, String deviceId) async {
    final url = Uri.parse(
        '${NetworkService.apiUrl}/user/update_user_device_id/$userIdd');

    try {
      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final Map<String, dynamic> data = {
        'user_device_id': deviceId,
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // Successfully made the card active
        if (kDebugMode) {
          print('user_device_id set successfully.');
        }
      } else {
        // Handle the case where the request was not successful
        if (kDebugMode) {
          print(
              'Failed to set the user_device_id. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      // Handle any exceptions that might occur during the request
      if (kDebugMode) {
        print('An error occurred: $e');
      }
    }
  }

  //es funkcia iuzeris barats aaktiurebs
  Future<void> makeCardActive(String userId, String totalDays, String token,
      String recId, String reff_code) async {
    final url =
    Uri.parse('${NetworkService.apiUrl}/user/make_card_active/$userId');

    try {
      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final Map<String, dynamic> data = {
        'total_days': totalDays,
        'recId': recId,
        'referral_code': reff_code
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // Successfully made the card active
        if (kDebugMode) {
          print('Card activated successfully.');
        }
      } else {
        // Handle the case where the request was not successful
        if (kDebugMode) {
          print(
              'Failed to make the card active. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      // Handle any exceptions that might occur during the request
      if (kDebugMode) {
        print('An error occurred: $e');
      }
    }
  }

  Future<Map<String, dynamic>> payment(
      String apiKey, String token, double amount) async {
    const url = 'https://api.tbcbank.ge/v1/tpay/payments';
    final headers = {
      'Content-Type': 'application/json',
      'apikey': apiKey,
      'Authorization': 'Bearer $token',
    };
    final data = {
      "amount": {
        "currency": "GEL",
        "total": amount,
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
        {"Name": "Subscription", "Price": amount, "Quantity": 1},
      ],
      "callbackUrl": "https://hotcard.online/api/callback",
      "preAuth": false,
      "language": "EN",
      "merchantPaymentId": "P123123",
      "saveCard": true,
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
    dynamic validationResponse = await validateReferralCode(inputController.text);
    bool paymentProcessed = false;

    double paymentAmount = 28.0; // Default payment amount. it is 0.1 because of debugging, this will later change to 28

// Check the validation response
    if (validationResponse is Map<String, dynamic> &&
        validationResponse['exists'] == true) {
      // Referral code is valid, set the payment amount to 15
      paymentAmount = 15.0;
    }

    final Map<String, dynamic> paymentResponse = await payment(
      apiKey,
      accessToken1,
      paymentAmount,
    );
 //   inputController.text.isNotEmpty && inputController.text.length >= 7 ? 15 : 28
    final String secondUrl = paymentResponse['links'][1]['uri'];
    final String rec_Id = paymentResponse['recId'];
    final String tbcBankLink = secondUrl;
     print(paymentResponse);
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
              debuggingEnabled: true,
              onPageStarted: (url) {    print('WebView page started: $url');
              },
              onPageFinished: (val) async {
                print('WebView page finished: $val');

                try {
                  // Check if payment has already been processed
                  if (!paymentProcessed && val.contains("status=true")) {
                    paymentProcessed = true; // Set the flag to true to prevent multiple executions

                    print('Payment successful');

                    // Perform actions directly without calling mCheckPaymentFunction
                  /*  const snackBar = SnackBar(
                      content: Text('Payment Successful!'),
                      backgroundColor: Colors.green,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);*/

                    final recId = rec_Id;
                    makeCardActive(userId, '30', accessToken, recId, inputController.text);

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                          (route) => false,
                    );

                    showDialog(
                      barrierDismissible: true,
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Lottie.asset(
                                'assets/lottie/done.json', // Replace with the path to your Lottie file
                                width: 100, // Adjust the width as needed
                                height: 100, // Adjust the height as needed
                                repeat: false,
                                reverse: false,
                              ),
                              SizedBox(height: 10),
                              Center(
                                child: Text(
                                  'გადახდა წარმატებულია',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                    HapticFeedback.mediumImpact();

                    updateUserReferral(userId, inputController.text);



                  }
                } catch (error) {
                  print('Error during payment processing: $error');
                }
              },

            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> validateReferralCode(String referralCode) async {
    try {
      final response = await http.post(
        Uri.parse('https://hotcard.online/api/check-referral-code'),
        body: {'referral_code': referralCode},
      );

      print('Server Response: ${response.body}');

      if (response.statusCode == 200) {
        // Parse the response JSON
        final Map<String, dynamic> responseBody = json.decode(response.body);

        // Log the response for debugging
        print('Validation Response: $responseBody');

        return responseBody;
      } else {
        print('Error validating referral code - StatusCode: ${response.statusCode}, Body: ${response.body}');
        return {'exists': false}; // or return an error indicator
      }
    } catch (e) {
      print('Error validating referral code: $e');
      return {'exists': false}; // or return an error indicator
    }
  }

  Future<void> updateUserReferral(String userId, String referralCode) async {
    try {
      final response = await http.post(
        Uri.parse('https://hotcard.online/api/update-referral?user_id=$userId&referral_code=$referralCode'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Successful update
        print('Referral code updated successfully');
      } else {
        // Handle error based on response status code or body
        print('Error updating referral code - StatusCode: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      // Handle any unexpected errors during the request
      print('Error updating referral code: $e');
    }
  }


  bool _isValid = false;

  Future<void> showValidationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Text('Enter Referral Code'),
          content: TextField(
            controller: inputController,
            decoration: InputDecoration(
              hintText: 'Enter referral code',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Validate the referral code
                bool isValid = await validateReferralCode(
                    inputController.text);

                // Update the state to reflect the validation result
                setState(() {
                  _isValid = isValid;
                });

                Navigator.of(context).pop();
                // Show the validation result
                showResultDialog();
              },
              child: Text('Validate'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showResultDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Validation Result'),
          content: Text(
            _isValid ? 'Valid Referral Code' : 'Not Valid Referral Code',
            style: TextStyle(
              color: _isValid ? Colors.green : Colors.red,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showErrorDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Text('Error'),
          content: Text('Invalid Referral Code. Please try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Color.fromARGB(255, 239, 127, 26)),),
            ),
          ],
        );
      },
    );
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
      Uri.parse('${NetworkService.apiUrl}/user/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final cardNumber = data['data']['card_number'] ?? 'Not Available';
      daysLeft = data['data']['available_subscription_days'] ?? 'Inactive';
      userId = data['data']['id'].toString();

      intDaysLeft = int.parse(daysLeft.toString());

      intDaysLeft <= 0 ? daysLeft == 'Inactive' : daysLeft == daysLeft;

      return cardNumber;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<int?> fetchMomwveviUserID(String? token) async {
    final response = await http.get(
      Uri.parse('${NetworkService.apiUrl}/user/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final momwvevi_useris_id = data['data']['momwvevi_useris_id'];

      // print('momwvevi useris id : ' + momwvevi_useris_id.toString());
      return momwvevi_useris_id;
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCardNumber(widget.userDataModel.data!.token);
    _getId();
    //
  }

  void updateCardCode(String newCardCode) {
    setState(() {
      cardCode1 = newCardCode;
    });
  }

  Future<void> showPopUp() async {
    TextEditingController cardCodeController = TextEditingController();

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
                  var urlToSend =
                      '${NetworkService.apiUrl}/user/update_card_number/';
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
              leading: Get.previousRoute == 'dashboardScreen'
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 22.r,
                      ),
                      onPressed: () {
                        Get.back();
                      },
                    )
                  : null,
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
                                                                        'Inactive' &&
                                                                    daysLeft > 0
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
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                    //    showValidationDialog();
                                        fetchMomwveviUserID(
                                                widget.userDataModel.data!.token)
                                            .then((value) {
                                          setState(() async {
                                            var momwveviUserId = value;
                                            var phoneId;
                                            var deviceInfo = DeviceInfoPlugin();
                                            if (Platform.isAndroid) {
                                              var meore =
                                                  await deviceInfo.androidInfo;
                                              phoneId = meore.id;
                                            } else {
                                              var meore = await deviceInfo.iosInfo;
                                              phoneId = meore.identifierForVendor;
                                            }
                                            setUserDeviceId(
                                                userId,
                                                widget.userDataModel.data!.token,
                                                phoneId);

                                        /*    inputController.text.length >= 7 &&
                                                    inputController.text.length <=
                                                        12
                                                ? ammount = 15
                                                : ammount = 28;*/

                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                                  title: Text(
                                                    _profileContentController.profileDataModel.value.data!.cardStatus != 'Inactive'
                                                        ? AppTags.cardUpgrade.tr
                                                        : '',
                                                 //   AppTags.activeCard.tr,
                                                  ),
                                                  content: SizedBox(
                                                    height: 110,
                                                    child: Column(
                                                      children: [
                                                        if (momwveviUserId == 0 || momwveviUserId == null)
                                                          TextField(
                                                            controller: inputController,
                                                            decoration:  InputDecoration(
                                                              enabledBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(20.0),
                                                                borderSide: BorderSide(color: Color.fromARGB(255, 239, 127, 26))
                                                              ),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(20.0),
                                                                borderSide:  BorderSide(color: Color.fromARGB(255, 239, 127, 26)),
                                                              ),
                                                              hintText: "რეფერალური კოდი", hintStyle: TextStyle(fontSize: 13),
                                                            ),
                                                          ),
                                                        SizedBox(height: 15,),
                                                        Text('(გამოწერის ღირებულება ავტომატურად ჩამოგეჭრებათ ყოველთვე)',style: TextStyle(fontSize: 13, color: Colors.grey),),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: Text(
                                                        AppTags.yes.tr,
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontFamily: 'bpg',
                                                          color: Colors.deepOrange.shade400,
                                                        ),
                                                      ),
                                                        onPressed: () async {
                                                          try {
                                                            if (momwveviUserId != 0 && momwveviUserId != null) {
                                                              // Handle case where momwveviUserId is not zero or null
                                                              // For example:
                                                              // showErrorMessage('MomwveviUserId is not allowed in this context.');
                                                              return;
                                                            }

                                                            // Validate the referral code
                                                            dynamic validationResponse = await validateReferralCode(inputController.text);

                                                            // Check if the referral code is valid
                                                            if (validationResponse is Map<String, dynamic> && validationResponse['exists'] == true) {
                                                              // Referral code is valid, continue with the payment process
                                                              processPayment();
                                                            } else {
                                                              // Referral code is not valid, show an error message
                                                              showErrorDialog();
                                                            }
                                                          } catch (e) {
                                                            // Handle any unexpected errors during the validation process
                                                            print('Error during validation: $e');
                                                            // Show a generic error message to the user if needed
                                                            // showErrorMessage('An unexpected error occurred.');
                                                          }
                                                        }


                                                    ),
                                                    TextButton(
                                                      child: Text(
                                                        AppTags.no.tr,
                                                        style: TextStyle(
                                                          fontFamily: 'bpg',
                                                          color: Colors.deepOrange.shade400,
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                        // Perform your "no" action here
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          });
                                        }).catchError((error) {
                                          // Handle error
                                          if (kDebugMode) {
                                            print(
                                                'Error fetching momwvevi_useris_id: $error');
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: 120,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          color:  Colors.deepOrange.shade400,
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
                                              height: 3,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: SizedBox(
                                                  width: double
                                                      .infinity, // Ensure the container takes the full width
                                                  child: Text(
                                                    'ბარათის გააქტიურება რეფერალური კოდით',
                                                    style: const TextStyle(
                                                      fontFamily: 'bpg',
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                    ),
                                                    maxLines: 4,
                                                    softWrap: true,
                                                    textAlign: TextAlign
                                                        .center, // Center the text
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 13,),
                                   // const Spacer(),
                                    InkWell(
                                      onTap: () {
                                        fetchMomwveviUserID(
                                            widget.userDataModel.data!.token)
                                            .then((value) {
                                          setState(() async {
                                            var momwveviUserId = value;
                                            var phoneId;
                                            var deviceInfo = DeviceInfoPlugin();
                                            if (Platform.isAndroid) {
                                              var meore =
                                              await deviceInfo.androidInfo;
                                              phoneId = meore.id;
                                            } else {
                                              var meore = await deviceInfo.iosInfo;
                                              phoneId = meore.identifierForVendor;
                                            }
                                            setUserDeviceId(
                                                userId,
                                                widget.userDataModel.data!.token,
                                                phoneId);

                                            inputController.text.length >= 7 &&
                                                inputController.text.length <=
                                                    12
                                                ? ammount = 15
                                                : ammount = 28;

                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
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
                                                  ),
                                                  content: SizedBox(
                                                    height: 80,
                                                    child: Column(
                                                      children: [
                                                        Text('(გამოწერის ღირებულება ავტომატურად ჩამოგეჭრებათ ყოველთვე)',style: TextStyle(fontSize: 13, color: Colors.grey),),
                                                        momwveviUserId != 0 &&
                                                            momwveviUserId !=
                                                                null
                                                            ? Container()
                                                            :
                                                        momwveviUserId != 0 &&
                                                            momwveviUserId !=
                                                                null
                                                            ? Text(AppTags
                                                            .costsAndDate.tr)
                                                            : Text(
                                                              "Referral Code (თუ გაქვთ)",
                                                          style: TextStyle(color: Colors.transparent),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: Text(AppTags.yes.tr,
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.w600,
                                                               color: Colors.deepOrange.shade400)),
                                                      onPressed: () async {
                                                     //    final String accessToken =
                                                      //       await getToken(apiKey,
                                                      //           clientId, clientSecret);
                                                      //   print(widget.userDataModel.data!.token);
                                                      //   print(userId);

                                                        processPayment();
                                                      },
                                                    ),
                                                    TextButton(
                                                      child: Text(AppTags.no.tr,
                                                          style: TextStyle(
                                                               color: Colors.deepOrange.shade400)),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                        // Perform your "no" action here
                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          });
                                        }).catchError((error) {
                                          // Handle error
                                          if (kDebugMode) {
                                            print(
                                                'Error fetching momwvevi_useris_id: $error');
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: 120,
                                        height: 140,
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
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: SizedBox(
                                                  width: double
                                                      .infinity, // Ensure the container takes the full width
                                                  child: Text(
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
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                    maxLines: 2,
                                                    softWrap: true,
                                                    textAlign: TextAlign
                                                        .center, // Center the text
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 25,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              else
                                InkWell(
                                  onTap: () async {
                                    key.currentState?.refreshPage();
                                    var urlToSend =
                                        '${NetworkService.apiUrl}/user/update_card_number/';
                                    final random = Random();
                                    const digits = '0123456789';
                                    const length = 14;
                                    String randomNumber = '';
                                    for (int i = 0; i < length; i++) {
                                      randomNumber +=
                                          digits[random.nextInt(digits.length)];
                                    }
                                    postData(
                                        urlToSend + userId,
                                        {"card_number": randomNumber},
                                        widget.userDataModel.data!.token);

                                    updateCardCode(randomNumber);
                                    setState(() {
                                      cardCode1 = snapshot.data;
                                    });


                                 //   Navigator.of(context).maybePop();
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
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                              title: Text(
                                                AppTags.cardCencellation.tr,

                                              ),
                                              content: Text(
                                                  AppTags
                                                      .cardCencellationCosts.tr,
                                                  ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text(AppTags.yes.tr, style: TextStyle(color: Colors.orange,fontWeight: FontWeight.w600),),
                                                  onPressed: () {
                                                    makeCardActive(
                                                        userId,
                                                        '0',
                                                        widget.userDataModel
                                                            .data!.token,
                                                        '0',
                                                        inputController.text);
                                                    Navigator.of(context).pop();
                                                    // Perform your "yes" action here
                                                  },
                                                ),
                                                TextButton(
                                                  child: Text(AppTags.no.tr, style: TextStyle(color: Colors.orange)),
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
                                        height: 140,
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
                                              Icons.remove,
                                              color: Colors.white,
                                              size: 35,
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Align(
                                              alignment: Alignment.center,
                                              child: SizedBox(
                                                width: double
                                                    .infinity, // Ensure the container takes the full width
                                                child: Text(
                                                  AppTags.cancellation.tr,
                                                  style: const TextStyle(
                                                    fontFamily: 'bpg',
                                                    color: Colors.white,
                                                  ),
                                                  textAlign: TextAlign
                                                      .center, // Center the text
                                                ),
                                              ),
                                            ),
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
            return FutureBuilder<String>(
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            //SizedBox(height: 5,),
                                            Container(
                                              width: isMobile(context)
                                                  ? 74.w
                                                  : 50.w,
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
                                                      offset:
                                                          const Offset(0, 5))
                                                ],
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(
                                                    widget.userDataModel.data!
                                                        .image!
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
                                                    ? AppThemeData
                                                        .titleTextStyle_14
                                                        .copyWith(
                                                            fontFamily: 'bpg')
                                                    : AppThemeData
                                                        .titleTextStyle_11Tab
                                                        .copyWith(
                                                            fontFamily: 'bpg')),
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
                                                      transform: Matrix4
                                                          .translationValues(
                                                              0.0, -20.0, 0.0),
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      decoration: BoxDecoration(
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 43, 43, 43),
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                                Radius.circular(
                                                                    15)),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: AppThemeData
                                                                .headlineTextColor
                                                                .withOpacity(
                                                                    0.1),
                                                            spreadRadius: 0.r,
                                                            blurRadius: 30.r,
                                                            offset: const Offset(
                                                                0,
                                                                15), // changes position of shadow
                                                          ),
                                                        ],
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            20.r),
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
                                                                  _profileContentController.profileDataModel.value.data!.cardStatus !=
                                                                              'Inactive' &&
                                                                          daysLeft >
                                                                              0
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
                                                                              TextOverflow.clip,
                                                                        )
                                                                      : AppThemeData
                                                                          .titleTextStyle_11Tab
                                                                          .copyWith(
                                                                              fontFamily: 'bpg'),
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
                                                                        width:
                                                                            20.w,
                                                                      ),
                                                                      Text(
                                                                        snapshot
                                                                            .data
                                                                            .toString(),
                                                                        style: isMobile(context)
                                                                            ? TextStyle(
                                                                                color: const Color.fromARGB(255, 255, 255, 255),
                                                                                fontFamily: "bpg",
                                                                                fontSize: 18.sp,
                                                                                overflow: TextOverflow.clip,
                                                                              )
                                                                            : AppThemeData.titleTextStyle_11Tab.copyWith(fontFamily: 'bpg'),
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
                                                            AppTags
                                                                .noCardIsAdded
                                                                .tr,
                                                            style:
                                                                const TextStyle(
                                                                    fontFamily:
                                                                        'bpg')),
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
                                          fetchMomwveviUserID(widget
                                                  .userDataModel.data!.token)
                                              .then((value) {
                                            setState(() async {
                                              var momwveviUserId = value;
                                              var phoneId;
                                              var deviceInfo =
                                                  DeviceInfoPlugin();
                                              if (Platform.isAndroid) {
                                                var meore = await deviceInfo
                                                    .androidInfo;
                                                phoneId = meore.id;
                                              } else {
                                                var meore =
                                                    await deviceInfo.iosInfo;
                                                phoneId =
                                                    meore.identifierForVendor;
                                              }
                                              setUserDeviceId(
                                                  userId,
                                                  widget.userDataModel.data!
                                                      .token,
                                                  phoneId);

                                              inputController.text.length >=
                                                          7 &&
                                                      inputController
                                                              .text.length <=
                                                          12
                                                  ? ammount = 15
                                                  : ammount = 28;

                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                        _profileContentController
                                                                    .profileDataModel
                                                                    .value
                                                                    .data!
                                                                    .cardStatus !=
                                                                'Inactive'
                                                            ? AppTags
                                                                .cardUpgrade.tr
                                                            : AppTags
                                                                .activeCard.tr,
                                                        // ak kide erti dasturi unda ro recurrent gadaxdaze tanaxmaa
                                                        style: const TextStyle(
                                                            fontFamily: 'bpg')),
                                                    content: SizedBox(
                                                      height: 80,
                                                      child: Column(
                                                        children: [
                                                          momwveviUserId != 0 &&
                                                                  momwveviUserId !=
                                                                      null
                                                              ? Container()
                                                              : const Text(
                                                                  'Referral Id'),
                                                          momwveviUserId != 0 &&
                                                                  momwveviUserId !=
                                                                      null
                                                              ? Text(AppTags
                                                                  .costsAndDate
                                                                  .tr)
                                                              : TextField(
                                                                  controller:
                                                                      inputController,
                                                                  decoration:
                                                                      const InputDecoration(
                                                                          hintText:
                                                                              "Referral Code"),
                                                                ),
                                                        ],
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: Text(
                                                            AppTags.yes.tr,
                                                            style:
                                                                const TextStyle(
                                                                    fontFamily:
                                                                        'bpg')),
                                                        onPressed: () async {
                                                          // print(inputText);
                                                          // final String accessToken =
                                                          //     await getToken(apiKey,
                                                          //         clientId, clientSecret);
                                                          // print(widget.userDataModel.data!.token);
                                                          // print(userId);

                                                          processPayment();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: Text(
                                                            AppTags.no.tr,
                                                            style:
                                                                const TextStyle(
                                                                    fontFamily:
                                                                        'bpg')),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                          // Perform your "no" action here
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            });
                                          }).catchError((error) {
                                            // Handle error
                                            if (kDebugMode) {
                                              print(
                                                  'Error fetching momwvevi_useris_id: $error');
                                            }
                                          });
                                        },
                                        child: Container(
                                          width: 120,
                                          height: 140,
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 15, 153, 61),
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
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: SizedBox(
                                                    width: double
                                                        .infinity, // Ensure the container takes the full width
                                                    child: Text(
                                                      _profileContentController
                                                                  .profileDataModel
                                                                  .value
                                                                  .data!
                                                                  .cardStatus !=
                                                              AppTags
                                                                  .nonActive.tr
                                                          ? AppTags.upgrade.tr
                                                          : AppTags.activate.tr,
                                                      style: const TextStyle(
                                                        fontFamily: 'bpg',
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                      ),
                                                      maxLines: 2,
                                                      softWrap: true,
                                                      textAlign: TextAlign
                                                          .center, // Center the text
                                                    ),
                                                  ),
                                                ),
                                              ),
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
                                          key.currentState?.refreshPage();
                                          var urlToSend =
                                              '${NetworkService.apiUrl}/user/update_card_number/';
                                          final random = Random();
                                          const digits = '0123456789';
                                          const length = 14;
                                          String randomNumber = '';
                                          for (int i = 0; i < length; i++) {
                                            randomNumber += digits[
                                                random.nextInt(digits.length)];
                                          }
                                          postData(
                                              urlToSend + userId,
                                              {"card_number": randomNumber},
                                              widget.userDataModel.data!.token);

                                          updateCardCode(randomNumber);
                                          setState(() {
                                            cardCode1 = snapshot.data;
                                          });
                                     //     Navigator.of(context).maybePop();
                                        },
                                        child: Container(
                                          width: 120,
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 15, 153, 61),
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
                                            _profileContentController
                                                    .profileDataModel
                                                    .value
                                                    .data!
                                                    .cardStatus !=
                                                'Inactive'
                                        ? const Spacer()
                                        : const SizedBox(),
                                    snapshot.data != 'Not Available' &&
                                            _profileContentController
                                                    .profileDataModel
                                                    .value
                                                    .data!
                                                    .cardStatus !=
                                                'Inactive'
                                        ? InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text(
                                                      AppTags
                                                          .cardCencellation.tr,
                                                      style: const TextStyle(
                                                          fontFamily: 'bpg'),
                                                    ),
                                                    content: Text(
                                                        AppTags
                                                            .cardCencellationCosts
                                                            .tr,
                                                        style: const TextStyle(
                                                            fontFamily: 'bpg')),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: Text(
                                                            AppTags.yes.tr,
                                                            style:
                                                                const TextStyle(
                                                                    fontFamily:
                                                                        'bpg')),
                                                        onPressed: () {
                                                          makeCardActive(
                                                              userId,
                                                              '0',
                                                              widget
                                                                  .userDataModel
                                                                  .data!
                                                                  .token,
                                                              '0',
                                                              inputController
                                                                  .text);
                                                          Navigator.of(context)
                                                              .pop();
                                                          // Perform your "yes" action here
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: Text(
                                                            AppTags.no.tr,
                                                            style:
                                                                const TextStyle(
                                                                    fontFamily:
                                                                        'bpg')),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
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
                                              height: 140,
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    255, 153, 15, 15),
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
                                              child: Column(
                                                children: [
                                                  const SizedBox(
                                                    height: 25,
                                                  ),
                                                  const Icon(
                                                    Icons.remove,
                                                    color: Colors.white,
                                                    size: 35,
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child: SizedBox(
                                                      width: double
                                                          .infinity, // Ensure the container takes the full width
                                                      child: Text(
                                                        AppTags.cancellation.tr,
                                                        style: const TextStyle(
                                                          fontFamily: 'bpg',
                                                          color: Colors.white,
                                                        ),
                                                        textAlign: TextAlign
                                                            .center, // Center the text
                                                      ),
                                                    ),
                                                  ),
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
                  return FutureBuilder<String>(
                    future: fetchCardNumber(widget.userDataModel.data!.token),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Obx(
                          () => myWalletController.myWalletModel.value.data !=
                                  null
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
                                            height: isMobile(context)
                                                ? 200.h
                                                : 220.h,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            color: AppThemeData
                                                .myRewardAppBarColor,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8.0.h,
                                                  horizontal: 10.w),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  //SizedBox(height: 5,),
                                                  Container(
                                                    width: isMobile(context)
                                                        ? 74.w
                                                        : 50.w,
                                                    height: 74.h,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          width: 0.w,
                                                          color: Theme.of(
                                                                  context)
                                                              .scaffoldBackgroundColor),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            spreadRadius: 2.r,
                                                            blurRadius: 10.r,
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.1),
                                                            offset:
                                                                const Offset(
                                                                    0, 5))
                                                      ],
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: NetworkImage(
                                                          widget.userDataModel
                                                              .data!.image!
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
                                                          ? AppThemeData
                                                              .titleTextStyle_14
                                                              .copyWith(
                                                                  fontFamily:
                                                                      'bpg')
                                                          : AppThemeData
                                                              .titleTextStyle_11Tab
                                                              .copyWith(
                                                                  fontFamily:
                                                                      'bpg')),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                              bottom: snapshot.data !=
                                                      'Not Available'
                                                  ? -130.h
                                                  : -90.h,
                                              left: 20.w,
                                              child: SizedBox(
                                                width: size.width - 40,
                                                child: Column(
                                                  children: [
                                                    snapshot.data !=
                                                            'Not Available'
                                                        ? Container(
                                                            transform: Matrix4
                                                                .translationValues(
                                                                    0.0,
                                                                    -20.0,
                                                                    0.0),
                                                            alignment: Alignment
                                                                .bottomCenter,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  43, 43, 43),
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                      Radius.circular(
                                                                          15)),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: AppThemeData
                                                                      .headlineTextColor
                                                                      .withOpacity(
                                                                          0.1),
                                                                  spreadRadius:
                                                                      0.r,
                                                                  blurRadius:
                                                                      30.r,
                                                                  offset: const Offset(
                                                                      0,
                                                                      15), // changes position of shadow
                                                                ),
                                                              ],
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          20.r),
                                                              child: Column(
                                                                children: [
                                                                  SizedBox(
                                                                    height: widget.userDataModel.data!.phone ==
                                                                            ""
                                                                        ? 0.h
                                                                        : 00.h,
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const Spacer(),
                                                                      Text(
                                                                        _profileContentController.profileDataModel.value.data!.cardStatus != 'Inactive' &&
                                                                                daysLeft > 0
                                                                            ? "${AppTags.active.tr} $daysLeft ${AppTags.day.tr}"
                                                                            : AppTags.nonActive.tr,
                                                                        style: isMobile(context)
                                                                            ? TextStyle(
                                                                                color: const Color.fromARGB(255, 255, 255, 255),
                                                                                fontFamily: "bpg",
                                                                                fontSize: 14.sp,
                                                                                overflow: TextOverflow.clip,
                                                                              )
                                                                            : AppThemeData.titleTextStyle_11Tab.copyWith(fontFamily: 'bpg'),
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            15,
                                                                      )
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        60.h,
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
                                                                              snapshot.data.toString(),
                                                                              style: isMobile(context)
                                                                                  ? TextStyle(
                                                                                      color: const Color.fromARGB(255, 255, 255, 255),
                                                                                      fontFamily: "bpg",
                                                                                      fontSize: 18.sp,
                                                                                      overflow: TextOverflow.clip,
                                                                                    )
                                                                                  : AppThemeData.titleTextStyle_11Tab.copyWith(fontFamily: 'bpg'),
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
                                                                  AppTags
                                                                      .noCardIsAdded
                                                                      .tr,
                                                                  style: const TextStyle(
                                                                      fontFamily:
                                                                          'bpg')),
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
                                                fetchMomwveviUserID(widget
                                                        .userDataModel
                                                        .data!
                                                        .token)
                                                    .then((value) {
                                                  setState(() async {
                                                    var momwveviUserId = value;
                                                    var phoneId;
                                                    var deviceInfo =
                                                        DeviceInfoPlugin();
                                                    if (Platform.isAndroid) {
                                                      var meore =
                                                          await deviceInfo
                                                              .androidInfo;
                                                      phoneId = meore.id;
                                                    } else {
                                                      var meore =
                                                          await deviceInfo
                                                              .iosInfo;
                                                      phoneId = meore
                                                          .identifierForVendor;
                                                    }
                                                    setUserDeviceId(
                                                        userId,
                                                        widget.userDataModel
                                                            .data!.token,
                                                        phoneId);

                                                    inputController.text
                                                                    .length >=
                                                                7 &&
                                                            inputController.text
                                                                    .length <=
                                                                12
                                                        ? ammount = 15
                                                        : ammount = 28;

                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: Text(
                                                              _profileContentController
                                                                          .profileDataModel
                                                                          .value
                                                                          .data!
                                                                          .cardStatus !=
                                                                      'Inactive'
                                                                  ? AppTags
                                                                      .cardUpgrade
                                                                      .tr
                                                                  : AppTags
                                                                      .activeCard
                                                                      .tr,
                                                              // ak kide erti dasturi unda ro recurrent gadaxdaze tanaxmaa
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      'bpg')),
                                                          content: SizedBox(
                                                            height: 80,
                                                            child: Column(
                                                              children: [
                                                                momwveviUserId !=
                                                                            0 &&
                                                                        momwveviUserId !=
                                                                            null
                                                                    ? Container()
                                                                    : const Text(
                                                                        'Referral Id'),
                                                                momwveviUserId !=
                                                                            0 &&
                                                                        momwveviUserId !=
                                                                            null
                                                                    ? Text(AppTags
                                                                        .costsAndDate
                                                                        .tr)
                                                                    : TextField(
                                                                        controller:
                                                                            inputController,
                                                                        decoration:
                                                                            const InputDecoration(hintText: "Referral Code"),
                                                                      ),
                                                              ],
                                                            ),
                                                          ),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              child: Text(
                                                                  AppTags
                                                                      .yes.tr,
                                                                  style: const TextStyle(
                                                                      fontFamily:
                                                                          'bpg')),
                                                              onPressed:
                                                                  () async {
                                                                // print(inputText);
                                                                // final String accessToken =
                                                                //     await getToken(apiKey,
                                                                //         clientId, clientSecret);
                                                                // print(widget.userDataModel.data!.token);
                                                                // print(userId);

                                                                processPayment();
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: Text(
                                                                  AppTags.no.tr,
                                                                  style: const TextStyle(
                                                                      fontFamily:
                                                                          'bpg')),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                // Perform your "no" action here
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  });
                                                }).catchError((error) {
                                                  // Handle error
                                                  if (kDebugMode) {
                                                    print(
                                                        'Error fetching momwvevi_useris_id: $error');
                                                  }
                                                });
                                              },
                                              child: Container(
                                                width: 120,
                                                height: 140,
                                                decoration: BoxDecoration(
                                                  color: const Color.fromARGB(
                                                      255, 15, 153, 61),
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
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: SizedBox(
                                                          width: double
                                                              .infinity, // Ensure the container takes the full width
                                                          child: Text(
                                                            _profileContentController
                                                                        .profileDataModel
                                                                        .value
                                                                        .data!
                                                                        .cardStatus !=
                                                                    AppTags
                                                                        .nonActive
                                                                        .tr
                                                                ? AppTags
                                                                    .upgrade.tr
                                                                : AppTags
                                                                    .activate
                                                                    .tr,
                                                            style:
                                                                const TextStyle(
                                                              fontFamily: 'bpg',
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                            ),
                                                            maxLines: 2,
                                                            softWrap: true,
                                                            textAlign: TextAlign
                                                                .center, // Center the text
                                                          ),
                                                        ),
                                                      ),
                                                    ),
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
                                                key.currentState?.refreshPage();
                                                var urlToSend =
                                                    '${NetworkService.apiUrl}/user/update_card_number/';
                                                final random = Random();
                                                const digits = '0123456789';
                                                const length = 14;
                                                String randomNumber = '';
                                                for (int i = 0;
                                                    i < length;
                                                    i++) {
                                                  randomNumber += digits[random
                                                      .nextInt(digits.length)];
                                                }
                                                postData(
                                                    urlToSend + userId,
                                                    {
                                                      "card_number":
                                                          randomNumber
                                                    },
                                                    widget.userDataModel.data!
                                                        .token);

                                                updateCardCode(randomNumber);
                                                setState(() {
                                                  cardCode1 = snapshot.data;
                                                });
                                             //   Navigator.of(context).maybePop();
                                              },
                                              child: Container(
                                                width: 120,
                                                decoration: BoxDecoration(
                                                  color: const Color.fromARGB(
                                                      255, 15, 153, 61),
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
                                                            color:
                                                                Colors.white)),
                                                    const SizedBox(
                                                      height: 25,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          snapshot.data != 'Not Available' &&
                                                  _profileContentController
                                                          .profileDataModel
                                                          .value
                                                          .data!
                                                          .cardStatus !=
                                                      'Inactive'
                                              ? const Spacer()
                                              : const SizedBox(),
                                          snapshot.data != 'Not Available' &&
                                                  _profileContentController
                                                          .profileDataModel
                                                          .value
                                                          .data!
                                                          .cardStatus !=
                                                      'Inactive'
                                              ? InkWell(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                          title: Text(
                                                            AppTags
                                                                .cardCencellation
                                                                .tr,
                                                            style:
                                                                const TextStyle(
                                                                    fontFamily:
                                                                        'bpg'),
                                                          ),
                                                          content: Text(
                                                              AppTags
                                                                  .cardCencellationCosts
                                                                  .tr,
                                                              ),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              child: Text(
                                                                  AppTags
                                                                      .yes.tr,
                                                                  ),
                                                              onPressed: () {
                                                                makeCardActive(
                                                                    userId,
                                                                    '0',
                                                                    widget
                                                                        .userDataModel
                                                                        .data!
                                                                        .token,
                                                                    '0',
                                                                    inputController
                                                                        .text);
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                // Perform your "yes" action here
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: Text(
                                                                  AppTags.no.tr,
                                                                  ),
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
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
                                                    height: 140,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 153, 15, 15),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  15)),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: AppThemeData
                                                              .headlineTextColor
                                                              .withOpacity(0.1),
                                                          spreadRadius: 0.r,
                                                          blurRadius: 30.r,
                                                          offset: const Offset(
                                                              0,
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
                                                          Icons.remove,
                                                          color: Colors.white,
                                                          size: 35,
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: SizedBox(
                                                            width: double
                                                                .infinity, // Ensure the container takes the full width
                                                            child: Text(
                                                              AppTags
                                                                  .cancellation
                                                                  .tr,
                                                              style:
                                                                  const TextStyle(
                                                                fontFamily:
                                                                    'bpg',
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              textAlign: TextAlign
                                                                  .center, // Center the text
                                                            ),
                                                          ),
                                                        ),
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
                            child: Column(
                          children: [
                            Text(AppTags.sorryForinconvenience.tr,
                                style: const TextStyle(fontFamily: 'bpg')),
                            ElevatedButton.icon(
                                onPressed: () {
                                  Get.back();
                                },
                                icon: const Icon(Icons.home),
                                label: Text(AppTags.back.tr))
                          ],
                        ));
                      }
                      return const Center(child: CircularProgressIndicator(color: Colors.orange,));
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator(color: Colors.orange,));
              },
            );
          }
          return const Center(child: CircularProgressIndicator(color: Colors.orange,));
        },
      ),
    );
  }
}
