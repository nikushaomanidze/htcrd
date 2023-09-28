import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hot_card/src/data/local_data_helper.dart';
import 'package:hot_card/src/screen/home/qr_page.dart';
import 'package:http/http.dart' as http;
import 'package:pagination_view/pagination_view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/home_screen_controller.dart';
import '../../../models/add_to_cart_list_model.dart';
import '../../../models/product_by_category_model.dart';
import '../../../servers/repository.dart';

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
      Uri.parse('https://julius.ltd/hotcard/api/v100/user/profile'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      daysLeft = data['data']['available_subscription_days'] ?? 'Inactive';

      return daysLeft;
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _launchGram() async {
    String url = widget.soc_in.toString();
    if (await canLaunchUrl(Uri.parse(url))) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchTiktok() async {
    String url = widget.soc_yt.toString();
    if (await canLaunchUrl(Uri.parse(url))) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static void navigateTo(String? latlong) async {
    var uri = Uri.parse("google.navigation:q=$latlong&mode=d");
    if (await canLaunchUrl(Uri.parse(uri.toString()))) {
      await launchUrl(Uri.parse(uri.toString()));
    } else {
      throw 'Could not launch ${uri.toString()}';
    }
  }

  void launchPhoneCall(String phoneNumber) async {
    final Uri phoneCallUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(Uri.parse(phoneCallUri.toString()))) {
      await launchUrl(Uri.parse(phoneCallUri.toString()));
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
  int dickHead = 0;
  int dickHead2 = 0;

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
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                additionalfinalIndex = index;
                                                additionalfinalId =
                                                    snapshot.data![index]['id'];
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
                                      child: RefreshProgressIndicator()));
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
        "https://julius.ltd/hotcard/api/v100/products-by-category/${categoryId.toString()}"));

    if (response.statusCode == 200) {
      if (dickHead < 1) {
        for (int i = 0; i < json.decode(response.body)['data'].length; i++) {
          quantity.add(0);
          var res = json.decode(response.body);
          ids.add(res['data'][i]['id']);
        }
        dickHead += 1;
      } else {}
      return json.decode(response.body);
    } else {
      return getProductsByCategory(categoryId);
    }
  }

  Future<List<dynamic>> getCheaperProducts(int categoryId, double price) async {
    // Fetch data from API
    var response = await http.get(Uri.parse(
        'https://julius.ltd/hotcard/api/v100/products-by-category/$categoryId'));

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

  Future<void> sendOrder(List<dynamic> quantity, List<dynamic> ids,
      List<dynamic> additionals) async {
    // var token = LocalDataHelper().getUserToken();
    var url =
        Uri.parse('https://julius.ltd/hotcard/api/v100/make/direct/order');

    // Create the orders object dynamically based on the input lists
    Map<String, dynamic> orders = {};
    int index = 0;
    for (int i = 0; i < quantity.length; i++) {
      if (quantity[i] > 0) {
        Map<String, dynamic> order = {
          "qty": quantity[i],
          "product_id": ids[i],
          "additional_product_id": additionals[0],
          "additional_product_qty": 1,
        };
        orders[index.toString()] = order;
        index++;
      } else {
        ids.removeAt(i);
        quantity.removeAt(i);
        i--;
      }
    }

    // Convert the orders object to JSON
    var orderData = jsonEncode({"user_id": 1, "orders": orders});

    try {
      var response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            // 'Authorization':
            // 'Bearer $token', // Include the token in the request header
          },
          body: orderData);

      if (response.statusCode == 200) {
        // Success!
      } else {
        // Something went wrong
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  int finalIndex = 25;
  double mainDishPrice = 0;
  int additionalfinalIndex = 250;
  int additionalfinalId = 250;
  int selectedQty = 0;
  List quantity = [];
  bool active_ac = false;
  List ids = [];
  List additionals = [];
  List addedIndexes = [];

  int switchnum = 1;

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
    return Scaffold(
        extendBody: true,
        floatingActionButton: SizedBox(
          width: 70,
          height: 70,
          child: FloatingActionButton(
            onPressed: () {
              setState(() {
                daysLeft != null && daysLeft != 'Inactive'
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => QrPage(
                                qty: quantity, ids: ids, adds: additionals)),
                      )
                    : Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileContent()),
                      );
                currentTab = 0; // Set the selected tab index
              });
            },
            backgroundColor: const Color.fromARGB(255, 239, 127, 26),
            child: const Icon(Icons.done, size: 45),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 74, 75, 77).withOpacity(0.11),
                spreadRadius: 15,
                blurRadius: 15,
                offset: const Offset(0, 3), // Set the desired shadow offset
              ),
            ],
          ),
          child: BottomAppBar(
            elevation: 0,
            shape: const CircularNotchedRectangle(),
            color: Colors.white,
            notchMargin: 20,
            child: SizedBox(
              height: 90,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    width: 70,
                    child: MaterialButton(
                      minWidth: 5,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MapScreen()),
                        );
                        setState(() {
                          currentTab = 1; // Set the selected tab index
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(
                            size: 20,
                            const AssetImage('assets/images/map.png'),
                            color:
                                currentTab == 1 ? Colors.orange : Colors.grey,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            textAlign: TextAlign.center,
                            AppTags.map.tr,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 11,
                                color: currentTab == 1
                                    ? Colors.orange
                                    : Colors.grey,
                                fontFamily: 'metro-reg'),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 85,
                    child: MaterialButton(
                      minWidth: 5,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AllCategory()),
                        );
                        setState(() {
                          currentTab = 2; // Set the selected tab index
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(
                            size: 20,
                            const AssetImage('assets/images/bag.png'),
                            color:
                                currentTab == 2 ? Colors.orange : Colors.grey,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            textAlign: TextAlign.center,
                            AppTags.topDeals.tr,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 11,
                                color: currentTab == 2
                                    ? Colors.orange
                                    : Colors.grey,
                                fontFamily: 'metro-reg'),
                          )
                        ],
                      ),
                    ),
                  ),
                  MaterialButton(
                    minWidth: 15,
                    onPressed: () {
                      setState(() {
                        currentTab = 1; // Set the selected tab index
                      });
                    },
                    child: const Column(),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 85,
                    child: MaterialButton(
                      minWidth: 5,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfileContent()),
                        );
                        setState(() {
                          currentTab = 3; // Set the selected tab index
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(
                            size: 20,
                            const AssetImage('assets/images/userimage.png'),
                            color:
                                currentTab == 3 ? Colors.orange : Colors.grey,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            textAlign: TextAlign.center,
                            AppTags.profile.tr,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 11,
                                color: currentTab == 3
                                    ? Colors.orange
                                    : Colors.grey,
                                fontFamily: 'metro-reg'),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: MaterialButton(
                      minWidth: 5,
                      onPressed: () {
                        _showPopup(context);
                        setState(() {
                          currentTab = 4; // Set the selected tab index
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ImageIcon(
                            size: 20,
                            const AssetImage('assets/images/more.png'),
                            color:
                                currentTab == 4 ? Colors.orange : Colors.grey,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            textAlign: TextAlign.center,
                            AppTags.socialNetworks.tr,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 11,
                                color: currentTab == 4
                                    ? Colors.orange
                                    : Colors.grey,
                                fontFamily: 'metro-reg'),
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
        body: Stack(children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
              image: NetworkImage(widget.imgurl.toString()),
              fit: BoxFit.cover,
            )),
            child: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('assets/images/shadow_zemodan.png'),
                fit: BoxFit.cover,
              )),
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: FutureBuilder(
                    future: getProductsByCategory(
                        widget.id!), // your function that returns a future
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            const SizedBox(
                              height: 35,
                            ),
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
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                // const SizedBox(
                                //   height: 70,
                                // ),
                                Center(
                                    child: Padding(
                                  padding: const EdgeInsets.only(top: 70.0),
                                  child: Text(
                                    AppTags.chooseProduct.tr,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'bpg',
                                        color: Colors.white),
                                  ),
                                )),
                                const Spacer(),
                                const SizedBox(
                                  width: 25,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 190,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 496,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft:
                                      Radius.circular(50.0), // top-left corner
                                  topRight:
                                      Radius.circular(50.0), // top-right corner
                                  bottomRight: Radius.circular(
                                      0.0), // bottom-right corner
                                  bottomLeft: Radius.circular(
                                      0.0), // bottom-left corner
                                ),
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        widget.title.toString(),
                                        style: const TextStyle(
                                            fontSize: 22,
                                            fontFamily: 'metro-bold',
                                            color: Color.fromARGB(
                                                255, 74, 75, 77)),
                                      ),
                                      const Spacer(),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        widget.category.toString(),
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontFamily: 'bpg',
                                            color: Colors.orange),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        AppTags.deals.tr,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'metro-bold',
                                            color:
                                                Color.fromARGB(255, 74, 75, 77),
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  switchnum == 1
                                      ? SizedBox(
                                          height: 290,
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
                                                return Column(
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
                                                                : const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    246,
                                                                    246,
                                                                    246),
                                                        child: Row(
                                                          children: [
                                                            const SizedBox(
                                                              width: 20,
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 8.0),
                                                              child:
                                                                  Image.network(
                                                                snapshot.data![
                                                                            'data']
                                                                        [index]
                                                                    ['image'],
                                                                width: 90,
                                                                height: 90,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 15,
                                                            ),
                                                            SizedBox(
                                                              width: 100,
                                                              child: Text(
                                                                snapshot.data![
                                                                        'data']
                                                                        [index][
                                                                        'title']
                                                                    .toString(),
                                                                maxLines: 2,
                                                                style: TextStyle(
                                                                    color: finalIndex ==
                                                                            index
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black,
                                                                    fontSize:
                                                                        13,
                                                                    fontFamily:
                                                                        'bpg',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              ),
                                                            ),
                                                            const Spacer(),
                                                            Row(
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      active_ac =
                                                                          true;
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
                                                                        differentDishes +=
                                                                            1;
                                                                        addedIndexes
                                                                            .add(index);
                                                                      } else if (quantity[
                                                                              index] ==
                                                                          0) {
                                                                        addedIndexes.removeWhere((element) =>
                                                                            element ==
                                                                            index);
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
                                                                                18,
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
                                                                        '${quantity[index]}',
                                                                        style: TextStyle(
                                                                            color: finalIndex == index
                                                                                ? Colors.white
                                                                                : Colors.black,
                                                                            fontSize: 15,
                                                                            fontFamily: 'bpg',
                                                                            fontWeight: FontWeight.w500),
                                                                      )
                                                                    : Container(),
                                                                const SizedBox(
                                                                  width: 5,
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    active_ac =
                                                                        true;
                                                                    if (differentAdditionalDishes ==
                                                                            3 &&
                                                                        !addedIndexes
                                                                            .contains(index)) {
                                                                      setState(
                                                                          () {
                                                                        if (addedIndexes
                                                                            .contains(index)) {
                                                                          quantity[index] +=
                                                                              1;
                                                                        }
                                                                      });

                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
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
                                                                        if (daysLeft !=
                                                                                null &&
                                                                            daysLeft !=
                                                                                'Inactive') {
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => const ProfileContent()),
                                                                          );
                                                                        } else {
                                                                          finalIndex =
                                                                              index;

                                                                          mainDishPrice = double.parse(snapshot
                                                                              .data!['data'][index]['formatted_price']
                                                                              .toString());
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
                                                                      SizedBox(
                                                                    width: 22,
                                                                    height: 22,
                                                                    child: Center(
                                                                        child: Icon(
                                                                      Icons.add,
                                                                      size: 18,
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
                                                              width: snapshot
                                                                          .data![
                                                                              'data']
                                                                              [
                                                                              index]
                                                                              [
                                                                              'formatted_price']
                                                                          .toString()
                                                                          .length ==
                                                                      1
                                                                  ? 12
                                                                  : snapshot.data!['data'][index]['formatted_price']
                                                                              .toString()
                                                                              .length ==
                                                                          2
                                                                      ? 4
                                                                      : 0,
                                                            ),
                                                            Row(
                                                              children: [
                                                                quantity[index] !=
                                                                        0
                                                                    ? Text(
                                                                        style: TextStyle(
                                                                            color: finalIndex == index
                                                                                ? Colors.white
                                                                                : Colors.black),
                                                                        (snapshot.data!['data'][index]['formatted_price'] * quantity[index]).toString() +
                                                                            '₾'.toString(),
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                      )
                                                                    : Text(
                                                                        style: TextStyle(
                                                                            color: finalIndex == index
                                                                                ? Colors.white
                                                                                : Colors.black),
                                                                        (snapshot.data!['data'][index]['formatted_price']).toString() +
                                                                            '₾'.toString(),
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                      ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              width: 20,
                                                            )
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
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Container(
                                              width: 350,
                                              height: 225,
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
                                                    fit: BoxFit.cover),
                                              ),
                                              child: Center(
                                                child: Row(
                                                  children: [
                                                    const SizedBox(
                                                      width: 50,
                                                    ),
                                                    Expanded(
                                                      child: SizedBox(
                                                          height: 200,
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
                                                                                  return GestureDetector(
                                                                                    onTap: () {
                                                                                      setState(() {
                                                                                        additionalfinalIndex = index;
                                                                                        additionalfinalId = snapshot.data![index]['id'];
                                                                                        additionals.add(additionalfinalId);
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
                                                                                              const SizedBox(height: 20),
                                                                                              Row(
                                                                                                children: [
                                                                                                  Container(
                                                                                                    width: 50,
                                                                                                    height: 50,
                                                                                                    decoration: BoxDecoration(
                                                                                                      borderRadius: BorderRadius.circular(25), // Half of the width/height for a circular shape
                                                                                                    ),
                                                                                                    child: ClipRRect(
                                                                                                      borderRadius: BorderRadius.circular(25), // Same as above for the child
                                                                                                      child: Image.network(
                                                                                                        snapshot.data![index]['image'].toString(),
                                                                                                        fit: BoxFit.cover,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  const SizedBox(
                                                                                                    width: 15,
                                                                                                  ),
                                                                                                  SizedBox(
                                                                                                    width: 80,
                                                                                                    child: Text(
                                                                                                      snapshot.data![index]['title'].toString(),
                                                                                                      style: TextStyle(fontFamily: 'metro-bold', fontSize: 13, fontWeight: FontWeight.w400, color: additionalfinalIndex == index ? Colors.white : Colors.black),
                                                                                                    ),
                                                                                                  ),
                                                                                                  SizedBox(
                                                                                                    width: 35,
                                                                                                    child: Text(
                                                                                                      snapshot.data![index]['formatted_price'].toString() + '₾',
                                                                                                      style: TextStyle(fontFamily: 'metro-bold', fontSize: 10, fontWeight: FontWeight.w300, color: additionalfinalIndex == index ? Colors.white : Colors.black),
                                                                                                    ),
                                                                                                  ),
                                                                                                  const SizedBox(
                                                                                                    width: 5,
                                                                                                  ),
                                                                                                  const SizedBox(
                                                                                                    width: 50,
                                                                                                    child: Icon(
                                                                                                      Icons.add,
                                                                                                      size: 18,
                                                                                                      color: Color.fromARGB(255, 252, 96, 17),
                                                                                                    ),
                                                                                                  ),
                                                                                                  const SizedBox(width: 5),
                                                                                                ],
                                                                                              ),
                                                                                              const SizedBox(height: 20),
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
                                                                            RefreshProgressIndicator(),
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
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ));
                    },
                  )),
            ),
          ),
          Stack(alignment: Alignment.centerRight, children: [
            const Padding(
              padding: EdgeInsets.only(top: 630, right: 850),
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
                onPressed: () {},
                icon: const Icon(Icons.favorite,
                    color: Color(0xffe07527), size: 27),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 135, top: 110),
              child: Container(
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
              child: Container(
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
              child: Container(
                width: 45,
                child: IconButton(
                    onPressed: () {
                      // Replace '1234567890' with the phone number you want to call
                      navigateTo(widget.latlong);
                    },
                    icon: Image.asset('assets/images/loc.png')),
              ),
            )
          ]),
        ]));
  }
}
