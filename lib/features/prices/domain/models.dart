class Product {
  final String id;
  final String nameEn;
  final String nameAr;
  final String? descriptionEn;
  final String? imageUrl;
  final List<ProductPrice> prices;

  Product({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.descriptionEn,
    this.imageUrl,
    this.prices = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<ProductPrice> parsedPrices = [];

    // The new API response is flat per product/store combo
    parsedPrices = [ProductPrice.fromJson(json)];

    return Product(
      id: json['Product ID']?.toString() ?? json['Sr No']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nameEn: json['Product Name'] ?? 'Product',
      nameAr: json['Product Name'] ?? 'منتج',
      descriptionEn: json['Description'],
      imageUrl: json['Product Image URL'] == 'N/A' ? null : json['Product Image URL'],
      prices: parsedPrices,
    );
  }
}

class ProductPrice {
  final double price;
  final double mrp;
  final String discountPercent;
  final String storeNameEn;
  final double storeRating;
  final String? productUrl;
  final String? location;

  ProductPrice({
    required this.price,
    required this.mrp,
    required this.discountPercent,
    required this.storeNameEn,
    required this.storeRating,
    this.productUrl,
    this.location,
  });

  factory ProductPrice.fromJson(Map<String, dynamic> json) {
    final priceValue = (json['Price'] is num ? (json['Price'] as num).toDouble() : 0.0);
    final mrpValue = (json['MRP (EGP)'] is num ? (json['MRP (EGP)'] as num).toDouble() :
                    (json['MRP'] is num ? (json['MRP'] as num).toDouble() : priceValue));

    return ProductPrice(
      price: priceValue,
      mrp: mrpValue,
      discountPercent: (json['Discount %'] ?? '0').toString(),
      storeNameEn: json['Store Name'] ?? 'Market',
      storeRating: 4.5, // Default rating for new API
      productUrl: json['Product URL'] == 'N/A' ? null : json['Product URL'],
      location: json['Location'],
    );
  }
}

class Category {
  final int id;
  final String nameEn;
  final String nameAr;

  Category({required this.id, required this.nameEn, required this.nameAr});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
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
