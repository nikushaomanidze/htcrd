import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../_route/routes.dart';
import '../../utils/app_tags.dart';
import '../../utils/app_theme_data.dart';
import '../../utils/responsive.dart';

class ProfileWithoutLoginScreen extends StatelessWidget {
  const ProfileWithoutLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/images/Frame.png"),
            SizedBox(
              height: 15.h,
            ),
            SizedBox(
              width: 231.w,
              child: Text(
                AppTags.noContent.tr,
                style: isMobile(context)
                    ? AppThemeData.orderHistoryTextStyle_12
                        .copyWith(fontSize: 12)
                    : AppThemeData.orderHistoryTextStyle_9Tab,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              width: 280.w,
              height: 60.h,
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed(Routes.logIn);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeData.lightBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 5,
                  shadowColor: AppThemeData.lightBackgroundColor,
                ),
                child: Text(
                  AppTags.signIn.tr,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: isMobile(context) ? 12.sp : 11.sp,
                    fontFamily: "bpg",
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            SizedBox(
              width: 280.w,
              height: 60.h,
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed(Routes.signUp);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 5,
                  shadowColor: const Color.fromARGB(255, 194, 83, 4),
                ),
                child: Text(
                  AppTags.signUp.tr,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: isMobile(context) ? 12.sp : 11.sp,
                    fontFamily: "bpg",
                    color: AppThemeData.lightBackgroundColor,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30.h,
            ),
            InkWell(
              onTap: () {
                Get.toNamed(Routes.dashboardScreen);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/arrow_back.svg",
                    height: 10.h,
                    width: 10.w,
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Text(
                    AppTags.backToShopping.tr,
                    style: isMobile(context)
                        ? AppThemeData.backToHomeTextStyle_12
                        : AppThemeData.categoryTitleTextStyle_9Tab,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 115,
            )
          ],
        ),
      ),
    );
  }
}
