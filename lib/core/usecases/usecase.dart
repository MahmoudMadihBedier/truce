import 'package:truce/core/utils/typedefs.dart';

abstract class UseCase<T, Params> {
  Future<ApiResult<T>> call(Params params);
}

class NoParams {}
