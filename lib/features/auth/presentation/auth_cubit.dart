import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  final String userId;
  const AuthAuthenticated(this.userId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthAuthenticated && userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
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

  AuthCubit(this._repository) : super(const AuthInitial()) {
    _init();
  }

  void _init() {
    final userId = _repository.currentUserId;
    if (_repository.isAuthenticated && userId != null) {
      emit(AuthAuthenticated(userId));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(const AuthLoading());
    final (failure, _) = await _repository.signInWithEmail(email, password);
    if (failure == null) {
      final userId = _repository.currentUserId;
      emit(AuthAuthenticated(userId ?? 'user'));
    } else {
      emit(AuthError(failure.message));
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(const AuthLoading());
    final (failure, _) = await _repository.signUpWithEmail(email, password);
    if (failure == null) {
      final userId = _repository.currentUserId;
      emit(AuthAuthenticated(userId ?? 'user'));
    } else {
      emit(AuthError(failure.message));
    }
  }

  Future<void> continueAsGuest() async {
    emit(const AuthLoading());
    final (failure, _) = await _repository.signInAsGuest();
    if (failure == null) {
      emit(const AuthGuest());
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    final (failure, _) = await _repository.signInWithGoogle();
    if (failure == null) {
      final userId = _repository.currentUserId;
      emit(AuthAuthenticated(userId ?? 'google_user'));
    } else {
      emit(AuthError(failure.message));
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    await _repository.signOut();
    emit(const AuthUnauthenticated());
  }
}
