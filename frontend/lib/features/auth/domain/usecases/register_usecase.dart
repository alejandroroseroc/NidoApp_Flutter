import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/usuario.dart';
import '../repositories/auth_repository.dart';

// Ejecuta el registro de usuario en la capa de dominio.
class RegisterUseCase {
  const RegisterUseCase(this.repository);

  final AuthRepository repository;

  Future<Either<Failure, Usuario>> call(RegisterParams params) {
    return repository.register(
      nombre: params.nombre,
      correo: params.correo,
      contrasena: params.contrasena,
      telefono: params.telefono,
    );
  }
}

class RegisterParams extends Equatable {
  const RegisterParams({
    required this.nombre,
    required this.correo,
    required this.contrasena,
    required this.telefono,
  });

  final String nombre;
  final String correo;
  final String contrasena;
  final String telefono;

  @override
  List<Object?> get props => [nombre, correo, contrasena, telefono];
}
