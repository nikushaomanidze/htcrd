// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hot_card/src/data/local_data_helper.dart';
import 'package:hot_card/src/models/home_data_model.dart';
import 'package:hot_card/src/servers/network_service.dart';
import 'package:http/http.dart' as http;

import '../../_route/routes.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/details_screen_controller.dart';
import '../../controllers/home_screen_controller.dart';
import '../../controllers/my_wallet_controller.dart';
import '../../utils/app_tags.dart';
import '../../utils/app_theme_data.dart';
import '../../utils/responsive.dart';
import '../../widgets/loader/shimmer_home_content.dart';
import 'category/product_by_category_screen.dart';

class HomeScreenGartobaContent extends StatefulWidget {
  const HomeScreenGartobaContent({Key? key}) : super(key: key);

  @override
  State<HomeScreenGartobaContent> createState() =>
      _HomeScreenGartobaContentState();
}

class _HomeScreenGartobaContentState extends State<HomeScreenGartobaContent> {
  final DashboardController homeScreenController =
      Get.find<DashboardController>();

  final homeScreenContentController = Get.find<HomeScreenController>();

  final MyWalletController myWalletController = Get.put(MyWalletController());

  final detailsPageController = Get.lazyPut(
    () => DetailsPageController(),
    fenix: true,
  );

