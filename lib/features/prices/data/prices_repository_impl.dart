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
      String url = 'https://mgqcolwglaavwazjwjir.supabase.co/functions/v1/product-aggregator';
      if (categoryId != null) {
        url += '?category_id=$categoryId';
      } else if (query != null) {
        url += '?q=${Uri.encodeComponent(query)}';
      }

      final response = await _httpClient.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final products = data.map((item) {
          return Product(
            id: DateTime.now().millisecondsSinceEpoch + item.hashCode,
            nameEn: item['name'],
            nameAr: item['name'],
            imageUrl: item['image'],
            descriptionEn: item['description'],
            categoryId: item['category_id'],
            prices: [
              ProductPrice(
                id: 0,
                price: (item['price'] as num).toDouble(),
                storeNameEn: item['store'],
                storeNameAr: _getStoreNameAr(item['store']),
                storeRating: (item['rating'] as num).toDouble(),
                isAvailable: true,
                productUrl: item['url'],
              )
            ],
          );
        }).toList();
        return (null, products);
      }
      return (ServerFailure('API Error'), null);
    } catch (e) {
      return (ServerFailure(e.toString()), null);
    }
  }

  String _getStoreNameAr(String en) {
    if (en.contains('Amazon')) return 'أمازون مصر';
    if (en.contains('Jumia')) return 'جوميا';
    if (en.contains('Carrefour')) return 'كارفور مصر';
    return en;
  }

  @override
  Future<ApiResult<List<Category>>> getCategories() async {
    try {
      final response = await _client.from('categories').select().order('id');
      final data = response as List<dynamic>;
      final List<Category> list = data.map((item) => Category.fromJson(item)).toList();
      return (null, list);
    } catch (e) {
      return (ServerFailure(e.toString()), null);
    }
  }

  @override
  Future<ApiResult<List<GoldPrice>>> getGoldPrices() async {
    try {
      final response = await _client.from('gold_prices').select();
      final data = response as List<dynamic>;
      final List<GoldPrice> list = data.map((g) => GoldPrice(
        carat: g['carat'],
        buy: (g['price_buy'] as num).toDouble(),
        sell: (g['price_sell'] as num).toDouble(),
        updatedAt: DateTime.parse(g['updated_at']),
      )).toList();
      return (null, list);
    } catch (e) {
      return (null, <GoldPrice>[]);
    }
  }

  @override
  Future<ApiResult<List<CurrencyRate>>> getCurrencyRates() async {
    try {
      final response = await _client.from('currency_rates').select();
      final data = response as List<dynamic>;
      final List<CurrencyRate> list = data.map((c) => CurrencyRate(
        code: c['currency_code'],
        rateToEgp: (c['rate_to_egp'] as num).toDouble(),
        updatedAt: DateTime.parse(c['updated_at']),
      )).toList();
      return (null, list);
    } catch (e) {
      return (null, <CurrencyRate>[]);
    }
  }
}
