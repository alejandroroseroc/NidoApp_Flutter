import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/reserva_invitado.dart';
import '../../domain/usecases/get_guest_reservations_usecase.dart';

class MisReservasState {
  const MisReservasState({
    this.isLoading = false,
    this.reservas = const [],
    this.errorMessage,
    this.reservasConCambio = const [],
  });

  final bool isLoading;
  final List<ReservaInvitado> reservas;
  final String? errorMessage;
  final List<ReservaInvitado> reservasConCambio;

  MisReservasState copyWith({
    bool? isLoading,
    List<ReservaInvitado>? reservas,
    String? errorMessage,
    List<ReservaInvitado>? reservasConCambio,
    bool clearError = false,
    bool clearCambios = false,
  }) {
    return MisReservasState(
      isLoading: isLoading ?? this.isLoading,
      reservas: reservas ?? this.reservas,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      reservasConCambio:
          clearCambios
              ? const []
              : (reservasConCambio ?? this.reservasConCambio),
    );
  }
}

class MisReservasNotifier extends StateNotifier<MisReservasState> {
  MisReservasNotifier(this._getGuestReservations)
      : super(const MisReservasState());

  final GetGuestReservationsUseCase _getGuestReservations;
  Timer? _timer;

  Future<void> loadReservas() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getGuestReservations();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (reservas) => state = state.copyWith(
        isLoading: false,
        reservas: reservas,
      ),
    );
  }

  void startPolling() {
    stopPolling();
    loadReservas();
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _pollReservas(),
    );
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  void clearCambios() {
    state = state.copyWith(clearCambios: true);
  }

  Future<void> _pollReservas() async {
    final previous = state.reservas;
    final result = await _getGuestReservations();

    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (nuevas) {
        final cambios = <ReservaInvitado>[];
        for (final nueva in nuevas) {
          ReservaInvitado? anterior;
          for (final r in previous) {
            if (r.id == nueva.id) {
              anterior = r;
              break;
            }
          }
          if (anterior != null &&
              anterior.estado == EstadoReservaInvitado.pendiente &&
              (nueva.estado == EstadoReservaInvitado.aceptada ||
                  nueva.estado == EstadoReservaInvitado.rechazada)) {
            cambios.add(nueva);
          }
        }

        state = state.copyWith(
          reservas: nuevas,
          reservasConCambio: cambios.isNotEmpty ? cambios : state.reservasConCambio,
        );
      },
    );
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}

final misReservasProvider =
    StateNotifierProvider.autoDispose<MisReservasNotifier, MisReservasState>(
  (ref) => MisReservasNotifier(sl<GetGuestReservationsUseCase>()),
);
