import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

// Contrato del repositorio de autenticacion.
abstract class AuthRepository {
  Future<Either<Failure, Map<String, dynamic>>> register({
    required String nombre,
    required String correo,
    required String contrasena,
    required String telefono,
  });

  Future<Either<Failure, Map<String, dynamic>>> login({
    required String correo,
    required String contrasena,
  });

  Future<Either<Failure, void>> forgotPassword({required String correo});

  Future<Either<Failure, void>> resetPassword({
    required String correo,
    required String codigo,
    required String nuevaContrasena,
  });
}
