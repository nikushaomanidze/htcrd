import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';
import '../_route/routes.dart';
import '../data/local_data_helper.dart';
import '../servers/repository.dart';
import '../utils/app_tags.dart';

class SplashController extends GetxController {
  var isLoading = true.obs;
  String? appName;
  String? packageName;
  String? appVersion;
  String? configVersion;
  String? buildNumber;
  String? whatsNew;
  bool? updateSkippable;
  String? url;
  PackageInfo? packageInfo;

  @override
  void onInit() async {
    super.onInit();
     packageInfo = await PackageInfo.fromPlatform().then(
       (value) {
         appName = value.appName;
        packageName = value.packageName;
         appVersion = value.version;
         buildNumber = value.buildNumber;
         return null;
       },
     );
    handleConfigData();
  }

  void handleConfigData() async {
    return Repository().getConfigData().then((configModel) {
      configVersion = Platform.isAndroid
          ? configModel.data!.androidVersion!.apkVersion
          : Platform.isIOS
              ? configModel.data!.iosVersion!.ipaVersion
              : "";

      whatsNew = Platform.isAndroid
          ? configModel.data!.androidVersion!.whatsNew
          : Platform.isIOS
              ? configModel.data!.iosVersion!.whatsNew
              : "";

      if (Platform.isAndroid) {
        if (configModel.data!.androidVersion!.apkFileUrl != null) {
          url = configModel.data!.androidVersion!.apkFileUrl!;
        }
      } else if (Platform.isIOS) {
        if (configModel.data!.iosVersion!.ipaFileUrl != null) {
          url = configModel.data!.iosVersion!.ipaFileUrl!;
        }
      }
      updateSkippable = Platform.isAndroid
          ? configModel.data!.androidVersion!.isSkippable!
          : Platform.isIOS
              ? configModel.data!.iosVersion!.isSkippable!
              : true;
      LocalDataHelper().saveConfigData(configModel).then((value) {
        showDialogue();
        isLoading(false);
      });
    });
  }

  Future<void> navigate() async {
    Timer(
      const Duration(seconds: 1),
      () {
        LocalDataHelper().getUserToken() != null
            ? Get.offAllNamed(
                Routes.dashboardScreen,
              )
            : Get.offAllNamed(
                Routes.withOutLoginPage,
              );
      },
    );
  }

  showDialogue() {
    if (configVersion == null) {
      navigate();
    } else {
      if (appVersion != configVersion) {
        Platform.isIOS ? appUpdateDialogueIos() : appUpdateDialogueAndroid();
      } else {
        navigate();
      }
    }
  }

  appUpdateDialogueIos() {
    showCupertinoDialog(
      context: Get.context!,
      builder: (context) => CupertinoAlertDialog(
        title: const Center(
          child: Text('განაახლეთ აპლიკაცია'),
        ),
        content: Column(
          children: [
            Text(
                "ხელმისაწვდომია განახლება: $appVersion - $configVersion"),
            SizedBox(
              height: 20.h,
            ),
            Row(
              children: [
                whatsNew != null
                    ? const Text(
                        "რა შეიცვალა",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
            SizedBox(
              height: 5.h,
            ),
            Row(
              children: [
                whatsNew != null
                    ? Text(
                        whatsNew!,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
            SizedBox(
              height: 30.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child:
                      Text(updateSkippable != null ? 'დახურვა' : 'Cancel'),
                  onPressed: () {
                    if (updateSkippable != null) {
                      updateSkippable!
                          ? navigate()
                          : SystemChannels.platform
                              .invokeMethod('SystemNavigator.pop');
                    } else {
                      navigate();
                    }
                  },
                ),
                SizedBox(
                  width: 10.w,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 239, 127, 26))
                  ),
                  child: const Text('განახლება',style: TextStyle(color: Colors.white),),
                  onPressed: () {
                    if (url != null) {
                      launchUrl(Uri.parse(url!));
                    } else {
                      Get.showSnackbar(GetSnackBar(
                        backgroundColor: Colors.red,
                        message: AppTags.somethingWentWrong.tr,
                        maxWidth: 200,
                        duration: const Duration(seconds: 3),
                        snackStyle: SnackStyle.FLOATING,
                        margin: const EdgeInsets.all(10),
                        borderRadius: 5,
                        isDismissible: true,
                        dismissDirection: DismissDirection.horizontal,
                      ));
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  appUpdateDialogueAndroid() {
    showCupertinoDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text('განაახლეთ აპლიკაცია'),
        ),
        content: SizedBox(
          height: 200.h,
          child: Column(
            children: [
              Text(
                  "ხელმისაწვდომია განახლება: $appVersion - $configVersion"),
              SizedBox(
                height: 20.h,
              ),
              Row(
                children: [
                  whatsNew != null
                      ? const Text(
                          "რა შეიცვალა",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
              SizedBox(
                height: 5.h,
              ),
              Row(
                children: [
                  whatsNew != null
                      ? Text(
                          whatsNew!,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
              SizedBox(
                height: 30.h,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text(
                        updateSkippable != null ? 'დახურვა' : 'Cancel'),
                    onPressed: () {
                      if (updateSkippable != null) {
                        updateSkippable!
                            ? navigate()
                            : SystemChannels.platform
                                .invokeMethod('SystemNavigator.pop');
                      } else {
                        navigate();
                      }
                    },
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  ElevatedButton(
                   style: ButtonStyle(
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 239, 127, 26))
                    ),
                    child: const Text('განახლება'),
                    onPressed: () {
                      if (url != null) {
                        launchUrl(Uri.parse(url!));
                      } else {
                        Get.showSnackbar(GetSnackBar(
                          backgroundColor: Colors.red,
                          message: AppTags.somethingWentWrong.tr,
                          maxWidth: 200,
                          duration: const Duration(seconds: 3),
                          snackStyle: SnackStyle.FLOATING,
                          margin: const EdgeInsets.all(10),
                          borderRadius: 5,
                          isDismissible: true,
                          dismissDirection: DismissDirection.horizontal,
                        ));
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
