// ignore_for_file: non_constant_identifier_names

class AllCategoryProductModel {
  bool? success;
  String? message;
  Data? data;

  AllCategoryProductModel({this.success, this.message, this.data});

  AllCategoryProductModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  FeaturedCategory? featuredCategory;
  List<Categories>? categories;

  Data({this.featuredCategory, this.categories});

  Data.fromJson(Map<String, dynamic> json) {
    featuredCategory = json['featured_category'] != null
        ? FeaturedCategory.fromJson(json['featured_category'])
        : null;
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((cat) {
        if (cat['sub_categories'] != null) {
          cat['sub_categories'].forEach((subCat) {
            categories!.add(Categories.fromJson(subCat));
          });
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (featuredCategory != null) {
      data['featured_category'] = featuredCategory!.toJson();
    }
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FeaturedCategory {
  String? title;
  String? icon;
  String? banner;
  List<FeaturedSubCategories>? featuredSubCategories;

  FeaturedCategory(
      {this.title, this.icon, this.banner, this.featuredSubCategories});

  FeaturedCategory.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    icon = json['icon'];
    banner = json['banner'] ?? "";
    if (json['featured_sub_categories'] != null) {
      featuredSubCategories = <FeaturedSubCategories>[];
      json['featured_sub_categories'].forEach((v) {
        featuredSubCategories!.add(FeaturedSubCategories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['icon'] = icon;
    data['banner'] = banner;
    if (featuredSubCategories != null) {
      data['featured_sub_categories'] =
          featuredSubCategories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FeaturedSubCategories {
  int? id;
  String? icon;
  int? parentId;
  String? slug;
  int? order;
  String? title;
  String? image;
  String? latlong;
  String? categoryFilter;
  String? number;
  String? soc_fb;
  String? soc_yt;
  String? soc_in;

  FeaturedSubCategories(
      {this.id,
      this.icon,
      this.parentId,
      this.slug,
      this.order,
      this.title,
      this.image,
      this.latlong,
      this.categoryFilter,
      this.soc_fb,
      this.number,
      this.soc_yt,
      this.soc_in});

  FeaturedSubCategories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    icon = json['icon'];
    parentId = json['parent_id'];
    slug = json['slug'];
    order = json['order'];
    title = json['title'];
    image = json['image'];
    latlong = json['latlong'];
    categoryFilter = json['category_filter'];
    number = json['number'];
    soc_fb = json['soc_fb'];
    soc_yt = json['soc_yt'];
    soc_in = json['soc_in'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['icon'] = icon;
    data['parent_id'] = parentId;
    data['slug'] = slug;
    data['order'] = order;
    data['title'] = title;
    data['image'] = image;
    data['latlong'] = latlong;
    data['category_filter'] - categoryFilter;
    data['number'] - number;
    data['soc_fb'] - soc_fb;
    data['soc_yt'] - soc_yt;
    data['soc_in'] - soc_in;
    return data;
  }
}

class Categories {
  int? id;
  String? icon;
  int? parentId;
  String? slug;
  int? order;
  String? banner;
  String? title;
  String? image;
  String? latlong;
  String? categoryFilter;
  String? number;
  String? soc_fb;
  String? soc_yt;
  String? soc_in;
  List<SubCategories>? subCategories;

  Categories(
      {this.id,
      this.icon,
      this.parentId,
      this.slug,
      this.order,
      this.banner,
      this.title,
      this.image,
      this.latlong,
      this.categoryFilter,
      this.number,
      this.soc_fb,
      this.soc_yt,
      this.soc_in,
      this.subCategories});

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    icon = json['icon'];
    parentId = json['parent_id'];
    slug = json['slug'];
    order = json['order'];
    banner = json['banner'];
    title = json['title'];
    image = json['image'];
    latlong = json['latlong'];
    categoryFilter = json['category_filter'];
    number = json['number'];
    soc_fb = json['soc_fb'];
    soc_yt = json['soc_yt'];
    soc_in = json['soc_in'];
    if (json['sub_categories'] != null) {
      subCategories = <SubCategories>[];
      json['sub_categories'].forEach((v) {
        subCategories!.add(SubCategories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['icon'] = icon;
    data['parent_id'] = parentId;
    data['slug'] = slug;
    data['order'] = order;
    data['banner'] = banner;
    data['title'] = title;
    data['image'] = image;
    data['latlong'] = latlong;
    data['category_filter'] = categoryFilter;
    data['number'] = number;
    data['soc_fb'] = soc_fb;
    data['soc_yt'] = soc_yt;
    data['soc_in'] = soc_in;
    if (subCategories != null) {
      data['sub_categories'] = subCategories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubCategories {
  int? id;
  String? icon;
  int? parentId;
  String? slug;
  String? banner;
  String? title;
  String? image;
  String? latlong;
  List<ChildCategories>? childCategories;

  SubCategories(
      {this.id,
      this.icon,
      this.parentId,
      this.slug,
      this.banner,
      this.title,
      this.image,
      this.latlong,
      this.childCategories});

  SubCategories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    icon = json['icon'];
    parentId = json['parent_id'];
    slug = json['slug'];
    banner = json['banner'];
    title = json['title'];
    image = json['image'];
    latlong = json['latlong'];
    if (json['child_categories'] != null) {
      childCategories = <ChildCategories>[];
      json['child_categories'].forEach((v) {
        childCategories!.add(ChildCategories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['icon'] = icon;
    data['parent_id'] = parentId;
    data['slug'] = slug;
    data['banner'] = banner;
    data['title'] = title;
    data['image'] = image;
    data['latlong'] = latlong;
    if (childCategories != null) {
      data['child_categories'] =
          childCategories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ChildCategories {
  int? id;
  String? icon;
  int? parentId;
  String? slug;
  String? banner;
  String? title;
  String? image;
  String? latlong;

  ChildCategories({
    this.id,
    this.icon,
    this.parentId,
    this.slug,
    this.banner,
    this.title,
    this.image,
    this.latlong,
  });

  ChildCategories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    icon = json['icon'];
    parentId = json['parent_id'];
    slug = json['slug'];
    banner = json['banner'];
    title = json['title'];
    image = json['image'];
    latlong = json['latlong'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['icon'] = icon;
    data['parent_id'] = parentId;
    data['slug'] = slug;
    data['banner'] = banner;
    data['title'] = title;
    data['image'] = image;
    data['latlong'] = latlong;

    return data;
  }
}
