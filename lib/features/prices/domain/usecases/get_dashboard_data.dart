import 'package:truce/core/usecases/usecase.dart';
import 'package:truce/core/utils/typedefs.dart';
import 'package:truce/features/prices/domain/models.dart';
import 'package:truce/features/prices/domain/prices_repository.dart';

class GetDashboardData extends UseCase<(List<CurrencyRate>, List<GoldPrice>, List<Product>), NoParams> {
  final PricesRepository _repository;

  GetDashboardData(this._repository);

  @override
  Future<ApiResult<(List<CurrencyRate>, List<GoldPrice>, List<Product>)>> call(NoParams params) async {
    final results = await Future.wait([
      _repository.getCurrencyRates(),
      _repository.getGoldPrices(),
      _repository.getProducts(),
    ]);

    final rates = (results[0] as ApiResult<List<CurrencyRate>>).$2 ?? [];
    final gold = (results[1] as ApiResult<List<GoldPrice>>).$2 ?? [];
    final products = (results[2] as ApiResult<List<Product>>).$2 ?? [];

    return (null, (rates, gold, products));
  }
}
