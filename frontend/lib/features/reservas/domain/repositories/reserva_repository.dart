import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/reserva.dart';
import '../entities/reserva_invitado.dart';

abstract class ReservaRepository {
  Future<Either<Failure, List<ReservaInvitado>>> getGuestReservations();

  Future<Either<Failure, List<Reserva>>> getHostReservations();

  Future<Either<Failure, Reserva>> updateReservationStatus(
    String reservationId,
    String newStatus,
  );
}
