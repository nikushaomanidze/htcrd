import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hot_card/src/Providers/MapProvider.dart';
import 'package:hot_card/src/data/local_data_helper.dart';
import 'package:hot_card/src/models/home_data_model.dart' as data_model;
import 'package:hot_card/src/servers/network_service.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hot_card/src/utils/app_tags.dart';

import '../../_route/routes.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/details_screen_controller.dart';
import '../../controllers/home_screen_controller.dart';
import '../../controllers/my_wallet_controller.dart';
import '../../controllers/profile_content_controller.dart';
import '../../screen/news/all_news_screen.dart';

import '../../utils/app_theme_data.dart';
import '../../utils/responsive.dart';
import '../../widgets/loader/shimmer_home_content.dart';
import '../../widgets/product_card_widgets/home_product_card.dart';
import '../../widgets/shop_card_widget.dart';
import 'campaign/all_campaign_screen.dart';
import 'campaign/campaign_screen.dart';
import 'category/all_product_screen.dart';
import 'category/all_shop_screen.dart';
import 'category/best_selling_products_screen.dart';
import 'category/best_shop_screen.dart';
import 'category/flash_sales_screen.dart';
import 'category/offer_ending_product_screen.dart';
import 'category/product_by_brand_screen.dart';
import 'category/product_by_category_screen.dart';
import 'category/product_by_shop_screen.dart';
import 'category/recent_view_product_screen.dart';
import 'category/today_deals_screen.dart';
import 'category/top_shop_screen.dart';
import 'video_shopping/all_video_shopping.dart';

class HomeScreenCafeContent extends StatefulWidget {
  const HomeScreenCafeContent({Key? key}) : super(key: key);

  @override
  State<HomeScreenCafeContent> createState() => _HomeScreenCafeContentState();
}

