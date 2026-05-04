import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truce/features/auth/data/auth_repository_impl.dart';
import 'package:truce/features/auth/domain/auth_repository.dart';
import 'package:truce/features/auth/presentation/auth_cubit.dart';
import 'package:truce/features/prices/data/prices_repository_impl.dart';
import 'package:truce/features/prices/domain/prices_repository.dart';
import 'package:truce/features/prices/domain/usecases/get_dashboard_data.dart';
import 'package:truce/features/prices/domain/usecases/search_products.dart';
import 'package:truce/features/prices/presentation/prices_cubit.dart';
import 'package:truce/features/coupons/data/coupons_repository_impl.dart';
import 'package:truce/features/coupons/domain/coupons_repository.dart';
import 'package:truce/features/settings/presentation/settings_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);

  // Supabase
  final supabase = Supabase.instance.client;
  sl.registerLazySingleton(() => supabase);

  // Features
  _initAuth();
  _initPrices();
  _initCoupons();
  _initSettings();
}

void _initAuth() {
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerFactory(() => AuthCubit(sl(), sl()));
}

void _initPrices() {
  sl.registerLazySingleton<PricesRepository>(() => PricesRepositoryImpl(sl()));

  // Use cases
  sl.registerLazySingleton(() => GetDashboardData(sl()));
  sl.registerLazySingleton(() => SearchProducts(sl()));

  sl.registerFactory(() => PricesCubit(sl(), sl()));
}

void _initCoupons() {
  sl.registerLazySingleton<CouponsRepository>(() => CouponsRepositoryImpl(sl()));
}

void _initSettings() {
  sl.registerFactory(() => SettingsCubit(sl()));
}
