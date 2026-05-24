import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/reserva.dart';
import '../../domain/usecases/get_host_reservations_usecase.dart';
import '../../domain/usecases/update_reservation_status_usecase.dart';

class HostReservationsState {
  const HostReservationsState({
    this.isLoading = false,
    this.reservations = const [],
    this.errorMessage,
    this.processingId,
  });

  final bool isLoading;
  final List<Reserva> reservations;
  final String? errorMessage;
  final String? processingId;

  HostReservationsState copyWith({
    bool? isLoading,
    List<Reserva>? reservations,
    String? errorMessage,
    String? processingId,
    bool clearError = false,
    bool clearProcessing = false,
  }) {
    return HostReservationsState(
      isLoading: isLoading ?? this.isLoading,
      reservations: reservations ?? this.reservations,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      processingId:
          clearProcessing ? null : (processingId ?? this.processingId),
    );
  }
}

class HostReservationsNotifier extends StateNotifier<HostReservationsState> {
  HostReservationsNotifier(this._getHostReservations, this._updateStatus)
      : super(const HostReservationsState());

  final GetHostReservationsUseCase _getHostReservations;
  final UpdateReservationStatusUseCase _updateStatus;

  Future<void> loadReservations() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getHostReservations();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (reservations) => state = state.copyWith(
        isLoading: false,
        reservations: reservations,
      ),
    );
  }

  Future<void> updateStatus(String reservationId, String newStatus) async {
    state = state.copyWith(processingId: reservationId, clearError: true);

    final result = await _updateStatus(
      UpdateReservationStatusParams(
        reservationId: reservationId,
        newStatus: newStatus,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        clearProcessing: true,
        errorMessage: failure.message,
      ),
      (updated) {
        final list = state.reservations
            .map((r) => r.id == updated.id ? updated : r)
            .toList();
        state = state.copyWith(
          clearProcessing: true,
          reservations: list,
        );
      },
    );
  }
}

final hostReservationsProvider =
    StateNotifierProvider<HostReservationsNotifier, HostReservationsState>(
  (ref) => HostReservationsNotifier(
    sl<GetHostReservationsUseCase>(),
    sl<UpdateReservationStatusUseCase>(),
  ),
);