class _HomeScreenCafeContentState extends State<HomeScreenCafeContent> {
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
                  left: 0,
                  right: 0,
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
                          Center(
                            child: DropdownButton<String>(
                              value: selectedOption,
                              onChanged: (String? newValue) {
                                setState(() {
                                  updateFilter(newValue!);
                                });
                              },
                              items: <String>[
                                AppTags.all.tr,
                                AppTags.traditional.tr,
                                AppTags.sushi.tr,
                                AppTags.pizza.tr,
                                AppTags.seafood.tr,
                                AppTags.burgers.tr,
                                AppTags.asian.tr,
                                AppTags.bakery.tr,
                                AppTags.dessert.tr,
                                AppTags.mexican.tr,
                                AppTags.shawarma.tr,
                                AppTags.vegetarian.tr,
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
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
  void initState() {
    super.initState();
    setState(() {

    });
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
                          physics: const BouncingScrollPhysics(),
                          itemCount: homeScreenContentController
                              .homeDataModel.value.data!.length,
                          scrollDirection: Axis.vertical,
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
  Widget popularCategories(popularCategoriesIndex, context) {
    MapProvider provider = Provider.of<MapProvider>(context, listen: false);

    homeScreenContentController
        .homeDataModel.value.data![popularCategoriesIndex].popularCategories!
        .sort((a, b) => calculateDistance(
                double.parse(a.latlong!.split(",")[0]),
                double.parse(a.latlong!.split(",")[1]),
                provider.position!.latitude,
                provider.position!.longitude)
            .compareTo(calculateDistance(
                double.parse(b.latlong!.split(",")[0]),
                double.parse(b.latlong!.split(",")[1]),
                provider.position!.latitude,
                provider.position!.longitude)));
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  AppTags.topBars.tr,
                  style: isMobile(context)
                      ? AppThemeData.headerTextStyle.copyWith(
                          color: const Color.fromARGB(255, 53, 53, 53),
                          fontFamily: 'bpg')
                      : AppThemeData.headerTextStyleTab.copyWith(
                          color: const Color.fromARGB(255, 41, 41, 41),
                          fontFamily: 'bpg'),
                ),
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
                    width: 37,
                    height: 37,
                    color: const Color.fromARGB(255, 232, 232, 232),
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
                padding: EdgeInsets.only(right: 1.w),
                physics: const AlwaysScrollableScrollPhysics(),
                primary: false,
                itemCount: homeScreenContentController.homeDataModel.value
                    .data![popularCategoriesIndex].popularCategories!.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  var p = 0.017453292519943295;
                  var a = 0.5 -
                      cos((double.parse(homeScreenContentController.homeDataModel.value.data![popularCategoriesIndex].popularCategories![index].latlong!.split(",")[0]) - provider.position!.latitude) * p) /
                          2 +
                      cos(provider.position!.latitude * p) *
                          cos(double.parse(homeScreenContentController
                                  .homeDataModel
                                  .value
                                  .data![popularCategoriesIndex]
                                  .popularCategories![index]
                                  .latlong!
                                  .split(",")[0]) *
                              p) *
                          (1 -
                              cos((double.parse(homeScreenContentController
                                          .homeDataModel
                                          .value
                                          .data![popularCategoriesIndex]
                                          .popularCategories![index]
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
                                padding: EdgeInsets.only(right: 0.w, left: 1.w),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ProductByCategory(
                                          id: homeScreenContentController
                                              .homeDataModel
                                              .value
                                              .data![popularCategoriesIndex]
                                              .popularCategories![index]
                                              .id,
                                          title: homeScreenContentController
                                              .homeDataModel
                                              .value
                                              .data![popularCategoriesIndex]
                                              .popularCategories![index]
                                              .title,
                                          imgurl: homeScreenContentController
                                              .homeDataModel
                                              .value
                                              .data![popularCategoriesIndex]
                                              .popularCategories![index]
                                              .banner,
                                          number: homeScreenContentController
                                              .homeDataModel
                                              .value
                                              .data![popularCategoriesIndex]
                                              .popularCategories![index]
                                              .number,
                                          soc_fb: homeScreenContentController
                                              .homeDataModel
                                              .value
                                              .data![popularCategoriesIndex]
                                              .popularCategories![index]
                                              .soc_fb,
                                          soc_yt: homeScreenContentController
                                              .homeDataModel
                                              .value
                                              .data![popularCategoriesIndex]
                                              .popularCategories![index]
                                              .soc_yt,
                                          soc_in: homeScreenContentController
                                              .homeDataModel
                                              .value
                                              .data![popularCategoriesIndex]
                                              .popularCategories![index]
                                              .soc_in,
                                          category: homeScreenContentController
                                                          .homeDataModel
                                                          .value
                                                          .data![
                                                              popularCategoriesIndex]
                                                          .popularCategories![
                                                              index]
                                                          .category_filter ==
                                                      null ||
                                                  homeScreenContentController
                                                          .homeDataModel
                                                          .value
                                                          .data![
                                                              popularCategoriesIndex]
                                                          .popularCategories![
                                                              index]
                                                          .category_filter ==
                                                      ''
                                              ? ''
                                              : homeScreenContentController.homeDataModel.value.data![popularCategoriesIndex].popularCategories![index].category_filter ==
                                                      AppTags.traditional.tr
                                                  ? AppTags.traditional.tr
                                                  : homeScreenContentController.homeDataModel.value.data![popularCategoriesIndex].popularCategories![index].category_filter ==
                                                          AppTags.sushi.tr
                                                      ? AppTags.sushi.tr
                                                      : homeScreenContentController
                                                                  .homeDataModel
                                                                  .value
                                                                  .data![
                                                                      popularCategoriesIndex]
                                                                  .popularCategories![index]
                                                                  .category_filter ==
                                                              AppTags.pizza.tr
                                                          ? AppTags.pizza.tr
                                                          : homeScreenContentController.homeDataModel.value.data![popularCategoriesIndex].popularCategories![index].category_filter == AppTags.seafood.tr
                                                              ? AppTags.seafood.tr
                                                              : homeScreenContentController.homeDataModel.value.data![popularCategoriesIndex].popularCategories![index].category_filter == AppTags.burgers.tr
                                                                  ? AppTags.burgers.tr
                                                                  : homeScreenContentController.homeDataModel.value.data![popularCategoriesIndex].popularCategories![index].category_filter == AppTags.asian.tr
                                                                      ? AppTags.asian.tr
                                                                      : homeScreenContentController.homeDataModel.value.data![popularCategoriesIndex].popularCategories![index].category_filter == AppTags.bakery.tr
                                                                          ? AppTags.bakery.tr
                                                                          : homeScreenContentController.homeDataModel.value.data![popularCategoriesIndex].popularCategories![index].category_filter == AppTags.dessert.tr
                                                                              ? AppTags.dessert.tr
                                                                              : homeScreenContentController.homeDataModel.value.data![popularCategoriesIndex].popularCategories![index].category_filter == AppTags.mexican.tr
                                                                                  ? AppTags.mexican.tr
                                                                                  : homeScreenContentController.homeDataModel.value.data![popularCategoriesIndex].popularCategories![index].category_filter == AppTags.shawarma.tr
                                                                                      ? AppTags.shawarma.tr
                                                                                      : AppTags.vegetarian.tr,
                                          latlong: homeScreenContentController
                                              .homeDataModel
                                              .value
                                              .data![popularCategoriesIndex]
                                              .popularCategories![index]
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
                                                    image: homeScreenContentController
                                                                .homeDataModel
                                                                .value
                                                                .data![
                                                                    popularCategoriesIndex]
                                                                .popularCategories![
                                                                    index]
                                                                .banner !=
                                                            null
                                                        ? NetworkImage(
                                                            homeScreenContentController
                                                                .homeDataModel
                                                                .value
                                                                .data![
                                                                    popularCategoriesIndex]
                                                                .popularCategories![
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
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                  )),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [
                                                    const Spacer(),
                                                    Align(
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      child: Text(
                                                        homeScreenContentController
                                                            .homeDataModel
                                                            .value
                                                            .data![
                                                                popularCategoriesIndex]
                                                            .popularCategories![
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
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      child: Text(
                                                        homeScreenContentController
                                                            .homeDataModel
                                                            .value
                                                            .data![
                                                                popularCategoriesIndex]
                                                            .popularCategories![
                                                                index]
                                                            .category_filter!
                                                            .toString(),
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
                                                      BorderRadius.circular(10),
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
                                  homeScreenContentController
                                      .homeDataModel
                                      .value
                                      .data![popularCategoriesIndex]
                                      .popularCategories![index]
                                      .category_filter
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
                                              id: homeScreenContentController
                                                  .homeDataModel
                                                  .value
                                                  .data![popularCategoriesIndex]
                                                  .popularCategories![index]
                                                  .id,
                                              title: homeScreenContentController
                                                  .homeDataModel
                                                  .value
                                                  .data![popularCategoriesIndex]
                                                  .popularCategories![index]
                                                  .title,
                                              number: homeScreenContentController
                                                  .homeDataModel
                                                  .value
                                                  .data![popularCategoriesIndex]
                                                  .popularCategories![index]
                                                  .number,
                                              soc_fb: homeScreenContentController
                                                  .homeDataModel
                                                  .value
                                                  .data![popularCategoriesIndex]
                                                  .popularCategories![index]
                                                  .soc_fb,
                                              soc_yt: homeScreenContentController
                                                  .homeDataModel
                                                  .value
                                                  .data![popularCategoriesIndex]
                                                  .popularCategories![index]
                                                  .soc_yt,
                                              soc_in: homeScreenContentController
                                                  .homeDataModel
                                                  .value
                                                  .data![popularCategoriesIndex]
                                                  .popularCategories![index]
                                                  .soc_in,
                                              latlong:
                                                  homeScreenContentController
                                                      .homeDataModel
                                                      .value
                                                      .data![
                                                          popularCategoriesIndex]
                                                      .popularCategories![index]
                                                      .latlong,
                                              imgurl: homeScreenContentController
                                                  .homeDataModel
                                                  .value
                                                  .data![popularCategoriesIndex]
                                                  .popularCategories![index]
                                                  .banner,
                                              category:
                                                  homeScreenContentController
                                                      .homeDataModel
                                                      .value
                                                      .data![
                                                          popularCategoriesIndex]
                                                      .popularCategories![index]
                                                      .category_filter,
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
                                                    borderRadius: const BorderRadius.all(
                                                        Radius.circular(5)),
                                                    image: DecorationImage(
                                                        image: homeScreenContentController
                                                                    .homeDataModel
                                                                    .value
                                                                    .data![
                                                                        popularCategoriesIndex]
                                                                    .popularCategories![
                                                                        index]
                                                                    .banner !=
                                                                null
                                                            ? NetworkImage(homeScreenContentController
                                                                .homeDataModel
                                                                .value
                                                                .data![
                                                                    popularCategoriesIndex]
                                                                .popularCategories![
                                                                    index]
                                                                .banner!)
                                                            : const NetworkImage(
                                                                'https://www.streamingmedia.com/Images/ArticleImages/ArticleImage.14143.jpg'),
                                                        fit: BoxFit.cover)),
                                                child: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
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
                                                            homeScreenContentController
                                                                .homeDataModel
                                                                .value
                                                                .data![
                                                                    popularCategoriesIndex]
                                                                .popularCategories![
                                                                    index]
                                                                .title!
                                                                .toString(),
                                                            maxLines: 15,
                                                            textAlign: TextAlign
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
                                                            homeScreenContentController
                                                                .homeDataModel
                                                                .value
                                                                .data![
                                                                    popularCategoriesIndex]
                                                                .popularCategories![
                                                                    index]
                                                                .category_filter!
                                                                .toString(),
                                                            maxLines: 14,
                                                            textAlign: TextAlign
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
                                                          BorderRadius.circular(
                                                              10),
                                                      color:
                                                          const Color.fromARGB(
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
    );
  }

  // Categories
  Widget popularBrands(brandIndex, context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15.0.w),
              child: Text(
                AppTags.popularBrands.tr,
                style: isMobile(context)
                    ? AppThemeData.headerTextStyle.copyWith(fontFamily: 'bpg')
                    : AppThemeData.headerTextStyleTab,
              ),
            ),
            InkWell(
              onTap: () {
                Get.toNamed(Routes.allBrand);
              },
              child: Padding(
                padding: EdgeInsets.all(15.r),
                child: SvgPicture.asset(
                  "assets/icons/more.svg",
                  height: 4.h,
                  width: 18.w,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: isMobile(context) ? 0.h : 8.h,
        ),
        SizedBox(
          height: 120.h,
          child: ListView.builder(
            padding: EdgeInsets.only(left: 15.w, bottom: 15.h),
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: homeScreenContentController
                .homeDataModel.value.data![brandIndex].popularBrands!.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 15.w),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProductByBrand(
                          id: homeScreenContentController.homeDataModel.value
                              .data![brandIndex].popularBrands![index].id!,
                          title: homeScreenContentController.homeDataModel.value
                              .data![brandIndex].popularBrands![index].title!,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 110.h,
                    width: isMobile(context) ? 110.w : 70.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppThemeData.boxShadowColor.withOpacity(0.05),
                          spreadRadius: 0,
                          blurRadius: 30.r,
                          offset:
                              const Offset(0, 15), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8.r),
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: homeScreenContentController
                              .homeDataModel
                              .value
                              .data![brandIndex]
                              .popularBrands![index]
                              .thumbnail!,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  //Slider
  Widget slider(sliderIndex, context) {
    return homeScreenContentController
            .homeDataModel.value.data![sliderIndex].slider!.isEmpty
        ? const SizedBox()
        : Stack(
            children: [
              CarouselSlider(
                carouselController: homeScreenContentController.controller,
                options: CarouselOptions(
                  onPageChanged: (index, reason) {
                    homeScreenContentController.currentUpdate(index);
                  },
                  height: isMobile(context) ? 140.h : 150.h,
                  autoPlayInterval: const Duration(seconds: 6),
                  viewportFraction: isMobile(context) ? 0.92 : 0.58,
                  aspectRatio: 16 / 9,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                  autoPlay: true,
                ),
                items: homeScreenContentController
                    .homeDataModel.value.data![sliderIndex].slider!
                    .map(
                      (item) => Container(
                        //height:100,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(0.0),
                        child: Stack(
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                if (item.actionType == "product") {
                                  Get.toNamed(
                                    Routes.detailsPage,
                                    parameters: {
                                      'productId': item.id!.toString(),
                                    },
                                  );
                                } else if (item.actionType == "category") {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProductByCategory(
                                        id: item.id!,
                                        title: item.title.toString(),
                                        imgurl: item.banner.toString(),
                                      ),
                                    ),
                                  );
                                } else if (item.actionType == "brand") {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProductByBrand(
                                        id: item.id!,
                                        title: "Brand",
                                      ),
                                    ),
                                  );
                                } else if (item.actionType == "seller") {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ProductByShop(
                                        id: item.id!,
                                        shopName: "Shop",
                                      ),
                                    ),
                                  );
                                } else if (item.actionType == "url") {
                                  Get.toNamed(
                                    Routes.wvScreen,
                                    parameters: {
                                      'url': item.actionTo.toString(),
                                      'title': "",
                                    },
                                  );
                                } else if (item.actionType == "blog") {
                                  Get.toNamed(
                                    Routes.newsScreen,
                                    parameters: {
                                      'title': item.title.toString(),
                                      'url': item.url.toString(),
                                      'image': item.backgroundImage.toString(),
                                    },
                                  );
                                }
                              },
                              child: SizedBox(
                                height: 140.h,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.r),
                                  child: CachedNetworkImage(
                                    imageUrl: item.banner!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
              Positioned(
                bottom: isMobile(context) ? 0.h : 5.h,
                left: 0.w,
                right: 0.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: homeScreenContentController
                      .homeDataModel.value.data![sliderIndex].slider!
                      .asMap()
                      .entries
                      .map(
                    (entry) {
                      return GestureDetector(
                        onTap: () {
                          homeScreenContentController.controller
                              .animateToPage(entry.key);
                          homeScreenContentController.currentUpdate(entry.key);
                        },
                        child: Obx(
                          () => Container(
                            width: homeScreenContentController.current.value ==
                                    entry.key
                                ? 20.0.w
                                : 10.w,
                            height: 3.0.h,
                            margin: EdgeInsets.symmetric(
                                vertical: 8.h, horizontal: 4.w),
                            decoration: BoxDecoration(
                              //shape: BoxShape.circle,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.r)),
                              color:
                                  homeScreenContentController.current.value ==
                                          entry.key
                                      ? const Color(0xff333333)
                                      : const Color(0xff999999),
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                ),
              ),
            ],
          );
  }

  //Banner
  Widget banner(bannerIndex, context) {
    final ProfileContentController profileContentController =
        Get.put(ProfileContentController());
    return Padding(
      padding: EdgeInsets.only(top: isMobile(context) ? 2.h : 30.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: isMobile(context) ? 120.h : 140.h,
            width: 350,
            child: Container(
              decoration: const BoxDecoration(
                  color: Color(0xff67904c),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(70),
                      bottomRight: Radius.circular(70),
                      topLeft: Radius.circular(70),
                      topRight: Radius.circular(70))),
              child: Center(
                child:
                    profileContentController.profileDataModel.value.data != null
                        ? FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              // ignore: prefer_interpolation_to_compose_strings
                              myWalletController.myWalletModel.value.data!
                                          .balance!.balance !=
                                      null
                                  ? '${AppTags.totallySaved} ${myWalletController.myWalletModel.value.data!.balance!.balance} ₾'
                                  : '${AppTags.totallySaved} 0 ₾',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'bpg'),
                            ))
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              AppTags.authorization.tr,
                              maxLines: 2,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'bpg'),
                            ),
                          ),
              ),
            ),
          ),
          SizedBox(height: 14.h),
        ],
      ),
    );
  }

  //Category Banner
  Widget categorySecBanner(catSecIndex, context) {
    return SizedBox(
        height: 100.h,
        child: Padding(
          padding:
              EdgeInsets.only(left: 16.w, right: 16.w, top: 10.h, bottom: 10.h),
          child: Container(
            width: MediaQuery.of(context).size.width - 30,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  homeScreenContentController
                      .homeDataModel.value.data![catSecIndex].categorySecBanner
                      .toString(),
                ),
              ),
              borderRadius: BorderRadius.all(Radius.circular(8.r)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppThemeData.boxShadowColor.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10.r,
                  offset: const Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
          ),
        ));
  }

  //Offer Ending Banner
  Widget offerEndingBanner(offerEndingIndex, context) {
    return SizedBox(
      height: 100.h,
      child: Padding(
        padding:
            EdgeInsets.only(left: 16.w, right: 16.w, top: 10.h, bottom: 10.h),
        child: Container(
          width: MediaQuery.of(context).size.width - 30,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(
                homeScreenContentController
                    .homeDataModel.value.data![offerEndingIndex].offerEnding
                    .toString(),
              ),
            ),
            borderRadius: BorderRadius.all(Radius.circular(8.r)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppThemeData.boxShadowColor.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 10.r,
                offset: const Offset(0, 2), // changes position of shadow
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Campaign
  Widget campaign(campaignIndex, context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: Text(
                AppTags.campaign.tr,
                style: isMobile(context)
                    ? AppThemeData.headerTextStyle
                    : AppThemeData.headerTextStyleTab,
              ),
            ),
            InkWell(
              onTap: () {
                Get.to(() => const AllCampaign());
              },
              child: Padding(
                padding: EdgeInsets.all(15.r),
                child: SvgPicture.asset(
                  "assets/icons/more.svg",
                  height: 4.h,
                  width: 18.w,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        SizedBox(
          height: isMobile(context) ? 100.h : 120.h,
          child: ListView.builder(
            padding: EdgeInsets.only(right: 15.w),
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: homeScreenContentController
                .homeDataModel.value.data![campaignIndex].campaigns!.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CampaignContentScreen(
                        campainId: homeScreenContentController.homeDataModel
                            .value.data![campaignIndex].campaigns![index].id!,
                        title: homeScreenContentController.homeDataModel.value
                            .data![campaignIndex].campaigns![index].title!,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 15.w),
                  child: Container(
                    width: isMobile(context) ? 165.w : 140.w,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: CachedNetworkImageProvider(
                          homeScreenContentController.homeDataModel.value
                              .data![campaignIndex].campaigns![index].banner!
                              .toString(),
                        ),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(8.r)),
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 14.h),
      ],
    );
  }

  // Featured Shop
  Widget featuredShop(featureShopIndex, context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: Text(
                AppTags.featuredShop.tr,
                style: isMobile(context)
                    ? AppThemeData.headerTextStyle
                    : AppThemeData.headerTextStyleTab,
              ),
            ),
            InkWell(
              onTap: () {
                Get.to(() => const AllShop());
              },
              child: Padding(
                padding: EdgeInsets.all(15.r),
                child: SvgPicture.asset(
                  "assets/icons/more.svg",
                  height: 4.h,
                  width: 18.w,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: isMobile(context) ? 230.h : 260.h,
          child: ListView.builder(
            padding: EdgeInsets.only(right: 15.w),
            itemCount: homeScreenContentController.homeDataModel.value
                .data![featureShopIndex].featuredShops!.length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Get.toNamed(
                    Routes.shopScreen,
                    parameters: {
                      'shopId': homeScreenContentController.homeDataModel.value
                          .data![featureShopIndex].featuredShops![index].id!
                          .toString(),
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 0.w, left: 15.w),
                  child: ShopCardWidget(
                    shop: homeScreenContentController.homeDataModel.value
                        .data![featureShopIndex].featuredShops![index],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  //Express Shop
  Widget expressShop(expressShopIndex, context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: Text(
                AppTags.expressShop.tr,
                style: isMobile(context)
                    ? AppThemeData.headerTextStyle
                    : AppThemeData.headerTextStyleTab,
              ),
            ),
            InkWell(
              onTap: () {
                Get.to(() => const AllShop());
              },
              child: Padding(
                padding: EdgeInsets.all(15.r),
                child: SvgPicture.asset(
                  "assets/icons/more.svg",
                  height: 4.h,
                  width: 18.w,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: isMobile(context) ? 230.h : 260.h,
          child: ListView.builder(
            padding: EdgeInsets.only(right: 15.w),
            itemCount: homeScreenContentController.homeDataModel.value
                .data![expressShopIndex].expressShops!.length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Get.toNamed(
                    Routes.shopScreen,
                    parameters: {
                      'shopId': homeScreenContentController.homeDataModel.value
                          .data![expressShopIndex].expressShops![index].id!
                          .toString(),
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 0.w, left: 15.w),
                  child: ShopCardWidget(
                    shop: homeScreenContentController.homeDataModel.value
                        .data![expressShopIndex].expressShops![index],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Best Shop
  Widget bestShop(bestShopIndex, context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: Text(
                AppTags.bestShop.tr,
                style: isMobile(context)
                    ? AppThemeData.headerTextStyle
                    : AppThemeData.headerTextStyleTab,
              ),
            ),
            InkWell(
              onTap: () {
                Get.to(() => const BestShop());
              },
              child: Padding(
                padding: EdgeInsets.all(15.r),
                child: SvgPicture.asset(
                  "assets/icons/more.svg",
                  height: 4.h,
                  width: 18.w,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: isMobile(context) ? 230.h : 260.h,
          child: ListView.builder(
            padding: EdgeInsets.only(right: 15.w),
            itemCount: homeScreenContentController
                .homeDataModel.value.data![bestShopIndex].bestShops!.length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Get.toNamed(
                    Routes.shopScreen,
                    parameters: {
                      'shopId': homeScreenContentController.homeDataModel.value
                          .data![bestShopIndex].bestShops![index].id!
                          .toString(),
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 15.w),
                  child: ShopCardWidget(
                    shop: homeScreenContentController.homeDataModel.value
                        .data![bestShopIndex].bestShops![index],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  //Top Shop
  Widget topShop(sellersIndex, context) {
    return Column(
      children: [
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: Text(
                AppTags.topShop.tr,
                style: isMobile(context)
                    ? AppThemeData.headerTextStyle
                    : AppThemeData.headerTextStyleTab,
              ),
            ),
            InkWell(
              onTap: () {
                Get.to(() => const TopShop());
              },
              child: Padding(
                padding: EdgeInsets.all(15.r),
                child: SvgPicture.asset(
                  "assets/icons/more.svg",
                  height: 4.h,
                  width: 18.w,
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: isMobile(context) ? 230.h : 260.h,
          child: ListView.builder(
            padding: EdgeInsets.only(right: 15.w),
            itemCount: homeScreenContentController
                .homeDataModel.value.data![sellersIndex].topShops!.length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Get.toNamed(
                    Routes.shopScreen,
                    parameters: {
                      'shopId': homeScreenContentController.homeDataModel.value
                          .data![sellersIndex].topShops![index].id!
                          .toString(),
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 0.w, left: 15.w),
                  child: ShopCardWidget(
                    shop: homeScreenContentController.homeDataModel.value
                        .data![sellersIndex].topShops![index],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  //Latest News
  Widget latestNews(latestNewsIndex, context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Get.to(AllNews());
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 15.w),
                child: Text(
                  AppTags.latestNews.tr,
                  style: isMobile(context)
                      ? AppThemeData.headerTextStyle
                      : AppThemeData.headerTextStyleTab,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15.r),
                child: SvgPicture.asset(
                  "assets/icons/more.svg",
                  height: 4.h,
                  width: 18.w,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220.h,
          child: ListView.builder(
            padding: EdgeInsets.only(right: 15.w),
            itemCount: homeScreenContentController
                .homeDataModel.value.data![latestNewsIndex].latestNews!.length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Get.toNamed(
                    Routes.newsScreen,
                    parameters: {
                      'title': homeScreenContentController.homeDataModel.value
                          .data![latestNewsIndex].latestNews![index].title!,
                      'url': homeScreenContentController.homeDataModel.value
                          .data![latestNewsIndex].latestNews![index].url!,
                      'image': homeScreenContentController.homeDataModel.value
                          .data![latestNewsIndex].latestNews![index].thumbnail!
                    },
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 0.w, left: 15.w),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 200.h,
                        width: isMobile(context) ? 165.w : 130.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(7.r)),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppThemeData.boxShadowColor.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 10.r,
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                      homeScreenContentController
                                          .homeDataModel
                                          .value
                                          .data![latestNewsIndex]
                                          .latestNews![index]
                                          .thumbnail!,
                                    ),
                                  ),
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10)),
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 4.w, bottom: 4.h, top: 4.h),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      homeScreenContentController
                                          .homeDataModel
                                          .value
                                          .data![latestNewsIndex]
                                          .latestNews![index]
                                          .title!,
                                      style: isMobile(context)
                                          ? AppThemeData.titleTextStyle_14
                                          : AppThemeData.titleTextStyle_11Tab,
                                      maxLines: 1,
                                    ),
                                    SizedBox(
                                      height: 4.h,
                                    ),
                                    Text(
                                      homeScreenContentController
                                          .homeDataModel
                                          .value
                                          .data![latestNewsIndex]
                                          .latestNews![index]
                                          .shortDescription!,
                                      style: isMobile(context)
                                          ? AppThemeData.qsTextStyle_12
                                          : AppThemeData.qsTextStyle_9Tab,
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  //Today Deal
  Widget todayDeal(todayDealIndex, context) {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    String time = "24:00:00";
    String date = "$formattedDate $time";
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 15.0.w),
                  child: Text(
                    AppTags.todayDeal.tr,
                    style: isMobile(context)
                        ? AppThemeData.headerTextStyle
                        : AppThemeData.headerTextStyleTab,
                  ),
                ),
                SizedBox(
                  width: 10.w,
                ),
                CountdownTimer(
                  endTime: DateTime.now().millisecondsSinceEpoch +
                      DateTime.parse(date)
                          .difference(DateTime.now())
                          .inMilliseconds,
                  widgetBuilder: (_, time) {
                    if (time == null) {
                      return Center(
                        child: Text(
                          'Over',
                          style: isMobile(context)
                              ? AppThemeData.timeDateTextStyle_12
                              : AppThemeData.timeDateTextStyleTab,
                        ),
                      );
                    } else {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: isMobile(context) ? 30.w : 20.w,
                            height: isMobile(context) ? 20.h : 23.h,
                            decoration: BoxDecoration(
                              color: const Color(0xff333333),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  spreadRadius: 30.r,
                                  blurRadius: 5.r,
                                  color: AppThemeData.boxShadowColor
                                      .withOpacity(0.01),
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "${time.hours ?? 0}".padLeft(2, '0'),
                                style: isMobile(context)
                                    ? AppThemeData.timeDateTextStyle_12
                                    : AppThemeData.timeDateTextStyleTab,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          Container(
                            width: isMobile(context) ? 30.w : 20.w,
                            height: isMobile(context) ? 20.h : 23.h,
                            decoration: BoxDecoration(
                              color: const Color(0xff333333),
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.r),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  spreadRadius: 30.r,
                                  blurRadius: 5.r,
                                  color: AppThemeData.boxShadowColor
                                      .withOpacity(0.01),
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "${time.min ?? 0}".padLeft(2, '0'),
                                style: isMobile(context)
                                    ? AppThemeData.timeDateTextStyle_12
                                    : AppThemeData.timeDateTextStyleTab,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          Container(
                            width: isMobile(context) ? 30.w : 20.w,
                            height: isMobile(context) ? 20.h : 23.h,
                            decoration: BoxDecoration(
                              color: const Color(0xff333333),
                              borderRadius: BorderRadius.all(
                                Radius.circular(5.r),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  spreadRadius: 30.r,
                                  blurRadius: 5.r,
                                  color: AppThemeData.boxShadowColor
                                      .withOpacity(0.01),
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "${time.sec ?? 0}".padLeft(2, '0'),
                                style: isMobile(context)
                                    ? AppThemeData.timeDateTextStyle_12
                                    : AppThemeData.timeDateTextStyleTab,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                )
              ],
            ),
            InkWell(
              onTap: () {
                Get.to(() => const TodayDeal());
              },
              child: Padding(
                padding: EdgeInsets.all(15.r),
                child: SvgPicture.asset(
                  "assets/icons/more.svg",
                  height: 4.h,
                  width: 18.w,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: isMobile(context) ? 0.h : 8.h,
        ),
        SizedBox(
          height: 255.h,
          child: ListView.builder(
            padding: EdgeInsets.only(right: 15.w),
            itemCount: homeScreenContentController
                .homeDataModel.value.data![todayDealIndex].todayDeals!.length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(left: 15.w),
                child: HomeProductCard(
                  dataModel: homeScreenContentController
                      .homeDataModel.value.data![todayDealIndex].todayDeals,
                  index: index,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  //Offer Ending
  Widget offerEnding(offerEndingIndex, context) {
    return Column(
      children: [
        const SizedBox(
          height: 0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15.0.w),
              child: Text(
                AppTags.offerEnding.tr,
                style: isMobile(context)
                    ? AppThemeData.headerTextStyle
                    : AppThemeData.headerTextStyleTab,
              ),
            ),
            InkWell(
              onTap: () {
                Get.to(() => const OfferEndingProductsView());
              },
              child: Padding(
                padding: EdgeInsets.all(15.r),
                child: SvgPicture.asset(
                  "assets/icons/more.svg",
                  height: 4.h,
                  width: 18.w,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 255.h,
          child: ListView.builder(
            padding: EdgeInsets.only(right: 15.w),
            itemCount: homeScreenContentController.homeDataModel.value
                .data![offerEndingIndex].offerEnding!.length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(left: 15.w),
                child: Column(
                  children: [
                    HomeProductCard(
                      dataModel: homeScreenContentController.homeDataModel.value
                          .data![offerEndingIndex].offerEnding,
                      index: index,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  //Flash Sale
  Widget flashSale(flashProductsIndex, context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: Text(
                AppTags.flashSale.tr,
                style: isMobile(context)
                    ? AppThemeData.headerTextStyle
                    : AppThemeData.headerTextStyleTab,
              ),
            ),
            InkWell(
              onTap: () {
                Get.to(() => const FlashSales());
              },
              child: Padding(
                padding: EdgeInsets.all(15.0.r),
                child: SvgPicture.asset(
                  "assets/icons/more.svg",
                  height: 4.h,
                  width: 18.w,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        SizedBox(
          height: 255.h,
          child: ListView.builder(
            padding: EdgeInsets.only(right: 15.w),
            itemCount: homeScreenContentController.homeDataModel.value
                        .data![flashProductsIndex].flashDeals !=
                    null
                ? homeScreenContentController.homeDataModel.value
                    .data![flashProductsIndex].flashDeals!.length
                : 0,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 0.w, left: 15.w),
                child: Column(
                  children: [
                    HomeProductCard(
                      dataModel: homeScreenContentController.homeDataModel.value
                          .data![flashProductsIndex].flashDeals,
                      index: index,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  //Recent Product
  Widget recentViewProducts(recentViewProductsIndex, context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: Text(
                AppTags.recentView.tr,
                style: isMobile(context)
                    ? AppThemeData.headerTextStyle
                    : AppThemeData.headerTextStyleTab,
              ),
            ),
            InkWell(
              onTap: () {
                Get.to(() => const RecentViewProduct());
              },
              child: Padding(
                padding: EdgeInsets.all(15.r),
                child: SvgPicture.asset(
                  "assets/icons/more.svg",
                  height: 4.h,
                  width: 18.w,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        SizedBox(
          height: 255.h,
          child: ListView.builder(
            padding: EdgeInsets.only(right: 15.w),
            itemCount: homeScreenContentController.homeDataModel.value
                .data![recentViewProductsIndex].recentViewedProduct!.length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(left: 15.w),
                child: Column(
                  children: [
                    HomeProductCard(
                      dataModel: homeScreenContentController.homeDataModel.value
                          .data![recentViewProductsIndex].recentViewedProduct,
                      index: index,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  //Custom Product
  Widget customProducts(customIndex, context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: Text(
                AppTags.customProduct.tr,
                style: isMobile(context)
                    ? AppThemeData.headerTextStyle
                    : AppThemeData.headerTextStyleTab,
              ),
            ),
            InkWell(
              onTap: () {
                Get.to(() => const AllProductView());
              },
              child: Padding(
                padding: EdgeInsets.all(15.r),
                child: SvgPicture.asset(
                  "assets/icons/more.svg",
                  height: 4.h,
                  width: 18.w,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        SizedBox(
          height: 255.h,
          child: ListView.builder(
            padding: EdgeInsets.only(right: 15.w),
            itemCount: homeScreenContentController
                .homeDataModel.value.data![customIndex].customProducts!.length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(left: 15.w),
                child: Column(
                  children: [
                    HomeProductCard(
                      dataModel: homeScreenContentController.homeDataModel.value
                          .data![customIndex].customProducts,
                      index: index,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  //Latest Product
  Widget latestProducts(latestProductsIndex, context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15.0.w),
              child: Text(
                AppTags.latestProducts.tr,
                style: isMobile(context)
                    ? AppThemeData.headerTextStyle
                    : AppThemeData.headerTextStyleTab,
              ),
            ),
            InkWell(
              onTap: () {
                Get.to(() => const AllProductView());
              },
              child: Padding(
                padding: EdgeInsets.all(15.r),
                child: SvgPicture.asset(
                  "assets/icons/more.svg",
                  height: 4.h,
                  width: 18.w,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        SizedBox(
          height: 255.h,
          child: ListView.builder(
            padding: EdgeInsets.only(right: 15.w),
            itemCount: homeScreenContentController.homeDataModel.value
                .data![latestProductsIndex].latestProducts!.length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(left: 15.w),
                child: Column(
                  children: [
                    HomeProductCard(
                      dataModel: homeScreenContentController.homeDataModel.value
                          .data![latestProductsIndex].latestProducts,
                      index: index,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  //Best Selling Product
  Widget bestSellingProduct(bestSellingProductIndex, context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: Text(
                AppTags.bestSellingProducts.tr,
                style: isMobile(context)
                    ? AppThemeData.headerTextStyle
                    : AppThemeData.headerTextStyleTab,
              ),
            ),
            InkWell(
              onTap: () {
                Get.to(() => const BestSellingProductsView());
              },
              child: Padding(
                padding: EdgeInsets.all(15.r),
                child: SvgPicture.asset(
                  "assets/icons/more.svg",
                  height: 4.h,
                  width: 18.w,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        SizedBox(
          height: 255.h,
          child: ListView.builder(
            padding: EdgeInsets.only(right: 15.w),
            itemCount: homeScreenContentController.homeDataModel.value
                .data![bestSellingProductIndex].bestSellingProducts!.length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(left: 15.w),
                child: Column(
                  children: [
                    HomeProductCard(
                      dataModel: homeScreenContentController.homeDataModel.value
                          .data![bestSellingProductIndex].bestSellingProducts,
                      index: index,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  //Video Shopping
  Widget videoShopping(videoShoppingIndex, context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: Text(
                AppTags.videoShopping.tr,
                style: isMobile(context)
                    ? AppThemeData.headerTextStyle
                    : AppThemeData.headerTextStyleTab,
              ),
            ),
            InkWell(
              onTap: () {
                Get.to(() => const AllVideoShopping());
              },
              child: Padding(
                padding: EdgeInsets.all(15.r),
                child: SvgPicture.asset(
                  "assets/icons/more.svg",
                  height: 4.h,
                  width: 18.w,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: isMobile(context) ? 150.h : 220.h,
          child: ListView.builder(
            padding: EdgeInsets.only(right: 15.w),
            itemCount: homeScreenContentController.homeDataModel.value
                .data![videoShoppingIndex].videoShopping!.length,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Get.toNamed(
                    Routes.detailsVideoShopping,
                    parameters: {
                      'videoSlug': homeScreenContentController
                          .homeDataModel
                          .value
                          .data![videoShoppingIndex]
                          .videoShopping![index]
                          .slug
                          .toString(),
                    },
                  );
                },
                child: Padding(
                    padding: EdgeInsets.only(right: 0.w, left: 15.w),
                    child: SizedBox(
                      //height: 120.h,
                      width: 105.w,

                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
                                image: DecorationImage(
                                  image: NetworkImage(
                                      homeScreenContentController
                                          .homeDataModel
                                          .value
                                          .data![videoShoppingIndex]
                                          .videoShopping![index]
                                          .thumbnail
                                          .toString()),
                                  fit: BoxFit.cover,
                                )),
                          ),
                          isMobile(context)
                              ? Positioned(
                                  child: SvgPicture.asset(
                                      "assets/icons/play_video.svg"))
                              : Positioned(
                                  child: SvgPicture.asset(
                                      "assets/icons/play_video.svg",
                                      height: 35.h)),
                          Positioned(
                            top: 5.h,
                            left: 10.w,
                            child: Text(
                              "LIVE",
                              style: isMobile(context)
                                  ? AppThemeData.todayDealNewStyle
                                  : AppThemeData.todayDealNewStyleTab,
                            ),
                          ),
                          Positioned(
                            bottom: 5.h,
                            left: 3.w,
                            right: 3.w,
                            child: Text(
                              homeScreenContentController
                                  .homeDataModel
                                  .value
                                  .data![videoShoppingIndex]
                                  .videoShopping![index]
                                  .title
                                  .toString(),
                              style: isMobile(context)
                                  ? AppThemeData.timeDateTextStyle_12
                                  : AppThemeData.timeDateTextStyleTab,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                    )),
              );
            },
          ),
        ),
      ],
    );
  }

  categoryCheck(data_model.HomeDataModel data, index, context) {
    switch (data.data![index].sectionType) {
      // case "categories":
      //   return _categories(index, context);
      // case 'slider':
      //   return slider(index, context);
      // case 'benefits':
      //   return const SizedBox();
      case 'popular_categories':
        return popularCategories(index, context);
      // case 'banners':
      //   return banner(index, context);
      case 'campaigns':
        return campaign(index, context);
      // case 'top_categories':
      //   return popularCategories(index, context);
      // case 'today_deals':
      //   return todayDeal(index, context);
      // case 'flash_deals':
      //   return flashSale(index, context);
      // case 'category_sec_banner':
      // //return categorySecBanner(index, context);
      // return const SizedBox();
      // case 'category_sec_banner_url':
      //   return const SizedBox();
      // case 'category_section':
      //   return const SizedBox();
      // case 'best_selling_products':
      //   return bestSellingProduct(index, context);
      // case 'offer_ending':
      //   return offerEnding(index, context);
      // case 'offer_ending_banner':
      //   // return offerEndingBanner(index, context);
      //   return const SizedBox();
      // case 'offer_ending_banner_url':
      //   return const SizedBox();
      // case 'latest_products':
      //   return latestProducts(index, context);
      // case 'latest_news':
      //   return latestNews(index, context);
      // case 'popular_brands':
      //   return popularBrands(index, context);
      // case 'best_shops':
      //   return bestShop(index, context);
      // case 'top_shops':
      //   return topShop(index, context);
      // case 'featured_shops':
      //   return featuredShop(index, context);
      // case 'express_shops':
      //   return expressShop(index, context);
      // case 'recent_viewed_product':
      //   return recentViewProducts(index, context);
      // case 'custom_products':
      //   return customProducts(index, context);
      // case 'subscription_section':
      //   return const SizedBox();
      // case 'video_shopping':
      //   return videoShopping(index, context);
      default:
        return const SizedBox();
    }
  }
}
