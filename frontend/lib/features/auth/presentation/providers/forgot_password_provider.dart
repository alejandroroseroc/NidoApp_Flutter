import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';

class ForgotPasswordState {
  const ForgotPasswordState({
    this.isLoading = false,
    this.errorMessage,
    this.codigoEnviado = false,
    this.resetExitoso = false,
    this.correo,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool codigoEnviado;
  final bool resetExitoso;
  final String? correo;

  ForgotPasswordState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? codigoEnviado,
    bool? resetExitoso,
    String? correo,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      codigoEnviado: codigoEnviado ?? this.codigoEnviado,
      resetExitoso: resetExitoso ?? this.resetExitoso,
      correo: correo ?? this.correo,
    );
  }
}

class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  ForgotPasswordNotifier(this._forgotUseCase, this._resetUseCase)
    : super(const ForgotPasswordState());

  final ForgotPasswordUseCase _forgotUseCase;
  final ResetPasswordUseCase _resetUseCase;

  Future<void> enviarCodigo(String correo) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _forgotUseCase(correo);

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ),
      (_) =>
          state = state.copyWith(
            isLoading: false,
            codigoEnviado: true,
            correo: correo,
          ),
    );
  }

  Future<void> resetearContrasena({
    required String codigo,
    required String nuevaContrasena,
  }) async {
    if (state.correo == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _resetUseCase(
      ResetPasswordParams(
        correo: state.correo!,
        codigo: codigo,
        nuevaContrasena: nuevaContrasena,
      ),
    );

    result.fold(
      (failure) =>
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          ),
      (_) => state = state.copyWith(isLoading: false, resetExitoso: true),
    );
  }

  void reiniciar() {
    state = const ForgotPasswordState();
  }
}

final forgotPasswordProvider =
    StateNotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>(
      (ref) => sl<ForgotPasswordNotifier>(),
    );
