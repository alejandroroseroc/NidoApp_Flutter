import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/usuario_model.dart';

// Define el contrato para llamadas remotas de autenticacion.
abstract class AuthRemoteDatasource {
  Future<UsuarioModel> registerUser({
    required String nombre,
    required String correo,
    required String contrasena,
    required String telefono,
  });
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  const AuthRemoteDatasourceImpl(this.dio);

  final Dio dio;

  @override
  Future<UsuarioModel> registerUser({
    required String nombre,
    required String correo,
    required String contrasena,
    required String telefono,
  }) async {
    try {
      final response = await dio.post(
        '/api/auth/register',
        data: {
          'nombre': nombre,
          'correo': correo,
          'contrasena': contrasena,
          'telefono': telefono,
        },
      );

      if (response.statusCode != 201) {
        throw const ServerException('No se pudo registrar el usuario');
      }

      final payload = response.data as Map<String, dynamic>;
      final userJson = payload['data'] as Map<String, dynamic>;
      return UsuarioModel.fromJson(userJson);
    } on DioException catch (error) {
      final dynamic data = error.response?.data;
      final message =
          data is Map<String, dynamic> && data['error'] is String
              ? data['error'] as String
              : 'Error del servidor al registrar usuario';
      throw ServerException(message);
    }
  }
}
