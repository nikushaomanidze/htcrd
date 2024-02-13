// ignore_for_file: non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:email_validator/email_validator.dart';

import '../data/local_data_helper.dart';
import '../models/user_data_model.dart';
import '../screen/auth_screen/login_screen.dart';
import '../screen/dashboard/dashboard_screen.dart';
import '../servers/repository.dart';
import '../utils/app_tags.dart';
import '../utils/constants.dart';

class AuthController extends GetxController {
  final GoogleSignIn _googleSign = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static AuthController authInstance =
      Get.put(AuthController(), permanent: true);
  late Rx<GoogleSignInAccount?> _googleSignInAccount;
  final box = GetStorage();

  final _isLoggingIn = false.obs;
  bool get isLoggingIn => _isLoggingIn.value;

  //login screen
  TextEditingController? emailController;
  TextEditingController? passwordController;
  var isVisible = true.obs;
  var isValue =
      LocalDataHelper().getRememberPass() != null ? true.obs : false.obs;
  bool isLoading = false;

  isValueUpdate(value) {
    isValue.value = value!;
  }

  isVisibleUpdate() {
    isVisible.value = !isVisible.value;
  }

  //SignUp Screen
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailControllers = TextEditingController();
  var phoneControllers = TextEditingController();
  var countryCodeControllers = TextEditingController();
  var codeControllers = TextEditingController();
  var passwordControllers = TextEditingController();
  var confirmPasswordController = TextEditingController();
  var statusController = TextEditingController();
  var referralController = TextEditingController();
  var passwordVisible = true.obs;
  var confirmPasswordVisible = true.obs;

  isVisiblePasswordUpdate() {
    passwordVisible.value = !passwordVisible.value;
  }

  isVisibleConfirmPasswordUpdate() {
    confirmPasswordVisible.value = !confirmPasswordVisible.value;
  }

  @override
  void onInit() {
    emailController =
        TextEditingController(text: LocalDataHelper().getRememberMail() ?? "");
    passwordController =
        TextEditingController(text: LocalDataHelper().getRememberPass() ?? "");
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _googleSignInAccount = Rx<GoogleSignInAccount?>(_googleSign.currentUser);
    _googleSignInAccount.bindStream(_googleSign.onCurrentUserChanged);
    ever(_googleSignInAccount, _setInitialScreenGoogle);
  }

  void showErrorPopup(BuildContext context, String errorMessage1) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage1),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the popup
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

