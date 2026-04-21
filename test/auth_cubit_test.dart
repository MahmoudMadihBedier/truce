import 'package:flutter_test/flutter_test.dart';
import 'package:truce/features/auth/domain/auth_repository.dart';
import 'package:truce/features/auth/presentation/auth_cubit.dart';
import 'package:truce/core/utils/typedefs.dart';

class MockAuthRepository implements AuthRepository {
  bool authenticated = false;

  @override
  bool get isAuthenticated => authenticated;

  @override
  Future<ApiResult<void>> signInAsGuest() async {
    authenticated = true;
    return (null, null);
  }

  @override
  Future<ApiResult<void>> signInWithEmail(String email, String password) async => (null, null);

  @override
  Future<ApiResult<void>> signInWithGoogle() async => (null, null);

  @override
  Future<ApiResult<void>> signOut() async {
    authenticated = false;
    return (null, null);
  }

  @override
  Future<ApiResult<void>> signUpWithEmail(String email, String password) async => (null, null);
}

void main() {
  late AuthCubit cubit;
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
    cubit = AuthCubit(repo);
  });

  test('initial state is Unauthenticated if repo is not authenticated', () {
    expect(cubit.state, isA<AuthUnauthenticated>());
  });

  test('signInAsGuest emits Authenticated', () async {
    await cubit.signInAsGuest();
    expect(cubit.state, isA<AuthAuthenticated>());
  });
}
