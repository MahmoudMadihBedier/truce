import 'dart:convert';
import 'dart:math';
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
      // 1. Fetch products from GS1 Egypt API
      final gs1Response = await _httpClient.get(
        Uri.parse('http://private-anon-b59c34f288-gs1egyptproducts.apiary-mock.com/products'),
      );

      List<Product> products = [];

      if (gs1Response.statusCode == 200) {
        final gs1Data = json.decode(gs1Response.body);
        final gs1Products = gs1Data['products'] as List<dynamic>;

        products = gs1Products.map((item) {
          final productName = item['productName']['value'] ?? 'Unknown Product';
          final description = item['consumerMarketingDescription']['value'];
          final imageUrl = (item['photos']['value'] as List<dynamic>).isNotEmpty
              ? item['photos']['value'][0]
              : null;

          // For demonstration, we'll add random prices from Egyptian stores
          final random = Random();
          final basePrice = 20.0 + random.nextInt(100);

          return Product(
            id: random.nextInt(10000),
            nameEn: productName,
            nameAr: productName, // Mocking AR name as the same since API only gives one
            descriptionEn: description,
            descriptionAr: description,
            imageUrl: imageUrl,
            prices: [
              ProductPrice(
                id: 1,
                price: basePrice,
                storeNameEn: 'Amazon Egypt',
                storeNameAr: 'أمازون مصر',
                storeRating: 4.5,
                isAvailable: true,
              ),
              ProductPrice(
                id: 2,
                price: basePrice - 2.5,
                storeNameEn: 'Noon',
                storeNameAr: 'نون',
                storeRating: 4.2,
                isAvailable: true,
              ),
            ]..sort((a, b) => a.price.compareTo(b.price)),
          );
        }).toList();
      }

      // 2. Fetch from Supabase as well
      final supabaseRequest = _client.from('products').select('''
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

      final supabaseResponse = await supabaseRequest;
      final supabaseData = supabaseResponse as List<dynamic>;

      final supabaseProducts = supabaseData.map((item) {
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

      return (null, [...products, ...supabaseProducts]);
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
      // Fetch USD/EGP from Metal Price API
      const url = 'https://api.metalpriceapi.com/v1/latest?api_key=b819b9d518eef61ac6a58d3ac63ae402&base=USD&currencies=EGP';
      final response = await _httpClient.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final egpRate = (data['rates']['EGP'] as num).toDouble();
          return (null, [
            CurrencyRate(code: 'USD', rateToEgp: egpRate, updatedAt: DateTime.now()),
          ]);
        }
      }

      // Fallback
      return (null, [
        CurrencyRate(code: 'USD', rateToEgp: 48.50, updatedAt: DateTime.now()),
      ]);
    } catch (e) {
      return (null, [
        CurrencyRate(code: 'USD', rateToEgp: 48.50, updatedAt: DateTime.now()),
      ]);
    }
  }
}
