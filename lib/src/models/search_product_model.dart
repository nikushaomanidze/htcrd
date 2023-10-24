class SearchProductModel {
  SearchProductModel({
    this.success,
    this.message,
    this.products,
    this.restaurants,
  });

  SearchProductModel.fromJson(dynamic json) {
    success = json['success'];
    message = json['message'];

    if (json['data'] != null) {
      if (json['data']['products'] != null) {
        products = [];
        json['data']['products'].forEach((v) {
          products?.add(SearchProductData.fromJson(v));
        });
      }

      if (json['data']['restaurants'] != null) {
        restaurants = [];
        json['data']['restaurants'].forEach((v) {
          restaurants?.add(SearchRestaurantData.fromJson(v));
        });
      }
    }
  }

  bool? success;
  String? message;
  List<SearchProductData>? products;
  List<SearchRestaurantData>? restaurants;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;

    if (products != null) {
      map['data'] = {
        'products': products?.map((v) => v.toJson()).toList(),
      };
    }

    if (restaurants != null) {
      if (map['data'] == null) {
        map['data'] = {};
      }
      map['data']['restaurants'] = restaurants?.map((v) => v.toJson()).toList();
    }

    return map;
  }
}

class SearchRestaurantData {
  SearchRestaurantData({
    this.id,
    this.parent_id,
    this.slug,
    this.title,
    this.banner,
    this.image,
    this.latlong,
    this.category_filter,
    this.number,
    this.soc_fb,
    this.soc_yt,
    this.soc_in,
  });

  SearchRestaurantData.fromJson(dynamic json) {
    id = json['id'];
    parent_id = json['parent_id'];
    slug = json['slug'];
    title = json['title'];
    banner = json['banner'];
    image = json['image'];
    latlong = json['latlong'];
    category_filter = json['category_filter'];
    number = json['number'];
    soc_fb = json['soc_fb'];
    soc_yt = json['soc_yt'];
    soc_in = json['soc_in'];
  }
  int? id;
  int? parent_id;
  String? slug;
  String? title;
  String? banner;
  String? image;
  String? latlong;
  String? category_filter;
  String? number;
  String? soc_fb;
  String? soc_yt;
  String? soc_in;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['parent_id'] = parent_id;
    map['slug'] = slug;
    map['title'] = title;
    map['banner'] = banner;
    map['image'] = image;
    map['latlong'] = latlong;
    map['category_filter'] = category_filter;
    map['number'] = number;
    map['soc_fb'] = soc_fb;
    map['soc_yt'] = soc_yt;
    map['soc_in'] = soc_in;
    return map;
  }
}

class SearchProductData {
  SearchProductData({
    this.id,
    this.slug,
    this.title,
    this.shortDescription,
    this.specialDiscountType,
    this.specialDiscount,
    this.discountPrice,
    this.formattedPrice,
    this.formattedDiscount,
    this.image,
    this.price,
    this.rating,
    this.totalReviews,
    this.currentStock,
    this.reward,
    this.minimumOrderQuantity,
    this.isFavourite,
    this.isNew,
    this.hasVariant,
  });

  SearchProductData.fromJson(dynamic json) {
    id = json['id'];
    slug = json['slug'];
    title = json['title'];
    shortDescription = json['short_description'];
    specialDiscountType = json['special_discount_type'];
    specialDiscount = json['special_discount'];
    discountPrice = json['discount_price'];
    formattedPrice = json['formatted_price'];
    formattedDiscount = json['formatted_discount'];
    image = json['image'];
    price = json['price'];
    rating = json['rating'];
    totalReviews = json['total_reviews'];
    currentStock = json['current_stock'];
    reward = json['reward'];
    minimumOrderQuantity = json['minimum_order_quantity'];
    isFavourite = json['is_favourite'];
    isNew = json['is_new'];
    hasVariant = json['has_variant'];
  }
  int? id;
  String? slug;
  String? title;
  String? shortDescription;
  String? specialDiscountType;
  String? specialDiscount;
  String? discountPrice;
  dynamic formattedPrice;
  dynamic formattedDiscount;
  String? image;
  String? price;
  dynamic rating;
  int? totalReviews;
  int? currentStock;
  int? reward;
  int? minimumOrderQuantity;
  bool? isFavourite;
  bool? isNew;
  bool? hasVariant;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['slug'] = slug;
    map['title'] = title;
    map['short_description'] = shortDescription;
    map['special_discount_type'] = specialDiscountType;
    map['special_discount'] = specialDiscount;
    map['discount_price'] = discountPrice;
    map['formatted_price'] = formattedPrice;
    map['formatted_discount'] = formattedDiscount;
    map['image'] = image;
    map['price'] = price;
    map['rating'] = rating;
    map['total_reviews'] = totalReviews;
    map['current_stock'] = currentStock;
    map['reward'] = reward;
    map['minimum_order_quantity'] = minimumOrderQuantity;
    map['is_favourite'] = isFavourite;
    map['is_new'] = isNew;
    map['has_variant'] = hasVariant;
    return map;
  }
}
