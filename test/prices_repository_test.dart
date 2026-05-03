import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truce/features/prices/data/prices_repository_impl.dart';

class MockSupabaseClient extends Fake implements SupabaseClient {}

void main() {
  test('PricesRepository returns user provided mock products', () async {
    final repo = PricesRepositoryImpl(MockSupabaseClient());
    final (failure, products) = await repo.getProducts();

    expect(failure, isNull);
    expect(products, isNotNull);

    // Check for "Red Bull" (Carrefour data)
    final redBull = products!.firstWhere((p) => p.nameEn.contains('Red Bull'));
    expect(redBull.prices.first.storeNameEn, 'Carrefour');
    expect(redBull.prices.first.price, 204.99);

    // Check for "Lavazza" (Jumia data)
    final lavazza = products.firstWhere((p) => p.nameEn.contains('Decaffeinated Ground Coffee'));
    expect(lavazza.prices.first.storeNameEn, 'Jumia');
    expect(lavazza.prices.first.price, 500.0);
  });
}
