import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hot_card/src/Providers/MapProvider.dart';
import 'package:hot_card/src/Providers/PaymentProvider.dart';
import 'package:provider/provider.dart';

import 'src/_route/routes.dart';
import 'src/bindings/init_bindings.dart';
import 'src/controllers/init_controller.dart';
import 'src/data/data_storage_service.dart';
import 'src/languages/language_translation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp();
  } else {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDSdAY0btx2wzn07dSKa_kjVy-dvKDMeDI",
        authDomain: "hotcard-ff104.firebaseapp.com",
        projectId: "hotcard-ff104",
        storageBucket: "hotcard-ff104.appspot.com",
        messagingSenderId: "848498097413",
        appId: "1:848498097413:web:94b755c4cc6cffe389cb6c",
        measurementId: "G-QQG1BBHK0E",
      ),
    );
  }
  await GetStorage.init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

Future<void> initialConfig() async {
  await Get.putAsync(() => StorageService().init());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);
  final storage = Get.put(StorageService());
  final initController = Get.put(InitController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<MapProvider>(
                create: (context) => MapProvider()),
            ChangeNotifierProvider<PaymentProvider>(
                create: (context) => PaymentProvider()),
          ],
          child: GetMaterialApp(
            navigatorObservers: <NavigatorObserver>[initController.observer],
            initialBinding: InitBindings(),
            locale: storage.languageCode != null
                ? Locale(storage.languageCode!, storage.countryCode)
                : const Locale('ka', 'GE'),
            translations: AppTranslations(),
            fallbackLocale: const Locale('ka', 'GE'),
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: false
            ),
            initialRoute: Routes.splashScreen,
            getPages: Routes.list,
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: child!,
              );
            },
          ),
        );
      },
    );
  }
}
