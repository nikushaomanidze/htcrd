import 'package:get/get.dart';

import '../models/my_wallet_model.dart';
import '../servers/repository.dart';

class MyWalletController extends GetxController {
  late Rx<MyWalletModel> myWalletModel = MyWalletModel().obs;

  Future getMyWallet() async {
    await Repository().getMyWallet().then((value) {
      print('getMyWallet then: ${value.toString()}');
      if (value != null) {
        myWalletModel.value = value;
      }
    });
    update();
  }

  @override
  void onInit() {
    getMyWallet();
    super.onInit();
  }
}
