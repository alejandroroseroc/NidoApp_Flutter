import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/usuario.dart';

// Contrato del repositorio de autenticacion.
abstract class AuthRepository {
  Future<Either<Failure, Usuario>> register({
    required String nombre,
    required String correo,
    required String contrasena,
    required String telefono,
  });
}
