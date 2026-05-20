import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/alojamiento.dart';
import '../../domain/repositories/alojamiento_repository.dart';

class AlojamientoState {
  const AlojamientoState({
    this.publicaciones = const [],
    this.selected,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<Alojamiento> publicaciones;
  final Alojamiento? selected;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  AlojamientoState copyWith({
    List<Alojamiento>? publicaciones,
    Alojamiento? selected,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return AlojamientoState(
      publicaciones: publicaciones ?? this.publicaciones,
      selected: selected ?? this.selected,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}

class AlojamientoNotifier extends StateNotifier<AlojamientoState> {
  AlojamientoNotifier(this._repository) : super(const AlojamientoState());

  final AlojamientoRepository _repository;

  String _message(Object error, String fallback) {
    if (error is ServerException) return error.message;
    return fallback;
  }

  Future<void> loadMisPublicaciones() async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final publicaciones = await _repository.getMisPublicaciones();
      state = state.copyWith(publicaciones: publicaciones, isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _message(
          error,
          'No se pudieron cargar tus publicaciones',
        ),
      );
    }
  }

  Future<void> loadById(String id) async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final alojamiento = await _repository.getById(id);
      state = state.copyWith(selected: alojamiento, isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _message(error, 'No se pudo cargar la publicacion'),
      );
    }
  }

  Future<bool> create({
    required String titulo,
    required String descripcion,
    required TipoEspacio tipoEspacio,
    required TipoPrivacidad tipoPrivacidad,
    required String tipoAcceso,
    required double precioMensual,
    required String ubicacion,
    String? reglas,
    List<String> servicios = const [],
    List<XFile> fotografias = const [],
  }) async {
    state = state.copyWith(isSaving: true, clearMessages: true);
    try {
      await _repository.createAlojamiento(
        titulo: titulo,
        descripcion: descripcion,
        tipoEspacio: tipoEspacio,
        tipoPrivacidad: tipoPrivacidad,
        tipoAcceso: tipoAcceso,
        precioMensual: precioMensual,
        ubicacion: ubicacion,
        reglas: reglas,
        servicios: servicios,
        fotografias: fotografias,
      );
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Publicacion creada correctamente',
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: _message(error, 'No se pudo guardar la publicacion'),
      );
      return false;
    }
  }

  Future<bool> update({
    required String id,
    required String titulo,
    required String descripcion,
    required TipoEspacio tipoEspacio,
    required TipoPrivacidad tipoPrivacidad,
    required String tipoAcceso,
    required double precioMensual,
    required String ubicacion,
    String? reglas,
    List<String> servicios = const [],
    List<String> fotografiasExistentes = const [],
    List<XFile> nuevasFotografias = const [],
  }) async {
    state = state.copyWith(isSaving: true, clearMessages: true);
    try {
      await _repository.updateAlojamiento(
        id: id,
        titulo: titulo,
        descripcion: descripcion,
        tipoEspacio: tipoEspacio,
        tipoPrivacidad: tipoPrivacidad,
        tipoAcceso: tipoAcceso,
        precioMensual: precioMensual,
        ubicacion: ubicacion,
        reglas: reglas,
        servicios: servicios,
        fotografiasExistentes: fotografiasExistentes,
        nuevasFotografias: nuevasFotografias,
      );
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Publicacion actualizada correctamente',
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: _message(error, 'No se pudo guardar la publicacion'),
      );
      return false;
    }
  }

  Future<void> toggleEstado(String id) async {
    state = state.copyWith(clearMessages: true);
    try {
      final updated = await _repository.toggleEstado(id);
      final publicaciones =
          state.publicaciones
              .map((item) => item.id == id ? updated : item)
              .toList();
      state = state.copyWith(
        publicaciones: publicaciones,
        successMessage: 'Estado actualizado correctamente',
      );
    } catch (error) {
      state = state.copyWith(
        errorMessage: _message(error, 'No se pudo cambiar el estado'),
      );
    }
  }

  Future<void> delete(String id) async {
    state = state.copyWith(clearMessages: true);
    try {
      await _repository.deleteAlojamiento(id);
      final publicaciones =
          state.publicaciones.where((item) => item.id != id).toList();
      state = state.copyWith(
        publicaciones: publicaciones,
        successMessage: 'Publicacion eliminada correctamente',
      );
    } catch (error) {
      state = state.copyWith(
        errorMessage: _message(error, 'No se pudo eliminar la publicacion'),
      );
    }
  }
}

final alojamientoProvider =
    StateNotifierProvider<AlojamientoNotifier, AlojamientoState>(
      (ref) => AlojamientoNotifier(sl<AlojamientoRepository>()),
    );
