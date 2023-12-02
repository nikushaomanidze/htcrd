// ignore_for_file: file_names

import 'package:flutter/foundation.dart';
import 'package:hot_card/src/models/check_Payment_model.dart';
import 'package:http/http.dart' as http;

class PaymentProvider with ChangeNotifier {
  String paymentMessage = "";
  CheckPaymentModel? checkPaymentModel;

  Future<CheckPaymentModel?> mCheckPaymentFunction(
      {required String payID, required String token}) async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'apikey': '2UwIqaRBAfEQ8y1Po8bn9y8n7ABMFWJR',
        'Authorization': 'Bearer $token'
      };
      var request = http.Request(
          'GET', Uri.parse('https://api.tbcbank.ge/v1/tpay/payments/$payID'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String value = await response.stream.bytesToString();
        checkPaymentModel = checkPaymentModelFromJson(value);
        checkPaymentModel = checkPaymentModel;

        if (checkPaymentModel?.status != "Failed") {
          paymentMessage = "Success";
          paymentMessage = paymentMessage;
          notifyListeners();
          return checkPaymentModel; // Return the data here
        } else {
          paymentMessage = "Unsuccess";
          paymentMessage = paymentMessage;
          notifyListeners();
        }
      } else {
        if (kDebugMode) {
          print(response.reasonPhrase);
        }
        paymentMessage = "Unsuccess";
        paymentMessage = paymentMessage;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      paymentMessage = "Unsuccess";
      paymentMessage = paymentMessage;
      notifyListeners();
    }

    return null; // Return null in case of failure
  }
}
