import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hot_card/src/screen/home/category/all_category_screen.dart';
// import 'package:hot_card/src/screen/home/home_screen.dart';
import 'package:hot_card/src/utils/app_tags.dart';

import '../../controllers/cart_content_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../Map/MapScreens.dart';
import '../home/mtla_home.dart';
import '../profile/profile_screen.dart';

import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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

  final homeController = Get.find<DashboardController>();
  final cartContentController = Get.put(CartContentController());
  final PageStorageBucket bucket = PageStorageBucket();
  int currentTab = 0;
  bool isPressed = false;

  final List<Widget> screens = [
    const MtlaHome(),
    const MapScreen(),
    const AllCategory(),
    const ProfileContent(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: PageStorage(
          bucket: bucket,
          child: screens[currentTab]), // Use the selected tab's screen
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              currentTab = 0; // Set the selected tab index
            });
          },
          backgroundColor: currentTab == 0
              ? const Color.fromARGB(255, 239, 127, 26)
              : Colors.grey,
          child: const Icon(Icons.home_rounded, size: 45),
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
                      setState(() {
                        isPressed = false;

                        currentTab = 1; // Set the selected tab index
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ImageIcon(
                          size: 20,
                          const AssetImage('assets/images/map.png'),
                          color: currentTab == 1 ? Colors.orange : Colors.grey,
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
                              color:
                                  currentTab == 1 ? Colors.orange : Colors.grey,
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
                      setState(() {
                        isPressed = false;
                        currentTab = 2; // Set the selected tab index
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ImageIcon(
                          size: 20,
                          const AssetImage('assets/images/bag.png'),
                          color: currentTab == 2 ? Colors.orange : Colors.grey,
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
                              color:
                                  currentTab == 2 ? Colors.orange : Colors.grey,
                              fontFamily: 'metro-reg'),
                        )
                      ],
                    ),
                  ),
                ),
                // MaterialButton(
                //   minWidth: 15,
                //   onPressed: () {
                //     setState(() {
                //       currentTab = 1; // Set the selected tab index
                //     });
                //   },
                //   child: const Column(),
                // ),
                const Spacer(),
                SizedBox(
                  width: 85,
                  child: MaterialButton(
                    minWidth: 5,
                    onPressed: () {
                      setState(() {
                        isPressed = false;

                        currentTab = 3; // Set the selected tab index
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ImageIcon(
                          size: 20,
                          const AssetImage('assets/images/userimage.png'),
                          color: currentTab == 3 ? Colors.orange : Colors.grey,
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
                              color:
                                  currentTab == 3 ? Colors.orange : Colors.grey,
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
                        isPressed = true;
                        currentTab = 0;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ImageIcon(
                          size: 20,
                          const AssetImage('assets/images/more.png'),
                          color:
                              isPressed == true ? Colors.orange : Colors.grey,
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
                              color: isPressed == true
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
    );
  }
}
