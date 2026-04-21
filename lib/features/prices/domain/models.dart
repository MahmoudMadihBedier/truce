class Product {
  final int id;
  final String nameEn;
  final String nameAr;
  final String? descriptionEn;
  final String? descriptionAr;
  final String? imageUrl;
  final List<ProductPrice> prices;

  Product({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.descriptionEn,
    this.descriptionAr,
    this.imageUrl,
    this.prices = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      nameEn: json['name_en'],
      nameAr: json['name_ar'],
      descriptionEn: json['description_en'],
      descriptionAr: json['description_ar'],
      imageUrl: json['image_url'],
    );
  }
}

class ProductPrice {
  final int id;
  final double price;
  final String storeNameEn;
  final String storeNameAr;
  final double storeRating;
  final bool isAvailable;

  ProductPrice({
    required this.id,
    required this.price,
    required this.storeNameEn,
    required this.storeNameAr,
    required this.storeRating,
    required this.isAvailable,
  });
}

class GoldPrice {
  final String carat;
  final double buy;
  final double sell;
  final DateTime updatedAt;

  GoldPrice({
    required this.carat,
    required this.buy,
    required this.sell,
    required this.updatedAt,
  });
}

class CurrencyRate {
  final String code;
  final double rateToEgp;
  final DateTime updatedAt;

  CurrencyRate({
    required this.code,
    required this.rateToEgp,
    required this.updatedAt,
  });
}
