import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truce/features/prices/domain/models.dart';
import 'package:truce/features/prices/domain/prices_repository.dart';

sealed class PricesState {}
class PricesInitial extends PricesState {}
class PricesLoading extends PricesState {}
class PricesLoaded extends PricesState {
  final List<Product> products;
  final List<GoldPrice> goldPrices;
  final List<CurrencyRate> currencyRates;

  PricesLoaded({
    required this.products,
    required this.goldPrices,
    required this.currencyRates,
  });
}
class PricesError extends PricesState {
  final String message;
  PricesError(this.message);
}

class PricesCubit extends Cubit<PricesState> {
  final PricesRepository _repository;

  PricesCubit(this._repository) : super(PricesInitial());

  Future<void> loadDashboard() async {
    emit(PricesLoading());

    final goldRes = await _repository.getGoldPrices();
    final currencyRes = await _repository.getCurrencyRates();
    final productsRes = await _repository.getProducts();

    if (goldRes.$1 != null) {
      emit(PricesError(goldRes.$1!.message));
      return;
    }

    emit(PricesLoaded(
      goldPrices: goldRes.$2 ?? [],
      currencyRates: currencyRes.$2 ?? [],
      products: productsRes.$2 ?? [],
    ));
  }

  Future<void> searchProducts(String query) async {
    final currentState = state;
    if (currentState is PricesLoaded) {
      emit(PricesLoading());
      final result = await _repository.getProducts(query: query);
      if (result.$1 != null) {
        emit(PricesError(result.$1!.message));
      } else {
        emit(PricesLoaded(
          goldPrices: currentState.goldPrices,
          currencyRates: currentState.currencyRates,
          products: result.$2 ?? [],
        ));
      }
    }
  }
}
