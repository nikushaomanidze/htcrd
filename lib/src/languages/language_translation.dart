import 'package:get/get.dart';

import 'english.dart';
import 'ukrainian.dart';
import 'georgian.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'uk_UA': ukUA,
        'ka_GE': kaGE,
      };
}
