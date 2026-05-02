import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/usuario.dart';
import '../repositories/auth_repository.dart';

class UpdateActiveModeUseCase {
  const UpdateActiveModeUseCase(this.repository);

  final AuthRepository repository;

  Future<Either<Failure, Usuario>> call(UpdateActiveModeParams params) {
    return repository.updateActiveMode(modoActivo: params.modoActivo);
  }
}

class UpdateActiveModeParams extends Equatable {
  const UpdateActiveModeParams({required this.modoActivo});

  final ModoActivo modoActivo;

  @override
  List<Object?> get props => [modoActivo];
}
