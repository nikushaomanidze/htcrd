import 'package:get/state_manager.dart';

import '../models/search_product_model.dart';
import '../servers/repository.dart';

class SearchController extends GetxController {
  final Rx<SearchProductModel> _searchResult = SearchProductModel().obs;
  SearchProductModel get searchResult => _searchResult.value;
  final RxBool _isSearching = false.obs;
  bool get isSearching => _isSearching.value;
  final RxBool _isSearchFieldEmpty = true.obs;
  bool get isSearchFieldEmpty => _isSearchFieldEmpty.value;

  search(String searchValue) async {
    _isSearching(true);
    await Repository().getSearchProducts(searchKey: searchValue).then((value) {
      if (value.products!.isNotEmpty || value.restaurants!.isNotEmpty) {
        _searchResult.value = value;
      } else {
        searchResult.products = [];
        searchResult.restaurants = [];
      }
      _isSearching(false);
    });
  }

  setIsSearchFieldEmpty(bool value) {
    _isSearchFieldEmpty(value);
  }

  @override
  void onInit() {
    searchResult.products = [];
    searchResult.restaurants = [];
    super.onInit();
  }
}
