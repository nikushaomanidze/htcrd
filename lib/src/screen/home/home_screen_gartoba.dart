import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hot_card/src/data/local_data_helper.dart';
import 'package:hot_card/src/servers/network_service.dart';
import 'package:hot_card/src/utils/app_tags.dart';

import 'package:hot_card/src/Providers/MapProvider.dart';
import 'package:hot_card/src/models/home_data_model.dart' as data_model;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../_route/routes.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/details_screen_controller.dart';
import '../../controllers/home_screen_controller.dart';
import '../../controllers/my_wallet_controller.dart';

import '../../utils/app_theme_data.dart';
import '../../utils/responsive.dart';
import '../../widgets/loader/shimmer_home_content.dart';
import 'category/product_by_category_screen.dart';

class HomeScreenGartoba extends StatefulWidget {
  const HomeScreenGartoba({Key? key}) : super(key: key);

  @override
  State<HomeScreenGartoba> createState() => _HomeScreenGartobaState();
}

class _HomeScreenGartobaState extends State<HomeScreenGartoba> {
  final DashboardController homeScreenController =
      Get.find<DashboardController>();

  final MyWalletController myWalletController = Get.put(MyWalletController());

  final homeScreenContentController = Get.find<HomeScreenController>();

  final detailsPageController = Get.lazyPut(
    () => DetailsPageController(),
    fenix: true,
  );

