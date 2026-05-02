import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/usecases/login_usecase.dart';

// Estado de UI para controlar flujo de login.
class LoginState {
  const LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.usuario,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;
  final Usuario? usuario;

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isSuccess,
    Usuario? usuario,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
      usuario: usuario ?? this.usuario,
    );
  }
}

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier(this._loginUseCase, this._tokenStorage)
      : super(const LoginState());

  final LoginUseCase _loginUseCase;
  final TokenStorageService _tokenStorage;

  Future<void> login({
    required String correo,
    required String contrasena,
  }) async {
    state = state.copyWith(isLoading: true, isSuccess: false, clearError: true);

    final result = await _loginUseCase(
      LoginParams(correo: correo, contrasena: contrasena),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMessage: failure.message,
        );
      },
      (data) async {
        final token = data['token'] as String;
        final usuario = data['usuario'] as Usuario;
        await _tokenStorage.saveToken(token);
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          usuario: usuario,
          clearError: true,
        );
      },
    );
  }

  void clearStatus() {
    state = state.copyWith(isSuccess: false, clearError: true);
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>(
  (ref) => sl<LoginNotifier>(),
);
