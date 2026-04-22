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
      // 1. Fetch products from GS1 Egypt API with validation
      final gs1Response = await _httpClient.get(
        Uri.parse('http://private-anon-b59c34f288-gs1egyptproducts.apiary-mock.com/products'),
      ).timeout(const Duration(seconds: 10));

      List<Product> products = [];

      if (gs1Response.statusCode == 200) {
        final gs1Data = json.decode(gs1Response.body);
        if (gs1Data is Map && gs1Data.containsKey('products')) {
          final gs1Products = gs1Data['products'] as List<dynamic>;

          products = gs1Products.map((item) {
            final productName = item['productName']?['value'] ?? 'Unknown Product';
            final description = item['consumerMarketingDescription']?['value'];
            final photos = item['photos']?['value'];
            final imageUrl = (photos is List && photos.isNotEmpty) ? photos[0] : null;

            final random = Random();
            final basePrice = 20.0 + random.nextInt(100);

            return Product(
              id: random.nextInt(10000),
              nameEn: productName,
              nameAr: productName,
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
                  price: max(5.0, basePrice - 2.5),
                  storeNameEn: 'Noon',
                  storeNameAr: 'نون',
                  storeRating: 4.2,
                  isAvailable: true,
                ),
              ]..sort((a, b) => a.price.compareTo(b.price)),
            );
          }).toList();
        }
      }

      // 2. Fetch from Supabase
      final supabaseResponse = await _client.from('products').select('''
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

      final supabaseData = supabaseResponse as List<dynamic>;

      final supabaseProducts = supabaseData.map((item) {
        final product = Product.fromJson(item);
        final prices = (item['product_prices'] as List<dynamic>).map((p) {
          final store = p['stores'];
          return ProductPrice(
            id: 0,
            price: (p['price'] as num).toDouble(),
            storeNameEn: store['name_en'] ?? 'Unknown',
            storeNameAr: store['name_ar'] ?? 'غير معروف',
            storeRating: (store['rating'] as num? ?? 0.0).toDouble(),
            isAvailable: p['is_available'] ?? true,
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
      return (ServerFailure('Failed to fetch products: ${e.toString()}'), null);
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
        carat: item['carat'] ?? '?',
        buy: (item['price_buy'] as num? ?? 0).toDouble(),
        sell: (item['price_sell'] as num? ?? 0).toDouble(),
        updatedAt: DateTime.tryParse(item['updated_at'] ?? '') ?? DateTime.now(),
      )).toList());
    } catch (e) {
      return (ServerFailure('Gold price data error: ${e.toString()}'), null);
    }
  }

  @override
  Future<ApiResult<List<CurrencyRate>>> getCurrencyRates() async {
    try {
      const url = 'https://api.metalpriceapi.com/v1/latest?api_key=b819b9d518eef61ac6a58d3ac63ae402&base=USD&currencies=EGP';
      final response = await _httpClient.get(Uri.parse(url)).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data['success'] == true && data['rates']?['EGP'] != null) {
          final egpRate = (data['rates']['EGP'] as num).toDouble();
          return (null, [
            CurrencyRate(code: 'USD', rateToEgp: egpRate, updatedAt: DateTime.now()),
          ]);
        }
      }
      return (null, [CurrencyRate(code: 'USD', rateToEgp: 48.50, updatedAt: DateTime.now())]);
    } catch (e) {
      return (null, [CurrencyRate(code: 'USD', rateToEgp: 48.50, updatedAt: DateTime.now())]);
    }
  }
}
