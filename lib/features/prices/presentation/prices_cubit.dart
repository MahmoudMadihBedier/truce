import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truce/core/usecases/usecase.dart';
import 'package:truce/features/prices/domain/models.dart';
import 'package:truce/features/prices/domain/usecases/get_dashboard_data.dart';
import 'package:truce/features/prices/domain/usecases/search_products.dart';

sealed class PricesState {}
class PricesInitial extends PricesState {}
class PricesLoading extends PricesState {}
class PricesLoaded extends PricesState {
  final List<CurrencyRate> currencyRates;
  final List<GoldPrice> goldPrices;
  final List<Product> products;
  PricesLoaded({required this.currencyRates, required this.goldPrices, required this.products});
}
class PricesError extends PricesState {
  final String message;
  PricesError(this.message);
}

class PricesCubit extends Cubit<PricesState> {
  final GetDashboardData _getDashboardData;
  final SearchProducts _searchProducts;

  PricesCubit(this._getDashboardData, this._searchProducts) : super(PricesInitial());

  Future<void> loadDashboard() async {
    emit(PricesLoading());
    final (failure, data) = await _getDashboardData(NoParams());
    if (failure != null) {
      emit(PricesError(failure.message));
    } else if (data != null) {
      emit(PricesLoaded(
        currencyRates: data.$1,
        goldPrices: data.$2,
        products: data.$3,
      ));
    }
  }

  Future<void> searchProducts(String query) async {
    final currentState = state;
    if (currentState is PricesLoaded) {
      emit(PricesLoading());
      final (failure, products) = await _searchProducts(query);
      if (failure != null) {
        emit(PricesError(failure.message));
      } else {
        emit(PricesLoaded(
          currencyRates: currentState.currencyRates,
          goldPrices: currentState.goldPrices,
          products: products ?? [],
        ));
      }
    }
  }
}
