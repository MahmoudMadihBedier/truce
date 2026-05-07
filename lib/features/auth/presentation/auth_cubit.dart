import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:truce/features/auth/domain/auth_repository.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final sb.User user;
  const AuthAuthenticated(this.user);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthAuthenticated && user.id == other.user.id;

  @override
  int get hashCode => user.id.hashCode;
}

class AuthGuest extends AuthState {
  const AuthGuest();
  @override
  bool operator ==(Object other) => other is AuthGuest;
  @override
  int get hashCode => runtimeType.hashCode;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
  @override
  bool operator ==(Object other) => other is AuthUnauthenticated;
  @override
  int get hashCode => runtimeType.hashCode;
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  bool operator ==(Object other) =>
      other is AuthError && message == other.message;
  @override
  int get hashCode => message.hashCode;
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final sb.SupabaseClient _client;
  late final StreamSubscription<sb.AuthState> _authSubscription;

  AuthCubit(this._repository, this._client) : super(const AuthInitial()) {
    _init();
  }

  void _init() {
    _authSubscription = _client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        if (state is! AuthAuthenticated || (state as AuthAuthenticated).user.id != session.user.id) {
          emit(AuthAuthenticated(session.user));
        }
      } else {
        if (state is! AuthGuest && state is! AuthUnauthenticated && state is! AuthInitial) {
           emit(const AuthUnauthenticated());
        }
      }
    });

    final currentUser = _client.auth.currentUser;
    if (currentUser != null) {
      emit(AuthAuthenticated(currentUser));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(const AuthLoading());
    final (failure, _) = await _repository.signInWithEmail(email, password);
    if (failure != null) {
      emit(AuthError(failure.message));
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(const AuthLoading());
    final (failure, _) = await _repository.signUpWithEmail(email, password);
    if (failure != null) {
      emit(AuthError(failure.message));
    }
  }

  Future<void> continueAsGuest() async {
    emit(const AuthLoading());
    final (failure, _) = await _repository.signInAsGuest();
    if (failure != null) {
      emit(const AuthGuest());
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    final (failure, _) = await _repository.signInWithGoogle();
    if (failure != null) {
      emit(AuthError(failure.message));
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    await _repository.signOut();
    emit(const AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
