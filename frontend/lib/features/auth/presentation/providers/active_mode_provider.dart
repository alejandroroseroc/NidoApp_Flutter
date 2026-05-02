import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/usecases/update_active_mode_usecase.dart';

class ActiveModeState {
  const ActiveModeState({
    this.modoActivo = ModoActivo.invitado,
    this.isLoading = false,
    this.errorMessage,
  });

  final ModoActivo modoActivo;
  final bool isLoading;
  final String? errorMessage;

  ActiveModeState copyWith({
    ModoActivo? modoActivo,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ActiveModeState(
      modoActivo: modoActivo ?? this.modoActivo,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ActiveModeNotifier extends StateNotifier<ActiveModeState> {
  ActiveModeNotifier(this._updateActiveModeUseCase, this._tokenStorage)
    : super(const ActiveModeState());

  final UpdateActiveModeUseCase _updateActiveModeUseCase;
  final TokenStorageService _tokenStorage;

  Future<void> loadFromSession() async {
    final modoActivo = await _tokenStorage.getModoActivo();
    state = state.copyWith(modoActivo: modoActivo, clearError: true);
  }

  Future<void> changeMode(ModoActivo modoActivo) async {
    if (modoActivo == state.modoActivo || state.isLoading) return;

    final previousMode = state.modoActivo;
    state = state.copyWith(
      modoActivo: modoActivo,
      isLoading: true,
      clearError: true,
    );

    final result = await _updateActiveModeUseCase(
      UpdateActiveModeParams(modoActivo: modoActivo),
    );

    await result.fold(
      (failure) async {
        state = state.copyWith(
          modoActivo: previousMode,
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (usuario) async {
        await _tokenStorage.saveUsuario(usuario);
        state = state.copyWith(
          modoActivo: usuario.modoActivo,
          isLoading: false,
          clearError: true,
        );
      },
    );
  }
}

final activeModeProvider =
    StateNotifierProvider<ActiveModeNotifier, ActiveModeState>(
      (ref) => sl<ActiveModeNotifier>(),
    );
