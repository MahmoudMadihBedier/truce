import 'package:truce/core/utils/typedefs.dart';
import 'package:truce/features/prices/domain/models.dart';

abstract class PricesRepository {
  Future<ApiResult<List<Product>>> getProducts({String? query, int? categoryId});
  Future<ApiResult<List<GoldPrice>>> getGoldPrices();
  Future<ApiResult<List<CurrencyRate>>> getCurrencyRates();
  Future<ApiResult<List<Category>>> getCategories();
}
