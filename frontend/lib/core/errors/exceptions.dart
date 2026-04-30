// Excepcion usada cuando la API responde con error.
class ServerException implements Exception {
  const ServerException(this.message);

  final String message;
}
