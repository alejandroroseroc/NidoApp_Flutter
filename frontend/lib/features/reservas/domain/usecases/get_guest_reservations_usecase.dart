import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/reserva_invitado.dart';
import '../repositories/reserva_repository.dart';

// Obtiene las reservas del invitado autenticado.
class GetGuestReservationsUseCase {
  const GetGuestReservationsUseCase(this.repository);

  final ReservaRepository repository;

  Future<Either<Failure, List<ReservaInvitado>>> call() {
    return repository.getGuestReservations();
  }
}
