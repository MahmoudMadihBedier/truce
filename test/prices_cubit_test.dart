import 'package:flutter_test/flutter_test.dart';
import 'package:truce/features/prices/domain/models.dart';
import 'package:truce/features/prices/domain/prices_repository.dart';
import 'package:truce/features/prices/domain/usecases/get_dashboard_data.dart';
import 'package:truce/features/prices/domain/usecases/search_products.dart';
import 'package:truce/features/prices/presentation/prices_cubit.dart';
import 'package:truce/core/utils/typedefs.dart';

class MockPricesRepository implements PricesRepository {
  @override
  Future<ApiResult<List<CurrencyRate>>> getCurrencyRates() async => (null, <CurrencyRate>[]);

  @override
  Future<ApiResult<List<GoldPrice>>> getGoldPrices() async => (null, <GoldPrice>[]);

  @override
  Future<ApiResult<List<Product>>> getProducts({String? query, int? categoryId}) async => (null, <Product>[]);
}

void main() {
  late PricesCubit cubit;
  late GetDashboardData getDashboardData;
  late SearchProducts searchProducts;
  late MockPricesRepository repo;

  setUp(() {
    repo = MockPricesRepository();
    getDashboardData = GetDashboardData(repo);
    searchProducts = SearchProducts(repo);
    cubit = PricesCubit(getDashboardData, searchProducts);
  });

  test('initial state is PricesInitial', () {
    expect(cubit.state, isA<PricesInitial>());
  });

  test('loadDashboard emits PricesLoaded', () async {
    await cubit.loadDashboard();
    expect(cubit.state, isA<PricesLoaded>());
  });
}
