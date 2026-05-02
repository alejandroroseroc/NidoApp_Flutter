import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/usuario.dart';
import '../datasources/auth_remote_datasource.dart';

// Adapta errores de infraestructura al dominio.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this.remoteDatasource);

  final AuthRemoteDatasource remoteDatasource;

  @override
  Future<Either<Failure, Map<String, dynamic>>> register({
    required String nombre,
    required String correo,
    required String contrasena,
    required String telefono,
  }) async {
    try {
      final result = await remoteDatasource.registerUser(
        nombre: nombre,
        correo: correo,
        contrasena: contrasena,
        telefono: telefono,
      );
      return Right(result);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(ServerFailure('Ocurrio un error inesperado'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> login({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final result = await remoteDatasource.loginUser(
        correo: correo,
        contrasena: contrasena,
      );
      return Right(result);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(ServerFailure('Ocurrio un error inesperado'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String correo}) async {
    try {
      await remoteDatasource.forgotPassword(correo: correo);
      return const Right(null);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(ServerFailure('Ocurrio un error inesperado'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String correo,
    required String codigo,
    required String nuevaContrasena,
  }) async {
    try {
      await remoteDatasource.resetPassword(
        correo: correo,
        codigo: codigo,
        nuevaContrasena: nuevaContrasena,
      );
      return const Right(null);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(ServerFailure('Ocurrio un error inesperado'));
    }
  }

  @override
  Future<Either<Failure, Usuario>> updateActiveMode({
    required ModoActivo modoActivo,
  }) async {
    try {
      final usuario = await remoteDatasource.updateActiveMode(
        modoActivo: modoActivo,
      );
      return Right(usuario);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(ServerFailure('Ocurrio un error inesperado'));
    }
  }
}
