import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/alojamiento.dart';
import '../../domain/entities/filtros_alojamiento.dart';
import '../../domain/repositories/alojamiento_repository.dart';

class ExplorarState {
  const ExplorarState({
    this.disponibles = const [],
    this.filtros = const FiltrosAlojamiento(),
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Alojamiento> disponibles;
  final FiltrosAlojamiento filtros;
  final bool isLoading;
  final String? errorMessage;

  ExplorarState copyWith({
    List<Alojamiento>? disponibles,
    FiltrosAlojamiento? filtros,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ExplorarState(
      disponibles: disponibles ?? this.disponibles,
      filtros: filtros ?? this.filtros,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ExplorarNotifier extends StateNotifier<ExplorarState> {
  ExplorarNotifier(this._repository) : super(const ExplorarState());

  final AlojamientoRepository _repository;

  String _message(Object error, String fallback) {
    if (error is ServerException) return error.message;
    return fallback;
  }

  Future<void> loadDisponibles() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final disponibles = await _repository.getAlojamientosDisponibles(
        filtros: state.filtros,
      );
      state = state.copyWith(disponibles: disponibles, isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _message(error, 'No se pudieron cargar los alojamientos'),
      );
    }
  }

  /// Aplica nuevos filtros y recarga la lista desde el backend.
  Future<void> applyFiltros(FiltrosAlojamiento filtros) async {
    state = state.copyWith(filtros: filtros);
    await loadDisponibles();
  }

  /// Limpia todos los filtros y recarga.
  Future<void> clearFiltros() async {
    state = state.copyWith(filtros: const FiltrosAlojamiento());
    await loadDisponibles();
  }
}

final explorarProvider =
    StateNotifierProvider<ExplorarNotifier, ExplorarState>(
      (ref) => ExplorarNotifier(sl<AlojamientoRepository>()),
    );
