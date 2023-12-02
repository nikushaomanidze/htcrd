import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controllers/forgot_password_controller.dart';
import '../../utils/app_tags.dart';
import '../../utils/app_theme_data.dart';
import '../../utils/responsive.dart';
import '../../widgets/login_edit_textform_field.dart';

class ForgetPasswordScreen extends StatelessWidget {
  ForgetPasswordScreen({Key? key}) : super(key: key);
  final emailController = TextEditingController();
  final otpController = TextEditingController();

  final ForgotPasswordController forgotPassController =
      Get.put(ForgotPasswordController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isMobile(context)
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: const BackButton(color: Colors.black),
              centerTitle: true,
              title: Text(
                AppTags.forgotPasswordText.tr,
                style: AppThemeData.headerTextStyle_16,
              ),
            )
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 60.h,
              leadingWidth: 40.w,
              centerTitle: true,
              leading: const BackButton(color: Colors.black),
              title: Text(
                AppTags.forgotPasswordText.tr,
                style: AppThemeData.headerTextStyle_14,
              ),
            ),
      body: Obx(() => Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 56,
              ),
              Center(
                child: SizedBox(
                  width: 333,
                  height: 56,
                  child: LoginEditTextField(
                    myController: emailController,
                    keyboardType: TextInputType.emailAddress,
                    hintText: AppTags.emailAddress.tr,
                    // fieldIcon: Icons.email,
                    myObscureText: false,
                  ),
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              forgotPassController.isValue.value
                  ? LoginEditTextField(
                      myController: otpController,
                      keyboardType: TextInputType.text,
                      hintText: "Enter OTP code",
                      fieldIcon: Icons.password_rounded,
                      myObscureText: false,
                    )
                  : const SizedBox(),
              SizedBox(
                height: 30.h,
              ),
              !forgotPassController.isValue.value
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: InkWell(
                        onTap: () async {
                          await forgotPassController.forgotPasswordSendOtp(
                              email: emailController.text);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 56,
                          width: 333,
                          decoration: const BoxDecoration(
                            // boxShadow: [
                            //   BoxShadow(
                            //       spreadRadius: 2,
                            //       blurRadius: 10,
                            //       color: AppThemeData.buttonShadowColor
                            //           .withOpacity(0.3),
                            //       offset: const Offset(0, 5))
                            // ],
                            color: Color.fromARGB(255, 239, 127, 26),
                            borderRadius: BorderRadius.all(
                              Radius.circular(35),
                            ),
                          ),
                          child: forgotPassController.isLoader.value
                              ? Text(
                                  AppTags.send.tr,
                                  style: isMobile(context)
                                      ? AppThemeData.buttonTextStyle_14
                                      : AppThemeData.buttonTextStyle_11Tab,
                                )
                              : const CircularProgressIndicator(),
                        ),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.w),
                      child: InkWell(
                        onTap: () async {
                          await forgotPassController
                              .forgotPasswordConfirmSentOtp(
                                  email: emailController.text,
                                  otp: otpController.text);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 48.h,
                          decoration: BoxDecoration(
                            // boxShadow: [
                            //   BoxShadow(
                            //       spreadRadius: 2,
                            //       blurRadius: 10,
                            //       color: AppThemeData.buttonShadowColor.withOpacity(0.3),
                            //       offset: const Offset(0, 5))
                            // ],
                            color: const Color.fromARGB(255, 239, 127, 26),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.r),
                            ),
                          ),
                          child: forgotPassController.isLoader.value
                              ? Text(
                                  AppTags.next.tr,
                                  style: isMobile(context)
                                      ? AppThemeData.buttonTextStyle_14
                                      : AppThemeData.buttonTextStyle_11Tab,
                                )
                              : const CircularProgressIndicator(),
                        ),
                      ),
                    ),
            ],
          )),
    );
  }
}
