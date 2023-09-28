import 'package:flutter/material.dart';
import 'package:hot_card/src/models/check_Payment_model.dart';
import 'package:http/http.dart' as http;

class PaymentProvider with ChangeNotifier {
  String paymentMessage = "";
  CheckPaymentModel? checkPaymentModel;
  mCheckPaymentFunction({required String payID, required String token}) async {
    CheckPaymentModel? checkPaymentModel;
    String paymentMessage = "";
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
        this.checkPaymentModel = checkPaymentModel;
        if (checkPaymentModel.status != "Failed") {
          paymentMessage = "Success";
          this.paymentMessage = paymentMessage;
          notifyListeners();
        } else {
          paymentMessage = "Unsuccess";
          this.paymentMessage = paymentMessage;
          notifyListeners();
        }
        notifyListeners();
      } else {
        print(response.reasonPhrase);
        paymentMessage = "Unsuccess";
        this.paymentMessage = paymentMessage;
        notifyListeners();
      }
    } catch (e) {
      paymentMessage = "Unsuccess";
      this.paymentMessage = paymentMessage;
      notifyListeners();
    }
  }
}
