import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/token_storage_service.dart';
import '../models/reserva_invitado_model.dart';
import '../models/reserva_model.dart';

abstract class ReservaRemoteDatasource {
  Future<List<ReservaInvitadoModel>> getGuestReservations();

  Future<List<ReservaModel>> getHostReservations();

  Future<ReservaModel> updateReservationStatus(String id, String status);
}

class ReservaRemoteDatasourceImpl implements ReservaRemoteDatasource {
  const ReservaRemoteDatasourceImpl(this.dio, this.tokenStorage);

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

  @override
  Future<List<ReservaInvitadoModel>> getGuestReservations() async {
    try {
      final response = await dio.get(
        '/api/reservas/invitado',
        options: await _authOptions(),
      );
      final data = response.data as Map<String, dynamic>;
      final reservas = data['data']?['reservas'] as List<dynamic>? ?? [];
      return reservas
          .map(
            (item) =>
                ReservaInvitadoModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (error) {
      throw ServerException(
        _extractError(error, 'No se pudieron cargar tus reservas'),
      );
    }
  }

  @override
  Future<List<ReservaModel>> getHostReservations() async {
    try {
      final response = await dio.get(
        '/api/reservas/host',
        options: await _authOptions(),
      );
      final data = response.data as Map<String, dynamic>;
      final reservas = data['data']?['reservas'] as List<dynamic>? ?? [];
      return reservas
          .map((item) => ReservaModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw ServerException(
        _extractError(error, 'No se pudieron cargar las solicitudes'),
      );
    }
  }

  @override
  Future<ReservaModel> updateReservationStatus(String id, String status) async {
    try {
      final response = await dio.patch(
        '/api/reservas/$id/status',
        data: {'estado': status},
        options: await _authOptions(),
      );
      final data = response.data as Map<String, dynamic>;
      final reserva = data['data']?['reserva'] as Map<String, dynamic>?;
      if (reserva == null) {
        throw const ServerException('Respuesta invalida del servidor');
      }
      return ReservaModel.fromJson(reserva);
    } on DioException catch (error) {
      throw ServerException(
        _extractError(error, 'No se pudo actualizar la reserva'),
      );
    }
  }
}
