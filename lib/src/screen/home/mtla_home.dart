// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hot_card/src/data/local_data_helper.dart';
import 'package:hot_card/src/screen/dashboard/dashboard_screen.dart';
import 'package:hot_card/src/servers/network_service.dart';
import 'package:hot_card/src/servers/repository.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/app_tags.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hot_card/src/Providers/MapProvider.dart';
import 'package:hot_card/src/screen/Map/MapScreens.dart';
import 'package:hot_card/src/screen/home/home_screen_gartoba.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../_route/routes.dart';
import '../../controllers/home_screen_controller.dart';
import '../../controllers/my_wallet_controller.dart';
import '../../controllers/profile_content_controller.dart';
import '../../utils/app_theme_data.dart';
import '../../utils/responsive.dart';
import 'category/all_category_screen.dart';
import 'category/product_by_category_screen.dart';
import 'home_screen.dart';
import 'home_screen_cafe.dart';
import '../Map/Widget/GetCurrentLocation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';

class MtlaHome extends StatefulWidget {
  const MtlaHome({super.key});

  @override
  State<MtlaHome> createState() => _MtlaHomeState();
}

class _MtlaHomeState extends State<MtlaHome> {
  final MyWalletController myWalletController = Get.put(MyWalletController());
  final homeScreenContentController = Get.find<HomeScreenController>();
  final GoogleSignIn _googleSign = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // int currentTab = 0;
  // final List<Widget> screens = [

  // ]

  Future<bool> isLocationPermissionEnabled() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse;
  }

  Future<void> clearCache() async {
    DefaultCacheManager manager = DefaultCacheManager();
    await manager.emptyCache();
  }

  Future<List<dynamic>> cacheApiResponse() async {
    String url =
        '${NetworkService.apiUrl}/category/all?lang=${LocalDataHelper().getLangCode() ?? "en"}'; // Replace with your API endpoint URL

    DefaultCacheManager manager = DefaultCacheManager();

    FileInfo? fileInfo = await manager.getFileFromCache(url);

    if (fileInfo != null && fileInfo.file.existsSync()) {
      // API response is cached, you can read and parse the JSON data
      String cachedData = await fileInfo.file.readAsString();
      Map<String, dynamic> jsonData = jsonDecode(cachedData);
      final categories = jsonData['data']['categories'][0]['sub_categories'];
      final secondCategories =
          jsonData['data']['categories'][1]['sub_categories'];

      return categories + secondCategories;
    } else {
      // API response is not cached, make the API request and cache it
      final apiResponse = await makeApiRequest(url);
      if (apiResponse != null) {
        // ignore: unused_local_variable
        File file = await manager.putFile(
            url, Uint8List.fromList(apiResponse.bodyBytes));
        // Now, you can parse the JSON data
        Map<String, dynamic> jsonData = jsonDecode(apiResponse.body);
        final categories = jsonData['data']['categories'];
        return categories;
      } else {
        // Handle the case when the API request fails
        return []; // Return an empty list or handle the error accordingly
      }
    }
  }

