 import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../config.dart';
import '../utils/app_tags.dart';
import 'api_exception.dart';

class NetworkService {
  static String apiUrl = "${Config.apiServerUrl}/v100";
  static String walletRechargeUrl =
  Config.apiServerUrl.substring(0, Config.apiServerUrl.length - 4);

  Future fetchJsonData(String url) {
    return _getData(url);
  }

  Future<dynamic> _getData(String url) async {
    dynamic responseJson;
    try {
      var headers = {"apiKey": Config.apiKey};
      final response = await http.get(Uri.parse(url), headers: headers);
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException(AppTags.noInternetConnection.tr);
    }
    return responseJson;
  }

  Future<dynamic> postData(String url, dynamic data) async {
    dynamic responseJson;
    try {
      var headers = {
        "apiKey": Config.apiKey,
        "Content-Type": "application/json",
      };
      final response = await http.post(Uri.parse(url),
          headers: headers, body: json.encode(data));
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException(AppTags.noInternetConnection.tr);
    }
    return responseJson;
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException(
            '${AppTags.errorOccurredWhileCommunicationWithServer.tr} : ${response.statusCode}');
    }
  }
}

