import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/reserva.dart';
import '../repositories/reserva_repository.dart';

// Obtiene las solicitudes de reserva de los alojamientos del anfitrion.
class GetHostReservationsUseCase {
  const GetHostReservationsUseCase(this.repository);

  final ReservaRepository repository;

  Future<Either<Failure, List<Reserva>>> call() {
    return repository.getHostReservations();
  }
}
