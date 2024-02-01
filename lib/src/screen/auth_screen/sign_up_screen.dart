import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import '../../../config.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

// import '../../data/local_data_helper.dart';
import '../../_route/routes.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_tags.dart';
import '../../utils/app_theme_data.dart';
import '../../utils/responsive.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/loader/loader_widget.dart';
import '../../widgets/login_edit_textform_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool switchValue = false;
  late String code;
  bool isButtonDisabled = false;
  int remainingTime = 60; // Initial time in seconds

  void startCountdown() {
    setState(() {
      isButtonDisabled = true;
    });

    const oneSecond = Duration(seconds: 1);
    Timer.periodic(oneSecond, (timer) {
      if (remainingTime == 0) {
        timer.cancel();
        setState(() {
          isButtonDisabled = false;
        });
      } else {
        setState(() {
          remainingTime--;
        });
      }
    });
  }

  final AuthController authController = Get.find<AuthController>();

  void showErrorPopup(BuildContext context, String errorMessage1) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage1),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the popup
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String generateRandomNumber() {
    Random random = Random();
    String number = '';

    for (int i = 0; i < 14; i++) {
      number += random.nextInt(10).toString();
    }

    return number;
  }

  String generateCode() {
    final rand = Random();
    final code = rand.nextInt(9000) +
        1000; // generates a random integer between 1000 and 9999
    return code.toString();
  }

  @override
  void initState() {
    super.initState();
    code = generateCode();
  }

  Future<String> sendSmsOffice(
      String apiKey, String customerMobile, String customerCode) async {
    // Check the SMS balance
    final balanceUrl = 'https://smsoffice.ge/api/getBalance?key=$apiKey';
    final balanceResponse = await http.get(Uri.parse(balanceUrl));
    final balanceString =
        balanceResponse.body.trim(); // Trim any whitespace characters
    final balance = int.parse(balanceString);

    if (balance > 0) {
      // Send SMS
      // final currentTime = DateTime.now().millisecondsSinceEpoch;

      final sendUrl =
          'https://smsoffice.ge/api/v2/send/?key=$apiKey&destination=$customerMobile&sender=Hotcard&content=თქვენი%20ვერიფიკაციის%20კოდია:$customerCode&urgent=true';
      final sendResponse = await http.get(Uri.parse(sendUrl));
      return sendResponse.body;
    } else {
      return 'Insufficient SMS balance';
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _ui(context),
            Obx(() => authController.isLoggingIn
                ? const Positioned(height: 50, width: 50, child: LoaderWidget())
                : const SizedBox()),
          ],
        ),
      ),
    );
  }

  Widget _ui(context) {
    return ListView(
      shrinkWrap: true,
      children: [
        SizedBox(
          height: 40.h,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SizedBox(
            //   width: 115.w,
            //   height: 83.h,
            //   //color: Colors.green,
            //   child: Image.asset("assets/logos/hcard.png"),
            // ),
            SizedBox(
              height: 15.h,
            ),
            Text(
              AppTags.welcome.tr,
              style: TextStyle(
                  color: const Color.fromARGB(255, 74, 75, 77),
                  fontFamily: "bpg",
                  fontSize: 24.sp),
            ),
            SizedBox(
              height: 6.h,
            ),
            Text(
              AppTags.signUpToContinue.tr,
              style: TextStyle(
                color: const Color.fromARGB(255, 74, 75, 77),
                fontFamily: "bpg",
                fontSize: 13.sp,
              ),
            )
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 30.h,
            ),
            SizedBox(
              width: 333,
              child: LoginEditTextField(
                myController: authController.firstNameController,
                keyboardType: TextInputType.text,
                hintText: AppTags.firstName.tr,
                // fieldIcon: Icons.person,
                myObscureText: false,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            SizedBox(
              width: 333,
              child: LoginEditTextField(
                myController: authController.lastNameController,
                keyboardType: TextInputType.text,
                hintText: AppTags.lastName.tr,
                // fieldIcon: Icons.person,
                myObscureText: false,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            SizedBox(
              width: 333,
              child: LoginEditTextField(
                myController: authController.emailControllers,
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
              child: Align(
                child: InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber number) {
                    // Handle phone number changes if needed
                  },
                  inputDecoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 242, 242, 242),

                    hintText: AppTags.phone.tr,
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 182, 183, 183),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0), // Adjust padding as needed
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          35.0), // Set your desired border radius
                      borderSide:
                          BorderSide.none, // Set to none to remove the border
                    ),
                  ),

                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.DIALOG,
                  ),
                  textFieldController: authController.phoneControllers,
                  initialValue: PhoneNumber(
                      isoCode: 'GE'), // Set the initial country code
                  keyboardType: TextInputType.phone,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: TextButton(
                    onPressed: () async {
                      // print(authController.phoneControllers.text);

                      sendSmsOffice(
                        'f83c88afe19b4bddb22d3394e3b02a55',
                        authController.phoneControllers.text,
                        code,
                      );
                      setState(() {
                        startCountdown();
                        // isButtonDisabled = true;
                      });
                      // // Wait for 1 minute
                      // await Future.delayed(Duration(minutes: 1));

                      // // Enable the button
                      // setState(() {
                      //   isButtonDisabled = false;
                      // });
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(118, 17),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: const Color(0xffffffff),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    child: Text(
                      isButtonDisabled
                          ? remainingTime.toString()
                          : AppTags.sendCode.tr,
                      style: const TextStyle(
                        color: Color(0xffe07527),
                        fontFamily: 'bpg',
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            SizedBox(
              width: 333,
              child: LoginEditTextField(
                myController: authController.codeControllers,
                keyboardType: TextInputType.number,
                hintText: AppTags.enterCode.tr,
                // fieldIcon: Icons.add_box_rounded,
                myObscureText: false,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            SizedBox(
              width: 333,
              child: LoginEditTextField(
                myController: authController.referralController,
                keyboardType: TextInputType.text,
                hintText: AppTags.referralCode.tr,
                // fieldIcon: Icons.man,
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
                  myController: authController.passwordControllers,
                  keyboardType: TextInputType.text,
                  hintText: AppTags.password.tr,
                  // fieldIcon: Icons.lock,
                  myObscureText: authController.passwordVisible.value,
                  suffixIcon: InkWell(
                    onTap: () {
                      authController.isVisiblePasswordUpdate();
                    },
                    child: Icon(
                      authController.passwordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppThemeData.iconColor,
                      //size: defaultIconSize,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            SizedBox(
              width: 333,
              child: Obx(() => LoginEditTextField(
                    myController: authController.confirmPasswordController,
                    keyboardType: TextInputType.text,
                    hintText: AppTags.confirmPassword.tr,
                    // fieldIcon: Icons.lock,
                    myObscureText: authController.confirmPasswordVisible.value,
                    suffixIcon: InkWell(
                      onTap: () {
                        authController.isVisibleConfirmPasswordUpdate();
                      },
                      child: Icon(
                        authController.confirmPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppThemeData.iconColor,
                        //size: defaultIconSize,
                      ),
                    ),
                  )),
            ),
            const SizedBox(
              height: 25,
            ),
            SizedBox(
              width: 333,
              child: InkWell(
                onTap: () {
                  if (authController.codeControllers.text == code) {
                    authController.signUp(
                        countryCode: authController.countryCodeControllers.text,
                        firstName: authController.firstNameController.text,
                        lastName: authController.lastNameController.text,
                        email: authController.emailControllers.text,
                        phone: authController.phoneControllers.text,
                        password: authController.passwordControllers.text,
                        confirmPassword:
                            authController.confirmPasswordController.text,
                        // switchValue: switchValue,
                        card_number: generateRandomNumber(),
                        referral_code: authController.referralController.text,
                        context: context);
                  } else {
                    showErrorPopup(
                      context,
                      Text(AppTags.wrongSmsCode.tr).toString(),
                    );
                  }
                },
                child: ButtonWidget(buttonTittle: AppTags.signUp.tr),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            InkWell(
              onTap: () {
                Get.toNamed(Routes.dashboardScreen);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset("assets/icons/arrow_back.svg",
                      // ignore: deprecated_member_use
                      color: const Color.fromARGB(255, 74, 75, 77)),
                  SizedBox(
                    width: 5.h,
                  ),
                  Text(
                    AppTags.backToShopping.tr,
                    style: isMobile(context)
                        ? TextStyle(
                            color: const Color.fromARGB(255, 74, 75, 77),
                            fontFamily: "bpg",
                            fontSize: 12.sp)
                        : TextStyle(
                            color: const Color.fromARGB(255, 74, 75, 77),
                            fontFamily: "bpg",
                            fontSize: 9.sp),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 60.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //google login button
                  Config.enableGoogleLogin
                      ? Container(
                          height: 48.h,
                          width: 48.w,
                          margin: EdgeInsets.only(right: 15.w),
                          decoration: BoxDecoration(
                            color: AppThemeData.socialButtonColor,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: InkWell(
                            onTap: () => authController.signInWithGoogle(),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            child: Padding(
                              padding: EdgeInsets.all(12.r),
                              child:
                                  SvgPicture.asset("assets/icons/google.svg"),
                            ),
                          ),
                        )
                      : const SizedBox(),
                  //facebook login button
                /*  Config.enableFacebookLogin
                      ? Container(
                          height: 48.h,
                          width: 48.w,
                          margin: EdgeInsets.only(right: 15.w),
                          decoration: BoxDecoration(
                            color: AppThemeData.socialButtonColor,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: InkWell(
                            onTap: () {
                              authController.facebookLogin();
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            child: Padding(
                              padding: EdgeInsets.all(12.r),
                              child:
                                  SvgPicture.asset("assets/icons/facebook.svg"),
                            ),
                          ),
                        )
                      : const SizedBox(),

                 */
                  Platform.isIOS
                      ? Container(
                          height: 48.h,
                          width: 48.w,
                          margin: EdgeInsets.only(right: 15.w),
                          decoration: BoxDecoration(
                            color: AppThemeData.socialButtonColor,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: InkWell(
                            onTap: () {
                              authController.signInWithApple();
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            child: Padding(
                              padding: EdgeInsets.all(12.r),
                              child: SvgPicture.asset(
                                  "assets/icons/apple_logo.svg"),
                            ),
                          ),
                        )
                      : Container(),
                  // LocalDataHelper().isPhoneLoginEnabled()
                  //     ? Container(
                  //         height: 48.h,
                  //         width: 48.w,
                  //         decoration: BoxDecoration(
                  //             color: AppThemeData.socialButtonColor,
                  //             borderRadius: BorderRadius.circular(10.r)),
                  //         child: InkWell(
                  //           onTap: () {
                  //             Get.toNamed(Routes.phoneRegistration);
                  //           },
                  //           splashColor: Colors.transparent,
                  //           highlightColor: Colors.transparent,
                  //           hoverColor: Colors.transparent,
                  //           child: Padding(
                  //             padding: EdgeInsets.all(12.r),
                  //             child: SvgPicture.asset(
                  //                 "assets/icons/phone_login.svg"),
                  //           ),
                  //         ),
                  //       )
                  //     : const SizedBox(),
                ],
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppTags.iHaveAnAccount.tr,
                  style: TextStyle(
                      color: const Color.fromARGB(255, 74, 75, 77),
                      fontFamily: "bpg",
                      fontSize: 12.sp),
                ),
                InkWell(
                  onTap: () {
                    Get.toNamed(Routes.logIn);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: 10.w,
                      top: 10.h,
                      bottom: 10.h,
                    ),
                    child: Text(
                      AppTags.signIn.tr,
                      style: TextStyle(
                          color: const Color.fromARGB(255, 74, 75, 77),
                          fontFamily: "bpg",
                          fontSize: 12.sp),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Text(
                AppTags.signUpTermsAndCondition.tr,
                textAlign: TextAlign.center,
                style: isMobile(context)
                    ? TextStyle(
                        color: const Color.fromARGB(255, 74, 75, 77),
                        fontFamily: "bpg",
                        fontSize: 13.sp)
                    : TextStyle(
                        color: const Color.fromARGB(255, 74, 75, 77),
                        fontFamily: "bpg",
                        fontSize: 10.sp),
              ),
            ),
            SizedBox(
              height: 20.h,
            ),
          ],
        ),
      ],
    );
  }
}
