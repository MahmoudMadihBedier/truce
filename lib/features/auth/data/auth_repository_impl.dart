import 'dart:async';
import 'package:truce/core/error/failures.dart';
import 'package:truce/core/utils/typedefs.dart';
import 'package:truce/features/auth/domain/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SharedPreferences _prefs;
  static const String _authKey = 'is_authenticated';
  static const String _userIdKey = 'user_id';

  AuthRepositoryImpl(this._prefs);

  @override
  Future<ApiResult<void>> signInWithEmail(String email, String password) async {
    try {
      // Local simulated auth
      await _prefs.setBool(_authKey, true);
      await _prefs.setString(_userIdKey, 'user_123');
      return (null, null);
    } catch (e) {
      return (AuthFailure(e.toString()), null);
    }
  }

  @override
  Future<ApiResult<void>> signUpWithEmail(String email, String password) async {
    try {
      await _prefs.setBool(_authKey, true);
      await _prefs.setString(_userIdKey, 'user_new');
      return (null, null);
    } catch (e) {
      return (AuthFailure(e.toString()), null);
    }
  }

  @override
  Future<ApiResult<void>> signOut() async {
    try {
      await _prefs.remove(_authKey);
      await _prefs.remove(_userIdKey);
      return (null, null);
    } catch (e) {
      return (AuthFailure(e.toString()), null);
    }
  }

  @override
  Future<ApiResult<void>> signInAsGuest() async {
    try {
      await _prefs.setBool(_authKey, false);
      return (null, null);
    } catch (e) {
       return (AuthFailure(e.toString()), null);
    }
  }

  @override
  Future<ApiResult<void>> signInWithGoogle() async {
    try {
      await _prefs.setBool(_authKey, true);
      await _prefs.setString(_userIdKey, 'google_user');
      return (null, null);
    } catch (e) {
      return (AuthFailure(e.toString()), null);
    }
  }

  @override
  bool get isAuthenticated => _prefs.getBool(_authKey) ?? false;

  @override
  String? get currentUserId => _prefs.getString(_userIdKey);
}
