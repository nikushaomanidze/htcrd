// ignore_for_file: deprecated_member_use

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hot_card/src/controllers/auth_controller.dart';
import 'package:hot_card/src/controllers/profile_content_controller.dart';
import 'package:hot_card/src/servers/repository.dart';
import 'package:hot_card/src/utils/validators.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config.dart';
import '../../../_route/routes.dart';
import '../../../controllers/currency_converter_controller.dart';
import '../../../controllers/language_controller.dart';
import '../../../controllers/setting_controller.dart';
import '../../../data/local_data_helper.dart';
import '../../../utils/app_tags.dart';
import '../../../utils/app_theme_data.dart';
import '../../../utils/responsive.dart';

// ignore: must_be_immutable
class Settings extends StatelessWidget {
  Settings({Key? key}) : super(key: key);
  final isUserLoggedIn = false;
  final isNotificationOn = false;
  final selectedLanguage = "English";
  final isDark = true;

  final controller = Get.put(LanguageController());
  final settingController = Get.put(SettingController());
  final currencyConverterController = Get.find<CurrencyConverterController>();

  var emailPhoneController = TextEditingController();
  final ProfileContentController _profileContentController =
      Get.put(ProfileContentController());

  var arguments = Get.arguments;

  @override
  Widget build(BuildContext context) {
    controller.getAppLanguageList();

    //Logout Dialogue
    logoutDialogue() {
      return AwesomeDialog(
        width: isMobile(context)
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.width - 100.w,
        context: context,
        animType: AnimType.scale,
        dialogType: DialogType.noHeader,
        btnOkColor: AppThemeData.okButton,
        btnCancelColor: AppThemeData.cancelButton,
        buttonsTextStyle:
            TextStyle(fontSize: isMobile(context) ? 13.sp : 10.sp, color: Colors.white),
        body: Center(
          child: Text(
            AppTags.doYouReallyWantToLogout.tr,
          ),
        ),
        btnOkOnPress: () {
          Navigator.pushNamed(context, 'withOutLoginPage');
          AuthController.authInstance.signOut();
        },
        btnCancelOnPress: () {
          Get.back();
        },
      ).show();
    }

    //Account Delete Dialog
    accountDeleteDialogue(userDataModel) {
      return AwesomeDialog(
        width: isMobile(context)
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.width - 100.w,
        context: context,
        animType: AnimType.scale,
        dialogType: DialogType.noHeader,
        btnOkColor: AppThemeData.okButton,
        btnCancelColor: AppThemeData.cancelButton,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  AppTags.enterYourEmailPhoneNumberToContinue.tr,
                  style: isMobile(context)
                      ? AppThemeData.priceTextStyle_14
                          .copyWith(fontFamily: 'bpg')
                      : AppThemeData.titleTextStyle_11Tab
                          .copyWith(fontFamily: 'bpg'),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                height: isMobile(context) ? 42.h : 48.h,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xffF4F4F4)),
                  borderRadius: BorderRadius.all(Radius.circular(5.r)),
                ),
                child: TextField(
                  style: isMobile(context)
                      ? AppThemeData.titleTextStyle_13
                      : AppThemeData.titleTextStyleTab,
                  controller: emailPhoneController,
                  maxLines: 1,
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: AppTags.enterYourEmailPhone.tr,
                    hintStyle: isMobile(context)
                        ? AppThemeData.hintTextStyle_13
                        : AppThemeData.hintTextStyle_10Tab,
                    contentPadding: EdgeInsets.only(
                      left: 8.w,
                      right: 8.w,
                      bottom: 8.h,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        btnOkOnPress: () {
          if (emailPhoneController.text == userDataModel.data!.email! ||
              emailPhoneController.text == userDataModel.data!.phone) {
            Repository().deleteAccount().then((value) {
              if (value) {
                _profileContentController.removeUserData();
                AuthController.authInstance.signOut();
                Get.offAllNamed(Routes.logIn);
              }
            });
          } else {
            showErrorToast(AppTags.pleaseEnterCorrectEmailPhone.tr);
          }
        },
        btnCancelOnPress: () {
          Get.back();
        },
      ).show();
    }

