// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:hot_card/src/servers/network_service.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:hot_card/src/utils/app_tags.dart';
import 'package:get/get.dart';
import '../../data/local_data_helper.dart';

class QrPage extends StatefulWidget {
  final List qty;
  final List ids;
  final List adds;
  final String idd;

  const QrPage(
      {super.key,
      required this.qty,
      required this.ids,
      required this.adds,
      required this.idd});

  @override
  State<QrPage> createState() => _QrPageState();
}

class _QrPageState extends State<QrPage> {
  int counter = 60;
  String? qrCodeData;

  @override
  void initState() {
    super.initState();
  }

  Future fetchUserProfile() async {
    final response = await http.get(Uri.parse(
        '${NetworkService.apiUrl}/user/profile?token=${LocalDataHelper().getUserToken()}'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      fetchUserProfile();
    }
  }

  Future<List<dynamic>> forEach(Map productIds) async {
    List<dynamic> results = [];

    for (var id in productIds.keys) {
      var data = await fetchData(id.toString());
      results.add(data);
    }

    return results;
  }

  Future<List<dynamic>> fetchDataFromApi(Map<int, dynamic> data) async {
    List<dynamic> results = [];
    for (int id in data.keys) {
      final response = await http
          .get(Uri.parse('${NetworkService.apiUrl}/product-details/$id'));
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        results.add(responseData);
      } else {}
    }
    return results;
  }

  Future<dynamic> fetchData(String id) async {
    final response = await http
        .get(Uri.parse('${NetworkService.apiUrl}/product-details/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      fetchData(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    List qty = widget.qty;
    List ids = widget.ids;
    List adds = widget.adds;
    String idd = widget.idd;

    Map combined = Map.fromIterables(ids, qty);

    Map<int, int> combinedWithoutZero = {};
    combined.forEach((key, value) {
      if (value > 0) {
        combinedWithoutZero[key] = value;
      }
    });

    Map<dynamic, int> sachurkebi = {};

    for (var item in adds) {
      if (sachurkebi.containsKey(item)) {
        sachurkebi[item] = (sachurkebi[item] ?? 0) + 1;
      } else {
        sachurkebi[item] = 1;
      }
    }
    Map<String, dynamic> jsonMap = json.decode(idd);
    return Scaffold(
      backgroundColor: const Color(0xffe07527),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 70,
            ),
            Center(
              child: Text(
                AppTags.details.tr,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'bpg',
                    color: Colors.white),
              ),
            ),
            Column(
              children: [
                const SizedBox(
                  height: 35,
                ),
                Center(
                  child: Text(
                    AppTags.order.tr,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'bpg',
                        color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                FutureBuilder(
                  future: forEach(combinedWithoutZero),
                  builder: (context, snapshot) {
                    try {
                      if (snapshot.hasData) {
                        return Column(
                          children:
                              List.generate(snapshot.data!.length, (index) {
                            var element = snapshot.data![index];
                            return SizedBox(
                                height: 50,
                                child: Text(
                                  '${element['data']['title']} x ${combinedWithoutZero[element['data']['id']].toString()}',
                                  style: const TextStyle(
                                      fontFamily: 'bpg', color: Colors.white),
                                ));
                          }),
                        );
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }

                      return const CircularProgressIndicator();
                    } catch (e) {
                      return const Center(
                          child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator()));
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(
                    AppTags.forPresent.tr,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'bpg',
                        color: Colors.white),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                FutureBuilder(
                  future: forEach(sachurkebi),
                  builder: (context, snapshot) {
                    try {
                      if (snapshot.hasData) {
                        return Column(
                          children:
                              List.generate(snapshot.data!.length, (index) {
                            var element = snapshot.data![index];
                            return SizedBox(
                                height: 50,
                                child: SingleChildScrollView(
                                    child: Text(
                                  '${element['data']['title']} x ${sachurkebi[element['data']['id']].toString()}',
                                  style: const TextStyle(
                                      fontFamily: 'bpg', color: Colors.white),
                                )));
                          }),
                        );
                      } else if (snapshot.hasError) {
                        return Column(
                          children:
                              List.generate(snapshot.data!.length, (index) {
                            var element = snapshot.data![index];
                            return SizedBox(
                                height: 50,
                                child: SingleChildScrollView(
                                    child: Text(
                                  '${element['data']['title']} x ${sachurkebi[element['data']['id']].toString()}',
                                  style: const TextStyle(
                                      fontFamily: 'bpg', color: Colors.white),
                                )));
                          }),
                        );
                      }

                      return const CircularProgressIndicator();
                    } catch (e) {
                      return const Center(
                          child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator()));
                    }
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                Center(
                  child: QrImageView(
                    data:
                        'https://julius.ltd/hotcard/api/v100/invoice-view/${jsonMap['data']['id']}',
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xffe07527),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Center(
                    child: CountdownTimer(
                  endTime: DateTime.now().millisecondsSinceEpoch +
                      60000, // 60 seconds
                  textStyle: const TextStyle(fontSize: 48, color: Colors.white),
                  onEnd: () {},
                )),
              ],
            )
          ],
        ),
      ),
    );
  }
}
