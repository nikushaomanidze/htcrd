// ignore_for_file: file_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hot_card/src/_route/routes.dart';
import 'package:hot_card/src/screen/dashboard/dashboard_screen.dart';
import 'package:provider/provider.dart';

import '../../Providers/MapProvider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, value, child) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Get.to(DashboardScreen()),),
        ),
        extendBodyBehindAppBar: true,
        extendBody: true,
        backgroundColor: Colors.transparent,
        body: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(value.position!.latitude, value.position!.longitude),
            // target: LatLng(41.701707, 44.823307),
            zoom: 14.4746,
          ),
          markers: Set<Marker>.of(value.restaurantMarkers),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
    );
  }
}
