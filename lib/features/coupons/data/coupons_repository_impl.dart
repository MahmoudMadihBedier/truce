import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truce/core/error/failures.dart';
import 'package:truce/core/utils/typedefs.dart';
import 'package:truce/features/coupons/domain/models.dart';
import 'package:truce/features/coupons/domain/coupons_repository.dart';

class CouponsRepositoryImpl implements CouponsRepository {
  final SupabaseClient _client;
  final http.Client _httpClient = http.Client();

  static const String _baseUrl = 'http://localhost:8000';

  CouponsRepositoryImpl(this._client);

  @override
  Future<ApiResult<List<Coupon>>> getCoupons() async {
    try {
      // First try backend for fresh coupons
      final response = await _httpClient.get(Uri.parse('$_baseUrl/coupons'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return (null, data.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Coupon(
            id: i,
            code: item['code'],
            description: '${item['discount']}: ${item['description']}',
            storeName: item['store'],
            expiresAt: DateTime.now().add(const Duration(days: 30)),
          );
        }).toList());
      }

      // Fallback to Supabase
      final supabaseResponse = await _client.from('coupons').select('*, stores(name_en, name_ar)');
      final supabaseData = supabaseResponse as List<dynamic>;
      return (null, supabaseData.map((item) => Coupon.fromJson(item)).toList());
    } catch (e) {
      return (ServerFailure(e.toString()), null);
    }
  }
}
