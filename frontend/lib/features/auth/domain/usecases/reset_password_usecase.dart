import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  const ResetPasswordUseCase(this.repository);

  final AuthRepository repository;

  Future<Either<Failure, void>> call(ResetPasswordParams params) {
    return repository.resetPassword(
      correo: params.correo,
      codigo: params.codigo,
      nuevaContrasena: params.nuevaContrasena,
    );
  }
}

class ResetPasswordParams extends Equatable {
  const ResetPasswordParams({
    required this.correo,
    required this.codigo,
    required this.nuevaContrasena,
  });

  final String correo;
  final String codigo;
  final String nuevaContrasena;

  @override
  List<Object?> get props => [correo, codigo, nuevaContrasena];
}
