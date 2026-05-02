import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../domain/entities/usuario.dart';
import '../models/usuario_model.dart';

// Define el contrato para llamadas remotas de autenticacion.
abstract class AuthRemoteDatasource {
  Future<Map<String, dynamic>> registerUser({
    required String nombre,
    required String correo,
    required String contrasena,
    required String telefono,
  });

  Future<Map<String, dynamic>> loginUser({
    required String correo,
    required String contrasena,
  });

  Future<void> forgotPassword({required String correo});

  Future<void> resetPassword({
    required String correo,
    required String codigo,
    required String nuevaContrasena,
  });

  Future<Usuario> updateActiveMode({required ModoActivo modoActivo});
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  const AuthRemoteDatasourceImpl(this.dio, this.tokenStorage);

  final Dio dio;
  final TokenStorageService tokenStorage;

  @override
  Future<Map<String, dynamic>> registerUser({
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
      final data = payload['data'] as Map<String, dynamic>;
      return {
        'token': data['token'] as String,
        'usuario': UsuarioModel.fromJson(
          data['usuario'] as Map<String, dynamic>,
        ),
      };
    } on DioException catch (error) {
      final dynamic data = error.response?.data;
      final message =
          data is Map<String, dynamic> && data['error'] is String
              ? data['error'] as String
              : 'Error del servidor al registrar usuario';
      throw ServerException(message);
    }
  }

  @override
  Future<Map<String, dynamic>> loginUser({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final response = await dio.post(
        '/api/auth/login',
        data: {'correo': correo, 'contrasena': contrasena},
      );

      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>;
      return {
        'token': data['token'] as String,
        'usuario': UsuarioModel.fromJson(
          data['usuario'] as Map<String, dynamic>,
        ),
      };
    } on DioException catch (error) {
      final dynamic data = error.response?.data;
      final message =
          data is Map<String, dynamic> && data['error'] is String
              ? data['error'] as String
              : 'Correo o contraseña incorrectos';
      throw ServerException(message);
    }
  }

  @override
  Future<void> forgotPassword({required String correo}) async {
    try {
      await dio.post('/api/auth/forgot-password', data: {'correo': correo});
    } on DioException catch (error) {
      final dynamic data = error.response?.data;
      final message =
          data is Map<String, dynamic> && data['error'] is String
              ? data['error'] as String
              : 'Error al enviar el correo';
      throw ServerException(message);
    }
  }

  @override
  Future<void> resetPassword({
    required String correo,
    required String codigo,
    required String nuevaContrasena,
  }) async {
    try {
      await dio.post(
        '/api/auth/reset-password',
        data: {
          'correo': correo,
          'codigo': codigo,
          'nuevaContrasena': nuevaContrasena,
        },
      );
    } on DioException catch (error) {
      final dynamic data = error.response?.data;
      final message =
          data is Map<String, dynamic> && data['error'] is String
              ? data['error'] as String
              : 'Error al restablecer la contrasena';
      throw ServerException(message);
    }
  }

  @override
  Future<Usuario> updateActiveMode({required ModoActivo modoActivo}) async {
    try {
      final token = await tokenStorage.getToken();
      final response = await dio.patch(
        '/api/auth/mode',
        data: {'modoActivo': UsuarioModel.modoActivoToString(modoActivo)},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>;
      return UsuarioModel.fromJson(data['usuario'] as Map<String, dynamic>);
    } on DioException catch (error) {
      final dynamic data = error.response?.data;
      final message =
          data is Map<String, dynamic> && data['error'] is String
              ? data['error'] as String
              : 'No se pudo actualizar el modo activo';
      throw ServerException(message);
    }
  }
}
