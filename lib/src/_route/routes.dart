import 'package:get/get.dart';
import 'package:hot_card/src/screen/home/mtla_home.dart';
import 'package:hot_card/src/screen/onboarding_screen.dart';
import 'package:hot_card/src/screen/profile/profile_screen.dart';

import '../bindings/dashboard_bindings.dart';
import '../bindings/news_binding.dart';
import '../bindings/payment_binding.dart';
import '../bindings/splash_binding.dart';
import '../screen/auth_screen/forgot_password_screen.dart';
import '../screen/auth_screen/login_screen.dart';
import '../screen/auth_screen/phone_login_screen.dart';
import '../screen/auth_screen/phone_registration_screen.dart';
import '../screen/auth_screen/sign_up_screen.dart';
import '../screen/cart/invoice_screen.dart';
import '../screen/cart/payment/confirmation_payment_screen.dart';
import '../screen/cart/payment/payment_screen.dart';
import '../screen/category/category_screen.dart';
import '../screen/connection_check/internet_check_view.dart';
import '../screen/dashboard/dashboard_screen.dart';
import '../screen/home/campaign/shop/shop_screen.dart';
import '../screen/home/category/all_brand_screen.dart';
import '../screen/home/category/product_category_screen.dart';
import '../screen/home/notification_screen.dart';
import '../screen/home/product_details/product_details_screen.dart';
import '../screen/home/search_product_screen.dart';
import '../screen/home/video_shopping/details_video_shopping.dart';
import '../screen/news/news_details_screen.dart';
import '../screen/profile/change_password_screen.dart';
import '../screen/profile/order_history_screen.dart';
import '../screen/profile/profile_without_login_screen.dart';
import '../screen/profile/settings/settings_screen.dart';
import '../screen/profile/tracking_order_screen.dart';
import '../screen/profile/voucher_screen.dart';
import '../screen/profile/wallet/my_wallet_recharge_screen.dart';
import '../screen/profile/wallet/recharge_confarmation_screen.dart';
import '../screen/profile/wv_screen/wv_screen.dart';
import '../screen/splash/splash_screen.dart';

class Routes {
  static const String splashScreen = '/splashScreen';
  static const String mainScreen = '/mainScreen';
  static const String dashboardScreen = '/dashboardScreen';
  static const String profilePage = '/profilePage';
  static const String internetCheckView = '/internetCheckView';
  static const String logIn = '/logIn';
  static const String signUp = '/signUp';
  static const String forgetPassword = '/forgetPassword';
  static const String phoneRegistration = '/phoneRegistration';
  static const String phoneLoginScreen = '/phoneLoginScreen';
  static const String categoryContent = '/categoryContent';
  static const String cartContent = '/cartContent';
  static const String detailsPage = '/detailsPage';
  static const String paymentScreen = '/paymentScreen';
  static const String paymentConfirm = '/paymentConfirm';
  static const String rechargeConfirm = '/rechargeConfirm';
  static const String newsScreen = '/newsScreen';
  static const String newsBinding = '/newsBinding';
  static const String notificationContent = '/notificationContent';
  static const String wvScreen = '/wvScreen';
  static const String productCategory = '/productCategory';
  static const String trackingOrder = '/trackingOrder';
  static const String settings = '/settings';
  static const String searchProduct = '/searchProduct';
  static const String allBrand = '/allBrand';
  static const String orderHistory = '/orderHistory';
  static const String voucherList = '/voucherList';
  static const String changePassword = '/changePassword';
  static const String myWalletRecharge = '/myWalletRecharge';
  static const String withOutLoginPage = '/withOutLoginPage';
  static const String invoiceScreen = '/invoiceScreen';
  static const String shopScreen = '/shopScreen';
  static const String detailsVideoShopping = '/detailsVideoShopping';
  static const String videoPlayer = '/videoPlayer';
  static const String onboarding = '/onboarding';

  static var list = [
    GetPage(
      name: internetCheckView,
      page: () => const InternetCheckView(),
    ),
    GetPage(
      name: mainScreen,
      page: () => const MtlaHome(),
    ),
    GetPage(
      name: splashScreen,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: onboarding,
      page: () => const OnBoardingScreen(),
    ),
    GetPage(
      name: dashboardScreen,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: profilePage,
      page: () => const ProfileContent(),
    ),
    GetPage(
      name: logIn,
      page: () => LoginScreen(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: signUp,
      page: () => const SignupScreen(),
    ),
    GetPage(
      name: detailsPage,
      page: () => DetailsPage(),
    ),
    GetPage(
      name: paymentScreen,
      page: () => PaymentScreen(),
      binding: PaymentBinding(),
    ),
    GetPage(
      name: paymentConfirm,
      page: () => PaymentConfirmationScreen(),
    ),
    GetPage(
      name: rechargeConfirm,
      page: () => RechargeConfirmationScreen(),
    ),
    GetPage(
      name: newsScreen,
      page: () => NewsScreen(),
      binding: NewsBinding(),
    ),
    GetPage(
      name: notificationContent,
      page: () => const NotificationContent(),
    ),
    GetPage(
      name: categoryContent,
      page: () => CategoryScreen(),
    ),
    GetPage(
      name: wvScreen,
      page: () => WVScreen(),
    ),
    GetPage(
      name: productCategory,
      page: () => const ProductCategory(),
    ),
    GetPage(
      name: forgetPassword,
      page: () => ForgetPasswordScreen(),
    ),
    GetPage(
      name: phoneRegistration,
      page: () => PhoneRegistrationScreen(),
    ),
    GetPage(
      name: phoneLoginScreen,
      page: () => PhoneLoginScreen(),
    ),
    GetPage(
      name: trackingOrder,
      page: () => TrackingOrder(),
    ),
    GetPage(
      name: settings,
      page: () => Settings(),
    ),
    GetPage(
      name: searchProduct,
      page: () => const SearchProduct(),
    ),
    GetPage(
      name: allBrand,
      page: () => const AllBrand(),
    ),
    GetPage(
      name: orderHistory,
      page: () => OrderHistory(),
    ),
    GetPage(
      name: voucherList,
      page: () => const VoucherList(),
    ),
    GetPage(
      name: changePassword,
      page: () => ChangePassword(),
    ),
    GetPage(
      name: myWalletRecharge,
      page: () => MyWalletRechargeScreen(),
      binding: PaymentBinding(),
    ),
    GetPage(
      name: withOutLoginPage,
      page: () => const ProfileWithoutLoginScreen(),
    ),
    GetPage(
      name: invoiceScreen,
      page: () => InvoiceScreen(),
    ),
    GetPage(
      name: shopScreen,
      page: () => ShopScreen(),
    ),
    GetPage(
      name: detailsVideoShopping,
      page: () => DetailsVideoShopping(),
    )
  ];
}