  Future<List<dynamic>> fetchCategories() async {
    final response = await http.get(Uri.parse(
        '${NetworkService.apiUrl}/category/all?lang=${LocalDataHelper().getLangCode() ?? "en"}'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final categories = jsonResponse['data']['categories'];
      List<dynamic> filteredCategories = [];

      for (var category in categories) {
        if (category['parent_id'] == 32) {
          filteredCategories.add(category);
        }
      }
      return filteredCategories;
    } else {
      fetchCategories();
      throw Exception('Failed to load categories');
    }
  }

  double _currentSliderValue = 50;
  String selectedOption = AppTags.all.tr;

  bool isContainerVisible = false;

  void toggleContainerVisibility() {
    setState(() {
      isContainerVisible = !isContainerVisible;
    });
  }

  void updateSliderValue(double value) {
    setState(() {
      _currentSliderValue = value;
    });
  }

  void updateFilter(String value) {
    setState(() {
      selectedOption = value;
    });
  }

  Future<void> popUp(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 100,
                  left: 80,
                  right: 5,
                  child: AlertDialog(
                    title: Text(
                      AppTags.filter.tr,
                      style: const TextStyle(fontFamily: 'bpg'),
                    ),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text(
                            AppTags.category.tr,
                            style: const TextStyle(fontFamily: 'bpg'),
                          ),
                          // Center(
                          //   child: DropdownButton<String>(
                          //     value: selectedOption,
                          //     onChanged: (String? newValue) {
                          //       setState(() {
                          //         updateFilter(newValue!);
                          //       });
                          //     },
                          //     items: <String>[
                          //       AppTags.all.tr,
                          //       AppTags.traditional.tr,
                          //       AppTags.sushi.tr,
                          //       AppTags.pizza.tr,
                          //       AppTags.seafood.tr,
                          //       AppTags.burgers.tr,
                          //       AppTags.asian.tr,
                          //       AppTags.bakery.tr,
                          //       AppTags.dessert.tr,
                          //       AppTags.mexican.tr,
                          //       AppTags.shawarma.tr,
                          //       AppTags.vegetarian.tr,
                          //     ].map<DropdownMenuItem<String>>((String value) {
                          //       return DropdownMenuItem<String>(
                          //         value: value,
                          //         child: Text(value),
                          //       );
                          //     }).toList(),
                          //   ),
                          // ),
                          Text(
                            AppTags.distanceMeter.tr,
                            style: const TextStyle(fontFamily: 'bpg'),
                          ),
                          Slider(
                            value: _currentSliderValue,
                            max: 500,
                            divisions: _currentSliderValue <= 10 ? 500 : 100,
                            activeColor: const Color.fromARGB(255, 221, 153, 6),
                            label: _currentSliderValue < 1
                                ? "${_currentSliderValue.toStringAsFixed(1)} ${AppTags.km.tr}"
                                : "${_currentSliderValue.round()} ${AppTags.km.tr}",
                            onChanged: (double value) {
                              setState(() {
                                updateSliderValue(value);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Close'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Obx(
      () => homeScreenContentController.homeDataModel.value.data != null
          ? Scaffold(
              // backgroundColor: Colors.white,
              extendBodyBehindAppBar: false,
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              appBar: isMobile(context)
                  ? AppBar(
                      leading: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Get.toNamed(Routes.dashboardScreen);
                        },
                      ),
                      backgroundColor: const Color.fromARGB(0, 252, 185, 0),
                      elevation: 0,
                      title: InkWell(
                        onTap: () {
                          Get.toNamed(Routes.searchProduct);
                        },
                        child: Container(
                          height: 40.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            color: Colors.grey.shade200,
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(11),
                                child: SvgPicture.asset(
                                  "assets/icons/search_bar.svg",
                                  color: Colors.black54,
                                ),
                              ),
                              SizedBox(width: 5,),
                              Text('პროდუქტის ძებნა', style: TextStyle(color: Colors.black54, fontSize: 13),),
                              SizedBox(width: 15,),
                              Padding(
                                padding: const EdgeInsets.all(9.0),
                                child: Image.asset('assets/logos/logo.png', width: 60,),
                              ),
                            ],
                          )
                        ),
                      ),
                actions: [
                  IconButton(
                    padding: EdgeInsets.all(4.r),
                    icon: SvgPicture.asset(
                      "assets/icons/search_bar.svg",
                      color: Colors.white,
                    ),
                    onPressed: () => Get.toNamed(Routes.searchProduct),
                  )
                ],
                    )
                  : AppBar(
                      backgroundColor: const Color(0xffFAB75A),
                      elevation: 0,
                      toolbarHeight: 60.h,
                      leadingWidth: 40.w,
                      // leading: Builder(
                      //   builder: (BuildContext context) {
                      //     return IconButton(
                      //       icon: SvgPicture.asset(
                      //         "assets/icons/menu_bar.svg",
                      //         height: 20.h,
                      //       ),
                      //       tooltip: MaterialLocalizations.of(context)
                      //           .openAppDrawerTooltip,
                      //       onPressed: () {
                      //         Scaffold.of(context).openDrawer();
                      //         homeScreenContentController
                      //             .isVisibleUpdate(false);
                      //       },
                      //     );
                      //   },
                      // ),
                      title: InkWell(
                        onTap: () {
                          Get.toNamed(Routes.searchProduct);
                        },
                        child: SizedBox(
                            //width: 2,
                            height: isMobile(context) ? 35.h : 35.h,
                            // decoration: BoxDecoration(
                            //   borderRadius: BorderRadius.circular(6.r),
                            //   color: Colors.white,
                            //   boxShadow: [
                            //     BoxShadow(
                            //       color: AppThemeData.boxShadowColor
                            //           .withOpacity(0.10),
                            //       spreadRadius: 0,
                            //       blurRadius: 5.r,
                            //       offset: const Offset(
                            //           0, 3), // changes position of shadow
                            //     ),
                            //   ],
                            // ),
                            child: Center(
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.w),
                                    child: SvgPicture.asset(
                                      "assets/icons/search_bar.svg",
                                      // ignore: deprecated_member_use
                                      color:
                                          const Color.fromARGB(255, 92, 92, 92),
                                      width: 18.w,
                                      height: 18.h,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.w, vertical: 8.h),
                                    child: const VerticalDivider(
                                      thickness: 2,
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.w),
                                    child: Text(AppTags.searchProduct.tr,
                                        style: AppThemeData.hintTextStyle_10Tab
                                            .copyWith(fontFamily: 'bpg')),
                                  )
                                ],
                              ),
                            )),
                      ),
                      actions: const [
                        // Padding(
                        //   padding: EdgeInsets.symmetric(horizontal: 18.w),
                        //   child: IconButton(
                        //     icon: SvgPicture.asset(
                        //       "assets/icons/_notification.svg",
                        //       height: 22.h,
                        //       width: 19.w,
                        //     ),
                        //     onPressed: () {
                        //       Get.toNamed(Routes.notificationContent);
                        //     },
                        //   ),
                        // ),
                      ],
                    ),
              body: Column(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: size.height,
                      width: double.infinity,
                      child:
                          NotificationListener<OverscrollIndicatorNotification>(
                        onNotification: (overscroll) {
                          overscroll
                              .disallowIndicator(); // This will prevent the overscroll glow effect
                          return false;
                        },
                        child: ListView.builder(
                          shrinkWrap: true,
                          //itemExtent: 2000,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: homeScreenContentController
                              .homeDataModel.value.data!.length,
                          itemBuilder: (context, index) {
                            return Obx(() => categoryCheck(
                                  homeScreenContentController
                                      .homeDataModel.value,
                                  index,
                                  context,
                                ));
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ))
          : const ShimmerHomeContent(),
    );
  }

  //Top Category
  double calculateDistance(lat1, lon1, lat2, lon2) {
    const p = 0.017453292519943295;
    const c = cos;
    final a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Popular Categories
  Widget categories(categoriesIndex, context) {
    MapProvider provider = Provider.of<MapProvider>(context, listen: false);

    List<dynamic> filteredCategories = [
      for (var category in homeScreenContentController
          .homeDataModel.value.data![categoriesIndex].categories!)
        if (category.parentId == 32) category,
    ];

    filteredCategories.sort((a, b) => calculateDistance(
            double.parse(a.latlong!.split(",")[0]),
            double.parse(a.latlong!.split(",")[1]),
            provider.position!.latitude,
            provider.position!.longitude)
        .compareTo(calculateDistance(
            double.parse(b.latlong!.split(",")[0]),
            double.parse(b.latlong!.split(",")[1]),
            provider.position!.latitude,
            provider.position!.longitude)));
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  AppTags.fun.tr,
                  style: isMobile(context)
                      ? AppThemeData.headerTextStyle.copyWith(
                          color: const Color.fromARGB(255, 53, 53, 53),
                          fontFamily: 'bpg')
                      : AppThemeData.headerTextStyleTab.copyWith(
                          color: const Color.fromARGB(255, 41, 41, 41),
                          fontFamily: 'bpg'),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      popUp(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color.fromARGB(255, 232, 232, 232),
                      ),
                      width: 37,
                      height: 37,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Image(
                            image: AssetImage("assets/images/filtersIcon.png")),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height - 170,
                width: MediaQuery.of(context).size.width - 50,
                child: ListView.builder(
                  // shrinkWrap: true,
                  padding: EdgeInsets.only(right: 1.w),
                  physics: const AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  primary: false,
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    var p = 0.017453292519943295;
                    var a = 0.5 -
                        cos((double.parse(filteredCategories[index].latlong!.split(",")[0]) -
                                    provider.position!.latitude) *
                                p) /
                            2 +
                        cos(provider.position!.latitude * p) *
                            cos(double.parse(filteredCategories[index]
                                    .latlong!
                                    .split(",")[0]) *
                                p) *
                            (1 -
                                cos((double.parse(filteredCategories[index]
                                            .latlong!
                                            .split(",")[1]) -
                                        provider.position!.longitude) *
                                    p)) /
                            2;
                    double location = 12742 * asin(sqrt(a));

                    return _currentSliderValue >= location &&
                            selectedOption == AppTags.all.tr
                        ? Center(
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.only(right: 0.w, left: 1.w),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ProductByCategory(
                                            id: filteredCategories[index].id,
                                            title:
                                                filteredCategories[index].title,
                                            imgurl: filteredCategories[index]
                                                .banner,
                                            number: filteredCategories[index]
                                                .number,
                                            soc_fb: filteredCategories[index]
                                                .soc_fb,
                                            soc_yt: filteredCategories[index]
                                                .soc_yt,
                                            soc_in: filteredCategories[index]
                                                .soc_in,
                                            category: AppTags.gartoba.tr,
                                            latlong: filteredCategories[index]
                                                .latlong,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Stack(
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 155,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(5)),
                                                  image: DecorationImage(
                                                      image: filteredCategories[
                                                                      index]
                                                                  .banner !=
                                                              null
                                                          ? NetworkImage(
                                                              filteredCategories[
                                                                      index]
                                                                  .banner!)
                                                          : const NetworkImage(
                                                              'https://www.streamingmedia.com/Images/ArticleImages/ArticleImage.14143.jpg'),
                                                      fit: BoxFit.cover)),
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(5)),
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          'assets/images/shadow.png'),
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                    )),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    children: [
                                                      const Spacer(),
                                                      Align(
                                                        alignment: Alignment
                                                            .bottomLeft,
                                                        child: Text(
                                                          filteredCategories[
                                                                  index]
                                                              .title!
                                                              .toString(),
                                                          maxLines: 15,
                                                          textAlign:
                                                              TextAlign.center,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: AppThemeData
                                                              .todayDealTitleStyle
                                                              .copyWith(
                                                                  fontFamily:
                                                                      'bpg',
                                                                  color: const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      255),
                                                                  fontSize: 19,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .bottomLeft,
                                                        child: Text(
                                                          AppTags.gartoba.tr,
                                                          maxLines: 14,
                                                          textAlign:
                                                              TextAlign.center,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: AppThemeData
                                                              .todayDealTitleStyle
                                                              .copyWith(
                                                                  fontFamily:
                                                                      'bpg',
                                                                  color: const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      209,
                                                                      209,
                                                                      209),
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 10,
                                              right: 10,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: const Color.fromARGB(
                                                        255, 255, 255, 255)),
                                                child: Text(
                                                    "${location.toStringAsFixed(2)} KM"),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _currentSliderValue >= location &&
                                selectedOption ==
                                    filteredCategories[index].category_filter
                            ? Center(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          right: 0.w, left: 1.w),
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => ProductByCategory(
                                                id: filteredCategories[index]
                                                    .id,
                                                title: filteredCategories[index]
                                                    .title,
                                                number:
                                                    filteredCategories[index]
                                                        .number,
                                                soc_fb:
                                                    filteredCategories[index]
                                                        .soc_fb,
                                                soc_in:
                                                    filteredCategories[index]
                                                        .soc_in,
                                                soc_yt:
                                                    filteredCategories[index]
                                                        .soc_yt,
                                                imgurl:
                                                    filteredCategories[index]
                                                        .banner,
                                                category: filteredCategories[index][
                                                                'category_filter'] ==
                                                            null ||
                                                        filteredCategories[index][
                                                                'category_filter'] ==
                                                            ''
                                                    ? ''
                                                    : filteredCategories[index][
                                                                'category_filter'] ==
                                                            AppTags
                                                                .traditional.tr
                                                        ? AppTags.traditional.tr
                                                        : filteredCategories[index]
                                                                    [
                                                                    'category_filter'] ==
                                                                AppTags.sushi.tr
                                                            ? AppTags.sushi.tr
                                                            : filteredCategories[index]
                                                                        ['category_filter'] ==
                                                                    AppTags.pizza.tr
                                                                ? AppTags.pizza.tr
                                                                : filteredCategories[index]['category_filter'] == AppTags.seafood.tr
                                                                    ? AppTags.seafood.tr
                                                                    : filteredCategories[index]['category_filter'] == AppTags.burgers.tr
                                                                        ? AppTags.burgers.tr
                                                                        : filteredCategories[index]['category_filter'] == AppTags.asian.tr
                                                                            ? AppTags.asian.tr
                                                                            : filteredCategories[index]['category_filter'] == AppTags.bakery.tr
                                                                                ? AppTags.bakery.tr
                                                                                : filteredCategories[index]['category_filter'] == AppTags.dessert.tr
                                                                                    ? AppTags.dessert.tr
                                                                                    : filteredCategories[index]['category_filter'] == AppTags.mexican.tr
                                                                                        ? AppTags.mexican.tr
                                                                                        : filteredCategories[index]['category_filter'] == AppTags.shawarma.tr
                                                                                            ? AppTags.shawarma.tr
                                                                                            : AppTags.vegetarian.tr,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          children: [
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Stack(
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: 155,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius
                                                                  .circular(5)),
                                                      image: DecorationImage(
                                                          image: filteredCategories[
                                                                          index]
                                                                      .banner !=
                                                                  null
                                                              ? NetworkImage(
                                                                  filteredCategories[
                                                                          index]
                                                                      .banner!)
                                                              : const NetworkImage(
                                                                  'https://www.streamingmedia.com/Images/ArticleImages/ArticleImage.14143.jpg'),
                                                          fit: BoxFit.cover)),
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5)),
                                                            image:
                                                                DecorationImage(
                                                              image: AssetImage(
                                                                  'assets/images/shadow.png'),
                                                              alignment: Alignment
                                                                  .bottomCenter,
                                                            )),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        children: [
                                                          const Spacer(),
                                                          Align(
                                                            alignment: Alignment
                                                                .bottomLeft,
                                                            child: Text(
                                                              filteredCategories[
                                                                      index]
                                                                  .title!
                                                                  .toString(),
                                                              maxLines: 15,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: AppThemeData
                                                                  .todayDealTitleStyle
                                                                  .copyWith(
                                                                      fontFamily:
                                                                          'bpg',
                                                                      color: const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          255,
                                                                          255,
                                                                          255),
                                                                      fontSize:
                                                                          19,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .bottomLeft,
                                                            child: Text(
                                                              filteredCategories[index][
                                                                              'category_filter'] ==
                                                                          null ||
                                                                      filteredCategories[index]
                                                                              [
                                                                              'category_filter'] ==
                                                                          ''
                                                                  ? ''
                                                                  : filteredCategories[index]
                                                                              [
                                                                              'category_filter'] ==
                                                                          AppTags
                                                                              .traditional
                                                                              .tr
                                                                      ? AppTags
                                                                          .traditional
                                                                          .tr
                                                                      : filteredCategories[index]['category_filter'] ==
                                                                              AppTags
                                                                                  .sushi.tr
                                                                          ? AppTags
                                                                              .sushi
                                                                              .tr
                                                                          : filteredCategories[index]['category_filter'] == AppTags.pizza.tr
                                                                              ? AppTags.pizza.tr
                                                                              : filteredCategories[index]['category_filter'] == AppTags.seafood.tr
                                                                                  ? AppTags.seafood.tr
                                                                                  : filteredCategories[index]['category_filter'] == AppTags.burgers.tr
                                                                                      ? AppTags.burgers.tr
                                                                                      : filteredCategories[index]['category_filter'] == AppTags.asian.tr
                                                                                          ? AppTags.asian.tr
                                                                                          : filteredCategories[index]['category_filter'] == AppTags.bakery.tr
                                                                                              ? AppTags.bakery.tr
                                                                                              : filteredCategories[index]['category_filter'] == AppTags.dessert.tr
                                                                                                  ? AppTags.dessert.tr
                                                                                                  : filteredCategories[index]['category_filter'] == AppTags.mexican.tr
                                                                                                      ? AppTags.mexican.tr
                                                                                                      : filteredCategories[index]['category_filter'] == AppTags.shawarma.tr
                                                                                                          ? AppTags.shawarma.tr
                                                                                                          : AppTags.vegetarian.tr,
                                                              maxLines: 14,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: AppThemeData
                                                                  .todayDealTitleStyle
                                                                  .copyWith(
                                                                      fontFamily:
                                                                          'bpg',
                                                                      color: const Color
                                                                          .fromARGB(
                                                                          255,
                                                                          209,
                                                                          209,
                                                                          209),
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 10,
                                                  right: 10,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 49, 49, 49)),
                                                    child: Text(
                                                        "${location.toStringAsFixed(2)} KM"),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container();
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            height: 1.h,
          ),
        ],
      ),
    );
  }

  categoryCheck(data_model.HomeDataModel data, index, context) {
    switch (data.data![index].sectionType) {
      // case "categories":
      //   return _categories(index, context);
      case 'benefits':
        return const SizedBox();
      case 'categories':
        return categories(index, context);
      // case 'banners':
      //   return banner(index, context);
      default:
        return const SizedBox();
    }
  }
}
