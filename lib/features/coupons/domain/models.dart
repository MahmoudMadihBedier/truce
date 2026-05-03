class Coupon {
  final int id;
  final String code;
  final String description;
  final String storeName;
  final DateTime? expiresAt;

  Coupon({
    required this.id,
    required this.code,
    required this.description,
    required this.storeName,
    this.expiresAt,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    final stores = json['stores'];
    return Coupon(
      id: json['id'],
      code: json['code'],
      description: json['description'] ?? '',
      storeName: stores != null ? (stores['name_en'] ?? 'Unknown Store') : 'Store',
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
    );
  }
}
