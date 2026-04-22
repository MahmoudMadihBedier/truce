import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truce/features/auth/domain/auth_repository.dart';

sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {}
class AuthGuest extends AuthState {}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(AuthInitial()) {
    checkAuth();
  }

  void checkAuth() {
    if (_repository.isAuthenticated) {
      emit(AuthAuthenticated());
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    final (failure, _) = await _repository.signInWithEmail(email, password);
    if (failure != null) {
      emit(AuthError(failure.message));
    } else {
      emit(AuthAuthenticated());
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(AuthLoading());
    final (failure, _) = await _repository.signUpWithEmail(email, password);
    if (failure != null) {
      emit(AuthError(failure.message));
    } else {
      emit(AuthAuthenticated());
    }
  }

  Future<void> continueAsGuest() async {
    emit(AuthLoading());
    final (failure, _) = await _repository.signInAsGuest();
    if (failure != null) {
      // If the server fails (e.g. anonymous provider disabled), we still allow them to enter as a local guest
      emit(AuthGuest());
    } else {
      emit(AuthAuthenticated());
    }
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    await _repository.signOut();
    emit(AuthUnauthenticated());
  }
}