    return Scaffold(
      appBar: isMobile(context)
          ? AppBar(
              backgroundColor: Colors.transparent,
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
                AppTags.settings.tr,
                style: AppThemeData.settingsTitleStyle,
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
                AppTags.settings.tr,
                style: AppThemeData.headerTextStyle_14,
              ),
            ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppTags.languages.tr,
                    style: isMobile(context)
                        ? AppThemeData.settingsTitleStyle
                        : AppThemeData.settingsTitleStyleTab,
                  ),
                  Center(
                    child: Obx(
                      () => DropdownButton(
                        isExpanded: false,
                        value: controller.locale.value,
                        icon: const Icon(Icons.arrow_drop_down_outlined),
                        style: isMobile(context)
                            ? AppThemeData.settingsTitleStyle
                            : AppThemeData.settingsTitleStyleTab,
                        iconSize: 24.r,
                        underline: const SizedBox(),
                        hint: SizedBox(
                          width: 100.w,
                          child: Center(
                            child: Text(
                              selectedLanguage,
                            ),
                          ),
                        ),
                        onChanged: (String? newValue) {
                          controller.updateLocale(newValue!);
                        },
                        items: controller.optionsLocales.entries.map(
                          (item) {
                            return DropdownMenuItem<String>(
                              value: item.key,
                              child: Text(
                                item.value['description'],
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // SizedBox(height: 15.h),
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 15.w),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Text(
            //         AppTags.notification.tr,
            //         style: isMobile(context)
            //             ? AppThemeData.settingsTitleStyle
            //             : AppThemeData.settingsTitleStyleTab,
            //       ),
            //       Center(
            //         child: Obx(
            //           () => FlutterSwitch(
            //             width: isMobile(context) ? 40.w : 25.w,
            //             height: 20.h,
            //             valueFontSize: 20,
            //             toggleSize: 20.r,
            //             borderRadius: 30.r,
            //             padding: 1.0,
            //             showOnOff: false,
            //             toggleColor: settingController.isToggle.value
            //                 ? AppThemeData.lightBackgroundColor
            //                 : Colors.white,
            //             activeColor: Colors.green,
            //             inactiveColor: Colors.grey,
            //             value: settingController.isToggle.value,
            //             onToggle: (value) {
            //               settingController.toggle();
            //             },
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // SizedBox(
            //   height: 10.h,
            // ),
            // Obx(
            //   () => Padding(
            //     padding: EdgeInsets.symmetric(horizontal: 15.w),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Text(
            //           AppTags.currency.tr,
            //           style: isMobile(context)
            //               ? AppThemeData.settingsTitleStyle
            //               : AppThemeData.settingsTitleStyleTab,
            //         ),
            //         Container(
            //           height: 42.h,
            //           alignment: Alignment.center,
            //           child: DropdownButtonHideUnderline(
            //             child: DropdownButton(
            //               iconSize: isMobile(context) ? 18.r : 25.r,
            //               isExpanded: false,
            //               style: isMobile(context)
            //                   ? AppThemeData.settingsTitleStyle
            //                   : AppThemeData.settingsTitleStyleTab,
            //               value: settingController.selectedCurrency.value,
            //               onChanged: (newValue) {
            //                 int index = settingController.getIndex(newValue);
            //                 settingController.updateCurrency(newValue);
            //                 settingController.updateCurrencyName(index);
            //                 LocalDataHelper().saveCurrency(
            //                     settingController.selectedCurrency.value);
            //                 currencyConverterController.fetchCurrencyData();
            //               },
            //               items: settingController.curr!.map(
            //                 (curr) {
            //                   return DropdownMenuItem(
            //                     value: curr.code,
            //                     child: Text(curr.name.toString()),
            //                   );
            //                 },
            //               ).toList(),
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile(context) ? 0.w : 10.w,
                  vertical: isMobile(context) ? 0.h : 8.h),
              child: InkWell(
                onTap: () {
                  StoreRedirect.redirect(
                    androidAppId: 'com.tapp.hotcard',
                    iOSAppId: Config.iosAppId,
                  );
                },
                child: ListTile(
                  title: Text(
                    AppTags.rateThisApp.tr,
                    style: isMobile(context)
                        ? AppThemeData.settingsTitleStyle
                        : AppThemeData.settingsTitleStyleTab,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 18.r,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile(context) ? 0.w : 10.w,
                  vertical: isMobile(context) ? 0.h : 8.h),
              child: InkWell(
                onTap: () async {
                  String messengerUrl = "https://m.me/hotcard.ge";
                  if (await canLaunchUrl(Uri.parse(messengerUrl))) {
                    await launchUrl(Uri.parse(messengerUrl));
                  } else {
                    throw 'Could not launch $messengerUrl';
                  }
                },
                child: ListTile(
                  title: Text(
                    AppTags.contact.tr,
                    style: isMobile(context)
                        ? AppThemeData.settingsTitleStyle
                        : AppThemeData.settingsTitleStyleTab,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 18.r,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: const Divider(
                color: AppThemeData.settingScreenDividerColor,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile(context) ? 0.w : 10.w,
                  vertical: isMobile(context) ? 0.h : 8.h),
              child: InkWell(
                onTap: () {
                  Get.toNamed(
                    Routes.wvScreen,
                    parameters: {
                      'url': LocalDataHelper()
                          .getConfigData()
                          .data!
                          .pages![3]
                          .link!,
                      'title': LocalDataHelper()
                          .getConfigData()
                          .data!
                          .pages![3]
                          .title!,
                    },
                  );
                },
                child: ListTile(
                  title: Text(
                    AppTags.termsCondition.tr,
                    style: isMobile(context)
                        ? AppThemeData.settingsTitleStyle
                        : AppThemeData.settingsTitleStyleTab,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 18.r,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile(context) ? 0.w : 10.w,
                  vertical: isMobile(context) ? 0.h : 8.h),
              child: InkWell(
                onTap: () {
                  Get.toNamed(
                    Routes.wvScreen,
                    parameters: {
                      'url': LocalDataHelper()
                          .getConfigData()
                          .data!
                          .pages![4]
                          .link!,
                      'title': LocalDataHelper()
                          .getConfigData()
                          .data!
                          .pages![4]
                          .title!,
                    },
                  );
                },
                child: ListTile(
                  title: Text(
                    AppTags.privacyPolicy.tr,
                    style: isMobile(context)
                        ? AppThemeData.settingsTitleStyle
                        : AppThemeData.settingsTitleStyleTab,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 18.r,
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: const Divider(
                color: AppThemeData.settingScreenDividerColor,
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile(context) ? 0.w : 10.w,
                  vertical: isMobile(context) ? 0.h : 8.h),
              child: InkWell(
                onTap: () {
                  logoutDialogue();
                },
                child: ListTile(
                  title: Text(
                    AppTags.logOut.tr,
                    style: isMobile(context)
                        ? AppThemeData.settingsTitleStyle
                        : AppThemeData.settingsTitleStyleTab,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 18.r,
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile(context) ? 0.w : 10.w,
                  vertical: isMobile(context) ? 0.h : 8.h),
              child: InkWell(
                onTap: () {
                  accountDeleteDialogue(arguments['dataModel']);
                },
                child: ListTile(
                  title: Text(
                    AppTags.deleteYourAccount.tr,
                    style: isMobile(context)
                        ? AppThemeData.settingsTitleStyle
                        : AppThemeData.settingsTitleStyleTab,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 18.r,
                  ),
                ),
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.symmetric(
            //       horizontal: isMobile(context) ? 0.w : 10.w,
            //       vertical: isMobile(context) ? 0.h : 8.h),
            //   child: InkWell(
            //     onTap: () {
            //       Get.toNamed(
            //         Routes.wvScreen,
            //         parameters: {
            //           'url': LocalDataHelper()
            //               .getConfigData()
            //               .data!
            //               .pages![5]
            //               .link!,
            //           'title': LocalDataHelper()
            //               .getConfigData()
            //               .data!
            //               .pages![5]
            //               .title!,
            //         },
            //       );
            //     },
            //     child: ListTile(
            //       title: Text(
            //         AppTags.aboutThisApp.tr,
            //         style: isMobile(context)
            //             ? AppThemeData.settingsTitleStyle
            //             : AppThemeData.settingsTitleStyleTab,
            //       ),
            //       trailing: Icon(
            //         Icons.arrow_forward_ios,
            //         size: 18.r,
            //       ),
            //     ),
            //   ),
            // ),
            // Padding(
            //   padding: EdgeInsets.symmetric(
            //       horizontal: isMobile(context) ? 0.w : 10.w,
            //       vertical: isMobile(context) ? 0.h : 8.h),
            //   child: InkWell(
            //     onTap: () {
            //       Get.toNamed(
            //         Routes.wvScreen,
            //         parameters: {
            //           'url': LocalDataHelper()
            //               .getConfigData()
            //               .data!
            //               .pages![6]
            //               .link!,
            //           'title': LocalDataHelper()
            //               .getConfigData()
            //               .data!
            //               .pages![6]
            //               .title!,
            //         },
            //       );
            //     },
            //     child: ListTile(
            //       title: Text(
            //         AppTags.contactUS.tr,
            //         style: isMobile(context)
            //             ? AppThemeData.settingsTitleStyle
            //             : AppThemeData.settingsTitleStyleTab,
            //       ),
            //       trailing: Icon(
            //         Icons.arrow_forward_ios,
            //         size: 18.r,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
