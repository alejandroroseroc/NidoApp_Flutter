import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

// Adapta errores de infraestructura al dominio.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this.remoteDatasource);

  final AuthRemoteDatasource remoteDatasource;

  @override
  Future<Either<Failure, Usuario>> register({
    required String nombre,
    required String correo,
    required String contrasena,
    required String telefono,
  }) async {
    try {
      final user = await remoteDatasource.registerUser(
        nombre: nombre,
        correo: correo,
        contrasena: contrasena,
        telefono: telefono,
      );
      return Right(user);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(ServerFailure('Ocurrio un error inesperado'));
    }
  }
}
