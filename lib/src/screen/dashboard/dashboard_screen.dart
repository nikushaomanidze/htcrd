import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../controllers/profile_content_controller.dart';
import 'package:hot_card/src/screen/home/category/all_category_screen.dart';
import 'package:hot_card/src/screen/profile/wallet/my_wallet_screen.dart';
// import 'package:hot_card/src/screen/home/home_screen.dart';
import 'package:hot_card/src/utils/app_tags.dart';

import '../../controllers/cart_content_controller.dart';
import '../../controllers/dashboard_controller.dart';
import '../Map/MapScreens.dart';
import '../home/mtla_home.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final homeController = Get.find<DashboardController>();
  final cartContentController = Get.put(CartContentController());
  final PageStorageBucket bucket = PageStorageBucket();
  int currentTab = 0;
  bool isPressed = false;

  final ProfileContentController _profileContentController =
      Get.put(ProfileContentController());


  Future<void> _checkAndRequestLocationPermission(
      BuildContext context) async {
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
                child: const Text(
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
              title: const Text(
                'ლოკაციის გაზიარება გამორთულია',
                // style: TextStyle(color: Colors.orange),
              ),
              content: const Text(
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
       // Navigator.push(context, route);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const MtlaHome(),
      const MapScreen(),
      const AllCategory(),
      const ProfileContent(),
      _profileContentController.user!.value.data != null
          ? MyWalletScreen(userDataModel: _profileContentController.user!.value)
          : const ProfileContent(),
    ];

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
              : Color.fromARGB(255, 239, 127, 26),
          child: const Icon(Icons.home_rounded, size: 45, color: Colors.white,),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: Platform.isIOS
            ? const BoxDecoration()
            : BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color.fromARGB(255, 74, 75, 77).withOpacity(0.11),
                    spreadRadius: 15,
                    blurRadius: 15,
                    offset: const Offset(0, 3), // Set the desired shadow offset
                  ),
                ],
              ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          color: const Color.fromARGB(255, 239, 127, 26),
          notchMargin: 20,
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  width: 70,
                  child: MaterialButton(
                    minWidth: 5,
                    onPressed: () {
                      _checkAndRequestLocationPermission(context);
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
                          color: currentTab == 1 ? Colors.white54 : Colors.white,
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
                                  currentTab == 1 ? Colors.white54 : Colors.white,
                              fontFamily: 'bpg'),
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
                          color: currentTab == 2 ? Colors.white54 : Colors.white,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        FittedBox(
                          fit: BoxFit
                              .scaleDown, // This scales the text down to fit within the available space
                          child: Text(
                            AppTags.topDeals.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  currentTab == 2 ? Colors.white54 : Colors.white,
                              fontFamily: 'bpg',
                            ),
                          ),
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
                          color: currentTab == 3 ? Colors.white54 : Colors.white,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            textAlign: TextAlign.center,
                            AppTags.profile.tr,
                            maxLines: 2,
                            style: TextStyle(
                                fontSize: 11,
                                color: currentTab == 3
                                    ? Colors.white54
                                    : Colors.white,
                                fontFamily: 'bpg'),
                            softWrap:
                                true, // This allows the text to wrap onto multiple lines if necessary
                          ),
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
                      // _showPopup(context);
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: ((context) => MyWalletScreen(
                      //             userDataModel:
                      //                 _profileContentController.user!.value))));
                      setState(() {
                        isPressed = true;
                        currentTab = 4;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ImageIcon(
                          size: 20,
                          const AssetImage('assets/images/credit-card.png'),
                          color: currentTab == 4 ? Colors.white54 : Colors.white,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          AppTags.dashboardCard.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9.5,
                            color:
                                currentTab == 4 ? Colors.white54 : Colors.white,
                            fontFamily: 'bpg',
                          ),
                          softWrap: true,
                          maxLines: 2,
                        ),
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
