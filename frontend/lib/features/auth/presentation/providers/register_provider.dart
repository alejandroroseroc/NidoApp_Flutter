import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/usecases/register_usecase.dart';

// Estado de UI para controlar flujo de registro.
class RegisterState {
  const RegisterState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.usuario,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;
  final Usuario? usuario;

  RegisterState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isSuccess,
    Usuario? usuario,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
      usuario: usuario ?? this.usuario,
    );
  }
}

class RegisterNotifier extends StateNotifier<RegisterState> {
  RegisterNotifier(this._registerUseCase, this._tokenStorage)
    : super(const RegisterState());

  final RegisterUseCase _registerUseCase;
  final TokenStorageService _tokenStorage;

  Future<void> register({
    required String nombre,
    required String correo,
    required String contrasena,
    required String telefono,
  }) async {
    state = state.copyWith(isLoading: true, isSuccess: false, clearError: true);

    final result = await _registerUseCase(
      RegisterParams(
        nombre: nombre,
        correo: correo,
        contrasena: contrasena,
        telefono: telefono,
      ),
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
        await _tokenStorage.saveSession(token: token, usuario: usuario);
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

final registerProvider = StateNotifierProvider<RegisterNotifier, RegisterState>(
  (ref) => sl<RegisterNotifier>(),
);
