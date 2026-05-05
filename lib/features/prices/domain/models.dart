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

    if (json['Other Stores'] != null) {
      parsedPrices = (json['Other Stores'] as List).map((p) => ProductPrice(
        price: (p['Price'] as num).toDouble(),
        mrp: (p['MRP'] as num).toDouble(),
        discountPercent: p['Discount'].toString(),
        storeNameEn: p['Store'],
        storeRating: (p['Rating'] as num).toDouble(),
        productUrl: p['URL'],
        location: p['Location'],
      )).toList();
    } else {
      parsedPrices = [
        ProductPrice(
          price: (json['Price'] as num).toDouble(),
          mrp: (json['MRP (EGP)'] as num).toDouble(),
          discountPercent: json['Discount %'].toString(),
          storeNameEn: _inferStore(json['Product URL'] ?? ''),
          storeRating: 4.5,
          productUrl: json['Product URL'],
        )
      ];
    }

    return Product(
      id: json['Product ID']?.toString() ?? json['Sr No']?.toString() ?? '',
      nameEn: json['Product Name'] ?? '',
      nameAr: json['Product Name'] ?? '', // Fallback to EN if AR not provided by live engine
      descriptionEn: json['Description'],
      imageUrl: json['Product Image URL'],
      prices: parsedPrices,
    );
  }

  static String _inferStore(String url) {
    if (url.contains('amazon')) return 'Amazon Egypt';
    if (url.contains('jumia')) return 'Jumia';
    if (url.contains('carrefour')) return 'Carrefour';
    return 'Market';
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
