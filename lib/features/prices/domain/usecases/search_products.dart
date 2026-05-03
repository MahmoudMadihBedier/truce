import 'package:truce/core/usecases/usecase.dart';
import 'package:truce/core/utils/typedefs.dart';
import 'package:truce/features/prices/domain/models.dart';
import 'package:truce/features/prices/domain/prices_repository.dart';

class SearchProducts extends UseCase<List<Product>, String> {
  final PricesRepository _repository;

  SearchProducts(this._repository);

  @override
  Future<ApiResult<List<Product>>> call(String query) async {
    return _repository.getProducts(query: query);
  }
}
