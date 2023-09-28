// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:hot_card/src/screen/profile/profile_without_login_screen.dart';

import '../../utils/app_tags.dart';

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

class MtlaHome extends StatefulWidget {
  const MtlaHome({super.key});

  @override
  State<MtlaHome> createState() => _MtlaHomeState();
}

class _MtlaHomeState extends State<MtlaHome> {
  final MyWalletController myWalletController = Get.put(MyWalletController());
  final homeScreenContentController = Get.find<HomeScreenController>();

  // int currentTab = 0;
  // final List<Widget> screens = [

  // ]

  Future<bool> isLocationPermissionEnabled() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse;
  }

  Future<List<dynamic>> fetchCategories() async {
    final response = await http
        .get(Uri.parse('https://julius.ltd/hotcard/api/v100/category/all'));

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

  @override
  void initState() {
    super.initState();
    mUpdate();
  }

  mUpdate() async {
    MapProvider provider = Provider.of<MapProvider>(context, listen: false);
    provider.position = await determinePosition();
    await provider.mGetLocationCategory();
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

  // void _showPopupBeforePermission(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(35.0),
  //         ),
  //         title: const Center(
  //           child: Text(
  //             'ლოკაციის გამოყენება',
  //             style: TextStyle(fontFamily: 'bpg'),
  //           ),
  //         ),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const SizedBox(
  //               height: 150, // set a fixed height
  //               child: Text(
  //                 'აპლიკაციას სრულყოფილად სამუშაოდ სჭირდება წვდომა თქვენს ლოკაციაზე, რათა გაჩვენოთ თქვენთვის ყველაზე მოსახერხებელი და ახლო ობიექტები.',
  //                 style: TextStyle(fontFamily: 'bpg'),
  //               ),
  //             ),
  //             ElevatedButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop(); // Close the dialog
  //                 // Call your function here
  //                 // Do something after the dialog is closed
  //               },
  //               child: const Text('OK'),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final ProfileContentController profileContentController =
        Get.put(ProfileContentController());

    return Scaffold(
      // backgroundColor: Colors.white,
      extendBodyBehindAppBar: false,
      extendBody: true,
      backgroundColor: Colors.transparent,

      // appBar: AppBar(
      //   leading: null,
      //   automaticallyImplyLeading: false,
      //   backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      //   elevation: 0,
      //   title: InkWell(
      //     onTap: () {
      //       Get.toNamed(Routes.searchProduct);
      //     },
      //     child: Row(
      //       children: [
      //         const Spacer(),
      //         Container(
      //           decoration: const BoxDecoration(
      //               color: Colors.transparent,
      //               borderRadius: BorderRadius.only(
      //                   bottomLeft: Radius.circular(70),
      //                   bottomRight: Radius.circular(70),
      //                   topLeft: Radius.circular(70),
      //                   topRight: Radius.circular(70))),
      //           width: 300,
      //           height: 45,
      //           child: Row(
      //             children: [
      //               const Spacer(),
      //               SvgPicture.asset(
      //                 "assets/icons/search_bar.svg",
      //                 color: const Color.fromARGB(255, 68, 68, 68),
      //                 width: 18.w,
      //                 height: 18.h,
      //               ),
      //               Padding(
      //                 padding:
      //                     EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      //                 child: const VerticalDivider(
      //                   thickness: 2,
      //                 ),
      //               ),
      //               Padding(
      //                 padding: EdgeInsets.symmetric(horizontal: 10.w),
      //                 child: Text(AppTags.searchProduct.tr,
      //                     style: AppThemeData.hintTextStyle_13.copyWith(
      //                         color: const Color.fromARGB(255, 68, 68, 68),
      //                         fontFamily: 'bpg')),
      //               ),
      //               const Spacer(),
      //             ],
      //           ),
      //         ),
      //         const Spacer(),
      //       ],
      //     ),
      //   ),
      // ),

      body: SafeArea(
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
                          child: profileContentController
                                      .profileDataModel.value.data !=
                                  null
                              ? FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    children: [
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      SizedBox(
                                          width: 65,
                                          child: Image.asset(
                                              "assets/images/xeli.png")),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      const SizedBox(
                                        width: 50,
                                      ),
                                      Column(
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              // ignore: prefer_interpolation_to_compose_strings
                                              myWalletController
                                                          .myWalletModel
                                                          .value
                                                          .data!
                                                          .balance!
                                                          .balance !=
                                                      null
                                                  ? '${'${myWalletController.myWalletModel.value.data!.balance!.balance}'} ₾'
                                                  : '0 ₾',
                                              style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 65, 65, 65),
                                                  fontSize: 25.5,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'bpg'),
                                            ),
                                          ),
                                          Text(AppTags.allSaved.tr)
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                    ],
                                  ))
                              : GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ProfileWithoutLoginScreen()),
                                    );
                                  },
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      AppTags.authorization.tr,
                                      maxLines: 2,
                                      style: const TextStyle(
                                          color:
                                              Color.fromARGB(255, 65, 65, 65),
                                          fontSize: 16.5,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'bpg'),
                                    ),
                                  ),
                                ),
                        ),
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const HomeScreenContent()),
                          );
                        },
                        child: Center(
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0)),
                                child: Image.asset(
                                  "assets/images/restornebi.png",
                                  width: 88,
                                  height: 88,
                                  fit: BoxFit.fill,
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreenCafeContent()),
                          );
                        },
                        child: Center(
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0)),
                                child: Image.asset(
                                  "assets/images/barebi.png",
                                  width: 88,
                                  height: 88,
                                  fit: BoxFit.fill,
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeScreenGartoba()),
                          );
                        },
                        child: Center(
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0)),
                                child: Image.asset(
                                  "assets/images/gartoba.png",
                                  width: 88,
                                  height: 88,
                                  fit: BoxFit.fill,
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
                        onTap: () {
                          _showPopup(context);
                        },
                        child: Center(
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0)),
                                child: Image.asset(
                                  "assets/images/socialebi.png",
                                  width: 88,
                                  height: 88,
                                  fit: BoxFit.fill,
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
                      const SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MapScreen()),
                          );
                        },
                        child: Center(
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0)),
                                child: Image.asset(
                                  "assets/images/mapi.png",
                                  width: 88,
                                  height: 88,
                                  fit: BoxFit.fill,
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
            homeScreenContentController.homeDataModel.value.data != null
                // && _cartController.addToCartListModel.data != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 200,
                          width: MediaQuery.of(context).size.width - 20,
                          child: FutureBuilder<List<dynamic>>(
                            future: fetchCategories(),
                            builder: (context, snapshot) {
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10),
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              ProductByCategory(
                                                            id: filteredCategories[
                                                                index]['id'],
                                                            title:
                                                                filteredCategories[
                                                                        index]
                                                                    ['title'],
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
                                                                  const BorderRadius
                                                                      .all(
                                                                      Radius.circular(
                                                                          10)),
                                                              image: DecorationImage(
                                                                  image: filteredCategories[index]['banner'] !=
                                                                          null
                                                                      ? NetworkImage(filteredCategories[index][
                                                                          'banner'])
                                                                      : const NetworkImage(
                                                                          'https://st3.depositphotos.com/23594922/31822/v/600/depositphotos_318221368-stock-illustration-missing-picture-page-for-website.jpg'),
                                                                  fit: BoxFit
                                                                      .cover)),
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
                                                  filteredCategories[index]
                                                          ['title']
                                                      .toString(),
                                                  maxLines: 1,
                                                  textAlign: TextAlign.left,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: AppThemeData
                                                      .todayDealTitleStyle
                                                      .copyWith(
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 43, 42, 42),
                                                          fontFamily:
                                                              'metro-bold',
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
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    filteredCategories[index][
                                                                'category_filter'] ==
                                                            'ტრადიციული'
                                                        ? AppTags.traditional.tr
                                                        : filteredCategories[index][
                                                                    'category_filter'] ==
                                                                'სუში'
                                                            ? AppTags.sushi.tr
                                                            : filteredCategories[index]
                                                                        [
                                                                        'category_filter'] ==
                                                                    'პიცა'
                                                                ? AppTags
                                                                    .pizza.tr
                                                                : filteredCategories[index]
                                                                            [
                                                                            'category_filter'] ==
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: AppThemeData
                                                        .todayDealTitleStyle
                                                        .copyWith(
                                                            color: const Color
                                                                .fromARGB(255,
                                                                128, 128, 128),
                                                            fontFamily: 'bpg',
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300),
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
                                final errorCode = snapshot.error.toString();
                                return Center(
                                    child: Text(
                                  "${AppTags.internetConnection.tr}! Error Code: $errorCode",
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 24),
                                ));
                              }
                              // By default, show a loading spinner
                              return const Center(
                                child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: SizedBox(
                                      child: CircularProgressIndicator(),
                                    )),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  )
          ],
        ),
      ),
    );
  }
}
