class Store {
  final int id;
  final String nameEn;
  final String nameAr;
  final String? locationEn;
  final String? locationAr;
  final double rating;
  final double? latitude;
  final double? longitude;

  Store({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.locationEn,
    this.locationAr,
    required this.rating,
    this.latitude,
    this.longitude,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      nameEn: json['name_en'],
      nameAr: json['name_ar'],
      locationEn: json['location_name_en'],
      locationAr: json['location_name_ar'],
      rating: (json['rating'] as num).toDouble(),
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }
}