// Replace this function with your API request logic
  Future<http.Response?> makeApiRequest(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response;
      }
    } catch (e) {
      if (kDebugMode) {
        print('API Request Error: $e');
      }
    }
    return null;
  }

  Future<List<dynamic>> fetchCategories() async {
    final response = await http.get(Uri.parse(
        '${NetworkService.apiUrl}/category/all?lang=${LocalDataHelper().getLangCode() ?? "en"}'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final categories = jsonResponse['data']['categories'];
      // List<dynamic> filteredCategories = [];
      return categories;
    } else {
      fetchCategories();
      throw Exception('Failed to load categories');
    }
  }

  void signOut() async {
    try {
      await _googleSign.signOut();
      await _auth.signOut();
      await Repository().logOut().then((value) {
        LocalDataHelper().box.remove("userToken");
        LocalDataHelper().box.remove("trxId");
        LocalDataHelper().box.remove('userModel');
        Get.offAll(() => const DashboardScreen());
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> checkAndUpdateCardNumber(String userId, String token) async {
    final response = await http.get(
      Uri.parse('${NetworkService.apiUrl}/user/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    Map<String, dynamic> jsonData = jsonDecode(response.body);
    final cardNumber = jsonData['data']['card_number'];
    final userDeviceId = jsonData['data']['user_device_id'];

    if (response.statusCode == 200) {
      if (cardNumber == null || cardNumber == '') {
        await updateCardNumber(userId, token);
        if (kDebugMode) {
          print('Generated and updated card number for the user');
        }
      }

      // ignore: prefer_typing_uninitialized_variables
      var phoneId;
      var deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        var meore = await deviceInfo.androidInfo;
        phoneId = meore.id;
      } else {
        var meore = await deviceInfo.iosInfo;
        phoneId = meore.identifierForVendor;
      }

      if (userDeviceId != null && userDeviceId != phoneId) {
        // exit(0);
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async {
                // Handle back button press, return false to prevent closing
                return false;
              },
              child: AlertDialog(
                title: Text(AppTags.popuptitle.tr),
                content: Text(AppTags.popupdescription.tr),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Close the popup
                      signOut();
                    },
                    child: Text(AppTags.understand.tr),
                  ),
                  TextButton(
                    onPressed: () {
                      // Close the popup
                      signOut();
                      _launchFb();
                    },
                    child: Text(AppTags.contact.tr),
                  ),
                ],
              ),
            );
          },
        );
      }
    } else {
      // Handle other status codes as needed
      if (kDebugMode) {
        print('Unexpected status code: ${response.statusCode}');
      }
    }
  }

  Future<void> updateCardNumber(String userId, String token) async {
    final urlToUpdate = '${NetworkService.apiUrl}/user/update_card_number/';
    final random = Random();
    const digits = '0123456789';
    const length = 14;
    String randomNumber = '';
    for (int i = 0; i < length; i++) {
      randomNumber += digits[random.nextInt(digits.length)];
    }

    await postData(urlToUpdate + userId, {"card_number": randomNumber}, token);
  }

  Future<void> postData(
      String url, Map<String, dynamic> data, String token) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print('Data posted successfully');
      }
    } else {
      if (kDebugMode) {
        print('Failed to post data. Status code: ${response.statusCode}');
      }
    }
  }

  @override
  initState() {
    myWalletController.getMyWallet();
    super.initState();
    mUpdate();
    LocalDataHelper().getUserToken() != null
        ? checkAndUpdateCardNumber(
            LocalDataHelper().getUserAllData()!.data!.userId.toString(),
            LocalDataHelper().getUserToken().toString())
        : null;

    if (kDebugMode) {
      print(LocalDataHelper().getUserToken().toString());
    }
   // checkAndRequestLocationPermission(context);

  }

  mUpdate() async {
    MapProvider provider = Provider.of<MapProvider>(context, listen: false);
    provider.position = await determinePosition();
    await provider.mGetLocationCategory();
    // ignore: use_build_context_synchronously
    await provider.mUpdateAllMarkers(context: context);
  }

  void _launchFb() async {
    String url = 'https://www.facebook.com/hotcard.ge';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchGram() async {
    String url = 'https://www.instagram.com/hotcard.ge/';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchTiktok() async {
    String url = 'https://www.tiktok.com/@hotcard.ge';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35.0),
          ),
          title: Center(
            child: Text(
              AppTags.socialNetworks.tr,
              style: const TextStyle(fontFamily: 'bpg'),
            ),
          ),
          content: SizedBox(
            height: 150, // set a fixed height
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _launchFb();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(75.0),
                      image: DecorationImage(
                        image: Image.asset('assets/images/fb.png').image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    width: 70,
                    height: 70,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    _launchGram();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(75.0),
                      image: DecorationImage(
                        image: Image.asset('assets/images/gram.png').image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    width: 70,
                    height: 70,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    _launchTiktok();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(75.0),
                      image: DecorationImage(
                        image: Image.asset('assets/images/tiktok.png').image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    width: 70,
                    height: 70,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Future<void> _checkAndRequestLocationPermission(
      BuildContext context, MaterialPageRoute route) async {
    LocationPermission locationPermission = await Geolocator.checkPermission();

    if (locationPermission == LocationPermission.denied ||
        locationPermission == LocationPermission.deniedForever) {
      await showDialog(
        context: context,
        barrierDismissible: false, // Prevent user from closing the dialog
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              AppTags.locreqtitle.tr,
              // style: TextStyle(color: Colors.orange),
            ),
            content: Text(
              AppTags.locreqbody.tr,
              //  style: TextStyle(color: Colors.orange),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Handle cancel action
                  Navigator.of(context).pop();
                },
                child: Text(
                  'არ ვეთანხმები',
                  style: TextStyle(color: Colors.orange.shade700),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () async {
                  // Request location permission and close the dialog
                  locationPermission = await Geolocator.requestPermission();
                  if (locationPermission == LocationPermission.deniedForever) {
                    // The user has permanently denied the location permission
                    // You may want to navigate to the app settings to enable the permission manually
                    openAppSettings();
                  }
                  Navigator.of(context).pop();
                },
                child: Text(
                  'თანხმობა',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    } else if (locationPermission == LocationPermission.always ||
        locationPermission == LocationPermission.whileInUse) {
      bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!isLocationServiceEnabled) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'ლოკაციის გაზიარება გამორთულია',
                // style: TextStyle(color: Colors.orange),
              ),
              content: Text(
                'გთხოვთ, ჩართეთ ლოკაციის გაზიარება თქვენს სმარტფონში',
                //  style: TextStyle(color: Colors.orange),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'დახურვა',
                    style: TextStyle(color: Colors.orange.shade700),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        Navigator.push(context, route);
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final ProfileContentController profileContentController =
        Get.put(ProfileContentController());


    return Scaffold(
      // backgroundColor: Colors.white,
      extendBodyBehindAppBar: false,
      extendBody: true,
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              InkWell(
                onTap: () {
                  Get.toNamed(Routes.searchProduct);
                },
                child: Container(
                  width: 333,
                  height: 45,
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 242, 242, 242),
                      borderRadius: BorderRadius.circular(35)),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 25,
                      ),
                      ImageIcon(
                        size: 20,
                        AssetImage('assets/images/searchicon.png'),
                        color: Color.fromARGB(255, 124, 125, 126),
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Text(
                        'Search Food',
                        style: TextStyle(
                            color: Color.fromARGB(255, 182, 183, 183),
                            fontSize: 14),
                      ),
                      Spacer(),
                      Image(
                        width: 68.35,
                        image: AssetImage('assets/images/hotcard-lo.png'),
                      ),
                      SizedBox(
                        width: 15,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: isMobile(context) ? 2.h : 30.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: isMobile(context) ? 100.h : 120.h,
                        width: 333,
                        child: Container(
                          decoration: const BoxDecoration(
                              // color: Color.fromARGB(255, 245, 245, 245),
                              color: Colors.transparent,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10))),
                          child: Center(
                              child: LocalDataHelper().getUserToken() != null
                                  ? FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 10),
                                          SizedBox(
                                              width: 65,
                                              child: Image.asset(
                                                  "assets/images/xeli.png")),
                                          const SizedBox(width: 8),
                                          const SizedBox(width: 50),
                                          Column(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Obx(() {
                                                  final balance =
                                                      myWalletController
                                                          .myWalletModel
                                                          .value
                                                          .data
                                                          ?.balance
                                                          ?.balance;

                                                  return Text(
                                                    balance != null
                                                        ? "${balance.toStringAsFixed(1)} ₾"
                                                        : "0 ₾", // Explicitly handle the case when balance is not loaded
                                                    style: const TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 65, 65, 65),
                                                      fontSize: 25.5,
                                                      fontWeight: FontWeight.w600,
                                                      fontFamily: 'bpg',
                                                    ),
                                                  );
                                                }),
                                              ),
                                              Text(AppTags.allSaved.tr),
                                            ],
                                          ),
                                          const SizedBox(width: 10),
                                        ],
                                      ))
                                  : Row(
                                      children: [
                                        SizedBox(
                                          width: 140.w,
                                          height: 60.h,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Get.toNamed(Routes.logIn);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppThemeData
                                                  .lightBackgroundColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              elevation: 5,
                                              shadowColor: AppThemeData
                                                  .lightBackgroundColor,
                                            ),
                                            child: Text(
                                              AppTags.signIn.tr,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: isMobile(context)
                                                    ? 12.sp
                                                    : 11.sp,
                                                fontFamily: "bpg",
                                                color: const Color.fromARGB(
                                                    255, 255, 255, 255),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        SizedBox(
                                          width: 140.w,
                                          height: 60.h,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Get.toNamed(Routes.signUp);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      255, 255, 255, 255),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              elevation: 5,
                                              shadowColor: const Color.fromARGB(
                                                  255, 194, 83, 4),
                                            ),
                                            child: Text(
                                              AppTags.signUp.tr,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontSize: isMobile(context)
                                                    ? 12.sp
                                                    : 11.sp,
                                                fontFamily: "bpg",
                                                color: AppThemeData
                                                    .lightBackgroundColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10, left: 10),
                child: SizedBox(
                  height: 130,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        GestureDetector(
                        onTap: () async {
                       await   _checkAndRequestLocationPermission(context, MaterialPageRoute(builder: (context) => HomeScreenContent()));
               /*   PermissionStatus status = await Permission.location.status;
                  if (status.isDenied || status.isPermanentlyDenied) {
                  // Permission is denied or permanently denied, do nothing or show a message
                    _checkAndRequestLocationPermission(context);
                  } else {
                  // Permission is granted, navigate to HomeScreenContent
                  Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreenContent()),
                  );
                  } */


                  },


                          child: Center(
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                      color: Colors
                                          .orange, // Choose your border color
                                      width: 3.0, // Choose your border width
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        15.0), // Adjust the radius to be slightly less than the container
                                    child: Image.asset(
                                      "assets/images/restornebi.png",
                                      width: 88,
                                      height: 88,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  AppTags.restaurants.tr,
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 14, 13, 13),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      fontFamily: 'bpg'),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: () async {
                            await   _checkAndRequestLocationPermission(context, MaterialPageRoute(builder: (context) => HomeScreenCafeContent()));

                          },
                          child: Center(
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                      color: Colors
                                          .orange, // Choose your border color
                                      width: 3.0, // Choose your border width
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        17.0), // Adjust the radius to be slightly less than the container
                                    child: Image.asset(
                                      "assets/images/barebi.png",
                                      width: 88,
                                      height: 88,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  AppTags.cafeBars.tr,
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 14, 13, 13),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      fontFamily: 'bpg'),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: () async {
                            await   _checkAndRequestLocationPermission(context, MaterialPageRoute(builder: (context) => HomeScreenGartoba()));
                          },
                          child: Center(
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                      color: Colors
                                          .orange, // Choose your border color
                                      width: 2.0, // Choose your border width
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        18.0), // Adjust the radius to be slightly less than the container
                                    child: Image.asset(
                                      "assets/images/gartoba.png",
                                      width: 88,
                                      height: 88,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  AppTags.fun.tr,
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 14, 13, 13),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      fontFamily: 'bpg'),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: () async {
                            await   _checkAndRequestLocationPermission(context, MaterialPageRoute(builder: (context) => MapScreen()));

                          },
                          child: Center(
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                      color: Colors
                                          .orange, // Choose your border color
                                      width: 2.0, // Choose your border width
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        18.0), // Adjust the radius to be slightly less than the container
                                    child: Image.asset(
                                      "assets/images/mapi.png",
                                      width: 88,
                                      height: 88,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  AppTags.map.tr,
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 14, 13, 13),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      fontFamily: 'bpg'),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            _showPopup(context);
                          },
                          child: Center(
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                      color: Colors
                                          .orange, // Choose your border color
                                      width: 2.0, // Choose your border width
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        15.0), // Adjust the radius to be slightly less than the container
                                    child: Image.asset(
                                      "assets/images/socialebi.png",
                                      width: 88,
                                      height: 88,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  AppTags.socialNetworks.tr,
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 14, 13, 13),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      fontFamily: 'bpg'),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Row(
                  children: [
                    Text(
                      AppTags.topObjects.tr,
                      style: const TextStyle(
                          fontFamily: 'bpg',
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AllCategory()),
                        );
                      },
                      child: Text(
                        AppTags.seeAll.tr,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 252, 96, 17),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'bpg'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 200,
                      width: MediaQuery.of(context).size.width - 20,
                      child: FutureBuilder<List<dynamic>>(
                        future: cacheApiResponse(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<dynamic>? categories = snapshot.data;
                            List<dynamic> filteredCategories = categories!
                                .where((category) =>
                                    category['slug'] != 'restornebi' &&
                                    category['slug'] != 'gartoba' &&
                                    category['order'] == 15)
                                .toList();
                            // print(filteredCategories);

                            // Render the list of categories as needed
                            return NotificationListener<
                                OverscrollIndicatorNotification>(
                              onNotification: (overscroll) {
                                overscroll
                                    .disallowIndicator(); // This will prevent the overscroll glow effect
                                return false;
                              },
                              child: ListView.builder(
                                itemCount: 5,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: [
                                      Column(
                                        children: [
                                          Center(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          ProductByCategory(
                                                        id: filteredCategories[
                                                            index]['id'],
                                                        title: filteredCategories[
                                                            index]['title'],
                                                        number:
                                                            filteredCategories[
                                                                index]['number'],
                                                        soc_fb:
                                                            filteredCategories[
                                                                index]['soc_fb'],
                                                        soc_yt:
                                                            filteredCategories[
                                                                index]['soc_yt'],
                                                        soc_in:
                                                            filteredCategories[
                                                                index]['soc_in'],
                                                        category:
                                                            filteredCategories[
                                                                    index][
                                                                'category_filter'],
                                                        imgurl:
                                                            filteredCategories[
                                                                index]['banner'],
                                                        latlong:
                                                            filteredCategories[
                                                                index]['latlong'],
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Container(
                                                      width: 250,
                                                      height: 130,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                                Radius.circular(
                                                                    10)),
                                                        border: Border.all(
                                                          color: Colors
                                                              .orange, // Choose your border color
                                                          width:
                                                              2.0, // Choose your border width
                                                        ),
                                                        image: DecorationImage(
                                                          image: filteredCategories[
                                                                          index][
                                                                      'banner'] !=
                                                                  null
                                                              ? NetworkImage(
                                                                  filteredCategories[
                                                                          index]
                                                                      ['banner'])
                                                              : const NetworkImage(
                                                                  'https://st3.depositphotos.com/23594922/31822/v/600/depositphotos_318221368-stock-illustration-missing-picture-page-for-website.jpg'),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 250,
                                            child: Text(
                                              filteredCategories[index]['title']
                                                  .toString(),
                                              maxLines: 1,
                                              textAlign: TextAlign.left,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppThemeData
                                                  .todayDealTitleStyle
                                                  .copyWith(
                                                      color: const Color.fromARGB(
                                                          255, 43, 42, 42),
                                                      fontFamily: 'metro-bold',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          SizedBox(
                                            width: 250,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                filteredCategories[index]['category_filter'] ==
                                                            '' ||
                                                        filteredCategories[index][
                                                                'category_filter'] ==
                                                            null
                                                    ? ''
                                                    : filteredCategories[index][
                                                                'category_filter'] ==
                                                            'ტრადიციული'
                                                        ? AppTags.traditional.tr
                                                        : filteredCategories[index][
                                                                    'category_filter'] ==
                                                                'სუში'
                                                            ? AppTags.sushi.tr
                                                            : filteredCategories[index]['category_filter'] ==
                                                                    'პიცა'
                                                                ? AppTags.pizza.tr
                                                                : filteredCategories[index]['category_filter'] ==
                                                                        'ზღვის პროდუქტები'
                                                                    ? AppTags
                                                                        .seafood
                                                                        .tr
                                                                    : filteredCategories[index]['category_filter'] ==
                                                                            'ბურგერები'
                                                                        ? AppTags
                                                                            .burgers
                                                                            .tr
                                                                        : filteredCategories[index]['category_filter'] == 'აზიური'
                                                                            ? AppTags.asian.tr
                                                                            : filteredCategories[index]['category_filter'] == 'საცხობი'
                                                                                ? AppTags.bakery.tr
                                                                                : filteredCategories[index]['category_filter'] == 'დესერტი'
                                                                                    ? AppTags.dessert.tr
                                                                                    : filteredCategories[index]['category_filter'] == 'მექსიკური'
                                                                                        ? AppTags.mexican.tr
                                                                                        : filteredCategories[index]['category_filter'] == 'შაურმა'
                                                                                            ? AppTags.shawarma.tr
                                                                                            : AppTags.vegetarian.tr,
                                                maxLines: 1,
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppThemeData
                                                    .todayDealTitleStyle
                                                    .copyWith(
                                                        color:
                                                            const Color.fromARGB(
                                                                255,
                                                                128,
                                                                128,
                                                                128),
                                                        fontFamily: 'bpg',
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w300),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                          } else if (snapshot.hasError) {
                            if (snapshot.hasData) {
                              List<dynamic>? categories = snapshot.data;
                              List<dynamic> filteredCategories = categories!
                                  .where((category) =>
                                      category['slug'] != 'restornebi' &&
                                      category['slug'] != 'gartoba')
                                  .toList();

                              // Render the list of categories as needed
                              return NotificationListener<
                                  OverscrollIndicatorNotification>(
                                onNotification: (overscroll) {
                                  overscroll
                                      .disallowIndicator(); // This will prevent the overscroll glow effect
                                  return false;
                                },
                                child: ListView.builder(
                                  itemCount: filteredCategories.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return Row(
                                      children: [
                                        Column(
                                          children: [
                                            Center(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10),
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            ProductByCategory(
                                                          id: filteredCategories[
                                                              index]['id'],
                                                          title:
                                                              filteredCategories[
                                                                  index]['title'],
                                                          number:
                                                              filteredCategories[
                                                                      index]
                                                                  ['number'],
                                                          soc_fb:
                                                              filteredCategories[
                                                                      index]
                                                                  ['soc_fb'],
                                                          soc_yt:
                                                              filteredCategories[
                                                                      index]
                                                                  ['soc_yt'],
                                                          soc_in:
                                                              filteredCategories[
                                                                      index]
                                                                  ['soc_in'],
                                                          category:
                                                              filteredCategories[
                                                                      index][
                                                                  'category_filter'],
                                                          imgurl:
                                                              filteredCategories[
                                                                      index]
                                                                  ['banner'],
                                                          latlong:
                                                              filteredCategories[
                                                                      index]
                                                                  ['latlong'],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Column(
                                                    children: [
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      Container(
                                                        width: 250,
                                                        height: 130,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                const BorderRadius.all(
                                                                    Radius.circular(
                                                                        10)),
                                                            image: DecorationImage(
                                                                image: filteredCategories[index]
                                                                            [
                                                                            'banner'] !=
                                                                        null
                                                                    ? NetworkImage(
                                                                        filteredCategories[index]
                                                                            [
                                                                            'banner'])
                                                                    : const NetworkImage(
                                                                        'https://st3.depositphotos.com/23594922/31822/v/600/depositphotos_318221368-stock-illustration-missing-picture-page-for-website.jpg'),
                                                                fit: BoxFit.cover)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            SizedBox(
                                              width: 250,
                                              child: Text(
                                                filteredCategories[index]['title']
                                                    .toString(),
                                                maxLines: 1,
                                                textAlign: TextAlign.left,
                                                overflow: TextOverflow.ellipsis,
                                                style: AppThemeData
                                                    .todayDealTitleStyle
                                                    .copyWith(
                                                        color:
                                                            const Color.fromARGB(
                                                                255, 43, 42, 42),
                                                        fontFamily: 'metro-bold',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            SizedBox(
                                              width: 250,
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  filteredCategories[index][
                                                                  'category_filter'] ==
                                                              '' ||
                                                          filteredCategories[index][
                                                                  'category_filter'] ==
                                                              null
                                                      ? ''
                                                      : filteredCategories[index][
                                                                  'category_filter'] ==
                                                              'ტრადიციული'
                                                          ? AppTags.traditional.tr
                                                          : filteredCategories[index]
                                                                      [
                                                                      'category_filter'] ==
                                                                  'სუში'
                                                              ? AppTags.sushi.tr
                                                              : filteredCategories[index]['category_filter'] ==
                                                                      'პიცა'
                                                                  ? AppTags
                                                                      .pizza.tr
                                                                  : filteredCategories[index]['category_filter'] ==
                                                                          'ზღვის პროდუქტები'
                                                                      ? AppTags
                                                                          .seafood
                                                                          .tr
                                                                      : filteredCategories[index]['category_filter'] == 'ბურგერები'
                                                                          ? AppTags.burgers.tr
                                                                          : filteredCategories[index]['category_filter'] == 'აზიური'
                                                                              ? AppTags.asian.tr
                                                                              : filteredCategories[index]['category_filter'] == 'საცხობი'
                                                                                  ? AppTags.bakery.tr
                                                                                  : filteredCategories[index]['category_filter'] == 'დესერტი'
                                                                                      ? AppTags.dessert.tr
                                                                                      : filteredCategories[index]['category_filter'] == 'მექსიკური'
                                                                                          ? AppTags.mexican.tr
                                                                                          : filteredCategories[index]['category_filter'] == 'შაურმა'
                                                                                              ? AppTags.shawarma.tr
                                                                                              : AppTags.vegetarian.tr,
                                                  maxLines: 1,
                                                  textAlign: TextAlign.center,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: AppThemeData
                                                      .todayDealTitleStyle
                                                      .copyWith(
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 128, 128, 128),
                                                          fontFamily: 'bpg',
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w300),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              );
                            }
                          }
                          // By default, show a loading spinner
                          return const Center(
                            child: SizedBox(
                                width: 50,
                                height: 50,
                                child: SizedBox(
                                  child: SpinKitDancingSquare(
                                    color: Colors.blue,
                                    size: 50.0,
                                  ),
                                )),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
