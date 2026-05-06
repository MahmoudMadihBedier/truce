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

  // Base URL for the Python Backend
  static const String _baseUrl = 'http://localhost:8000';

  PricesRepositoryImpl(this._client);

  @override
  Future<ApiResult<List<Product>>> getProducts({String? query, int? categoryId}) async {
    try {
      if (query == null || query.isEmpty) {
        // Return popular items from Supabase if no search query
        // or a default search from the backend
        query = 'Milk';
      }

      final uri = Uri.parse('$_baseUrl/search').replace(queryParameters: {'q': query});

      final response = await _httpClient.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 60)); // Scrapers can take time

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final List<dynamic> data = body['results'];
        final products = data.map((item) => Product.fromJson(item)).toList();
        return (null, products);
      }
      return (ServerFailure('Live search currently unavailable (${response.statusCode})'), null);
    } catch (e) {
      return (ServerFailure('Connection error: $e'), null);
    }
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
      final response = await _httpClient.get(Uri.parse('$_baseUrl/gold'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return (null, data.map((g) => GoldPrice(
          carat: g['caliber'],
          buy: (g['price'] as num).toDouble(),
          sell: (g['price'] as num).toDouble(),
          updatedAt: DateTime.now(),
        )).toList());
      }
      return (null, <GoldPrice>[]);
    } catch (e) {
      return (null, <GoldPrice>[]);
    }
  }

  @override
  Future<ApiResult<List<CurrencyRate>>> getCurrencyRates() async {
    try {
      final response = await _httpClient.get(Uri.parse('$_baseUrl/currency'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return (null, data.map((c) => CurrencyRate(
          code: c['currency'],
          rateToEgp: (c['sell'] as num).toDouble(),
          updatedAt: DateTime.now(),
        )).toList());
      }
      return (null, <CurrencyRate>[]);
    } catch (e) {
      return (null, <CurrencyRate>[]);
    }
  }
}
