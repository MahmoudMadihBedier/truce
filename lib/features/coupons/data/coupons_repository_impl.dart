import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:truce/core/error/failures.dart';
import 'package:truce/core/utils/typedefs.dart';
import 'package:truce/core/utils/constants.dart';
import 'package:truce/features/coupons/domain/models.dart';
import 'package:truce/features/coupons/domain/coupons_repository.dart';

class CouponsRepositoryImpl implements CouponsRepository {
  final http.Client _httpClient = http.Client();

  CouponsRepositoryImpl();

  @override
  Future<ApiResult<List<Coupon>>> getCoupons() async {
    try {
      final response = await _httpClient.get(Uri.parse('${Constants.apiBaseUrl}/coupons'));

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

      return (const ServerFailure('No coupons available'), null);
    } catch (e) {
      return (ServerFailure(e.toString()), null);
    }
  }
}
