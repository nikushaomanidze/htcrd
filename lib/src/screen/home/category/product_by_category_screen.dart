// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables, deprecated_member_use, duplicate_ignore

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hot_card/src/controllers/profile_content_controller.dart';
import 'package:hot_card/src/data/local_data_helper.dart';
import 'package:hot_card/src/screen/home/qr_page.dart';
import 'package:hot_card/src/screen/profile/wallet/my_wallet_screen.dart';
import 'package:hot_card/src/servers/network_service.dart';
import 'package:http/http.dart' as http;
import 'package:pagination_view/pagination_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../controllers/home_screen_controller.dart';
import '../../../models/add_to_cart_list_model.dart';
import '../../../models/product_by_category_model.dart';
import '../../../servers/repository.dart';
import 'package:flutter/services.dart';
import 'package:blobs/blobs.dart';
import 'package:hot_card/src/screen/home/category/all_category_screen.dart';
import 'package:hot_card/src/utils/app_tags.dart';

import 'package:hot_card/src/screen/Map/MapScreens.dart';
import 'package:hot_card/src/screen/home/mtla_home.dart';
import 'package:hot_card/src/screen/profile/profile_screen.dart';

class ProductByCategory extends StatefulWidget {
  const ProductByCategory({
    Key? key,
    required this.id,
    this.title,
    this.imgurl,
    this.category,
    this.number,
    this.soc_fb,
    this.soc_yt,
    this.soc_in,
    this.latlong,
  }) : super(key: key);
  final int? id;
  final String? title;
  final String? imgurl;
  final String? category;
  final String? number;
  final String? soc_fb;
  final String? soc_yt;
  final String? soc_in;
  final String? latlong;

  @override
  State<ProductByCategory> createState() => _ProductByCategoryState();
}

class _ProductByCategoryState extends State<ProductByCategory> {
  final RxString locale = Get.locale.toString().obs;
  var daysLeft;

