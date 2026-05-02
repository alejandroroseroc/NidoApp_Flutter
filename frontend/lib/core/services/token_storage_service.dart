import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/models/usuario_model.dart';
import '../../features/auth/domain/entities/usuario.dart';

// Guarda y recupera el JWT de forma segura en el dispositivo.
class TokenStorageService {
  const TokenStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';
  static const _usuarioKey = 'auth_usuario';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> saveSession({
    required String token,
    required Usuario usuario,
  }) async {
    await saveToken(token);
    await saveUsuario(usuario);
  }

  Future<void> saveUsuario(Usuario usuario) async {
    final model = UsuarioModel.fromEntity(usuario);
    await _storage.write(key: _usuarioKey, value: jsonEncode(model.toJson()));
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<Usuario?> getUsuario() async {
    final rawUsuario = await _storage.read(key: _usuarioKey);
    if (rawUsuario == null || rawUsuario.isEmpty) return null;

    final json = jsonDecode(rawUsuario) as Map<String, dynamic>;
    return UsuarioModel.fromJson(json);
  }

  Future<ModoActivo> getModoActivo() async {
    final usuario = await getUsuario();
    return usuario?.modoActivo ?? ModoActivo.invitado;
  }

  Future<void> updateModoActivo(ModoActivo modoActivo) async {
    final usuario = await getUsuario();
    if (usuario == null) return;

    await saveUsuario(
      UsuarioModel(
        id: usuario.id,
        nombre: usuario.nombre,
        correo: usuario.correo,
        telefono: usuario.telefono,
        fotoPerfil: usuario.fotoPerfil,
        descripcion: usuario.descripcion,
        modoActivo: modoActivo,
      ),
    );
  }

  Future<bool> hasToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _usuarioKey);
  }
}
