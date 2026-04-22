import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:truce/core/error/failures.dart';
import 'package:truce/core/utils/typedefs.dart';
import 'package:truce/features/auth/domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  AuthRepositoryImpl(this._client);

  @override
  Future<ApiResult<void>> signInWithEmail(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      return (null, null);
    } catch (e) {
      return (const AuthFailure(''), null);
    }
  }

  @override
  Future<ApiResult<void>> signUpWithEmail(String email, String password) async {
    try {
      await _client.auth.signUp(email: email, password: password);
      return (null, null);
    } catch (e) {
      return (const AuthFailure(''), null);
    }
  }

  @override
  Future<ApiResult<void>> signInWithGoogle() async {
    try {
      // Mocking Google Sign In for now as per user request to 'add' it but it didn't work before
      // In a real app, you'd use google_sign_in package then call _client.auth.signInWithIdToken
      return (const AuthFailure('Google Sign In is not configured yet.'), null);
    } catch (e) {
      return (const AuthFailure(''), null);
    }
  }

  @override
  Future<ApiResult<void>> signInAsGuest() async {
    try {
      await _client.auth.signInAnonymously();
      return (null, null);
    } catch (e) {
      // If anonymous sign-in is disabled, we will handle this in the Cubit to allow local guest mode
      return (const AuthFailure(''), null);
    }
  }

  @override
  Future<ApiResult<void>> signOut() async {
    try {
      await _client.auth.signOut();
      return (null, null);
    } catch (e) {
      return (ServerFailure(e.toString()), null);
    }
  }

  @override
  bool get isAuthenticated => _client.auth.currentSession != null;
}
