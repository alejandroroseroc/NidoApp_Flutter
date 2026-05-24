import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/reserva.dart';
import '../../domain/entities/reserva_invitado.dart';
import '../../domain/repositories/reserva_repository.dart';
import '../datasources/reserva_remote_datasource.dart';

class ReservaRepositoryImpl implements ReservaRepository {
  const ReservaRepositoryImpl(this.remoteDatasource);

  final ReservaRemoteDatasource remoteDatasource;

  @override
  Future<Either<Failure, List<ReservaInvitado>>> getGuestReservations() async {
    try {
      final result = await remoteDatasource.getGuestReservations();
      return Right(result);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(ServerFailure('Ocurrio un error inesperado'));
    }
  }

  @override
  Future<Either<Failure, List<Reserva>>> getHostReservations() async {
    try {
      final result = await remoteDatasource.getHostReservations();
      return Right(result);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(ServerFailure('Ocurrio un error inesperado'));
    }
  }

  @override
  Future<Either<Failure, Reserva>> updateReservationStatus(
    String reservationId,
    String newStatus,
  ) async {
    try {
      final result = await remoteDatasource.updateReservationStatus(
        reservationId,
        newStatus,
      );
      return Right(result);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(ServerFailure('Ocurrio un error inesperado'));
    }
  }
}
