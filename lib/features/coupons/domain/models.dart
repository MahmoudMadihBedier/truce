class Coupon {
  final int id;
  final String code;
  final String? descriptionEn;
  final String? descriptionAr;
  final double? discountPercentage;
  final String storeNameEn;
  final String storeNameAr;

  Coupon({
    required this.id,
    required this.code,
    this.descriptionEn,
    this.descriptionAr,
    this.discountPercentage,
    required this.storeNameEn,
    required this.storeNameAr,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    final store = json['stores'];
    return Coupon(
      id: json['id'],
      code: json['code'],
      descriptionEn: json['description_en'],
      descriptionAr: json['description_ar'],
      discountPercentage: json['discount_percentage'] != null ? (json['discount_percentage'] as num).toDouble() : null,
      storeNameEn: store['name_en'],
      storeNameAr: store['name_ar'],
    );
  }
}
