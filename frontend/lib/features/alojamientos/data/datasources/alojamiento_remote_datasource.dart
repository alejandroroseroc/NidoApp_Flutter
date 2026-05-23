import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../domain/entities/alojamiento.dart';
import '../models/alojamiento_model.dart';

abstract class AlojamientoRemoteDatasource {
  Future<Alojamiento> create({
    required Map<String, dynamic> data,
    List<XFile> fotografias,
  });

  Future<List<Alojamiento>> getMisPublicaciones();

  Future<List<Alojamiento>> getAlojamientosDisponibles({
    Map<String, dynamic> queryParams = const {},
  });

  Future<Alojamiento> getById(String id);

  Future<Alojamiento> update({
    required String id,
    required Map<String, dynamic> data,
    List<XFile> nuevasFotografias,
  });

  Future<Alojamiento> toggleEstado(String id);

  Future<void> delete(String id);
}

class AlojamientoRemoteDatasourceImpl implements AlojamientoRemoteDatasource {
  const AlojamientoRemoteDatasourceImpl(this.dio, this.tokenStorage);

  final Dio dio;
  final TokenStorageService tokenStorage;

  Future<Options> _authOptions() async {
    final token = await tokenStorage.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  String _extractError(DioException error, String fallback) {
    final dynamic data = error.response?.data;
    if (data is Map<String, dynamic> && data['error'] is String) {
      return data['error'] as String;
    }
    return fallback;
  }

  Future<FormData> _buildFormData(
    Map<String, dynamic> data,
    List<XFile> fotografias,
  ) async {
    final formMap = <String, dynamic>{};
    for (final entry in data.entries) {
      if (entry.value is List) {
        formMap[entry.key] = jsonEncode(entry.value);
      } else {
        formMap[entry.key] = entry.value?.toString();
      }
    }

    if (fotografias.isNotEmpty) {
      final files = <MultipartFile>[];
      for (final image in fotografias) {
        final bytes = await image.readAsBytes();
        files.add(MultipartFile.fromBytes(bytes, filename: image.name));
      }
      formMap['fotografias'] = files;
    }

    return FormData.fromMap(formMap);
  }

  @override
  Future<Alojamiento> create({
    required Map<String, dynamic> data,
    List<XFile> fotografias = const [],
  }) async {
    try {
      final Response<dynamic> response;
      if (fotografias.isEmpty) {
        response = await dio.post(
          '/api/alojamientos',
          data: data,
          options: await _authOptions(),
        );
      } else {
        response = await dio.post(
          '/api/alojamientos',
          data: await _buildFormData(data, fotografias),
          options: await _authOptions(),
        );
      }

      final payload = response.data as Map<String, dynamic>;
      final responseData = payload['data'] as Map<String, dynamic>;
      return AlojamientoModel.fromJson(
        responseData['alojamiento'] as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw ServerException(
        _extractError(error, 'No se pudo guardar la publicacion'),
      );
    }
  }

  @override
  Future<List<Alojamiento>> getMisPublicaciones() async {
    try {
      final response = await dio.get(
        '/api/alojamientos/mis-publicaciones',
        options: await _authOptions(),
      );
      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>;
      final list = data['alojamientos'] as List<dynamic>;
      return list
          .map(
            (item) => AlojamientoModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (error) {
      throw ServerException(
        _extractError(error, 'No se pudieron cargar tus publicaciones'),
      );
    }
  }

  @override
  Future<List<Alojamiento>> getAlojamientosDisponibles({
    Map<String, dynamic> queryParams = const {},
  }) async {
    try {
      final response = await dio.get(
        '/api/alojamientos',
        queryParameters: queryParams.isEmpty ? null : queryParams,
        options: await _authOptions(),
      );
      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>;
      final list = data['alojamientos'] as List<dynamic>;
      return list
          .map(
            (item) => AlojamientoModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (error) {
      throw ServerException(
        _extractError(error, 'No se pudieron cargar los alojamientos'),
      );
    }
  }

  @override
  Future<Alojamiento> getById(String id) async {
    try {
      final response = await dio.get(
        '/api/alojamientos/$id',
        options: await _authOptions(),
      );
      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>;
      return AlojamientoModel.fromJson(
        data['alojamiento'] as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw ServerException(
        _extractError(error, 'No se pudo cargar la publicacion'),
      );
    }
  }

  @override
  Future<Alojamiento> update({
    required String id,
    required Map<String, dynamic> data,
    List<XFile> nuevasFotografias = const [],
  }) async {
    try {
      final Response<dynamic> response;
      if (nuevasFotografias.isEmpty) {
        response = await dio.put(
          '/api/alojamientos/$id',
          data: data,
          options: await _authOptions(),
        );
      } else {
        response = await dio.put(
          '/api/alojamientos/$id',
          data: await _buildFormData(data, nuevasFotografias),
          options: await _authOptions(),
        );
      }

      final payload = response.data as Map<String, dynamic>;
      final responseData = payload['data'] as Map<String, dynamic>;
      return AlojamientoModel.fromJson(
        responseData['alojamiento'] as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw ServerException(
        _extractError(error, 'No se pudo guardar la publicacion'),
      );
    }
  }

  @override
  Future<Alojamiento> toggleEstado(String id) async {
    try {
      final response = await dio.patch(
        '/api/alojamientos/$id/estado',
        options: await _authOptions(),
      );
      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>;
      return AlojamientoModel.fromJson(
        data['alojamiento'] as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw ServerException(
        _extractError(error, 'No se pudo cambiar el estado'),
      );
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await dio.delete('/api/alojamientos/$id', options: await _authOptions());
    } on DioException catch (error) {
      throw ServerException(
        _extractError(error, 'No se pudo eliminar la publicacion'),
      );
    }
  }
}
