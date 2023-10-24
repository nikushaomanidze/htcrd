import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hot_card/src/screen/home/category/product_by_category_screen.dart';
import 'package:http/http.dart' as http;

import '../models/GetCategoryLocationModel.dart';
import 'package:url_launcher/url_launcher.dart';

class MapProvider with ChangeNotifier {
  Position? position;
  mUpdateCurrentLocation(Position position) {
    this.position = position;
    notifyListeners();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  static void navigateTo(double lat, double lng) async {
    var uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      throw 'Could not launch ${uri.toString()}';
    }
  }

  List<Marker> restaurantMarkers = [];
  mUpdateAllMarkers({required BuildContext context}) async {
    List<Marker> restaurantMarkers = [];
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/marker.png', 200);
    final Uint8List personIcon =
        await getBytesFromAsset('assets/images/location.png', 200);
    for (var element in getCategoryLocationModel!.data.categories) {
      for (var e in element.subCategories!) {
        if (e.latlong.toString().contains(",")) {
          var p = 0.017453292519943295;
          var a = 0.5 -
              cos((double.parse(e.latlong!.split(",")[0]) -
                          position!.latitude) *
                      p) /
                  2 +
              cos(position!.latitude * p) *
                  cos(double.parse(e.latlong!.split(",")[0]) * p) *
                  (1 -
                      cos((double.parse(e.latlong!.split(",")[1]) -
                              position!.longitude) *
                          p)) /
                  2;
          double location = 12742 * asin(sqrt(a));
          restaurantMarkers.add(
            Marker(
              infoWindow: InfoWindow(
                title: e.title,
                onTap: () async {
                  Get.to(ProductByCategory(
                    id: e.id,
                    title: e.title.toString(),
                    imgurl: e.banner.toString(),
                    category: e.categoryFilter.toString(),
                    latlong: e.latlong.toString(),
                    number: e.number.toString(),
                    soc_fb: e.soc_fb.toString(),
                    soc_in: e.soc_in.toString(),
                    soc_yt: e.soc_yt.toString(),
                  ));
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (_) => ProductByCategory(
                  // id: e.id,
                  // title: e.title.toString(),
                  // imgurl: e.banner.toString(),
                  // category: e.categoryFilter.toString(),
                  // latlong: e.latlong.toString(),
                  // number: e.number.toString(),
                  // soc_fb: e.soc_fb.toString(),
                  // soc_in: e.soc_in.toString(),
                  // soc_yt: e.soc_yt.toString(),
                  //     ),
                  //   ),
                  // );
                  // navigateTo(double.parse(e.latlong!.split(",")[0]),
                  //     double.parse(e.latlong!.split(",")[1]));
                },
              ),
              onTap: () {},
              markerId: MarkerId(e.slug),
              icon: BitmapDescriptor.fromBytes(markerIcon),
              // infoWindow: InfoWindow(title: "Distance : ${location}"),
              position: LatLng(double.parse(e.latlong!.split(",")[0]),
                  double.parse(e.latlong!.split(",")[1])),
            ),
          );
        }
      }
    }
    restaurantMarkers.add(
      Marker(
        markerId: const MarkerId("Me"),
        infoWindow: const InfoWindow(title: "Me"),
        icon: BitmapDescriptor.fromBytes(personIcon),
        // position: LatLng(41.701707, 44.823307),
        position: LatLng(position!.latitude, position!.longitude),
      ),
    );
    this.restaurantMarkers = restaurantMarkers;
    notifyListeners();
  }

  GetCategoryLocationModel? getCategoryLocationModel;
  mGetLocationCategory() async {
    GetCategoryLocationModel? getCategoryLocationModel;
    var headers = {
      'Content-Type': 'application/json',
      'Cookie':
          'hot_card_session=eyJpdiI6ImRSN3pqTDZaZ2h6RjN1SUVOa1NhaXc9PSIsInZhbHVlIjoiYkk4KytoTTh3WXg1Y0haN0NpNEQxc2w4eVA3d2lCdnlEamx6ajNjazVWVUlJWGN4U1JsNmZtTzZXNFZzQTZXd1dsQ0doTjBnbjdESFdzTlIyR2lWdDkwVUN6STdHVWxuWkZLcmEzSVJEZ2ltOUI4UEV0UHJ3UDEzeXNDS2h6Q20iLCJtYWMiOiJkYzc2ZTRmNjBiMzU0MDdkMTVjZmNmODAyYzg5OTMzOTRlNDhjYmJkZDk5NzFmNWJmZmY0OWMwNjRmNzQwMDkwIiwidGFnIjoiIn0%3D',
    };
    var request = http.Request(
        'GET', Uri.parse('https://julius.ltd/hotcard/api/v100/category/all'));
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      String value = await response.stream.bytesToString();
      getCategoryLocationModel = getCategoryLocationModelFromJson(value);
      this.getCategoryLocationModel = getCategoryLocationModel;
      notifyListeners();
    } else {}
  }
}
