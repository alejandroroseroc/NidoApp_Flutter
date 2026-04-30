import 'package:equatable/equatable.dart';

// Modela errores de dominio convertidos desde excepciones.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
