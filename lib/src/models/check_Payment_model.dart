// To parse this JSON data, do
//
//     final checkPaymentModel = checkPaymentModelFromJson(jsonString);

// ignore_for_file: file_names

import 'dart:convert';

CheckPaymentModel checkPaymentModelFromJson(String str) =>
    CheckPaymentModel.fromJson(json.decode(str));

String checkPaymentModelToJson(CheckPaymentModel data) =>
    json.encode(data.toJson());

class CheckPaymentModel {
  String payId;
  String merchantPaymentId;
  String status;
  String currency;
  String resultCode;
  double amount;
  double confirmedAmount;
  int returnedAmount;
  dynamic links;
  String transactionId;
  int paymentMethod;
  bool preAuth;
  dynamic recurringCard;
  String paymentCardNumber;
  dynamic binHash;
  String rrn;
  dynamic extra;
  dynamic extra2;
  String initiator;
  dynamic operationType;
  int httpStatusCode;
  dynamic developerMessage;
  dynamic userMessage;

  CheckPaymentModel({
    required this.payId,
    required this.merchantPaymentId,
    required this.status,
    required this.currency,
    required this.resultCode,
    required this.amount,
    required this.confirmedAmount,
    required this.returnedAmount,
    required this.links,
    required this.transactionId,
    required this.paymentMethod,
    required this.preAuth,
    required this.recurringCard,
    required this.paymentCardNumber,
    required this.binHash,
    required this.rrn,
    required this.extra,
    required this.extra2,
    required this.initiator,
    required this.operationType,
    required this.httpStatusCode,
    required this.developerMessage,
    required this.userMessage,
  });

  factory CheckPaymentModel.fromJson(Map<String, dynamic> json) =>
      CheckPaymentModel(
        payId: json["payId"],
        merchantPaymentId: json["merchantPaymentId"],
        status: json["status"],
        currency: json["currency"],
        resultCode: json["resultCode"],
        amount: json["amount"]?.toDouble(),
        confirmedAmount: json["confirmedAmount"],
        returnedAmount: json["returnedAmount"],
        links: json["links"],
        transactionId: json["transactionId"],
        paymentMethod: json["paymentMethod"],
        preAuth: json["preAuth"],
        recurringCard: json["recurringCard"],
        paymentCardNumber: json["paymentCardNumber"],
        binHash: json["binHash"],
        rrn: json["rrn"],
        extra: json["extra"],
        extra2: json["extra2"],
        initiator: json["initiator"],
        operationType: json["operationType"],
        httpStatusCode: json["httpStatusCode"],
        developerMessage: json["developerMessage"],
        userMessage: json["userMessage"],
      );

  Map<String, dynamic> toJson() => {
        "payId": payId,
        "merchantPaymentId": merchantPaymentId,
        "status": status,
        "currency": currency,
        "resultCode": resultCode,
        "amount": amount,
        "confirmedAmount": confirmedAmount,
        "returnedAmount": returnedAmount,
        "links": links,
        "transactionId": transactionId,
        "paymentMethod": paymentMethod,
        "preAuth": preAuth,
        "recurringCard": recurringCard,
        "paymentCardNumber": paymentCardNumber,
        "binHash": binHash,
        "rrn": rrn,
        "extra": extra,
        "extra2": extra2,
        "initiator": initiator,
        "operationType": operationType,
        "httpStatusCode": httpStatusCode,
        "developerMessage": developerMessage,
        "userMessage": userMessage,
      };
}
