import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truce/core/error/failures.dart';
import 'package:truce/core/utils/typedefs.dart';
import 'package:truce/features/prices/domain/models.dart';
import 'package:truce/features/prices/domain/prices_repository.dart';

class PricesRepositoryImpl implements PricesRepository {
  final SupabaseClient _client;

  PricesRepositoryImpl(this._client);

  @override
  Future<ApiResult<List<Product>>> getProducts({String? query, int? categoryId}) async {
    try {
      var request = _client.from('products').select('''
        *,
        product_prices (
          price,
          is_available,
          stores (
            name_en,
            name_ar,
            rating
          )
        )
      ''');

      if (query != null && query.isNotEmpty) {
        request = request.or('name_en.ilike.%%,name_ar.ilike.%%');
      }

      if (categoryId != null) {
        request = request.eq('category_id', categoryId);
      }

      final response = await request;
      final data = response as List<dynamic>;

      final products = data.map((item) {
        final product = Product.fromJson(item);
        final prices = (item['product_prices'] as List<dynamic>).map((p) {
          final store = p['stores'];
          return ProductPrice(
            id: 0,
            price: (p['price'] as num).toDouble(),
            storeNameEn: store['name_en'],
            storeNameAr: store['name_ar'],
            storeRating: (store['rating'] as num).toDouble(),
            isAvailable: p['is_available'],
          );
        }).toList();

        prices.sort((a, b) => a.price.compareTo(b.price));

        return Product(
          id: product.id,
          nameEn: product.nameEn,
          nameAr: product.nameAr,
          descriptionEn: product.descriptionEn,
          descriptionAr: product.descriptionAr,
          imageUrl: product.imageUrl,
          prices: prices,
        );
      }).toList();

      return (null, products);
    } catch (e) {
      return (ServerFailure(e.toString()), null);
    }
  }

  @override
  Future<ApiResult<List<GoldPrice>>> getGoldPrices() async {
    try {
      final response = await _client.from('gold_prices').select();
      final data = response as List<dynamic>;

      if (data.isEmpty) {
        return (null, [
          GoldPrice(carat: '24K', buy: 3450, sell: 3500, updatedAt: DateTime.now()),
          GoldPrice(carat: '21K', buy: 3020, sell: 3060, updatedAt: DateTime.now()),
          GoldPrice(carat: '18K', buy: 2588, sell: 2623, updatedAt: DateTime.now()),
        ]);
      }

      return (null, data.map((item) => GoldPrice(
        carat: item['carat'],
        buy: (item['price_buy'] as num).toDouble(),
        sell: (item['price_sell'] as num).toDouble(),
        updatedAt: DateTime.parse(item['updated_at']),
      )).toList());
    } catch (e) {
      return (ServerFailure(e.toString()), null);
    }
  }

  @override
  Future<ApiResult<List<CurrencyRate>>> getCurrencyRates() async {
    try {
      final response = await _client.from('currency_rates').select();
      final data = response as List<dynamic>;

      if (data.isEmpty) {
        return (null, [
          CurrencyRate(code: 'USD', rateToEgp: 48.50, updatedAt: DateTime.now()),
          CurrencyRate(code: 'EUR', rateToEgp: 52.30, updatedAt: DateTime.now()),
          CurrencyRate(code: 'SAR', rateToEgp: 12.93, updatedAt: DateTime.now()),
        ]);
      }

      return (null, data.map((item) => CurrencyRate(
        code: item['currency_code'],
        rateToEgp: (item['rate_to_egp'] as num).toDouble(),
        updatedAt: DateTime.parse(item['updated_at']),
      )).toList());
    } catch (e) {
      return (ServerFailure(e.toString()), null);
    }
  }
}
