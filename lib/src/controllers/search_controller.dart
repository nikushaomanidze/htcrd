import 'package:get/state_manager.dart';

import '../models/search_product_model.dart';
import '../servers/repository.dart';

import 'dart:async';

class SearchController extends GetxController {
  final Rx<SearchProductModel> _searchResult = SearchProductModel().obs;
  SearchProductModel get searchResult => _searchResult.value;
  final RxBool _isSearching = false.obs;
  bool get isSearching => _isSearching.value;
  final RxBool _isSearchFieldEmpty = true.obs;
  bool get isSearchFieldEmpty => _isSearchFieldEmpty.value;

  Timer? _debounceTimer;

  search(String searchValue) {
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(Duration(milliseconds: 500), () async {
      _isSearching(true);

      try {
        // Clear previous search results
        searchResult.products = [];
        searchResult.restaurants = [];

        final value = await Repository().getSearchProducts(searchKey: searchValue);

        if (value.products!.isNotEmpty || value.restaurants!.isNotEmpty) {
          _searchResult.value = value;
        } else {
        }
      } finally {
        _isSearching(false);
      }
    });
  }

  setIsSearchFieldEmpty(bool value) {
    _isSearchFieldEmpty(value);
  }

  @override
  void onInit() {
    // Clear initial search results
    searchResult.products = [];
    searchResult.restaurants = [];
    super.onInit();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}