//General LogIn
  void loginWithEmailPassword(
      {required String email, required String password}) async {
    _isLoggingIn(true);
    await Repository().loginWithEmailPassword(email, password).then(
      (value) {
        if (value) Get.offAllNamed('/dashboardScreen');
        _isLoggingIn(false);
      },
    );
  }

  //General SignUp
  Future signUp(
      {required String firstName,
      required String lastName,
      required String email,
      required String password,
      required String phone,
      required String card_number,
      required String referral_code,
      required String confirmPassword,
      required String countryCode,
      context
      // required bool switchValue,
      }) async {
    _isLoggingIn(true);

    // Provide empty string as default value if card_number is null
    String finalCardNumber = card_number;

    // Provide empty string as default value if referral_code is null
    String finalReferralCode = referral_code;

    final emailStatus = EmailValidator.validate(email);

    if (emailStatus == true) {
      await Repository()
          .signUp(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: countryCode + phone,
        password: password,
        confirmPassword: confirmPassword,
        // switchValue: switchValue,
        card_number: finalCardNumber,
        referral_code: finalReferralCode,
      )
          .then((value) {
        _isLoggingIn(false);
      });
    } else {
      showErrorPopup(context, "Wrong format Email Address.");
      // Get.snackbar(
      //   "Error!!",
      //   "Wrong format Email Address.",
      //   snackPosition: SnackPosition.BOTTOM,
      // );
    }
  }

  //Google SignIn
  _setInitialScreenGoogle(GoogleSignInAccount? googleSignInAccount) {
    if (googleSignInAccount != null) {
      Get.offAllNamed('/dashboardScreen');
    } else {
      Get.offAll(() => LoginScreen());
    }
  }

  void signInWithGoogle() async {
    _isLoggingIn(true);
    try {
      GoogleSignInAccount? googleSignInAccount = await _googleSign.signIn();
      if (googleSignInAccount != null) {
        GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final User? user = (await _auth.signInWithCredential(credential)).user;
        if (user != null) {
          UserDataModel? userDataModel = await Repository().postFirebaseAuth(
              name: user.displayName.toString(),
              email: user.providerData[0].email ?? "",
              phone: user.phoneNumber ?? "",
              image: user.photoURL ?? "",
              providerId: "google.com",
              uid: user.uid);
          if (userDataModel != null) {
            printLog("---------google auth: success");
            Get.offAllNamed('/dashboardScreen');
            _isLoggingIn(false);
          } else {
            printLog("---------google auth: failed");
            _isLoggingIn(false);
            Get.snackbar(
              "Error!!",
              "Failed to login",
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        } else {
          printLog("-----google user null");
          _isLoggingIn(false);
          Get.snackbar(
            "Error!!",
            "Failed to login2",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      printLog("-----sign in error: $e");
      _isLoggingIn(false);
      Get.snackbar(
        "Error!!",
        "$e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  //Facebook Login
  Future<void> facebookLogin() async {
    _isLoggingIn(true);
    User? user = await _createFBLoginFlow();

    if (user != null) {
      await Repository()
          .postFirebaseAuth(
              name: user.displayName ?? "",
              email: user.providerData[0].email ?? "",
              phone: user.phoneNumber ?? "",
              image: user.photoURL ?? "",
              providerId: "facebook.com",
              uid: user.uid)
          .then((value) {
        _isLoggingIn(false);
        if (value != null) {
          //go to home screen
          Get.offAll(() => const DashboardScreen());
        } else {
          Get.snackbar(
            "Error!",
            "Failed to signing in with facebook.",
            snackPosition: SnackPosition.BOTTOM,
            borderRadius: 10,
          );
        }
      });
    } else {
      _isLoggingIn(false);
      Get.snackbar(
        "Error!",
        "Failed to signin.",
        snackPosition: SnackPosition.BOTTOM,
        borderRadius: 10,
      );
    }
  }

  Future<UserCredential> _getFBCredential() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();
    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken != null
            ? loginResult.accessToken!.token
            : "");
    // Once signed in, return the UserCredential
    return _auth.signInWithCredential(facebookAuthCredential);
  }

  Future<User?> _createFBLoginFlow() async {
    UserCredential credential = await _getFBCredential();
    User? user = credential.user;
    return user;
  }

  //apple Login
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  emailTrim(String email) {
    String delimiter = '@';
    int lastIndex = email.indexOf(delimiter);
    String trimmed = email.substring(0, lastIndex);
    printLog(trimmed);
    return trimmed;
  }

  Future signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
    final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode);
    final User? user = (await _auth.signInWithCredential(credential)).user;

    if (user!.email != null) {
      await Repository()
          .postFirebaseAuth(
              name: user.displayName ?? emailTrim(user.email!),
              email: user.email.toString(),
              phone: user.providerData[0].phoneNumber ?? "",
              image: user.photoURL ?? "",
              providerId: "apple.com",
              uid: user.uid)
          .then((value) => Get.offAllNamed('/dashboardScreen'));
    } else {
      Get.snackbar(
        AppTags.login.tr,
        AppTags.doNotMatchCredential.tr,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        colorText: Colors.black,
        backgroundColor: Colors.red,
        forwardAnimationCurve: Curves.decelerate,
        shouldIconPulse: false,
      );
    }

    if (user.email != null && user.email != "") {
      assert(user.email != null);
    }
    if (user.displayName != null && user.displayName != "") {
      assert(user.displayName != null);
    }
    assert(!user.isAnonymous);

    final User? currentUser =
        (await _auth.signInWithCredential(credential)).user;
    assert(user.uid == currentUser!.uid);
    printLog("--- User----$currentUser");
    return user;
  }

  //Sign Out
  void signOut() async {
    try {
      printLog("From Auth: ${LocalDataHelper().box.read("userToken")}");
      await _googleSign.signOut();
      await _auth.signOut();
      await Repository().logOut().then((value) {
        LocalDataHelper().box.remove("userToken");
        LocalDataHelper().box.remove("trxId");
        LocalDataHelper().box.remove('userModel');
        Get.offAll(() => const DashboardScreen());
      });
    } catch (e) {
      printLog(e.toString());
    }
  }
}
