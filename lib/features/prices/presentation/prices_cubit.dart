import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truce/features/prices/domain/models.dart';
import 'package:truce/features/prices/domain/prices_repository.dart';

sealed class PricesState {}
class PricesInitial extends PricesState {}
class PricesLoading extends PricesState {}
class PricesLoaded extends PricesState {
  final List<CurrencyRate> currencyRates;
  final List<GoldPrice> goldPrices;
  final List<Product> products;
  final List<Category> categories;
  final int? selectedCategoryId;

  PricesLoaded({
    required this.currencyRates,
    required this.goldPrices,
    required this.products,
    required this.categories,
    this.selectedCategoryId
  });

  PricesLoaded copyWith({
    List<CurrencyRate>? currencyRates,
    List<GoldPrice>? goldPrices,
    List<Product>? products,
    List<Category>? categories,
    int? selectedCategoryId,
    bool clearCategory = false
  }) {
    return PricesLoaded(
      currencyRates: currencyRates ?? this.currencyRates,
      goldPrices: goldPrices ?? this.goldPrices,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategoryId: clearCategory ? null : (selectedCategoryId ?? this.selectedCategoryId),
    );
  }
}
class PricesError extends PricesState {
  final String message;
  PricesError(this.message);
}

class PricesCubit extends Cubit<PricesState> {
  final PricesRepository _repository;
  Timer? _searchDebounce;

  PricesCubit(this._repository) : super(PricesInitial());

  Future<void> loadDashboard({int? categoryId}) async {
    final currentState = state;
    List<Category> categories = [];
    List<CurrencyRate> rates = [];
    List<GoldPrice> gold = [];

    if (currentState is PricesLoaded) {
      categories = currentState.categories;
      rates = currentState.currencyRates;
      gold = currentState.goldPrices;
    }

    emit(PricesLoading());

    try {
      if (categories.isEmpty) {
        final catRes = await _repository.getCategories();
        categories = catRes.$2 ?? [];
      }

      if (rates.isEmpty) {
        final ratesRes = await _repository.getCurrencyRates();
        rates = ratesRes.$2 ?? [];
      }

      if (gold.isEmpty) {
        final goldRes = await _repository.getGoldPrices();
        gold = goldRes.$2 ?? [];
      }

      final prodRes = await _repository.getProducts(categoryId: categoryId);
      final products = prodRes.$2 ?? [];

      emit(PricesLoaded(
        currencyRates: rates,
        goldPrices: gold,
        products: products,
        categories: categories,
        selectedCategoryId: categoryId
      ));
    } catch (e) {
      emit(PricesError(e.toString()));
    }
  }

  Future<void> selectCategory(int? id) async {
    await loadDashboard(categoryId: id);
  }

  void searchProducts(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      final currentState = state;
      if (currentState is PricesLoaded) {
        emit(PricesLoading());
        final prodRes = await _repository.getProducts(query: query);
        if (!isClosed) {
          emit(currentState.copyWith(
            products: prodRes.$2 ?? [],
            clearCategory: true
          ));
        }
      }
    });
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
