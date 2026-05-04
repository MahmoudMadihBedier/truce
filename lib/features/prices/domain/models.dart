class Product {
  final int id;
  final String nameEn;
  final String nameAr;
  final String? descriptionEn;
  final String? descriptionAr;
  final String? imageUrl;
  final int? categoryId;
  final List<ProductPrice> prices;

  Product({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.descriptionEn,
    this.descriptionAr,
    this.imageUrl,
    this.categoryId,
    this.prices = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nameEn: json['name_en'] ?? json['name'] ?? '',
      nameAr: json['name_ar'] ?? json['name'] ?? '',
      descriptionEn: json['description_en'] ?? json['description'],
      descriptionAr: json['description_ar'] ?? json['description'],
      imageUrl: json['image_url'] ?? json['image'],
      categoryId: json['category_id'],
    );
  }
}

class ProductPrice {
  final int id;
  final double price;
  final double? previousPrice;
  final String storeNameEn;
  final String storeNameAr;
  final double storeRating;
  final bool isAvailable;
  final String? productUrl;
  final String? discountInfo;

  ProductPrice({
    required this.id,
    required this.price,
    this.previousPrice,
    required this.storeNameEn,
    required this.storeNameAr,
    required this.storeRating,
    required this.isAvailable,
    this.productUrl,
    this.discountInfo,
  });
}

class Category {
  final int id;
  final String nameEn;
  final String nameAr;

  Category({required this.id, required this.nameEn, required this.nameAr});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      nameEn: json['name_en'],
      nameAr: json['name_ar'],
    );
  }
}

class GoldPrice {
  final String carat;
  final double buy;
  final double sell;
  final DateTime? updatedAt;

  const GoldPrice({
    required this.carat,
    required this.buy,
    required this.sell,
    this.updatedAt,
  });
}

class CurrencyRate {
  final String code;
  final double rateToEgp;
  final DateTime updatedAt;

  const CurrencyRate({
    required this.code,
    required this.rateToEgp,
    required this.updatedAt,
  });
}
