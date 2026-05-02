import 'package:flutter_test/flutter_test.dart';
import 'package:truce/features/prices/domain/models.dart';
import 'package:truce/features/prices/domain/prices_repository.dart';
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
  late MockPricesRepository repo;

  setUp(() {
    repo = MockPricesRepository();
    cubit = PricesCubit(repo);
  });

  test('initial state is PricesInitial', () {
    expect(cubit.state, isA<PricesInitial>());
  });

  test('loadDashboard emits PricesLoaded', () async {
    await cubit.loadDashboard();
    expect(cubit.state, isA<PricesLoaded>());
  });
}
