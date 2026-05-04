import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truce/core/error/failures.dart';
import 'package:truce/core/utils/typedefs.dart';
import 'package:truce/features/prices/domain/models.dart';
import 'package:truce/features/prices/domain/prices_repository.dart';

class PricesRepositoryImpl implements PricesRepository {
  final SupabaseClient _client;
  final http.Client _httpClient = http.Client();

  PricesRepositoryImpl(this._client);

  @override
  Future<ApiResult<List<Product>>> getProducts({String? query, int? categoryId}) async {
    try {
      final searchTerm = query ?? 'iphone';

      final response = await _httpClient.get(
        Uri.parse('https://mgqcolwglaavwazjwjir.supabase.co/functions/v1/product-aggregator?q=$searchTerm'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final List<Product> products = data.map((item) {
          final price = (item['price'] as num).toDouble();
          final mrp = item['mrp'] != null ? (item['mrp'] as num).toDouble() : null;

          return Product(
            id: DateTime.now().millisecondsSinceEpoch + item.hashCode,
            nameEn: item['name'],
            nameAr: item['name'],
            imageUrl: item['image'],
            descriptionEn: item['description'],
            descriptionAr: item['description'],
            prices: [
              ProductPrice(
                id: 0,
                price: price,
                previousPrice: mrp,
                storeNameEn: item['store'],
                storeNameAr: _getStoreNameAr(item['store']),
                storeRating: (item['rating'] as num).toDouble(),
                isAvailable: true,
                productUrl: item['url'],
                discountInfo: item['discount'],
              )
            ],
          );
        }).toList();

        return (null, products);
      } else {
        return (ServerFailure('Backend Aggregator Error: ${response.statusCode}'), null);
      }
    } catch (e) {
      return (ServerFailure('Failed to fetch from aggregator: ${e.toString()}'), null);
    }
  }

  String _getStoreNameAr(String en) {
    if (en.contains('Amazon')) return 'أمازون مصر';
    if (en.contains('Jumia')) return 'جوميا';
    if (en.contains('Carrefour')) return 'كارفور مصر';
    return en;
  }

  @override
  Future<ApiResult<List<GoldPrice>>> getGoldPrices() async {
    try {
      final response = await _client.from('gold_prices').select();
      final data = response as List<dynamic>;
      return (null, data.map((g) => GoldPrice(
        carat: g['carat'],
        buy: (g['price_buy'] as num).toDouble(),
        sell: (g['price_sell'] as num).toDouble(),
        updatedAt: DateTime.parse(g['updated_at']),
      )).toList());
    } catch (e) {
      return (null, [
        GoldPrice(carat: '24K', buy: 4200, sell: 4250, updatedAt: DateTime.now()),
        GoldPrice(carat: '21K', buy: 3675, sell: 3720, updatedAt: DateTime.now()),
        GoldPrice(carat: '18K', buy: 3150, sell: 3190, updatedAt: DateTime.now()),
      ]);
    }
  }

  @override
  Future<ApiResult<List<CurrencyRate>>> getCurrencyRates() async {
    try {
      final response = await _client.from('currency_rates').select();
      final data = response as List<dynamic>;
      return (null, data.map((c) => CurrencyRate(
        code: c['currency_code'],
        rateToEgp: (c['rate_to_egp'] as num).toDouble(),
        updatedAt: DateTime.parse(c['updated_at']),
      )).toList());
    } catch (e) {
      return (null, [
        CurrencyRate(code: 'USD', rateToEgp: 53.50, updatedAt: DateTime.now()),
      ]);
    }
  }
}