  void _launchFb() async {
    String url = widget.soc_fb.toString();
    if (await canLaunchUrl(Uri.parse(url))) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<String> fetchCardNumber(String token) async {
    final response = await http.get(
      Uri.parse('${NetworkService.apiUrl}/user/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      daysLeft = data['data']['available_subscription_days'] ?? 'Inactive';
      if (daysLeft > 0) {
        return daysLeft.toString();
      } else {
        daysLeft = 'Inactive';
        return daysLeft;
      }
    } else {
      final response = await http.get(
        Uri.parse('${NetworkService.apiUrl}/user/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        daysLeft = data['data']['available_subscription_days'] ?? 'Inactive';
        if (daysLeft > 0) {
          return daysLeft;
        } else {
          daysLeft = 'Inactive';
          return daysLeft;
        }
      } else {
        daysLeft = 'Inactive2';
        throw Exception('Failed to load data');
      }
    }
  }

  YoutubePlayerController? _ytController;
  bool showYoutubePlayer = false;

  @override
  void initState() {
    super.initState();

    try {
      final videoID = YoutubePlayer.convertUrlToId(widget.soc_yt.toString());

      if (videoID != null && videoID.isNotEmpty) {
        _ytController = YoutubePlayerController(
          initialVideoId: videoID,
          flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
        );
        showYoutubePlayer = true;
      }
    } catch (e) {
      print("Exception: $e");
      showYoutubePlayer = false;
    }

    fetchCardNumber(LocalDataHelper().getUserToken().toString());
  }

  void _launchGram() async {
    String url = widget.soc_in.toString();
    if (await canLaunchUrl(Uri.parse(url))) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchYt() async {
    String url = widget.soc_yt.toString();
    if (await canLaunchUrl(Uri.parse(url))) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static void navigateTo(String? latlong) async {
    String url;

    // Check the platform
    if (Platform.isIOS) {
      // Apple Maps URL for iOS
      url = 'http://maps.apple.com/?q=$latlong';
    } else {
      // Google Maps URL for other platforms
      url = 'google.navigation:q=$latlong&mode=d';
    }

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  void launchPhoneCall(String phoneNumber) async {
    final Uri phoneCallUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(Uri.parse(phoneCallUri.toString()))) {
      launchUrl(Uri.parse(phoneCallUri.toString()));
    } else {
      throw 'Could not launch $phoneCallUri';
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
                    _launchYt();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(75.0),
                      image: DecorationImage(
                        image: Image.asset('assets/images/yt.png').image,
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

  final homeController = Get.put(HomeScreenController());

  late final AddToCartListModel cartList;

  int page = 0;
  int productId = 0;
  int dvar = 0;

  int maxFreeDish = 3;

  GlobalKey<PaginationViewState> key2 = GlobalKey<PaginationViewState>();
  GlobalKey<PaginationViewState> key = GlobalKey<PaginationViewState>();

  late List<CategoryProductData> data = [];

  void openGoogleMaps(String coordinates) async {
    final parts = coordinates.split(',');
    if (parts.length != 2) {
      throw 'Invalid coordinates format: $coordinates';
    }

    final latitude = double.tryParse(parts[0].trim());
    final longitude = double.tryParse(parts[1].trim());

    if (latitude == null || longitude == null) {
      throw 'Invalid coordinates: $coordinates';
    }

    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<List<CategoryProductData>> getData(int offset) async {
    page++;
    return await Repository()
        .getProductByCategoryItem(id: widget.id, page: page);
  }

  final ProfileContentController _profileContentController =
      Get.put(ProfileContentController());

  Future<void> showRoundedPopup(BuildContext context, int category,
      String price, String imageUrl, String productName) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        if (differentAdditionalDishes < maxFreeDish) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: 600,
                height: 225,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      locale.value == 'ka_GE'
                          ? 'assets/images/background_11.png'
                          : locale.value == 'uk_UA'
                              ? 'assets/images/background_11_ukr.png'
                              : 'assets/images/background_11_eng.ng',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 40,
                    ),
                    Expanded(
                      // child: SingleChildScrollView(
                      child: Column(
                        children: [
                          FutureBuilder(
                            future: getCheaperProducts(
                              int.parse(widget.id!.toString()),
                              double.parse(price),
                            ), // your function that returns a future
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                // if the data has arrived, show the widget
                                return
                                    // SingleChildScrollView(
                                    //   physics: const ScrollPhysics(),
                                    //   child:
                                    Column(
                                  children: [
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    NotificationListener<
                                        OverscrollIndicatorNotification>(
                                      onNotification: (overscroll) {
                                        overscroll
                                            .disallowIndicator(); // This will prevent the overscroll glow effect
                                        return false;
                                      },
                                      child: ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: snapshot.data!.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          List<dynamic> dataList2 =
                                              snapshot.data!;

                                          dataList2.sort((a, b) =>
                                              a['current_stock'].compareTo(
                                                  b['current_stock']));
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                additionalfinalIndex = index;
                                                additionalfinalId =
                                                    dataList2[index]['id'];
                                                additionals
                                                    .add(additionalfinalId);
                                                differentAdditionalDishes += 1;
                                                Navigator.pop(context);
                                              });
                                            },
                                            child: Container(
                                              color:
                                                  additionalfinalIndex == index
                                                      ? const Color.fromARGB(
                                                          255, 239, 127, 26)
                                                      : Colors.transparent,
                                              child: Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 30,
                                                  ),
                                                  Column(
                                                    children: [
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                            width: 220,
                                                            child: Text(
                                                              snapshot
                                                                  .data![index]
                                                                      ['title']
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'metro-bold',
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: additionalfinalIndex ==
                                                                          index
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          )
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      )
                                                    ],
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
                              } else if (snapshot.hasError) {
                                // if an error has occurred, show an error message
                                return Text(
                                    "An error has occurred: ${snapshot.error}");
                              }
                              // if the data hasn't arrived yet, show a loading indicator
                              return const Center(
                                  child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: RefreshProgressIndicator(color: Colors.orange,)));
                            },
                          ),
                        ],
                      ),
                    ),
                    // ),
                  ],
                ),
              );
            }),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Future<Map<String, dynamic>> getProductsByCategory(int categoryId) async {
    final response = await http.get(Uri.parse(
        "${NetworkService.apiUrl}/products-by-category/${categoryId.toString()}?lang=${LocalDataHelper().getLangCode() ?? "en"}"));

    if (response.statusCode == 200) {
      if (dvar < 1) {
        for (int i = 0; i < json.decode(response.body)['data'].length; i++) {
          quantity.add(0);
          var res = json.decode(response.body);
          ids.add(res['data'][i]['id']);
        }
        dvar += 1;
      } else {}
      return json.decode(response.body);
    } else {
      return getProductsByCategory(categoryId);
    }
  }

  Future<List<dynamic>> getCheaperProducts(int categoryId, double price) async {
    // Fetch data from API
    var response = await http.get(Uri.parse(
        '${NetworkService.apiUrl}/products-by-category/$categoryId?lang=${LocalDataHelper().getLangCode() ?? "en"}'));

    if (response.statusCode == 200) {
      // Decode the JSON response
      var decodedData = json.decode(response.body);
      // Convert the decoded data to a List
      List<dynamic> products = decodedData['data'];

      // Return the list of products that are cheaper than the given price
      return products
          .where((product) =>
              double.parse(product['formatted_price'].toString()) <= price)
          .toList();
    } else {
      return getCheaperProducts(categoryId, price);
    }
  }

