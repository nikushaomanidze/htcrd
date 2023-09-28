import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hot_card/src/utils/app_tags.dart';
import 'package:http/http.dart' as http;

import '../../controllers/profile_content_controller.dart';
import '../../data/local_data_helper.dart';
import '../../servers/network_service.dart';

class UsersList extends StatefulWidget {
  const UsersList({super.key});

  @override
  State<UsersList> createState() => _UsersListState();
}

String allWordsCapitilize(String str) {
  return str.toLowerCase().split(' ').map((word) {
    String leftText = (word.length > 1) ? word.substring(1, word.length) : '';
    return word[0].toUpperCase() + leftText;
  }).join(' ');
}

var jsonDta = {};
const String referralUrl = '/user/referral_users_lists/';
final ProfileContentController _profileContentController =
    Get.put(ProfileContentController());

Future<Map> sendPostRequest() async {
  String dd =
      _profileContentController.profileDataModel.value.data!.referralId!;
  var url =
      "${NetworkService.apiUrl}$referralUrl$dd?token=${LocalDataHelper().getUserToken()}";
  var headers = {'Content-Type': 'application/json'};

  // Send POST request
  var response = await http.post(Uri.parse(url), headers: headers);

  jsonDta = jsonDecode(response.body);
  return jsonDta;
}

class _UsersListState extends State<UsersList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTags.listOfInvitedFriends.tr,
          style: const TextStyle(fontSize: 17),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: FutureBuilder(
          future: sendPostRequest(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: jsonDta['data'].length,
                    itemBuilder: (context, index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color:
                            jsonDta['data'][index]['card_status'] == 'Inactive'
                                ? const Color.fromARGB(255, 204, 52, 52)
                                : const Color.fromARGB(255, 13, 149, 121),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: <Widget>[
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                allWordsCapitilize(
                                    jsonDta['data'][index]['full_name']),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                jsonDta['data'][index]['phone'],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                jsonDta['data'][index]['card_status'],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            } else {
              // show a loading indicator while the data is being fetched
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          }),
    );
  }
}
