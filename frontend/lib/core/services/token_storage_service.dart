import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Guarda y recupera el JWT de forma segura en el dispositivo.
class TokenStorageService {
  const TokenStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