  Future<void> updateUserBalance(
      String authorizationToken, double value) async {
    String apiUrl = '${NetworkService.apiUrl}/user/update_balance_value';

    final Map<String, String> headers = {
      'Authorization': 'Bearer $authorizationToken',
      'Content-Type': 'application/json',
    };

    final Map<String, dynamic> body = {
      'value': value,
      'type': 'add',
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      // Request was successful
      if (kDebugMode) {
        print('Balance updated successfully.');
      }
    } else {
      String apiUrl = '${NetworkService.apiUrl}/user/update_balance_value';

      final Map<String, String> headers = {
        'Authorization': 'Bearer $authorizationToken',
        'Content-Type': 'application/json',
      };

      final Map<String, dynamic> body = {
        'value': value,
        'type': 'add',
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        // Request was successful
        if (kDebugMode) {
          print('Balance updated successfully.');
        }
      }
    }
  }

  Future<void> sendOrder(
      List<dynamic> quantity,
      List<dynamic> ids,
      List<dynamic> additionals,
      BuildContext context,
      additionalWNames,
      ) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      // Log the error, send to a server, or show a friendly error message
      // instead of the red or grey screen
    };

    var url = Uri.parse('${NetworkService.apiUrl}/make/direct/order');

    List<Map<String, dynamic>> orders = [];

    for (int i = 0; i < quantity.length; i++) {
      if (quantity[i] > 0) {
        int productId = ids.length > i ? ids[i] : 0;
      //  int additionalProductId = additionals.length > i ? additionals[i] : [];
     //   List<int> additionalProductId = (additionals.length > i) ? [additionals[i]] : <int>[];
        List<dynamic> additionalProductId = additionals;

        orders.add({
          "qty": quantity[i],
          "product_id": productId,
          "additional_product_id": additionalProductId,
          "additional_product_qty": quantity[i],
        });
      }
    }

    var orderData = jsonEncode({
      "user_id": LocalDataHelper().getUserAllData()!.data!.userId,
      "orders": orders,
    });

    print('Generated JSON: $orderData');

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: orderData,
      );

      if (response.statusCode == 200) {
        updateUserBalance(
          LocalDataHelper().getUserToken().toString(),
          totalMainPrice,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QrPage(
              qty: quantity,
              ids: ids,
              adds: additionals,
              idd: response.body,
              addwn: additionalWNames,
              iddwn: mainWNames,
            ),
          ),
        );
      } else {
        print('Error: ${response.statusCode}');
        // Handle error or retry logic here
      }
    } catch (e) {
      print('Exception: $e');
      // Handle exception or retry logic here
    }
  }


  int finalIndex = 125;
  double mainDishPrice = 0;
  double totalMainPrice = 0;
  int additionalfinalIndex = 250;
  int additionalfinalId = 250;
  int selectedQty = 0;
  List quantity = [];
  bool active_ac = false;
  List ids = [];
  List additionals = [];
  var additionalWNames = {};
  var mainWNames = {};
  List addedIndexes = [];

  int switchnum = 1;

  int selectedPill = 1;


  int differentDishes = 0;
  int differentAdditionalDishes = 0;
  int currentTab = 0;

  final List<Widget> screens = [
    const MtlaHome(),
    const MapScreen(),
    const AllCategory(),
    const ProfileContent(),
  ];

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Container();
    };
    return Scaffold(
     /* appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
        Navigator.of(context).pop();
        },
        ),
      ),*/
        extendBody: true,
        floatingActionButton: SizedBox(
          width: 80,
          height: 81,
          child: Column(
            children: [
              FloatingActionButton(
                onPressed: () {
                  finalIndex == 125
                      ? showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: Text(AppTags.error.tr),
                              content: Text(AppTags.chooseProductsFirst.tr),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the popup
                                  },
                                  child: Text('OK', style: TextStyle(color: Colors.deepOrange.shade400),),
                                ),
                              ],
                            );
                          },
                        )
                      : sendOrder(quantity, ids, additionals, context,
                          additionalWNames);

                  HapticFeedback.mediumImpact();

                  // print('Order Sent!');

                  // currentTab = 0; // Set the selected tab index
                },
                backgroundColor: const Color.fromARGB(255, 239, 127, 26),
                child: const Icon(Icons.done_rounded, size: 45, color: Colors.white,),
              ),
              const SizedBox(
                height: 15,
              )
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Container(
            decoration: Platform.isIOS
                ? const BoxDecoration()
                : BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 74, 75, 77)
                            .withOpacity(0.11),
                        spreadRadius: 15,
                        blurRadius: 15,
                        offset:
                            const Offset(0, 3), // Set the desired shadow offset
                      ),
                    ],
                  ),
            child: const SizedBox()),
        body: Stack(children: [
          Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/backgroundicons.png'),
                  fit: BoxFit.cover,
                )
            ),
            child: Container(
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: FutureBuilder(
                    future: getProductsByCategory(
                        widget.id!), // your function that returns a future
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            const SizedBox(height: 55,),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.black,
                                  ),
                                ),
                                const Spacer(),
                                // const SizedBox(
                                //   height: 70,
                                // ),
                              /*  Center(
                                    child: Text(
                                        AppTags.chooseProduct.tr,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'bpg',
                                            color: Colors.white),
                                      ),
                                    ),*/
                                const Spacer(),
                                const SizedBox(
                                  width: 25,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12,),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              height: MediaQuery.sizeOf(context).height * 0.18,
                              width: MediaQuery.sizeOf(context).width * 0.89,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: _ytController != null
                                    ? Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: YoutubePlayer(
                                          controller: _ytController!,
                                          aspectRatio: 9 / 16,
                                          showVideoProgressIndicator: true,
                                          onReady: () {
                                            // Handle onReady event if needed
                                          },
                                          onEnded: (data) {
                                            // Handle onEnded event if needed
                                          },
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          _launchYt();
                                         /* Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => FullScreenVideoPage(
                                                videoId: _ytController!.initialVideoId,
                                              ),
                                            ),
                                          );*/
                                        },
                                        behavior: HitTestBehavior.translucent, // Ensure GestureDetector captures taps even on transparent areas
                                      ),
                                    ),
                                  ],
                                )
                                    : Container(
                                  // Empty container with the same height
                                  height: MediaQuery.sizeOf(context).height * 0.1935,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18,),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.7,
                              //  height: 496,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topLeft:
                                  Radius.circular(50.0), // top-left corner
                                  topRight:
                                  Radius.circular(50.0), // top-right corner
                                  bottomRight: Radius.circular(
                                      0.0), // bottom-right corner
                                  bottomLeft: Radius.circular(
                                      0.0), // bottom-left corner
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(255, 74, 75, 77)
                                        .withOpacity(0.2),
                                    spreadRadius: 15,
                                    blurRadius: 15,
                                    offset:
                                    const Offset(0, 3), // Set the desired shadow offset
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 32,
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      SizedBox(
                                        width: 300, // Set the desired width
                                        child: Text(
                                          widget.title.toString(),
                                          style: const TextStyle(
                                            fontSize: 21,
                                            fontFamily: 'metro-bold',
                                            color:
                                            Color.fromARGB(255, 74, 75, 77),
                                          ),
                                          maxLines:
                                          3, // Set the maximum number of lines
                                          overflow: TextOverflow
                                              .ellipsis, // Handle overflow with ellipsis
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3,),
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        widget.category.toString(),
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Color.fromARGB(255, 239, 127, 26)),
                                      ),
                                    ],
                                  ),
                                 // const SizedBox(height: 10,),
                                  HorizontalOutlinedPillScroll(
                                    items: [AppTags.deals.tr, AppTags.contact.tr, AppTags.socialNetworks.tr, AppTags.map.tr],
                                    onTapFunctions: [
                                          () {
                                      HapticFeedback.mediumImpact();
                                      },
                                          () {
                                            HapticFeedback.mediumImpact();
                                            launchPhoneCall(widget.number.toString());

                                          },
                                          () {
                                            HapticFeedback.mediumImpact();
                                            _showPopup(context);

                                          },
                                          () {
                                            HapticFeedback.mediumImpact();
                                            navigateTo(widget.latlong);
                                      },
                                    ],
                                  ),
                                /* Row(
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        AppTags.deals.tr,
                                        style: const TextStyle(
                                            fontSize: 15,
                                           // fontFamily: 'metro-bold',
                                            color:
                                            Color.fromARGB(255, 74, 75, 77),
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),*/
                            /*  Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        OutlinedPill(
                                          label: AppTags.deals.tr,
                                          onPressed: () {

                                          },
                                        ),
                                        OutlinedPill(
                                          label: 'Placeholder 1',
                                          onPressed: () {

                                          },
                                        ),
                                        OutlinedPill(
                                          label: 'Placeholder 2',
                                          onPressed: () {

                                          },
                                        ),
                                      ],
                                    ),
                                ]
                                                            ),
                              ),*/

                                  const SizedBox(
                                    height: 4,
                                  ),
                                  switchnum == 1
                                      ? SizedBox(
                                  //  height: 260,
                                    height: MediaQuery.sizeOf(context).height * 0.4,
                                    child: NotificationListener<
                                        OverscrollIndicatorNotification>(
                                      onNotification: (overscroll) {
                                        overscroll
                                            .disallowIndicator(); // This will prevent the overscroll glow effect
                                        return false;
                                      },
                                      child: ListView.builder(
                                        // itemExtent: 200.
                                        padding: const EdgeInsets.all(0),
                                        shrinkWrap: true,
                                        // physics:
                                        //     const NeverScrollableScrollPhysics(),
                                        itemCount:
                                        snapshot.data!['data'].length,

                                        itemBuilder:
                                            (BuildContext context,
                                            int index) {
                                          List<dynamic> dataList =
                                          snapshot.data!['data'];

                                          void _showImageDialog(BuildContext context) {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  backgroundColor: Colors.transparent,
                                                  child: SizedBox(
                                                    width: double.infinity,
                                                    height: 250,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(25),
                                                      child: Image.network(
                                                        dataList[index]
                                                        ['image'], // Replace with your image URL
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          }

                                          dataList.sort((a, b) => a[
                                          'current_stock']
                                              .compareTo(
                                              b['current_stock']));

                                          return Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets
                                                    .fromLTRB(0, 0, 0, 0),
                                                child: Container(
                                                  height: 90,
                                                  color:
                                                  finalIndex == index
                                                      ? const Color
                                                      .fromARGB(
                                                      255,
                                                      239,
                                                      127,
                                                      26)
                                                      : Colors.white,
                                                  child: Row(
                                                    children: [
                                                      const SizedBox(
                                                        width: 20,
                                                      ),
                                                      Padding(
                                                        padding:
                                                        const EdgeInsets
                                                            .only(
                                                            top: 8.0,
                                                        bottom: 8),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            _showImageDialog(context);
                                                          },
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(15),
                                                            child: Image.network(
                                                              dataList[index]
                                                              ['image'],
                                                              width: 90,
                                                              height: 90,
                                                              fit: BoxFit
                                                                  .cover,
                                                            ),),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 15,),
                                                      SizedBox(
                                                        width: 110,
                                                        child: Text(
                                                          dataList[index][
                                                          'title']
                                                              .toString(),
                                                          maxLines: 3,
                                                          style: TextStyle(
                                                              color: finalIndex ==
                                                                  index
                                                                  ? Colors
                                                                  .white
                                                                  : Colors
                                                                  .black,
                                                              fontSize:
                                                              13,
                                                            //  fontFamily: 'bpg',
                                                              fontWeight:
                                                              FontWeight
                                                                  .w500),
                                                        ),
                                                      ),
                                                     // const Spacer(),
                                                      Row(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              HapticFeedback.lightImpact();
                                                              setState(
                                                                      () {
                                                                    active_ac =
                                                                    true;
                                                                    differentAdditionalDishes -=
                                                                    1;
                                                                    additionalWNames
                                                                        .remove(
                                                                        additionalfinalId);
                                                                    additionals
                                                                        .remove(
                                                                        additionalfinalId);
                                                                    finalIndex =
                                                                        index;
                                                                    quantity[index] >=
                                                                        1
                                                                        ? quantity[index] -=
                                                                    1
                                                                        : quantity[
                                                                    index];

                                                                    selectedQty =
                                                                    quantity[
                                                                    index];
                                                                    if (!addedIndexes.contains(
                                                                        index) &&
                                                                        (quantity[index] !=
                                                                            0)) {
                                                                      differentDishes -=
                                                                      1;
                                                                    } else if (quantity[
                                                                    index] ==
                                                                        0) {
                                                                      addedIndexes.removeWhere((element) =>
                                                                      element ==
                                                                          index);
                                                                      mainWNames.remove(dataList[index]
                                                                      [
                                                                      'id']);
                                                                      differentDishes -=
                                                                      1;
                                                                    }
                                                                  });
                                                            },
                                                            child: quantity[
                                                            index] !=
                                                                0
                                                                ? SizedBox(
                                                              width:
                                                              22,
                                                              height:
                                                              22,
                                                              child: Center(
                                                                  child: Icon(
                                                                    size:
                                                                    22,
                                                                    Icons.remove,
                                                                    color: finalIndex == index
                                                                        ? Colors.white
                                                                        : const Color.fromARGB(255, 252, 96, 17),
                                                                  )),
                                                            )
                                                                : Container(
                                                              width:
                                                              30,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          quantity[index] !=
                                                              0
                                                              ? Text(
                                                            '${quantity[index] <= 3 ? quantity[index] : 3}',
                                                            style: TextStyle(
                                                                color: finalIndex == index
                                                                    ? Colors.white
                                                                    : Colors.black,
                                                                fontSize: 15,
                                                                fontWeight: FontWeight.w500),
                                                          )
                                                              : Container(),
                                                          //  const SizedBox(width: 5,),
                                                          GestureDetector(
                                                            behavior: HitTestBehavior.translucent,
                                                            onTap: () {
                                                              HapticFeedback.lightImpact();
                                                              active_ac =
                                                              true;
                                                              if (differentAdditionalDishes ==
                                                                  3) {


                                                                showDialog(
                                                                  context:
                                                                  context,
                                                                  builder:
                                                                      (BuildContext
                                                                  context) {
                                                                    return AlertDialog(
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(25)
                                                                      ),
                                                                      title:
                                                                      Text(
                                                                        AppTags.limitExpired.tr,
                                                                      ),
                                                                      content:
                                                                      Text(
                                                                        AppTags.limitIs3.tr,
                                                                      ),
                                                                      actions: <Widget>[
                                                                        TextButton(
                                                                          child: Text(
                                                                            AppTags.close.tr,
                                                                            style: TextStyle(color: Colors.deepOrange.shade400),
                                                                          ),
                                                                          onPressed: () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                );
                                                              } else {
                                                                setState(
                                                                        () {
                                                                      if (daysLeft ==
                                                                          'Inactive') {
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) => _profileContentController.user!.value.data != null ? MyWalletScreen(userDataModel: _profileContentController.user!.value) : const ProfileContent(),
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        finalIndex =
                                                                            index;
                                                                        mainDishPrice =
                                                                            double.parse(dataList[index]['formatted_price'].toString());
                                                                        totalMainPrice +=
                                                                            double.parse(dataList[index]['formatted_price'].toString());
                                                                        mainWNames[dataList[index]
                                                                        [
                                                                        'id']] = dataList[
                                                                        index]
                                                                        [
                                                                        'title'];
                                                                        switchnum =
                                                                        2;
                                                                        quantity[index] +=
                                                                        1;
                                                                        if (!addedIndexes
                                                                            .contains(index)) {
                                                                          differentDishes +=
                                                                          1;
                                                                          addedIndexes.add(index);
                                                                        }

                                                                        additionalfinalIndex =
                                                                        250;
                                                                        selectedQty =
                                                                        quantity[index];
                                                                      }
                                                                    });
                                                              }
                                                            },
                                                            child:
                                                            Padding(
                                                              padding: const EdgeInsets.all(12.0),
                                                              child: Center(
                                                                  child: Icon(
                                                                    Icons.add,
                                                                    size: 22,
                                                                    color: finalIndex ==
                                                                        index
                                                                        ? Colors
                                                                        .white
                                                                        : const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        252,
                                                                        96,
                                                                        17),
                                                                  )),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        width: dataList[index]
                                                        [
                                                        'formatted_price']
                                                            .toString()
                                                            .length ==
                                                            1
                                                            ? 15
                                                            : dataList[index]['formatted_price']
                                                            .toString()
                                                            .length ==
                                                            2
                                                            ? 15
                                                            : 10,
                                                      ),
                                                      Row(
                                                        children: [
                                                          quantity[index] !=
                                                              0
                                                              ? FittedBox(
                                                            fit: BoxFit
                                                                .scaleDown,
                                                            child:
                                                            Text(
                                                              softWrap:
                                                              true,
                                                              style:
                                                              TextStyle(color: finalIndex == index ? Colors.white : Colors.black),
                                                              (dataList[index]['formatted_price'] * quantity[index]).toString() +
                                                                  '₾'.toString(),
                                                              textAlign:
                                                              TextAlign.left,
                                                            ),
                                                          )
                                                              : Text(
                                                            style: TextStyle(
                                                                color: finalIndex == index
                                                                    ? Colors.white
                                                                    : Colors.black,
                                                              fontSize: 15
                                                            ),
                                                            (dataList[index]['formatted_price']).toString() +
                                                                '₾'.toString(),
                                                            textAlign:
                                                            TextAlign.left,
                                                          ),
                                                        ],
                                                      ),
                                                   //    SizedBox(width: MediaQuery.sizeOf(context).width * 0.005,)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // const Divider(),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  )
                                      : Row(
                                    children: [
                                      const SizedBox(width: 20,),
                                      Container(
                                       // width: 370,
                                        //height: 300,
                                        width: MediaQuery.sizeOf(context).width * 0.9,
                                        height: MediaQuery.sizeOf(context).height * 0.34,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage(locale
                                                  .value ==
                                                  'ka_GE'
                                                  ? 'assets/images/background_11.png'
                                                  : locale.value ==
                                                  'uk_UA'
                                                  ? 'assets/images/background_11_ukr.png'
                                                  : 'assets/images/background_11_eng.png'),
                                              fit: BoxFit.fill),
                                        ),
                                        child: Center(
                                          child: Row(
                                            children: [
                                              const SizedBox(width: 50,),
                                              Expanded(
                                                child: SizedBox(
                                                  //  height: 280,
                                                    height: MediaQuery.sizeOf(context).height * 0.27,

                                                    child:
                                                    SingleChildScrollView(
                                                      child: Column(
                                                        children: [
                                                          FutureBuilder(
                                                            future:
                                                            getCheaperProducts(
                                                              int.parse(widget
                                                                  .id!
                                                                  .toString()),
                                                              double.parse(
                                                                  mainDishPrice
                                                                      .toString()),
                                                            ),
                                                            builder: (context,
                                                                snapshot) {
                                                              if (snapshot
                                                                  .hasData) {
                                                                return SingleChildScrollView(
                                                                  physics:
                                                                  const ScrollPhysics(),
                                                                  child:
                                                                  Column(
                                                                    children: [
                                                                      NotificationListener<OverscrollIndicatorNotification>(
                                                                        onNotification: (overscroll) {
                                                                          overscroll.disallowIndicator(); // This will prevent the overscroll glow effect
                                                                          return false;
                                                                        },
                                                                        child: ListView.builder(
                                                                          physics: const NeverScrollableScrollPhysics(),
                                                                          shrinkWrap: true,
                                                                          itemCount: snapshot.data!.length,
                                                                          itemBuilder: (BuildContext context, int index) {
                                                                            List<dynamic> dataList3 = snapshot.data!;

                                                                            dataList3.sort((a, b) => a['current_stock'].compareTo(b['current_stock']));
                                                                            return GestureDetector(
                                                                              onTap: () {
                                                                                HapticFeedback.lightImpact();
                                                                                setState(() {
                                                                                  additionalfinalIndex = index;
                                                                                  additionalfinalId = dataList3[index]['id'];
                                                                                  additionals.add(additionalfinalId);
                                                                                  additionalWNames[dataList3[index]['id']] = dataList3[index]['title'];
                                                                                  differentAdditionalDishes += 1;
                                                                                  switchnum = 1;
                                                                                });
                                                                              },
                                                                              child: Container(
                                                                                color: additionalfinalIndex == index ? const Color.fromARGB(255, 239, 127, 26) : Colors.transparent,
                                                                                child: Row(
                                                                                  children: [
                                                                                    const SizedBox(width: 30),
                                                                                    Column(
                                                                                      children: [
                                                                                        const SizedBox(height: 5),
                                                                                        Row(
                                                                                          children: [
                                                                                            Container(
                                                                                              width: 50,
                                                                                              height: 50,
                                                                                              decoration: BoxDecoration(
                                                                                                borderRadius: BorderRadius.circular(15), // Half of the width/height for a circular shape
                                                                                              ),
                                                                                              child: ClipRRect(
                                                                                                borderRadius: BorderRadius.circular(15), // Same as above for the child
                                                                                                child: Image.network(
                                                                                                  dataList3[index]['image'].toString(),
                                                                                                  fit: BoxFit.cover,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            const SizedBox(
                                                                                              width: 15,
                                                                                            ),
                                                                                            SizedBox(
                                                                                              width: 90,
                                                                                              child: Text(
                                                                                                dataList3[index]['title'].toString(),
                                                                                                style: TextStyle(fontFamily: 'metro-bold', fontSize: 11.5, fontWeight: FontWeight.w400, color: additionalfinalIndex == index ? Colors.white : Colors.black),
                                                                                              ),
                                                                                            ),
                                                                                            const SizedBox(width: 15,),
                                                                                            SizedBox(
                                                                                              width: 45,
                                                                                              child: Text(
                                                                                                '${dataList3[index]['formatted_price']}₾',
                                                                                                style: TextStyle( fontSize: 14, fontWeight: FontWeight.w600, color: additionalfinalIndex == index ? Colors.white : Colors.black),
                                                                                              ),
                                                                                            ),
                                                                                            const SizedBox(
                                                                                              width: 54,
                                                                                              child: Icon(
                                                                                                Icons.add,
                                                                                                size: 25,
                                                                                                color: Color.fromARGB(255, 252, 96, 17),
                                                                                              ),
                                                                                            ),
                                                                                            const SizedBox(width: 5),
                                                                                          ],
                                                                                        ),
                                                                                     //   const SizedBox(height: 20),
                                                                                      ],
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              } else if (snapshot
                                                                  .hasError) {
                                                                return Text(
                                                                    "An error has occurred: ${snapshot.error}");
                                                              }
                                                              return const Center(
                                                                child:
                                                                SizedBox(
                                                                  width:
                                                                  50,
                                                                  height:
                                                                  50,
                                                                  child:
                                                                  RefreshProgressIndicator(color: Colors.orange,),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        // if an error has occurred, show an error message
                        return Text("An error has occurred: ${snapshot.error}");
                      }
                      // if the data hasn't arrived yet, show a loading indicator
                      return const Center(
                          child: SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                      ));
                    },
                  )),
            ),
          ),
          Stack(
            alignment: Alignment.centerRight,
              children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(670,560,0, 0),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 60),
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                    Color.fromARGB(255, 246, 246, 246), BlendMode.srcIn),
                child: Blob.fromID(id: const ['3-9-419'], size: 120),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 35),
              child: IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                },
                icon: const Icon(Icons.favorite,
                    color: Color(0xffe07527), size: 27),
              ),
            ),
          /*  Padding(
              padding: const EdgeInsets.only(right: 135, top: 110),
              child: SizedBox(
                width: 45,
                child: IconButton(
                    onPressed: () {
                      // Replace '1234567890' with the phone number you want to call
                      launchPhoneCall(widget.number.toString());
                    },
                    icon: Image.asset('assets/images/call.png')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 85, top: 110),
              child: SizedBox(
                width: 45,
                child: IconButton(
                    onPressed: () {
                      // Replace '1234567890' with the phone number you want to call
                      _showPopup(context);
                    },
                    icon: Image.asset('assets/images/fbb.png')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 35, top: 110),
              child: SizedBox(
                width: 45,
                child: IconButton(
                    onPressed: () {
                      // Replace '1234567890' with the phone number you want to call
                      navigateTo(widget.latlong);
                    },
                    icon: Image.asset('assets/images/loc.png')),
              ),
            )*/
          ]),
        ]));
  }


}

class OutlinedPill extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const OutlinedPill({super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.black,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color:  Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class YourCustomSecondPillContent extends StatelessWidget {
  const YourCustomSecondPillContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Customize the content for the second pill
    return Container(
      color: Colors.green,
      child: const Center(
        child: Text(
          'Your Custom Content for Second Pill',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class YourCustomThirdPillContent extends StatelessWidget {
  const YourCustomThirdPillContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Customize the content for the third pill
    return Container(
      color: Colors.orange,
      child: const Center(
        child: Text(
          'Your Custom Content for Third Pill',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class FullScreenVideoPage extends StatelessWidget {
  final String videoId;

  FullScreenVideoPage({required this.videoId});

  @override
  Widget build(BuildContext context) {
    final YoutubePlayerController _ytController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white,),
          onPressed: () {
          Navigator.pop(context);
        },),
      ),
      body: Center(
          child: Container(
            height: MediaQuery.sizeOf(context).height * 1,
            child: YoutubePlayer(
              controller: _ytController,
              aspectRatio: 9 / 16,
              showVideoProgressIndicator: true,
              onReady: () {
                _ytController.play();
              },
              onEnded: (data) {
              },
              bottomActions: [
                CurrentPosition(),
                ProgressBar(
                  isExpanded: true,
                  colors: ProgressBarColors(
                    playedColor: Colors.orange,
                    handleColor: Colors.orange.shade700,
                  ),
                ),
                RemainingDuration(),
              ],
            ),
          ),
        ),

    );
  }
}

class HorizontalOutlinedPillScroll extends StatelessWidget {
  final List<String> items;
  final List<VoidCallback> onTapFunctions;

  const HorizontalOutlinedPillScroll({
    required this.items,
    required this.onTapFunctions,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(items.length, (index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: OutlinedPillButton(
              text: items[index],
              filled: index == 0,
              onTap: onTapFunctions[index],
            ),
          );
        }),
      ),
    );
  }
}

class OutlinedPillButton extends StatelessWidget {
  final String text;
  final bool filled;
  final VoidCallback onTap;

  const OutlinedPillButton({
    required this.text,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: const BorderSide(
              color: Colors.black,
              style: BorderStyle.solid
            ),
          ),
        ),
        backgroundColor: filled
            ? MaterialStateProperty.all<Color>(Colors.orange)
            : MaterialStateProperty.all<Color>(Colors.transparent),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          text,
          style: TextStyle(
            color: filled ? Colors.white : Colors.black,
            fontWeight: filled ? FontWeight.w600 : FontWeight.normal
          ),
        ),
      ),
    );
  }
}
