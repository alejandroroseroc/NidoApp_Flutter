import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/token_storage_service.dart';

class SolicitudReservaState {
  const SolicitudReservaState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  SolicitudReservaState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SolicitudReservaState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SolicitudReservaNotifier extends StateNotifier<SolicitudReservaState> {
  SolicitudReservaNotifier(this._dio, this._tokenStorage)
      : super(const SolicitudReservaState());

  final Dio _dio;
  final TokenStorageService _tokenStorage;

  Future<void> enviarSolicitud({
    required String alojamientoId,
    required DateTime fechaIngreso,
    required int duracionDias,
  }) async {
    state = state.copyWith(
      isLoading: true,
      isSuccess: false,
      clearError: true,
    );

    try {
      final token = await _tokenStorage.getToken();
      await _dio.post(
        '/api/reservas',
        data: {
          'alojamientoId': alojamientoId,
          'fechaIngreso': fechaIngreso.toIso8601String(),
          'duracionDias': duracionDias,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      state = state.copyWith(isLoading: false, isSuccess: true);
    } on DioException catch (error) {
      final dynamic data = error.response?.data;
      final message = data is Map<String, dynamic> && data['error'] is String
          ? data['error'] as String
          : 'No se pudo enviar la solicitud de reserva';
      state = state.copyWith(isLoading: false, errorMessage: message);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrio un error inesperado',
      );
    }
  }

  void clearStatus() {
    state = const SolicitudReservaState();
  }
}

final solicitudReservaProvider =
    StateNotifierProvider<SolicitudReservaNotifier, SolicitudReservaState>(
  (ref) => SolicitudReservaNotifier(sl<Dio>(), sl<TokenStorageService>()),
);
