import 'package:flutter/material.dart';

class Config {
  // copy your server url from admin panel
  static String apiServerUrl = "https://julius.ltd/hotcard/api";
  // copy your api key from admin panel
  static String apiKey = "X7BICVCWBZUB6S8Y";

  //enter onesignal app id below
  static String oneSignalAppId = "af8921eb-ddd6-4d08-9b1e-e4df461e50ef";
  // find your ios APP id from app store
  static const String iosAppId = "com.tapp.hotcard";
  static const bool enableGoogleLogin = true;
  static const bool enableFacebookLogin = true;
  // if "groceryCartMode = true" then product will be added to cart directly
  static const bool groceryCartMode = false;

  static var supportedLanguageList = [
    const Locale("en", "US"),
    const Locale("uk", "UA"),
    const Locale("ka", "GE"),
  ];
  static const String initialCountrySelection = "GE";
}
