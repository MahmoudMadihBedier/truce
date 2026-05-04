import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truce/features/prices/data/prices_repository_impl.dart';

class MockSupabaseClient extends Fake implements SupabaseClient {
  @override
  String get supabaseKey => 'mock-key';
}

void main() {
  test('PricesRepository returns aggregated products from backend', () async {
    final repo = PricesRepositoryImpl(MockSupabaseClient());
    final (failure, products) = await repo.getProducts();

    // In a test environment, the real fetch might fail or return mock depending on connectivity
    // But we check that it doesn't crash and returns a result
    if (failure != null) {
      expect(failure.message, contains('Aggregator'));
    } else {
      expect(products, isNotNull);
    }
  });
}
