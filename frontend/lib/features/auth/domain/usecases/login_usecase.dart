import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

// Ejecuta el inicio de sesion en la capa de dominio.
class LoginUseCase {
  const LoginUseCase(this.repository);

  final AuthRepository repository;

  Future<Either<Failure, Map<String, dynamic>>> call(LoginParams params) {
    return repository.login(
      correo: params.correo,
      contrasena: params.contrasena,
    );
  }
}

class LoginParams extends Equatable {
  const LoginParams({required this.correo, required this.contrasena});

  final String correo;
  final String contrasena;

  @override
  List<Object?> get props => [correo, contrasena];
}
