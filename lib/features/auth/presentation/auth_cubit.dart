import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:truce/features/auth/domain/auth_repository.dart';

sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final sb.User user;
  AuthAuthenticated(this.user);
}
class AuthGuest extends AuthState {}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final sb.SupabaseClient _client;
  late final StreamSubscription<sb.AuthState> _authSubscription;

  AuthCubit(this._repository, this._client) : super(AuthInitial()) {
    _init();
  }

  void _init() {
    // Listen for auth changes (e.g. after OAuth redirect)
    _authSubscription = _client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        emit(AuthAuthenticated(session.user));
      } else {
        // If we were loading or authenticated but now session is null, emit unauth
        if (state is! AuthGuest && state is! AuthInitial) {
           emit(AuthUnauthenticated());
        }
      }
    });

    final currentUser = _client.auth.currentUser;
    if (currentUser != null) {
      emit(AuthAuthenticated(currentUser));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    final (failure, _) = await _repository.signInWithEmail(email, password);
    if (failure != null) {
      emit(AuthError(failure.message));
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(AuthLoading());
    final (failure, _) = await _repository.signUpWithEmail(email, password);
    if (failure != null) {
      emit(AuthError(failure.message));
    }
  }

  Future<void> continueAsGuest() async {
    emit(AuthLoading());
    final (failure, _) = await _repository.signInAsGuest();
    if (failure != null) {
      emit(AuthGuest());
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    final (failure, _) = await _repository.signInWithGoogle();
    if (failure != null) {
      emit(AuthError(failure.message));
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    await _repository.signOut();
    emit(AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
