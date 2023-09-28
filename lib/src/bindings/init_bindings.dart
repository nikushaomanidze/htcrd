import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/currency_converter_controller.dart';
import '../controllers/phone_auth_controller.dart';
import '../data/data_storage_service.dart';

class InitBindings implements Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController());
    Get.put<PhoneAuthController>(PhoneAuthController());
    Get.put(StorageService());
    Get.lazyPut(() => CurrencyConverterController(), fenix: true);
  }
}
