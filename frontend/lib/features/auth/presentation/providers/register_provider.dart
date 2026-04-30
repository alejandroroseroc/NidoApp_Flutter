import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/usecases/register_usecase.dart';

// Estado de UI para controlar flujo de registro.
class RegisterState {
  const RegisterState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  RegisterState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isSuccess,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class RegisterNotifier extends StateNotifier<RegisterState> {
  RegisterNotifier(this._registerUseCase) : super(const RegisterState());

  final RegisterUseCase _registerUseCase;

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
      (_) {
        state = state.copyWith(isLoading: false, isSuccess: true, clearError: true);
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
