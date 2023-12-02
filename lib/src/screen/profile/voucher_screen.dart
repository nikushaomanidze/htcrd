// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../controllers/currency_converter_controller.dart';
import '../../controllers/profile_content_controller.dart';
import '../../controllers/voucher_controller.dart';
import '../../data/local_data_helper.dart';
import '../../servers/network_service.dart';
import '../../utils/app_tags.dart';
import '../../utils/app_theme_data.dart';
import '../../utils/responsive.dart';
import 'users_list.dart';

class VoucherList extends StatefulWidget {
  const VoucherList({Key? key}) : super(key: key);
  @override
  State<VoucherList> createState() => _VoucherListState();
}

class _VoucherListState extends State<VoucherList> {
  final voucherController = Get.put(VoucherController());
  var jsonDta = {};
  var totalUsr = {};
  var totalActvUsr = {};
  final String referralUrl = '/user/referral_users_lists/';
  final String totalUsersUrl = '/user/total_referral_users/';
  final String totalActiveUsersUrl = '/user/total_active_referral_users/';

  final ProfileContentController _profileContentController =
      Get.put(ProfileContentController());

  final currencyConverterController = Get.find<CurrencyConverterController>();

//

  Future<Map> sendPostRequest() async {
    String userIdd = _profileContentController
        .profileDataModel.value.data!.userId!
        .toString();
    var url =
        "${NetworkService.apiUrl}$referralUrl$userIdd?token=${LocalDataHelper().getUserToken()}";
    var headers = {'Content-Type': 'application/json'};

    // Send POST request
    var response = await http.post(Uri.parse(url), headers: headers);

    jsonDta = jsonDecode(response.body);
    return jsonDta;
  }

  Future<Map> totalUsers() async {
    String userIdd = _profileContentController
        .profileDataModel.value.data!.userId!
        .toString();
    var url =
        "${NetworkService.apiUrl}$totalUsersUrl$userIdd?token=${LocalDataHelper().getUserToken()}";
    var headers = {'Content-Type': 'application/json'};

    // Send POST request
    var response = await http.post(Uri.parse(url), headers: headers);

    totalUsr = jsonDecode(response.body);
    return totalUsr;
  }

// http://julius.ltd/hotcard/api/v100/user/total_active_referral_users/U-REF-ID-19
  Future<Map> totalActiveUsers() async {
    String userIdd = _profileContentController
        .profileDataModel.value.data!.userId!
        .toString();
    var url =
        "${NetworkService.apiUrl}$totalActiveUsersUrl$userIdd?token=${LocalDataHelper().getUserToken()}";
    var headers = {'Content-Type': 'application/json'};

    // Send POST request
    var response = await http.post(Uri.parse(url), headers: headers);

    totalActvUsr = jsonDecode(response.body);
    return totalActvUsr;
  }

  @override
  Widget build(BuildContext context) {
    sendPostRequest();

    totalUsers();

    totalActiveUsers();

    return FutureBuilder(
        future: totalUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: isMobile(context)
                  ? AppBar(
                      backgroundColor: Colors.white,
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
                        AppTags.voucherList.tr,
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
                        AppTags.voucherList.tr,
                        style: AppThemeData.headerTextStyle_14,
                      ),
                    ),
              body: Column(
                children: [
                  Center(
                    child: Text(
                      AppTags.yourCode.tr,
                      style: const TextStyle(
                        fontSize: 19,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      _profileContentController.profileDataModel.value.data!
                          .referralId!, //esaa gasasworebeli
                      style: const TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ),
                  TextButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(
                            text: _profileContentController
                                .profileDataModel.value.data!.referralId!));
                        // copied successfully
                        Flushbar(
                          message: AppTags.codeIsCopied.tr,
                          duration: const Duration(seconds: 2),
                        ).show(context);
                      },
                      icon: const Icon(Icons.copy),
                      label: Text(AppTags.copyCode.tr)),
                  // Text(jsonDta.toString()),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: 270,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 200, 210, 209),
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppThemeData.headlineTextColor.withOpacity(0.1),
                          spreadRadius: 0.r,
                          blurRadius: 30.r,
                          offset:
                              const Offset(0, 15), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Spacer(),
                        Text(AppTags.totalOutput.tr,
                            style: const TextStyle(color: Colors.white)),
                        const Spacer(),
                        Text(
                          snapshot.data!['data']['result_active'] != null
                              ? '${snapshot.data!['data']['result_active']}₾'
                              : '0' '₾',
                          style: const TextStyle(
                              fontSize: 22, color: Colors.white),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      const Spacer(),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 103, 144, 76),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15)),
                          boxShadow: [
                            BoxShadow(
                              color: AppThemeData.headlineTextColor
                                  .withOpacity(0.1),
                              spreadRadius: 0.r,
                              blurRadius: 30.r,
                              offset: const Offset(
                                  0, 15), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Spacer(),
                            Text(AppTags.active.tr,
                                style: const TextStyle(color: Colors.white)),
                            const Spacer(),
                            Text(
                              snapshot.data!['data']['result_active'] != null
                                  ? snapshot.data!['data']['result_active']
                                      .toString()
                                  : '0',
                              style: const TextStyle(
                                  fontSize: 22, color: Colors.white),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 183, 3),
                          borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              topRight: Radius.circular(15)),
                          boxShadow: [
                            BoxShadow(
                              color: AppThemeData.headlineTextColor
                                  .withOpacity(0.1),
                              spreadRadius: 0.r,
                              blurRadius: 30.r,
                              offset: const Offset(
                                  0, 15), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Spacer(),
                            Text(AppTags.totally.tr,
                                style: const TextStyle(color: Colors.white)),
                            const Spacer(),
                            Text(
                              snapshot.data!['data']['result'] != null
                                  ? snapshot.data!['data']['result'].toString()
                                  : '0',
                              style: const TextStyle(
                                  fontSize: 22, color: Colors.white),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UsersList(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.people),
                      label: Text(AppTags.listOfInvitedFriends.tr))
                ],
              ),
            );
          } else {
            // show a loading indicator while the data is being fetched
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}

class DashedLineVerticalPainter extends CustomPainter {
  final Color color;
  DashedLineVerticalPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 5, startY = -15;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
