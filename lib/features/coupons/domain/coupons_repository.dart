import 'package:truce/core/utils/typedefs.dart';
import 'package:truce/features/coupons/domain/models.dart';

abstract class CouponsRepository {
  Future<ApiResult<List<Coupon>>> getCoupons();
}
