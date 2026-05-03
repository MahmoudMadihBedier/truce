import 'dart:async';
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
      return (AuthFailure(e.toString()), null);
    }
  }

  @override
  Future<ApiResult<void>> signUpWithEmail(String email, String password) async {
    try {
      await _client.auth.signUp(email: email, password: password);
      return (null, null);
    } catch (e) {
      return (AuthFailure(e.toString()), null);
    }
  }

  @override
  Future<ApiResult<void>> signOut() async {
    try {
      await _client.auth.signOut();
      return (null, null);
    } catch (e) {
      return (AuthFailure(e.toString()), null);
    }
  }

  @override
  Future<ApiResult<void>> signInAsGuest() async {
    try {
      // Note: This requires 'Allow Anonymous Sign-ins' to be enabled in Supabase Dashboard
      await _client.auth.signInAnonymously();
      return (null, null);
    } catch (e) {
       return (AuthFailure(e.toString()), null);
    }
  }

  @override
  Future<ApiResult<void>> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.truce://login-callback/',
      );
      return (null, null);
    } catch (e) {
      return (AuthFailure(e.toString()), null);
    }
  }

  @override
  bool get isAuthenticated => _client.auth.currentUser != null;
}
