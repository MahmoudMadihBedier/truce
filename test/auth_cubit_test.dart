import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:truce/features/auth/domain/auth_repository.dart';
import 'package:truce/features/auth/presentation/auth_cubit.dart';
import 'package:truce/core/utils/typedefs.dart';

class MockAuthRepository implements AuthRepository {
  @override
  bool get isAuthenticated => false;

  @override
  Future<ApiResult<void>> signInAsGuest() async => (null, null);

  @override
  Future<ApiResult<void>> signInWithEmail(String email, String password) async => (null, null);

  @override
  Future<ApiResult<void>> signInWithGoogle() async => (null, null);

  @override
  Future<ApiResult<void>> signOut() async => (null, null);

  @override
  Future<ApiResult<void>> signUpWithEmail(String email, String password) async => (null, null);
}

class MockSupabaseClient extends Fake implements sb.SupabaseClient {
  @override
  sb.GoTrueClient get auth => MockGoTrueClient();
}

class MockGoTrueClient extends Fake implements sb.GoTrueClient {
  @override
  sb.User? get currentUser => null;

  @override
  Stream<sb.AuthState> get onAuthStateChange => const Stream.empty();
}

void main() {
  late AuthCubit cubit;
  late MockAuthRepository repo;
  late MockSupabaseClient client;

  setUp(() {
    repo = MockAuthRepository();
    client = MockSupabaseClient();
    cubit = AuthCubit(repo, client);
  });

  test('initial state is AuthUnauthenticated if client has no user', () {
    expect(cubit.state, isA<AuthUnauthenticated>());
  });
}
