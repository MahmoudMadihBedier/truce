import 'package:truce/core/utils/typedefs.dart';

abstract class AuthRepository {
  Future<ApiResult<void>> signInWithEmail(String email, String password);
  Future<ApiResult<void>> signUpWithEmail(String email, String password);
  Future<ApiResult<void>> signInWithGoogle();
  Future<ApiResult<void>> signInAsGuest();
  Future<ApiResult<void>> signOut();
  bool get isAuthenticated;
}
