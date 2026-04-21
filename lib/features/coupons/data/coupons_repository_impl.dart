import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truce/core/error/failures.dart';
import 'package:truce/core/utils/typedefs.dart';
import 'package:truce/features/coupons/domain/models.dart';
import 'package:truce/features/coupons/domain/coupons_repository.dart';

class CouponsRepositoryImpl implements CouponsRepository {
  final SupabaseClient _client;

  CouponsRepositoryImpl(this._client);

  @override
  Future<ApiResult<List<Coupon>>> getCoupons() async {
    try {
      final response = await _client.from('coupons').select('*, stores(name_en, name_ar)');
      final data = response as List<dynamic>;
      return (null, data.map((item) => Coupon.fromJson(item)).toList());
    } catch (e) {
      return (ServerFailure(e.toString()), null);
    }
  }
}
