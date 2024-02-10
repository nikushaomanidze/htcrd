import 'package:get/get.dart';

import '../screen/dashboard/dashboard_screen.dart';
import '../servers/repository.dart';

class PhoneAuthController extends GetxController {
  var isLoading = true.obs;

  Future phoneLogin({String? phoneNumber}) async {
    isLoading.value = false;
    await Repository().postPhoneLogin(phoneNumber: phoneNumber).then((value) {
      isLoading.value = value!;
    });
    isLoading.value = true;
  }

  Future phoneRegistration(
      {String? phoneNumber}) async {
    isLoading.value = false;
    await Repository()
        .postPhoneRegistration(
      phoneNumber: phoneNumber,
    )
        .then((value) {
      isLoading.value = value!;
    });
    isLoading.value = true;
  }

  Future phoneLoginSendOtp({String? phoneNumber, String? otp}) async {
    isLoading.value = false;
    await Repository()
        .postPhoneLoginOTP(phoneNumber: phoneNumber, otp: otp)
        .then((value) {
      if (value!) {
        Get.offAll(() => const DashboardScreen());
      }
      isLoading.value = true;
    });
  }

  Future phoneRegistrationSendOtp({String? phoneNumber, String? otp}) async {
    isLoading.value = false;
    await Repository()
        .postPhoneRegistrationOTP(phoneNumber: phoneNumber, otp: otp)
        .then((value) {
      isLoading.value = true;
    });
  }

  Future updatePhone({required String phoneNumber}) async {
    isLoading.value = false;
    await Repository().updatePhoneNumber(phoneNumber: phoneNumber)
    .then((value) {
      isLoading.value = true;
    });
  }
}
