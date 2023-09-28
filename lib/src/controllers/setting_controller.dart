import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../data/local_data_helper.dart';
import '../models/config_model.dart';
import '../servers/repository.dart';

class SettingController extends GetxController {
  RxBool isToggle = false.obs;

  var box = GetStorage();
  var selectedCurrency = "".obs;
  var selectedCurrencyName = "".obs;

  List<Currencies>? curr;

  getIndex(value) {
    return curr!.indexWhere(((currIndex) => currIndex.code == value));
  }

  void updateCurrency(value) {
    selectedCurrency.value = value;
  }

  void updateCurrencyName(value) {
    selectedCurrencyName.value = curr![value].name!;
  }

  void toggle() {
    isToggle.value = isToggle.value ? false : true;
  }

  void handleConfigData() async {
    return Repository().getConfigData().then((configModel) {
      LocalDataHelper().saveConfigData(configModel).then((value) {});
    });
  }

  @override
  void onInit() async {
    curr = LocalDataHelper().getConfigData().data!.currencies!;
    selectedCurrency.value = LocalDataHelper().getCurrCode() ?? "USD";
    selectedCurrencyName.value = selectedCurrencyName.isEmpty
        ? "US Dollar"
        : curr![getIndex(selectedCurrencyName)].name.toString();
    super.onInit();
  }
}
