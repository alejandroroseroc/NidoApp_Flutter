import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nido_app/core/di/injection_container.dart';
import 'package:nido_app/core/services/token_storage_service.dart';
import 'package:nido_app/features/resenas/data/models/resena_model.dart';

class ResenasState {
  const ResenasState({
    this.isLoading = false,
    this.isSaving = false,
    this.resumen = const ResenaResumen(promedio: 0, total: 0),
    this.resenas = const [],
    this.errorMessage,
    this.isSuccess = false,
  });

  final bool isLoading;
  final bool isSaving;
  final ResenaResumen resumen;
  final List<Resena> resenas;
  final String? errorMessage;
  final bool isSuccess;

  ResenasState copyWith({
    bool? isLoading,
    bool? isSaving,
    ResenaResumen? resumen,
    List<Resena>? resenas,
    String? errorMessage,
    bool? isSuccess,
    bool clearError = false,
  }) {
    return ResenasState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      resumen: resumen ?? this.resumen,
      resenas: resenas ?? this.resenas,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ResenasNotifier extends StateNotifier<ResenasState> {
  ResenasNotifier(this._dio, this._tokenStorage) : super(const ResenasState());

  final Dio _dio;
  final TokenStorageService _tokenStorage;

  Future<Options> _authOptions() async {
    final token = await _tokenStorage.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<void> load(String alojamientoId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await _dio.get(
        '/api/alojamientos/$alojamientoId/resenas',
        options: await _authOptions(),
      );
      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>;
      final resumenJson = data['resumen'] as Map<String, dynamic>;
      final list = data['resenas'] as List<dynamic>;
      state = state.copyWith(
        isLoading: false,
        resumen: ResenaResumen(
          promedio: (resumenJson['promedio'] as num? ?? 0).toDouble(),
          total: resumenJson['total'] as int? ?? 0,
        ),
        resenas: list
            .map((item) => ResenaModel.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudieron cargar las reseñas',
      );
    }
  }

  Future<void> create({
    required String alojamientoId,
    required int calificacion,
    required String comentario,
  }) async {
    state = state.copyWith(isSaving: true, isSuccess: false, clearError: true);
    try {
      await _dio.post(
        '/api/alojamientos/$alojamientoId/resenas',
        data: {
          'calificacion': calificacion,
          'comentario': comentario.trim(),
        },
        options: await _authOptions(),
      );
      state = state.copyWith(isSaving: false, isSuccess: true);
      await load(alojamientoId);
    } on DioException catch (error) {
      final dynamic data = error.response?.data;
      final message = data is Map<String, dynamic> && data['error'] is String
          ? data['error'] as String
          : 'No se pudo publicar la reseña';
      state = state.copyWith(isSaving: false, errorMessage: message);
    }
  }

  void clearStatus() {
    state = state.copyWith(isSuccess: false, clearError: true);
  }
}

final resenasProvider =
    StateNotifierProvider.autoDispose<ResenasNotifier, ResenasState>(
  (ref) => ResenasNotifier(sl<Dio>(), sl<TokenStorageService>()),
);
