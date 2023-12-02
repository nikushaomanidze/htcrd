class UserDataModel {
  UserDataModel({
    this.success,
    this.message,
    this.data,
  });

  UserDataModel.fromJson(dynamic json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  bool? success;
  String? message;
  Data? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }
}

class Data {
  Data(
      {this.token = "",
      this.userId,
      this.firstName,
      this.lastName,
      this.image,
      this.phone,
      this.email,
      this.favourites,
      this.notifications,
      this.currencyCode,
      this.cardStatus,
      this.cardNumber,
      this.gender,
      this.momwveviUserisId,
      this.dateOfBirth});

  Data.fromJson(dynamic json) {
    token = json['token'];
    userId = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    image = json['image'] ?? "";
    phone = json['phone'];
    email = json['email'];
    cardNumber = json['card_number'];
    cardStatus = json['card_status'];
    favourites = json['favourites'];
    notifications = json['notifications'];
    currencyCode = json['currency_code'];
    dateOfBirth = json['date_of_birth'] ?? "Select Date";
    gender = json['gender'] ?? "Select Gender";
    momwveviUserisId = json['momwvevi_useris_id'];
  }
  late String token;
  int? userId;
  String? firstName;
  String? lastName;
  String? image;
  String? phone;
  String? email;
  String? cardNumber;
  String? cardStatus;
  dynamic favourites;
  dynamic notifications;
  String? dateOfBirth;
  String? currencyCode;
  String? gender;
  String? momwveviUserisId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['token'] = token;
    map['id'] = userId;
    map['first_name'] = firstName;
    map['last_name'] = lastName;
    map['image'] = image;
    map['phone'] = phone;
    map['email'] = email;
    map['card_status'] = cardStatus;
    map['card_number'] = cardNumber;
    map['favourites'] = favourites;
    map['notifications'] = notifications;
    map['date_of_birth'] = dateOfBirth;
    map['currency_code'] = currencyCode;
    map['gender'] = gender;
    map['momwvevi_useris_id'] = momwveviUserisId;
    return map;
  }
}