  void updateSliderValue(double value) {
    setState(() {});
  }

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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Obx(
      () => homeScreenContentController.homeDataModel.value.data != null
          ? Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/back_50.png"),
                      fit: BoxFit.cover)),
              child: Scaffold(
                  // backgroundColor: Colors.white,
                  extendBodyBehindAppBar: false,
                  backgroundColor: Colors.transparent,
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
                                          color: AppThemeData.searchIconColor,
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
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.w),
                                        child: Text(AppTags.searchProduct.tr,
                                            style: AppThemeData
                                                .hintTextStyle_10Tab
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
                      homeScreenContentController.isLoadingFromServer.value
                          ? const ShimmerHomeContent()
                          : Expanded(
                              child: SizedBox(
                                height: size.height,
                                width: double.infinity,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: 1,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index) {
                                    return Obx(
                                        () => _categories(index, context));
                                  },
                                ),
                              ),
                            ),
                    ],
                  )),
            )
          : const ShimmerHomeContent(),
    );
  }

  // Popular Categories
  // Widget popularCategories(categoriesIndex, context) {
  //   return Column(
  //     children: [
  //       Padding(
  //         padding: EdgeInsets.only(
  //           left: 0.0.w,
  //         ),
  //         child: Text(
  //           AppTags.fun.tr,
  //           style: isMobile(context)
  //               ? AppThemeData.headerTextStyle
  //                   .copyWith(color: Colors.white, fontFamily: 'bpg')
  //               : AppThemeData.headerTextStyleTab
  //                   .copyWith(color: Colors.white, fontFamily: 'bpg'),
  //         ),
  //       ),
  //       Column(
  //         children: [
  //           SizedBox(
  //             height: MediaQuery.of(context).size.height - 250,
  //             width: MediaQuery.of(context).size.width - 50,
  //             child: FutureBuilder<List<dynamic>>(
  //               future: fetchCategories(),
  //               builder: (context, snapshot) {
  //                 if (snapshot.hasData) {
  //                   List? categories = snapshot.data;
  //                   // Render the list of categories as needed
  //                   return ListView.builder(
  //                     itemCount: categories?.length,
  //                     itemBuilder: (context, index) {
  //                       return Center(
  //                         child: Column(
  //                           children: [
  //                             Padding(
  //                               padding: EdgeInsets.only(right: 0.w, left: 1.w),
  //                               child: InkWell(
  //                                 onTap: () {
  //                                   Navigator.of(context).push(
  //                                     MaterialPageRoute(
  //                                       builder: (_) => ProductByCategory(
  //                                         id: categories[index]['id'],
  //                                         title: categories[index]['title'],
  //                                       ),
  //                                     ),
  //                                   );
  //                                 },
  //                                 child: Column(
  //                                   children: [
  //                                     const SizedBox(
  //                                       height: 20,
  //                                     ),
  //                                     Container(
  //                                       width:
  //                                           MediaQuery.of(context).size.width,
  //                                       height: 130,
  //                                       decoration: BoxDecoration(
  //                                           borderRadius:
  //                                               const BorderRadius.all(
  //                                                   Radius.circular(25)),
  //                                           image: DecorationImage(
  //                                               image: categories![index]
  //                                                           ['banner'] !=
  //                                                       null
  //                                                   ? NetworkImage(
  //                                                       categories[index]
  //                                                           ['banner'])
  //                                                   : const NetworkImage(
  //                                                       'https://st3.depositphotos.com/23594922/31822/v/600/depositphotos_318221368-stock-illustration-missing-picture-page-for-website.jpg'),
  //                                               fit: BoxFit.cover)),
  //                                       child: Center(
  //                                         child: Text(
  //                                           categories[index]['title']
  //                                               .toString(),
  //                                           maxLines: 1,
  //                                           textAlign: TextAlign.center,
  //                                           overflow: TextOverflow.ellipsis,
  //                                           style: AppThemeData
  //                                               .todayDealTitleStyle
  //                                               .copyWith(
  //                                                   color: Colors.white,
  //                                                   fontFamily: 'bpg',
  //                                                   fontSize: 24,
  //                                                   fontWeight:
  //                                                       FontWeight.w600),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       );
  //                     },
  //                   );
  //                 } else if (snapshot.hasError) {
  //                   return Text("${snapshot.error}");
  //                 }
  //                 // By default, show a loading spinner
  //                 return const Center(
  //                   child: SizedBox(
  //                       width: 50,
  //                       height: 50,
  //                       child: CircularProgressIndicator()),
  //                 );
  //               },
  //             ),
  //           ),
  //           // SizedBox(
  //           //   height: MediaQuery.of(context).size.height - 250,
  //           //   width: MediaQuery.of(context).size.width - 50,
  //           //   child: ListView.builder(
  //           //     padding: EdgeInsets.only(right: 1.w),
  //           //     physics: const AlwaysScrollableScrollPhysics(),
  //           //     itemCount: homeScreenContentController.homeDataModel.value
  //           //         .data![popularCategoriesIndex].popularCategories!.length,
  //           //     scrollDirection: Axis.vertical,
  //           //     itemBuilder: (context, index) {
  //           //       return
  //           //     },
  //           //   ),
  //           // ),
  //         ],
  //       ),
  //       SizedBox(
  //         height: 1.h,
  //       ),
  //     ],
  //   );
  // }

  // Categories
  Widget _categories(categoryIndex, context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: 0.0.w,
          ),
          child: Text(
            AppTags.fun.tr,
            style: isMobile(context)
                ? AppThemeData.headerTextStyle
                    .copyWith(color: Colors.white, fontFamily: 'bpg')
                : AppThemeData.headerTextStyleTab
                    .copyWith(color: Colors.white, fontFamily: 'bpg'),
          ),
        ),
        Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 250,
              width: MediaQuery.of(context).size.width - 50,
              child: ListView.builder(
                padding: EdgeInsets.only(right: 1.w),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: homeScreenContentController.homeDataModel.value
                    .data![categoryIndex].categories!.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  return Center(
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
                                        .data![categoryIndex]
                                        .categories![index]
                                        .id,
                                    title: homeScreenContentController
                                        .homeDataModel
                                        .value
                                        .data![categoryIndex]
                                        .categories![index]
                                        .title,
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
                                  width: MediaQuery.of(context).size.width,
                                  height: 130,
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(25)),
                                      image: DecorationImage(
                                          image: homeScreenContentController
                                                      .homeDataModel
                                                      .value
                                                      .data![categoryIndex]
                                                      .categories![index]
                                                      .banner !=
                                                  null
                                              ? NetworkImage(
                                                  homeScreenContentController
                                                      .homeDataModel
                                                      .value
                                                      .data![categoryIndex]
                                                      .categories![index]
                                                      .banner!)
                                              : const NetworkImage(
                                                  'https://www.streamingmedia.com/Images/ArticleImages/ArticleImage.14143.jpg'),
                                          fit: BoxFit.cover)),
                                  child: Center(
                                    child: Text(
                                      homeScreenContentController
                                          .homeDataModel
                                          .value
                                          .data![categoryIndex]
                                          .categories![index]
                                          .title!
                                          .toString(),
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppThemeData.todayDealTitleStyle
                                          .copyWith(
                                              fontFamily: 'bpg',
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
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

  categoryCheck(HomeDataModel data, index, context) {
    switch (data.data![index].sectionType) {
      case "categories":
        return _categories(index, context);
      // case 'benefits':
      //   return const SizedBox();
      // case 'popular_categories':
      //   return popularCategories(index, context);
      // case 'banners':
      //   return banner(index, context);
      // // case 'top_categories':
      // //   return topCategories(index, context);
      // case 'category_sec_banner':
      //   //return categorySecBanner(index, context);
      //   return const SizedBox();
      // case 'category_sec_banner_url':
      //   return const SizedBox();
      // case 'category_section':
      //   return const SizedBox();
      // case 'offer_ending_banner':
      //   // return offerEndingBanner(index, context);
      //   return const SizedBox();
      // case 'offer_ending_banner_url':
      //   return const SizedBox();

      // case 'subscription_section':
      //   return const SizedBox();

      // default:
      //   return const SizedBox();
    }
  }
}
