import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  const ForgotPasswordUseCase(this.repository);

  final AuthRepository repository;

  Future<Either<Failure, void>> call(String correo) {
    return repository.forgotPassword(correo: correo);
  }
}
