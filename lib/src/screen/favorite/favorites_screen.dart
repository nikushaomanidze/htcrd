import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/app_tags.dart';
import '../../utils/app_theme_data.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);
  // final controller = Get.put(FavouriteController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppTags.favorites.tr,
          style: AppThemeData.headerTextStyle_16,
        ),
      ),
      // body: Obx(
      //   () => controller.isLoading
      //       ? const ShimmerFavorite()
      //       : Column(
      //           children: [
      //             Expanded(
      //               child: DefaultTabController(
      //                 length: 2, // length of tabs
      //                 initialIndex: 0,
      //                 child: Column(
      //                   crossAxisAlignment: CrossAxisAlignment.center,
      //                   children: [
      //                     SizedBox(
      //                       width: 140.w,
      //                       height: isMobile(context) ? 25.h : 35.h,
      //                       child: TabBar(
      //                         labelColor: Colors.red,
      //                         unselectedLabelColor: Colors.black,
      //                         indicatorColor: Colors.red,
      //                         indicatorSize: TabBarIndicatorSize.label,
      //                         padding: EdgeInsets.zero,
      //                         indicatorPadding: EdgeInsets.zero,
      //                         labelPadding: EdgeInsets.zero,
      //                         labelStyle: TextStyle(
      //                           fontFamily: "Poppins Medium",
      //                           fontSize: isMobile(context) ? 13.sp : 10.sp,
      //                         ),
      //                         tabs: [
      //                           Tab(text: AppTags.products.tr),
      //                           Tab(text: AppTags.store.tr),
      //                         ],
      //                       ),
      //                     ),
      //                     controller.data != null
      //                         ? Expanded(
      //                             child: TabBarView(
      //                               children: [
      //                                 FavoriteProduct(
      //                                     favouriteData: controller.data!),
      //                                 FavoriteStore(
      //                                     favouriteData: controller.data!),
      //                               ],
      //                             ),
      //                           )
      //                         : const SizedBox()
      //                   ],
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      // ),
    );
  }
}
