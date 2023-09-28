import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/data_storage_service.dart';
import '../data/local_data_helper.dart';
import '../models/config_model.dart';

class LanguageController extends GetxController {
  final storage = Get.find<StorageService>();
  final RxString locale = Get.locale.toString().obs;

  final Map<String, dynamic> optionsLocales = {
    'en_US': {
      'languageCode': 'en',
      'countryCode': 'US',
      'description': 'English'
    },
    'ka_GE': {
      'languageCode': 'ka',
      'countryCode': 'GE',
      'description': 'ქართული'
    },
    'uk_UA': {
      'languageCode': 'uk',
      'countryCode': 'UA',
      'description': 'українська'
    },
  };

  List<Languages> lang = LocalDataHelper().getConfigData().data!.languages!;
  void updateLocale(String? key) {
    final String languageCode = optionsLocales[key]['languageCode'];
    final String countryCode = optionsLocales[key]['countryCode'];
    // Update App
    Get.updateLocale(Locale(languageCode, countryCode));
    // Update obs
    locale.value = Get.locale.toString();

    //Language code check and save
    lang.asMap().forEach((index, value) {
      if (lang[index].code!.contains(languageCode)) {
        LocalDataHelper().saveLanguageServer(languageCode);
        //print("=====EE====$languageCode");
      }
    });
    // Update storage
    storage.write('languageCode', languageCode);
    storage.write('countryCode', countryCode);
  }

  List<Languages> getAppLanguageList() {
    List<Languages> languageList = [];
    optionsLocales.forEach((k, v) => languageList.add(Languages(
        code: optionsLocales[k]['languageCode'],
        name: optionsLocales[k]['description'])));
    return languageList;
  }
}
