import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../config.dart';
import '../../_route/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/details_screen_controller.dart';
import '../../data/local_data_helper.dart';
import '../../utils/app_tags.dart';
import '../../utils/app_theme_data.dart';
import '../../utils/responsive.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/loader/loader_widget.dart';
import '../../widgets/login_edit_textform_field.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);
  final authController = Get.find<AuthController>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final homeScreenController = Get.put<DashboardController>;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Obx(
          () => Stack(
            alignment: Alignment.center,
            children: [
              _ui(context),
              authController.isLoggingIn
                  ? Positioned(
                      height: 50.h,
                      width: 50.w,
                      child: const LoaderWidget(),
                    )
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  Widget _ui(context) {
    return ListView(
      shrinkWrap: true,
      children: [
        SizedBox(
          height: 30.h,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Login',
              style: AppThemeData.welComeTextStyle_24
                  .copyWith(fontFamily: 'bpg', fontSize: 30),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              AppTags.loginToContinue.tr,
              style: AppThemeData.titleTextStyle_13
                  .copyWith(fontFamily: 'bpg', fontSize: 13),
            )
          ],
        ),
        Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 20.h,
              ),
              SizedBox(
                width: 333,
                child: LoginEditTextField(
                  myController: authController.emailController,
                  keyboardType: TextInputType.text,
                  hintText: AppTags.emailAddress.tr,
                  // fieldIcon: Icons.email,
                  myObscureText: false,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              SizedBox(
                width: 333,
                child: Obx(
                  () => LoginEditTextField(
                    myController: authController.passwordController,
                    keyboardType: TextInputType.text,
                    hintText: AppTags.password.tr,
                    myObscureText: authController.isVisible.value,
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              SizedBox(
                width: 333,
                height: 56,
                child: InkWell(
                  onTap: () async {
                    authController.loginWithEmailPassword(
                        email: authController.emailController!.text,
                        password: authController.passwordController!.text);

                    if (authController.isValue.value) {
                      LocalDataHelper().saveRememberMail(
                          authController.emailController!.text.toString());
                      LocalDataHelper().saveRememberPass(
                          authController.passwordController!.text.toString());
                    } else {
                      LocalDataHelper().box.remove("mail");
                      LocalDataHelper().box.remove("pass");
                    }
                    Get.delete<DetailsPageController>();
                  },
                  child: ButtonWidget(buttonTittle: AppTags.signIn.tr),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              InkWell(
                onTap: () {
                  Get.toNamed(Routes.forgetPassword);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    AppTags.forgotPassword.tr,
                    style: isMobile(context)
                        ? AppThemeData.forgotTextStyle_12
                        : AppThemeData.todayDealNewStyle,
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
           /*   Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Text(
                  AppTags.orUse.tr,
                  style: isMobile(context)
                      ? AppThemeData.forgotTextStyle_12
                      : AppThemeData.todayDealNewStyle,
                ),
              ),*/
              const SizedBox(
                height: 25,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //google login button
                   /* Config.enableGoogleLogin
                        ? Container(
                            height: 56,
                            width: 333,
                            // margin: EdgeInsets.only(right: 15.w),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 221, 75, 57),
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            child: InkWell(
                              onTap: () {
                                authController.signInWithGoogle();
                              },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              child: Center(
                                child: Row(
                                  children: [
                                    const Spacer(),
                                    Padding(
                                      padding: EdgeInsets.all(12.r),
                                      child: Image.asset(
                                          "assets/images/googlewhite.png"),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      AppTags.googleAuthText.tr,
                                      style: const TextStyle(
                                          fontFamily: 'bpg',
                                          color: Colors.white),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : const SizedBox(),
                    const SizedBox(
                      height: 15,
                    ),
                    Config.enableFacebookLogin
                        ? Container(
                            height: 56,
                            width: 333,
                            // margin: EdgeInsets.only(right: 15.w),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 54, 127, 192),
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            child: InkWell(
                              onTap: () {
                                authController.facebookLogin();
                              },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              child: Center(
                                child: Row(
                                  children: [
                                    const Spacer(),
                                    Padding(
                                      padding: EdgeInsets.all(12.r),
                                      child: Image.asset(
                                          "assets/images/fbwhite.png"),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      AppTags.fbAuthText.tr,
                                      style: const TextStyle(
                                          fontFamily: 'bpg',
                                          color: Colors.white),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                            ))
                        : const SizedBox(),
                    const SizedBox(
                      height: 15,
                    ),

                    Platform.isIOS
                        ? Container(
                            height: 56,
                            width: 333,
                            // margin: EdgeInsets.only(right: 15.w),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                            child: InkWell(
                              onTap: () {
                                authController.signInWithApple();
                              },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              child: Center(
                                child: Row(
                                  children: [
                                    const Spacer(),
                                    Padding(
                                      padding: EdgeInsets.all(12.r),
                                      child: Image.asset(
                                          "assets/images/apple.png"),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      AppTags.appleAuthText.tr,
                                      style: const TextStyle(
                                          fontFamily: 'bpg',
                                          color: Color.fromARGB(255, 0, 0, 0)),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                            ))
                        : const SizedBox(),*/
                    // LocalDataHelper().isPhoneLoginEnabled()
                    //     ? Container(
                    //         height: 48.h,
                    //         width: 48.w,
                    //         margin: EdgeInsets.only(right: 15.w),
                    //         decoration: BoxDecoration(
                    //           color: AppThemeData.socialButtonColor,
                    //           borderRadius: BorderRadius.circular(10.r),
                    //         ),
                    //         child: InkWell(
                    //           splashColor: Colors.transparent,
                    //           highlightColor: Colors.transparent,
                    //           hoverColor: Colors.transparent,
                    //           onTap: () {
                    //             Get.toNamed(
                    //               Routes.phoneLoginScreen,
                    //             );
                    //           },
                    //           child: Padding(
                    //             padding: EdgeInsets.all(12.r),
                    //             child: SvgPicture.asset(
                    //                 "assets/icons/phn_login.svg"),
                    //           ),
                    //         ),
                    //       )
                    //     : const SizedBox(),
                  ],
                ),
              ),
              SizedBox(
                height: 30.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppTags.newUser.tr,
                    style: AppThemeData.qsTextStyle_12,
                  ),
                  InkWell(
                    onTap: () {
                      Get.toNamed(Routes.signUp);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: 10.w,
                        top: 10.h,
                        bottom: 10.h,
                      ),
                      child: Text(
                        " ${AppTags.signUp.tr}",
                        style: AppThemeData.qsboldTextStyle_12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Text(
                  AppTags.signInTermsAndCondition.tr,
                  textAlign: TextAlign.center,
                  style: isMobile(context)
                      ? AppThemeData.hintTextStyle_13
                      : AppThemeData.hintTextStyle_10Tab,
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
