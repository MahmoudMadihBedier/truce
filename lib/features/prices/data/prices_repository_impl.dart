import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:truce/core/error/failures.dart';
import 'package:truce/core/utils/typedefs.dart';
import 'package:truce/core/utils/constants.dart';
import 'package:truce/features/prices/domain/models.dart';
import 'package:truce/features/prices/domain/prices_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PricesRepositoryImpl implements PricesRepository {
  final http.Client _httpClient = http.Client();

  PricesRepositoryImpl(SupabaseClient client);

  @override
  Future<ApiResult<List<Product>>> getProducts({String? query, int? categoryId}) async {
    try {
      final queryParams = <String, String>{};
      if (query != null && query.isNotEmpty) queryParams['q'] = query;
      if (categoryId != null) queryParams['category_id'] = categoryId.toString();

      final uri = Uri.parse('${Constants.apiBaseUrl}/products').replace(queryParameters: queryParams);

      final response = await _httpClient.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: Constants.apiTimeoutSeconds));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final products = data.map((item) => Product.fromJson(item)).toList();
        return (null, products);
      }
      return (ServerFailure('Error fetching products (${response.statusCode})'), null);
    } catch (e) {
      return (ServerFailure('Connection error: $e'), null);
    }
  }

  @override
  Future<ApiResult<List<Category>>> getCategories() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('${Constants.apiBaseUrl}/categories'),
      ).timeout(const Duration(seconds: Constants.apiTimeoutSeconds));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final categories = data.map((item) => Category.fromJson(item)).toList();
        return (null, categories);
      }
      return (const ServerFailure('Error fetching categories'), null);
    } catch (e) {
      return (ServerFailure(e.toString()), null);
    }
  }

  @override
  Future<ApiResult<List<GoldPrice>>> getGoldPrices() async {
    // Return empty as requested to focus on the provided APIs
    return (null, <GoldPrice>[]);
  }

  @override
  Future<ApiResult<List<CurrencyRate>>> getCurrencyRates() async {
    // Return empty as requested to focus on the provided APIs
    return (null, <CurrencyRate>[]);
  }
}
