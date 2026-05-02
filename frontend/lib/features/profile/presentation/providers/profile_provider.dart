import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../../auth/data/models/usuario_model.dart';
import '../../../auth/domain/entities/usuario.dart';

class ProfileState {
  const ProfileState({
    this.usuario,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  final Usuario? usuario;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final String? successMessage;

  ProfileState copyWith({
    Usuario? usuario,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return ProfileState(
      usuario: usuario ?? this.usuario,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this._dio, this._tokenStorage) : super(const ProfileState());

  final Dio _dio;
  final TokenStorageService _tokenStorage;

  Future<Options> _authOptions() async {
    final token = await _tokenStorage.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, clearMessages: true);
    try {
      final localUser = await _tokenStorage.getUsuario();
      if (localUser != null) {
        state = state.copyWith(usuario: localUser);
      }

      final response = await _dio.get(
        '/api/users/me',
        options: await _authOptions(),
      );
      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>;
      final usuario = UsuarioModel.fromJson(
        data['usuario'] as Map<String, dynamic>,
      );
      await _tokenStorage.saveUsuario(usuario);
      state = state.copyWith(usuario: usuario, isLoading: false);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudo cargar el perfil',
      );
    }
  }

  Future<void> updateProfile({
    required String nombre,
    required String telefono,
    required String descripcion,
  }) async {
    state = state.copyWith(isSaving: true, clearMessages: true);
    try {
      final response = await _dio.put(
        '/api/users/me',
        data: {
          'nombre': nombre,
          'telefono': telefono,
          'descripcion': descripcion,
        },
        options: await _authOptions(),
      );
      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>;
      final usuario = UsuarioModel.fromJson(
        data['usuario'] as Map<String, dynamic>,
      );
      await _tokenStorage.saveUsuario(usuario);
      state = state.copyWith(
        usuario: usuario,
        isSaving: false,
        successMessage: 'Perfil actualizado',
      );
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'No se pudo actualizar el perfil',
      );
    }
  }

  Future<void> uploadPhoto(XFile image) async {
    final length = await image.length();
    if (length > 2 * 1024 * 1024) {
      state = state.copyWith(errorMessage: 'La imagen debe pesar maximo 2 MB');
      return;
    }

    final extension = image.name.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
      state = state.copyWith(errorMessage: 'Usa una imagen JPG, PNG o WEBP');
      return;
    }

    state = state.copyWith(isSaving: true, clearMessages: true);
    try {
      final bytes = await image.readAsBytes();
      final formData = FormData.fromMap({
        'fotoPerfil': MultipartFile.fromBytes(bytes, filename: image.name),
      });
      final response = await _dio.post(
        '/api/users/me/photo',
        data: formData,
        options: await _authOptions(),
      );
      final payload = response.data as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>;
      final usuario = UsuarioModel.fromJson(
        data['usuario'] as Map<String, dynamic>,
      );
      await _tokenStorage.saveUsuario(usuario);
      state = state.copyWith(
        usuario: usuario,
        isSaving: false,
        successMessage: 'Foto actualizada',
      );
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'No se pudo subir la foto',
      );
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(sl<Dio>(), sl<TokenStorageService>()),
);
