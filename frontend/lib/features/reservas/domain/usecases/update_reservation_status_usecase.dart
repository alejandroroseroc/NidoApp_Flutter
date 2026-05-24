import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/reserva.dart';
import '../repositories/reserva_repository.dart';

// Actualiza el estado de una solicitud pendiente (aceptar/rechazar).
class UpdateReservationStatusUseCase {
  const UpdateReservationStatusUseCase(this.repository);

  final ReservaRepository repository;

  Future<Either<Failure, Reserva>> call(UpdateReservationStatusParams params) {
    return repository.updateReservationStatus(
      params.reservationId,
      params.newStatus,
    );
  }
}

class UpdateReservationStatusParams extends Equatable {
  const UpdateReservationStatusParams({
    required this.reservationId,
    required this.newStatus,
  });

  final String reservationId;
  final String newStatus;

  @override
  List<Object?> get props => [reservationId, newStatus];
}
